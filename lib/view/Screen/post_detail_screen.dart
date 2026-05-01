import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rajeali_app/core/constant/app_routes.dart';
import 'package:rajeali_app/core/shared/app_theme.dart';

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
    final bool isLost = args['type'] == 'lost';

    return _PostDetailView(args: args, isLost: isLost);
  }
}

class _PostDetailView extends StatefulWidget {
  const _PostDetailView({required this.args, required this.isLost});
  final Map<String, dynamic> args;
  final bool isLost;

  @override
  State<_PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<_PostDetailView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ألوان بناءً على النوع
  Color get _accent => widget.isLost ? const Color(0xFFE53935) : const Color(0xFF2E7D32);
  Color get _accentLight => widget.isLost
      ? const Color(0xFFFFEBEE)
      : const Color(0xFFE8F5E9);
  LinearGradient get _headerGradient => widget.isLost
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFB71C1C), Color(0xFFE53935)],
        )
      : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1B5E20), Color(0xFF388E3C)],
        );

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final DateTime dt = DateTime.parse(raw);
      return DateFormat('dd MMMM yyyy • hh:mm a', 'ar').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = widget.args;
    final String? imageUrl = args['image'] as String?;
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: CustomScrollView(
          slivers: <Widget>[
            // ── Hero Header ──
            SliverAppBar(
              expandedHeight: hasImage ? 320 : 200,
              pinned: true,
              backgroundColor: _accent,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.snackbar('تم', 'تم نسخ رابط البلاغ',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.black87,
                          colorText: Colors.white,
                          borderRadius: 14,
                          margin: const EdgeInsets.all(16));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.share_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    // صورة أو gradient
                    if (hasImage)
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(gradient: _headerGradient)),
                      )
                    else
                      Container(decoration: BoxDecoration(gradient: _headerGradient)),

                    // Overlay gradient للقراءة
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          stops: const <double>[0.4, 1.0],
                        ),
                      ),
                    ),

                    // Badge + Title على الصورة
                    Positioned(
                      bottom: 20,
                      right: 20,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              // Badge النوع
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _accent,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: _accent.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      widget.isLost
                                          ? Icons.search_rounded
                                          : Icons.handshake_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.isLost ? 'مفقود' : 'موجود',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (args['category'] != null) ...<Widget>[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    args['category'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            args['title'] as String? ?? '',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.3,
                              shadows: <Shadow>[
                                Shadow(
                                    color: Colors.black45,
                                    blurRadius: 8,
                                    offset: Offset(0, 2)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Body Content ──
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        // ── Info Cards Row ──
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _InfoChip(
                                icon: Icons.location_on_rounded,
                                label: 'الموقع',
                                value: args['location'] as String? ?? 'غير محدد',
                                color: _accent,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _InfoChip(
                                icon: Icons.calendar_month_rounded,
                                label: widget.isLost ? 'تاريخ الفقدان' : 'تاريخ الإيجاد',
                                value: _formatDate(args['date'] as String?),
                                color: _accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // ── Description Card ──
                        if (args['description'] != null &&
                            (args['description'] as String).isNotEmpty)
                          _SectionCard(
                            icon: Icons.description_rounded,
                            title: 'الوصف',
                            accentColor: _accent,
                            child: Text(
                              args['description'] as String,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF374151),
                                height: 1.8,
                              ),
                            ),
                          ),

                        const SizedBox(height: 14),

                        // ── Match Score Card (لو موجود) ──
                        if (args['match_score'] != null)
                          _MatchScoreCard(
                            score: (args['match_score'] as num).toDouble(),
                            accentColor: _accent,
                            accentLight: _accentLight,
                          ),

                        const SizedBox(height: 14),

                        // ── Tips Card ──
                        _TipsCard(isLost: widget.isLost, accentColor: _accent),

                        const SizedBox(height: 24),

                        // ── Action Button ──
                        _ActionButton(
                          isLost: widget.isLost,
                          accent: _accent,
                          gradient: _headerGradient,
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Get.toNamed(
                              AppRoutes.verification,
                              arguments: args,
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        // ── Report Button ──
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => Get.snackbar(
                              'إبلاغ',
                              'تم إرسال البلاغ لمدير النظام',
                              snackPosition: SnackPosition.BOTTOM,
                            ),
                            icon: const Icon(Icons.flag_outlined, size: 18),
                            label: const Text('إبلاغ عن هذا البلاغ'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Info Chip — موقع / تاريخ
// ─────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value.isEmpty ? 'غير محدد' : value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
                height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Section Card
// ─────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    required this.accentColor,
  });
  final IconData icon;
  final String title;
  final Widget child;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 19),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E))),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Match Score Card
// ─────────────────────────────────────────
class _MatchScoreCard extends StatelessWidget {
  const _MatchScoreCard({
    required this.score,
    required this.accentColor,
    required this.accentLight,
  });
  final double score;
  final Color accentColor;
  final Color accentLight;

  @override
  Widget build(BuildContext context) {
    final int percent = (score * 100).round();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accentLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: score,
                  strokeWidth: 6,
                  backgroundColor: accentColor.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
              Text('$percent%',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: accentColor)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('نسبة التطابق',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: accentColor)),
                const SizedBox(height: 4),
                Text(
                  percent >= 70
                      ? 'تطابق عالي — يُنصح بالتحقق الآن'
                      : percent >= 40
                          ? 'تطابق متوسط — قد يكون نفس الغرض'
                          : 'تطابق منخفض — راجع التفاصيل',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Tips Card
// ─────────────────────────────────────────
class _TipsCard extends StatelessWidget {
  const _TipsCard({required this.isLost, required this.accentColor});
  final bool isLost;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final List<String> tips = isLost
        ? <String>[
            'أجب على أسئلة التحقق بدقة لإثبات ملكيتك',
            'كلما كانت إجاباتك أدق، زادت فرصة استرداد غرضك',
            'تواصل مع الواجد عبر الشات بعد التحقق',
          ]
        : <String>[
            'احتفظ بالغرض في مكان آمن حتى يتواصل معك صاحبه',
            'سيتحقق الـ AI من هوية المطالب بالغرض',
            'يمكنك التواصل مع صاحب الغرض بعد التحقق',
          ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tips_and_updates_rounded,
                    color: Colors.amber, size: 19),
              ),
              const SizedBox(width: 10),
              const Text('نصائح مفيدة',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E))),
            ],
          ),
          const SizedBox(height: 14),
          ...tips.map((String tip) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: accentColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(tip,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                              height: 1.5)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Action Button
// ─────────────────────────────────────────
class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.isLost,
    required this.accent,
    required this.gradient,
    required this.onTap,
  });
  final bool isLost;
  final Color accent;
  final LinearGradient gradient;
  final VoidCallback onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: widget.accent.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                widget.isLost
                    ? Icons.verified_user_rounded
                    : Icons.chat_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                widget.isLost ? 'التحقق من الملكية' : 'تواصل مع صاحب الغرض',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
