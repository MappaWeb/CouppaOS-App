import '../import.dart';
import 'gradient_button.dart';

class LoginRequiredDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  ViIcons.lock,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Đăng nhập để tiếp tục'.lang(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Description
              Text(
                'Bạn cần đăng nhập để sử dụng tính năng này và trải nghiệm đầy đủ các ưu đãi'.lang(),
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.gray600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              
              // Benefits list
              _buildBenefitRow(ViIcons.map_01, 'Tìm cửa hàng gần bạn'),
              const SizedBox(height: 12),
              _buildBenefitRow(ViIcons.alert_circle, 'Gửi phản ánh về cửa hàng vi phạm'),
              const SizedBox(height: 28),
              
              // Login Button
              GradientButtonWidget(
                label: 'Đăng nhập'.lang(),
                width: double.infinity,
                height: 50,
                borderRadius: 12,
                onPressed: () {
                  Navigator.of(context).pop();
                  appNavigator.pushNamed(RouterConstants.login);
                },
              ),
              const SizedBox(height: 12),
              
              // Register Button
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  appNavigator.pushNamed(RouterConstants.login);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Tạo tài khoản mới'.lang(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Close button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Để sau'.lang(),
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.gray500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text.lang(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor,
            ),
          ),
        ),
        Icon(
          ViIcons.check,
          color: AppColors.secondary,
          size: 20,
        ),
      ],
    );
  }
}
