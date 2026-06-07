import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../models/vocabulary_word.dart';

/// Three large colored buttons for Der (blue), Die (pink), Das (green).
class ArticleButtons extends StatelessWidget {
  final void Function(Article article) onSelect;

  const ArticleButtons({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ArticleButton(
            article: Article.der,
            label: 'DER',
            subtitle: 'Maskulin',
            color: AppColors.derBlue,
            icon: Icons.male_rounded,
            onTap: () => onSelect(Article.der),
          ),
        ),
        12.horizontalSpace,
        Expanded(
          child: _ArticleButton(
            article: Article.die,
            label: 'DIE',
            subtitle: 'Feminin',
            color: AppColors.diePink,
            icon: Icons.female_rounded,
            onTap: () => onSelect(Article.die),
          ),
        ),
        12.horizontalSpace,
        Expanded(
          child: _ArticleButton(
            article: Article.das,
            label: 'DAS',
            subtitle: 'Neutral',
            color: AppColors.dasGreen,
            icon: Icons.circle_outlined,
            onTap: () => onSelect(Article.das),
          ),
        ),
      ],
    );
  }
}

class _ArticleButton extends StatefulWidget {
  final Article article;
  final String label;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _ArticleButton({
    required this.article,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_ArticleButton> createState() => _ArticleButtonState();
}

class _ArticleButtonState extends State<_ArticleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: isDark
                ? widget.color.withValues(alpha: 0.12)
                : widget.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: widget.color,
                size: 24,
              ),
              6.verticalSpace,
              Text(
                widget.label,
                style: context.textTheme.titleLarge?.copyWith(
                  color: widget.color,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 2,
                ),
              ),
              2.verticalSpace,
              Text(
                widget.subtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: widget.color.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
