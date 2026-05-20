import 'package:flutter/material.dart';
import '../main.dart';

enum SnackType { success, error, info, warning }

class CustomSnackbar {
  static void show(
      BuildContext context, {
        required String message,
        SnackType type = SnackType.info,
        Duration duration = const Duration(seconds: 3),
      }) {
    // Cerrar el anterior si hay uno abierto
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final config = _config(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        content: _SnackContent(
          message: message,
          icon: config['icon'] as IconData,
          color: config['color'] as Color,
          label: config['label'] as String,
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.zero,
      ),
    );
  }

  // ── Atajos ───────────────────────────────────────────
  static void success(BuildContext context, String message) =>
      show(context, message: message, type: SnackType.success);

  static void error(BuildContext context, String message) =>
      show(context, message: message, type: SnackType.error);

  static void info(BuildContext context, String message) =>
      show(context, message: message, type: SnackType.info);

  static void warning(BuildContext context, String message) =>
      show(context, message: message, type: SnackType.warning);

  // ── Config por tipo ──────────────────────────────────
  static Map<String, dynamic> _config(SnackType type) {
    switch (type) {
      case SnackType.success:
        return {
          'icon': Icons.check_circle_outline_rounded,
          'color': AppColors.success,
          'label': 'Éxito',
        };
      case SnackType.error:
        return {
          'icon': Icons.error_outline_rounded,
          'color': AppColors.accent,
          'label': 'Error',
        };
      case SnackType.warning:
        return {
          'icon': Icons.warning_amber_rounded,
          'color': const Color(0xFFE67E22),
          'label': 'Aviso',
        };
      case SnackType.info:
        return {
          'icon': Icons.info_outline_rounded,
          'color': const Color(0xFF2980B9),
          'label': 'Info',
        };
    }
  }
}

// ============================================================
// WIDGET INTERNO — el contenido animado del snackbar
// ============================================================
class _SnackContent extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;
  final String label;

  const _SnackContent({
    required this.message,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  State<_SnackContent> createState() => _SnackContentState();
}

class _SnackContentState extends State<_SnackContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.color.withOpacity(0.4), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icono con fondo circular
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.color, size: 22),
              ),
              const SizedBox(width: 14),
              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label.toUpperCase(),
                      style: TextStyle(
                        color: widget.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.message,
                      style:  TextStyle(
                        color: AppColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}