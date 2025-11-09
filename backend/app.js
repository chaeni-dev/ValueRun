require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const mysql = require('mysql2/promise');


const app = express();
app.use(cors());
app.use(bodyParser.json());

// ✅ DB 연결 풀
const pool = mysql.createPool({
  host: '127.0.0.1',   // localhost 대체 (Mac 환경에서 안전)
  user: 'vr_user',
  password: 'vr_pass',
  database: 'valuerun',
  waitForConnections: true
});

// ✅ 서버 상태 확인용
app.get('/', (req, res) => res.send('ValueRun API OK'));

// -----------------------------------------------------------------------------
// 🏃 러닝 API
// -----------------------------------------------------------------------------

// ▶ 러닝 시작
app.post('/api/runs/start', async (req, res) => {
  const { userId, startedAt } = req.body;
  const conn = await pool.getConnection();
  try {
    // 🕒 MySQL이 이해 가능한 형식으로 변환
    const formattedStart = new Date(startedAt)
      .toISOString()
      .slice(0, 19)
      .replace('T', ' ');

    const [r] = await conn.execute(
      'INSERT INTO runs (user_id, started_at) VALUES (?, ?)',
      [userId, formattedStart]
    );
    res.json({ runId: r.insertId });
  } catch (e) {
    console.error('❌ /api/runs/start 에러:', e.message);
    res.status(500).json({ error: e.message });
  } finally {
    conn.release();
  }
});

// ▶ 러닝 종료 (총 정산 + 일자 집계 + 지갑 적립)
app.post('/api/runs/:runId/finish', async (req, res) => {
  const runId = req.params.runId;
  const { finishedAt, totalDistanceKm, totalSeconds, calories = 0 } = req.body;
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    // 🕒 종료 시간 변환
    const formattedFinish = new Date(finishedAt)
      .toISOString()
      .slice(0, 19)
      .replace('T', ' ');

    const totalM = Math.round(Number(totalDistanceKm) * 1000);

    // 🔹 러닝 저장
    await conn.execute(
      `UPDATE runs 
       SET finished_at=?, total_distance_m=?, total_seconds=?, 
           avg_pace_sec_per_km=?, calories=?, status='finished'
       WHERE id=?`,
      [
        formattedFinish,
        totalM,
        totalSeconds,
        totalDistanceKm > 0
          ? Math.round(totalSeconds / totalDistanceKm)
          : 0,
        calories,
        runId,
      ]
    );

    // 🔹 user_id, started_at 조회
    const [[run]] = await conn.query(
      'SELECT user_id, started_at FROM runs WHERE id=?',
      [runId]
    );
    const day = formattedFinish.slice(0, 10); // YYYY-MM-DD

    // 🔹 일자 합산
    await conn.execute(
      `INSERT IGNORE INTO daily_stats (user_id, ymd, total_distance_m, total_seconds)
       VALUES (?, ?, 0, 0)`,
      [run.user_id, day]
    );
    await conn.execute(
      `UPDATE daily_stats 
       SET total_distance_m = total_distance_m + ?, 
           total_seconds = total_seconds + ? 
       WHERE user_id=? AND ymd=?`,
      [totalM, totalSeconds, run.user_id, day]
    );

    // 🔹 지갑 적립
    const creditKm = Number(totalDistanceKm.toFixed(2));
    await conn.execute(
      'INSERT IGNORE INTO donation_wallet (user_id, km_balance) VALUES (?, 0)',
      [run.user_id]
    );
    await conn.execute(
      'UPDATE donation_wallet SET km_balance = km_balance + ? WHERE user_id=?',
      [creditKm, run.user_id]
    );
    await conn.execute(
      `INSERT INTO donation_ledger (user_id, type, amount_km, ref_run_id, memo) 
       VALUES (?, 'credit', ?, ?, 'Run finished')`,
      [run.user_id, creditKm, runId]
    );

    const [[wallet]] = await conn.query(
      'SELECT km_balance FROM donation_wallet WHERE user_id=?',
      [run.user_id]
    );

    await conn.commit();
    res.json({
      total_distance_km: Number(totalDistanceKm.toFixed(2)),
      wallet_km_balance: Number(wallet.km_balance),
    });
  } catch (e) {
    await conn.rollback();
    console.error('❌ /api/runs/:runId/finish 에러:', e.message);
    res.status(500).json({ error: e.message });
  } finally {
    conn.release();
  }
});

// -----------------------------------------------------------------------------
// 📊 리포트 API
// -----------------------------------------------------------------------------

// ▶ 주간 리포트
app.get('/api/report/weekly', async (req, res) => {
  const userId = req.query.userId;
  const conn = await pool.getConnection();
  try {
    const [rows] = await conn.query(
      `
      SELECT DAYOFWEEK(ymd) AS dow, SUM(total_distance_m)/1000 AS km
      FROM daily_stats
      WHERE user_id=? 
        AND YEARWEEK(ymd, 1) = YEARWEEK(CURDATE(), 1)
      GROUP BY dow
      ORDER BY dow
      `,
      [userId]
    );

    const dailyDistances = Array(7).fill(0);
    rows.forEach((r) => {
      // MySQL: 1=일, 2=월 ... -> 월~일(0~6)로 변환
      const idx = (r.dow + 5) % 7;
      dailyDistances[idx] = Number(parseFloat(r.km || 0).toFixed(2));
    });

    const total = dailyDistances.reduce((a, b) => a + b, 0);
    const [[{ runs }]] = await conn.query(
      'SELECT COUNT(*) AS runs FROM runs WHERE user_id=? AND YEARWEEK(started_at,1)=YEARWEEK(CURDATE(),1)',
      [userId]
    );

    res.json({
      weekLabel: '이번 주',
      dailyDistances,
      totalDistance: Number(total.toFixed(2)),
      totalRuns: runs,
    });
  } catch (e) {
    console.error('❌ /api/report/weekly 에러:', e.message);
    res.status(500).json({ error: e.message });
  } finally {
    conn.release();
  }
});

// ▶ 월간 리포트
app.get('/api/report/monthly', async (req, res) => {
  const { userId, year, month } = req.query;
  const conn = await pool.getConnection();
  try {
    const [rows] = await conn.query(
      `
      SELECT DAY(ymd) AS day, SUM(total_distance_m)/1000 AS km
      FROM daily_stats
      WHERE user_id=? AND YEAR(ymd)=? AND MONTH(ymd)=?
      GROUP BY day
      ORDER BY day
      `,
      [userId, year, month]
    );

    const dailyRecords = rows.map((r) => ({
      day: r.day,
      distance: Number((r.km || 0).toFixed(2)),
    }));

    const total = dailyRecords.reduce((a, b) => a + b.distance, 0);
    const [[{ runs }]] = await conn.query(
      `
      SELECT COUNT(*) AS runs 
      FROM runs 
      WHERE user_id=? AND YEAR(started_at)=? AND MONTH(started_at)=?
      `,
      [userId, year, month]
    );

    res.json({
      monthLabel: `${year}년 ${month}월`,
      dailyRecords,
      totalDistance: Number(total.toFixed(2)),
      totalRuns: runs,
    });
  } catch (e) {
    console.error('❌ /api/report/monthly 에러:', e.message);
    res.status(500).json({ error: e.message });
  } finally {
    conn.release();
  }
});

// -----------------------------------------------------------------------------
// 💖 기부 & 전체 요약 API
// -----------------------------------------------------------------------------

// ▶ 전체 요약 (TotalPage)
// app.get('/api/summary/total', async (req, res) => {
//   const userId = Number(req.query.userId);
//   const conn = await pool.getConnection();

//   try {
//     // 전체 달린 거리
//     const [[{ total_run_km }]] = await conn.query(
//       `SELECT IFNULL(SUM(total_distance_m)/1000, 0) AS total_run_km 
//        FROM runs WHERE user_id=? AND status='finished'`,
//       [userId]
//     );

//     // 기부한 거리 (ledger의 debit 합)
//     const [[{ donated_km }]] = await conn.query(
//       `SELECT IFNULL(SUM(amount_km), 0) AS donated_km 
//        FROM donation_ledger WHERE user_id=? AND type='debit'`,
//       [userId]
//     );

//     // 기부 가능한 거리 (wallet)
//     const [[{ km_balance }]] = await conn.query(
//       `SELECT IFNULL(km_balance, 0) AS km_balance 
//        FROM donation_wallet WHERE user_id=?`,
//       [userId]
//     );

//     res.json({
//       total_distance_km: Number(total_run_km.toFixed(2)),
//       donated_km: Number(donated_km.toFixed(2)),
//       available_km: Number(km_balance.toFixed(2))
//     });
//   } catch (e) {
//     console.error('❌ /api/summary/total 에러:', e.message);
//     res.status(500).json({ error: e.message });
//   } finally {
//     conn.release();
//   }
// });
app.get('/api/summary/total', async (req, res) => {
  const userId = Number(req.query.userId);
  const conn = await pool.getConnection();

  try {
    const [[result1]] = await conn.query(
      `SELECT IFNULL(SUM(total_distance_m)/1000, 0) AS total_run_km 
       FROM runs WHERE user_id=? AND status='finished'`,
      [userId]
    );

    const [[result2]] = await conn.query(
      `SELECT IFNULL(SUM(amount_km), 0) AS donated_km 
       FROM donation_ledger WHERE user_id=? AND type='debit'`,
      [userId]
    );

    const [[result3]] = await conn.query(
      `SELECT IFNULL(km_balance, 0) AS km_balance 
       FROM donation_wallet WHERE user_id=?`,
      [userId]
    );

    // ✅ MySQL이 반환한 값이 문자열일 수 있으므로 Number()로 변환
    const total_run_km = Number(result1.total_run_km) || 0;
    const donated_km = Number(result2.donated_km) || 0;
    const km_balance = Number(result3.km_balance) || 0;

    res.json({
      total_distance_km: total_run_km.toFixed(2),
      donated_km: donated_km.toFixed(2),
      available_km: km_balance.toFixed(2),
    });
  } catch (e) {
    console.error('❌ /api/summary/total 에러:', e.message);
    res.status(500).json({ error: e.message });
  } finally {
    conn.release();
  }
});


// ▶ 최근 기부 내역
// app.get('/api/donation/recent', async (req, res) => {
//   const userId = req.query.userId;
//   const conn = await pool.getConnection();

//   try {
//     const [rows] = await conn.query(
//       `SELECT DATE(created_at) AS date, amount_km 
//        FROM donation_ledger 
//        WHERE user_id=? AND type='debit' 
//        ORDER BY created_at DESC 
//        LIMIT 5`,
//       [userId]
//     );

//     const history = rows.map(r => ({
//       date: r.date,
//       distance_km: Number(r.amount_km.toFixed(2))
//     }));

//     res.json({ history });
//   } catch (e) {
//     console.error('❌ /api/donation/recent 에러:', e.message);
//     res.status(500).json({ error: e.message });
//   } finally {
//     conn.release();
//   }
// });

app.get('/api/donation/recent', async (req, res) => {
  const userId = Number(req.query.userId);
  const conn = await pool.getConnection();

  try {
    const [rows] = await conn.query(
      `SELECT DATE(created_at) AS date, amount_km 
       FROM donation_ledger 
       WHERE user_id=? AND type='debit' 
       ORDER BY created_at DESC 
       LIMIT 5`,
      [userId]
    );

    const history = rows.map(r => ({
      date: r.date,
      distance_km: Number(r.amount_km).toFixed(2),  // ✅ Number() 추가
    }));

    res.json({ history });
  } catch (e) {
    console.error('❌ /api/donation/recent 에러:', e.message);
    res.status(500).json({ error: e.message });
  } finally {
    conn.release();
  }
});


// ▶ 캠페인 리스트 (더미 데이터)
app.get('/api/donation/campaigns', (req, res) => {
  const campaigns = [
    {
      id: 1,
      title: '굿네이버스 러닝 캠페인',
      organization: 'Good Neighbors',
      goalKm: 100,
      currentKm: 72.5,
      image: 'https://cdn.pixabay.com/photo/2016/03/09/15/10/runners-1246610_1280.jpg',
      description: '국내 취약계층 아동을 위한 러닝 기부 캠페인입니다.'
    },
    {
      id: 2,
      title: '하트세이브 마라톤',
      organization: 'HeartSave 재단',
      goalKm: 200,
      currentKm: 185.3,
      image: 'https://cdn.pixabay.com/photo/2019/05/06/16/32/run-4189082_1280.jpg',
      description: '심장질환 환자 지원을 위한 러닝 기부 캠페인입니다.'
    },
    {
      id: 3,
      title: '러닝 포 피스',
      organization: 'UN 평화재단',
      goalKm: 300,
      currentKm: 90.1,
      image: 'https://cdn.pixabay.com/photo/2016/09/05/09/32/people-1647321_1280.jpg',
      description: '전쟁 피해 지역 아동을 돕는 평화 러닝 캠페인입니다.'
    }
  ];

  res.json({ campaigns });
});

// ▶ 기부하기 (거리 차감 + ledger 기록)
app.post('/api/donation/donate', async (req, res) => {
  const { userId, campaignId, donateKm } = req.body;
  const conn = await pool.getConnection();

  try {
    await conn.beginTransaction();

    // 현재 지갑 확인
    const [[wallet]] = await conn.query(
      'SELECT km_balance FROM donation_wallet WHERE user_id=?',
      [userId]
    );

    if (!wallet || wallet.km_balance < donateKm) {
      throw new Error('기부 가능한 거리가 부족합니다.');
    }

    // 거리 차감
    await conn.execute(
      'UPDATE donation_wallet SET km_balance = km_balance - ? WHERE user_id=?',
      [donateKm, userId]
    );

    // ledger에 기록
    await conn.execute(
      `INSERT INTO donation_ledger (user_id, type, amount_km, ref_run_id, memo, campaign_id)
       VALUES (?, 'debit', ?, NULL, 'Campaign donation', ?)`,
      [userId, donateKm, campaignId]
    );

    await conn.commit();

    res.json({
      success: true,
      message: `✅ ${donateKm}km 기부 완료!`,
      donated_km: donateKm
    });
  } catch (e) {
    await conn.rollback();
    console.error('❌ /api/donation/donate 에러:', e.message);
    res.status(400).json({ error: e.message });
  } finally {
    conn.release();
  }
});


// -----------------------------------------------------------------------------
// 🚀 서버 실행
// -----------------------------------------------------------------------------
app.listen(4000, () =>
  console.log('✅ ValueRun API running at http://localhost:4000/')
);
