import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rajeali_app/controller/auth_controller.dart';
import 'package:rajeali_app/controller/post_controller.dart';
import 'package:rajeali_app/core/constant/app_routes.dart';
import 'package:rajeali_app/core/shared/app_theme.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D47A1),
        body: Stack(
          children: <Widget>[
            // ── خلفية متحركة ──
            const _AnimatedBackground(),

            // ── المحتوى ──
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  // ── Header ──
                  _buildHeader(size),

                  // ── Form Card ──
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: size.height * 0.65),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(36),
                        topRight: Radius.circular(36),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // ── Handle bar ──
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Title ──
                          const Text(
                            'مرحباً بعودتك! 👋',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0D47A1),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'سجّل الدخول للمتابعة إلى تطبيق رجعلي',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ── Email ──
                          _FieldLabel(text: 'البريد الإلكتروني'),
                          const SizedBox(height: 8),
                          _InputField(
                            controller: controller.loginEmailCtrl,
                            hint: 'example@email.com',
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 20),

                          // ── Password ──
                          _FieldLabel(text: 'كلمة المرور'),
                          const SizedBox(height: 8),
                          Obx(
                            () => _InputField(
                              controller: controller.loginPasswordCtrl,
                              hint: '••••••••',
                              icon: Icons.lock_rounded,
                              obscureText: controller.obscurePassword.value,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscurePassword.value
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: AppColors.grey,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    controller.obscurePassword.toggle(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // ── Forgot password ──
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: () =>
                                  Get.toNamed(AppRoutes.forgotPassword),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'نسيت كلمة المرور؟',
                                style: TextStyle(
                                  color: Color(0xFF1976D2),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Error ──
                          Obx(() {
                            if (controller.error.value.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.error.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      controller.error.value,
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          // ── Login Button ──
                          Obx(
                            () => _LoginButton(
                              isLoading: controller.isLoading.value,
                              onTap: () async {
                                HapticFeedback.mediumImpact();
                                final bool ok = await controller.login();
                                if (ok) {
                                  Get.find<PostController>().loadAllData();
                                  Get.offAllNamed(AppRoutes.home);
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ── Divider ──
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'أو',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // ── Register Link ──
                          Center(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                children: <InlineSpan>[
                                  const TextSpan(text: 'ليس لديك حساب؟  '),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () =>
                                          Get.toNamed(AppRoutes.register),
                                      child: const Text(
                                        'إنشاء حساب',
                                        style: TextStyle(
                                          color: Color(0xFF1976D2),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return SizedBox(
      height: size.height * 0.32,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'رجعلي',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'منصة ذكية لإدارة المفقودات والموجودات',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.75),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Animated Background
// ─────────────────────────────────────────
class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        width: size.width,
        height: size.height * 0.4,
        child: CustomPaint(painter: _BgPainter(progress: _anim.value)),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  _BgPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Circle 1
    final Paint p1 = Paint()
      ..color = const Color(0xFF1565C0).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(
        size.width * 0.15,
        size.height * 0.2 + progress * size.height * 0.05,
      ),
      size.width * 0.35,
      p1,
    );

    // Circle 2
    final Paint p2 = Paint()
      ..color = const Color(0xFF42A5F5).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(
        size.width * 0.85,
        size.height * 0.1 - progress * size.height * 0.05,
      ),
      size.width * 0.28,
      p2,
    );

    // Circle 3
    final Paint p3 = Paint()
      ..color = const Color(0xFF0D47A1).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(
        size.width * 0.6,
        size.height * 0.55 + progress * size.height * 0.03,
      ),
      size.width * 0.2,
      p3,
    );
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────
// Field Label
// ─────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A2E),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Input Field
// ─────────────────────────────────────────
class _InputField extends StatefulWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.textDirection,
    this.textAlign = TextAlign.start,
  });
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextDirection? textDirection;
  final TextAlign textAlign;

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (bool f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _focused ? const Color(0xFF1976D2) : Colors.grey.shade200,
            width: _focused ? 1.8 : 1,
          ),
          boxShadow: _focused
              ? <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF1976D2).withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: TextField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          textDirection: widget.textDirection,
          textAlign: widget.textAlign,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A2E),
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: Icon(
              widget.icon,
              color: _focused ? const Color(0xFF1976D2) : Colors.grey.shade400,
              size: 20,
            ),
            suffixIcon: widget.suffixIcon,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Login Button
// ─────────────────────────────────────────
class _LoginButton extends StatefulWidget {
  const _LoginButton({required this.isLoading, required this.onTap});
  final bool isLoading;
  final VoidCallback onTap;

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => !widget.isLoading ? _ctrl.forward() : null,
      onTapUp: (_) {
        _ctrl.reverse();
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[
                Color(0xFF1565C0),
                Color(0xFF1976D2),
                Color(0xFF42A5F5),
              ],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF1976D2).withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
