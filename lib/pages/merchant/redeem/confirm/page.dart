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
      backgroundColor: Palette.bgColor,
      appBar: BaseAppBar(
        context: context,
        title: const Text('Xác nhận đổi mã'),
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
        title: const Text('Đổi mã thành công!'),
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
    final canRedeem = state.canRedeem;

    final campaignName = data['campaignName']?.toString();
    final faceValue = _formatFaceValue(data['faceValue']);
    final note = data['note']?.toString();
    final status = _statusLabel(data['status']?.toString());
    final hasCustomer = state.hasCustomer;
    final phone = hasCustomer ? data['customerPhone']?.toString() : null;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatusBanner(
                  canRedeem: canRedeem,
                  title: state.invalidTitle,
                  reason: state.invalidReason,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Palette.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Palette.borderColor),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  child: Column(
                    children: [
                      _InfoRow(label: 'Mã', value: code, mono: true),
                      if (campaignName != null)
                        _InfoRow(label: 'Chiến dịch', value: campaignName),
                      if (faceValue != null)
                        _InfoRow(
                          label: 'Mệnh giá',
                          value: faceValue,
                          valueColor: Palette.primary,
                        ),
                      _InfoRow(
                        label: 'Khách hàng',
                        value: phone ?? 'Chưa có khách nhận',
                        valueColor: hasCustomer ? null : Palette.textPrimary3,
                      ),
                      if (status != null)
                        _InfoRow(label: 'Trạng thái', value: status),
                      if (note != null && note.isNotEmpty)
                        _InfoRow(label: 'Ghi chú', value: note),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: BaseButton(
            onPressed: (!canRedeem || state.isSubmitting)
                ? null
                : () =>
                    context.read<MerchantRedeemConfirmCubit>().confirm(code),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                state.isSubmitting
                    ? 'Đang đổi mã...'
                    : canRedeem
                        ? 'Xác nhận đổi mã'
                        : 'Không thể đổi mã',
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String? _formatFaceValue(dynamic raw) {
    if (raw == null) return null;
    final value = num.tryParse(raw.toString());
    if (value == null) return raw.toString();
    final s = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return '$bufferđ';
  }

  static String? _statusLabel(String? status) {
    switch (status) {
      case null:
        return null;
      case 'ISSUED':
        return 'Đã phát hành';
      case 'REDEEMED':
        return 'Đã sử dụng';
      case 'EXPIRED':
        return 'Hết hạn';
      default:
        return status;
    }
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.canRedeem,
    required this.title,
    required this.reason,
  });

  final bool canRedeem;
  final String title;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final bg = canRedeem ? Palette.successBgColor : const Color(0xFFFEF2F2);
    final fg = canRedeem ? Palette.successTxtColor : Palette.redTxtColor;
    final icon = canRedeem ? Icons.check_circle : Icons.cancel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
                if (!canRedeem && reason != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    reason!,
                    style: TextStyle(fontSize: 14, color: fg),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.mono = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Palette.textPrimary4),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor ?? Palette.textPrimary,
                fontFeatures: mono
                    ? const [FontFeature.tabularFigures()]
                    : null,
                letterSpacing: mono ? 1 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
