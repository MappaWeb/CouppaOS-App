import '../import.dart';

class GradientButtonWidget extends StatelessWidget {
  final String? label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;
  final double? height;
  final double? borderRadius;
  final TextStyle? labelStyle;
  final Color? primary;
  final Color? secondary;

  const GradientButtonWidget({
    super.key,
    this.label,
    this.onPressed,
    this.icon,
    this.width,
    this.height,
    this.borderRadius,
    this.labelStyle,
    this.primary,
    this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        child: Ink(
          height: height ?? 48,
          width: width ?? 202,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: !empty(onPressed) ? [
                primary ?? AppColors.primary,
                secondary ?? AppColors.secondary,
              ] : [
                AppColors.gray500,
                AppColors.gray500,
              ],
            ),
          ),
          child: Center(
            child: Row(
              spacing: 5,
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              children: [
                Text(label ?? '', style: labelStyle ?? TextStyle(color: AppColors.cardColor)),
                if (!empty(icon)) Icon(icon, color: AppColors.cardColor, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
