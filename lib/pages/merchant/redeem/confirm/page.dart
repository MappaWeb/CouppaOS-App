import '../../../../import.dart';
import 'bloc.dart';

class MerchantRedeemConfirmPage extends StatelessWidget {
  const MerchantRedeemConfirmPage(this.args, {super.key});

  final Map? args;

  String get code => args?['code']?.toString() ?? '';

  Map<String, dynamic> get _verifyData {
    final v = args?['verifyData'];
    return v is Map<String, dynamic> ? v : {};
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => MerchantRedeemConfirmCubit(
        apiClient: ctx.read<ApiClient>(),
        initialData: _verifyData,
      ),
      child: _MerchantRedeemConfirmView(code: code),
    );
  }
}

class _MerchantRedeemConfirmView extends StatelessWidget {
  const _MerchantRedeemConfirmView({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        context: context,
        title: const Text('Xác nhận sử dụng coupon'),
      ),
      body: BlocConsumer<MerchantRedeemConfirmCubit, MerchantRedeemConfirmState>(
        listenWhen: (p, c) =>
            (!p.success && c.success) ||
            (p.isSubmitting && !c.isSubmitting && c.error != null),
        listener: (context, state) async {
          if (state.success) {
            await _showSuccessDialog(context);
            return;
          }
          if (state.error != null) {
            showMessage(state.error!, type: 'error');
          }
        },
        builder: (context, state) => _VerifyBody(code: code, state: state),
      ),
    );
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận thành công!'),
        content: const Text('Voucher đã được sử dụng thành công.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Quét tiếp'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (shouldExit == true) {
      appNavigator.go(RouterConstants.merchantCoupon);
    } else {
      appNavigator.pop();
    }
  }
}

class _VerifyBody extends StatelessWidget {
  const _VerifyBody({required this.code, required this.state});

  final String code;
  final MerchantRedeemConfirmState state;

  @override
  Widget build(BuildContext context) {
    final data = state.verifyData;
    final couponName =
        _extract(data, ['campaign.name', 'coupon.name', 'couponName', 'name', 'title']);
    final userName = _extract(
        data, ['user.name', 'holder.name', 'owner.name', 'customerName', 'userName']);
    final discount = _extract(data, ['discount', 'discountValue', 'voucherValue', 'value']);
    final expiresAt = _extract(data, ['expiresAt', 'expiredAt', 'expires_at']);
    final status = _extract(data, ['status', 'codeStatus']);
    final isValid = data['isValid'] as bool? ?? true;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Validity badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isValid
                              ? Colors.green.withValues(alpha: 0.12)
                              : Theme.of(context)
                                  .colorScheme
                                  .error
                                  .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isValid ? 'Hợp lệ' : 'Không hợp lệ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isValid
                                ? Colors.green.shade700
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Mã token', value: code),
                  if (couponName != null)
                    _InfoRow(label: 'Coupon', value: couponName),
                  if (userName != null)
                    _InfoRow(label: 'Người dùng', value: userName),
                  if (discount != null)
                    _InfoRow(label: 'Giá trị', value: discount),
                  if (expiresAt != null)
                    _InfoRow(label: 'Hạn sử dụng', value: expiresAt),
                  if (status != null)
                    _InfoRow(label: 'Trạng thái', value: status),
                ],
              ),
            ),
          ),
          const Spacer(),
          BaseButton(
            onPressed: state.isSubmitting
                ? null
                : () => context
                    .read<MerchantRedeemConfirmCubit>()
                    .confirm(code),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                  state.isSubmitting ? 'Đang xác nhận...' : 'Xác nhận & Claim'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static String? _extract(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final parts = key.split('.');
      dynamic val = data;
      for (final part in parts) {
        val = val is Map ? val[part] : null;
      }
      if (val != null) return val.toString();
    }
    return null;
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.outline),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
