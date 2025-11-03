import 'package:flutter/material.dart';
import '../../screens/main_page.dart';
import 'package:flutter/services.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // 브랜드 컬러 팔레트
  static const Color brand = Color(0xFF15B3DA);
  static const Color brandDark = Color(0xFF0C8EAE);

  @override
  Widget build(BuildContext context) {
    // 상태바 가독성
    SystemChrome.setSystemUIOverlayStyle(
      Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () => _goHome(context),
            child: const Text('로그인'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // 히어로 영역
              const SizedBox(height: 8),
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 로고 워드마크
                    Text(
                      '가치런',
                      textAlign: TextAlign.center,
                      style: textTheme.displaySmall?.copyWith(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        height: 1.0,
                        color: brand,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Value Run',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // 소셜 버튼 영역
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _SocialButton(
                      label: '카카오로 시작하기',
                      style: _SocialStyle.kakao(),
                      onPressed: () => _login(context, provider: 'kakao'),
                    ),
                    const SizedBox(height: 14),
                    _SocialButton(
                      label: '네이버로 시작하기',
                      style: _SocialStyle.naver(),
                      onPressed: () => _login(context, provider: 'naver'),
                    ),
                    const SizedBox(height: 14),
                    _SocialButton(
                      label: 'Sign in with Apple',
                      style: _SocialStyle.apple(isDark: isDark),
                      onPressed: () => _login(context, provider: 'apple'),
                    ),
                    const SizedBox(height: 18),

                    // 구분선
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1.2,
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '또는',
                            style: textTheme.labelLarge?.copyWith(
                              color: isDark ? Colors.white60 : Colors.black45,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1.2,
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 이메일로 계속하기(예시)
                    _PrimaryCTA(
                      label: '이메일로 계속하기',
                      onPressed: () => _login(context, provider: 'email'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 약관 문구
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text.rich(
                  TextSpan(
                    text: '계속하면 ',
                    style: textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    children: [
                      TextSpan(
                        text: '서비스 이용약관',
                        style: TextStyle(
                          color: brandDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' 및 '),
                      TextSpan(
                        text: '개인정보 처리방침',
                        style: TextStyle(
                          color: brandDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: '에 동의하게 됩니다.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login(BuildContext context, {required String provider}) async {
    HapticFeedback.lightImpact(); // 가벼운 햅틱
    // TODO: 실제 로그인 로직 연결
    // 로딩 UI가 필요하면 showDialog로 프로그레스 넣기
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _goHome(context);
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainPage()),
    );
  }
}

/// 공통 소셜 버튼 스타일
class _SocialStyle {
  final Color bg;
  final Color fg;
  final Color border;
  final Widget icon;

  _SocialStyle({
    required this.bg,
    required this.fg,
    required this.border,
    required this.icon,
  });

  factory _SocialStyle.kakao() => _SocialStyle(
        bg: const Color(0xFFFEE500),
        fg: Colors.black,
        border: Colors.black,
        icon: _SquareIcon(
          color: Color(0xFFFEE500),
          border: Colors.black,
          child: Text('K',
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w900)),
        ),
      );

  factory _SocialStyle.naver() => _SocialStyle(
        bg: Colors.white,
        fg: Colors.black,
        border: Colors.black,
        icon: _SquareIcon(
          color: Color(0xFF03C75A),
          border: Colors.black,
          child: const Text('N',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w900)),
        ),
      );

  factory _SocialStyle.apple({required bool isDark}) => _SocialStyle(
        bg: isDark ? Colors.white : Colors.black,
        fg: isDark ? Colors.black : Colors.white,
        border: isDark ? Colors.white : Colors.black,
        icon: Icon(Icons.apple, size: 22, color: isDark ? Colors.black : Colors.white),
      );
}

/// 소셜 버튼 위젯
class _SocialButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final _SocialStyle style;

  const _SocialButton({
    required this.label,
    required this.onPressed,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(height: 52),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.black12,
          backgroundColor: style.bg,
          foregroundColor: style.fg,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: style.border, width: 2),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            style.icon,
            const SizedBox(width: 10),
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// 프라이머리 CTA(이메일 등)
class _PrimaryCTA extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PrimaryCTA({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(height: 52),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 3,
          shadowColor: Colors.black26,
          backgroundColor: WelcomeScreen.brand,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

/// 정사각형 미니 아이콘
class _SquareIcon extends StatelessWidget {
  final Color color;
  final Color border;
  final Widget child;

  const _SquareIcon({
    required this.color,
    required this.border,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 1.5),
      ),
      child: child,
    );
  }
}
