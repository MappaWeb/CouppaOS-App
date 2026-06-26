import '../../import.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({
    super.key,
    required this.account,
    this.onResend,
    required this.onChanged,
    this.errorText,
    this.value,
    required this.timer,
  });

  final ValueNotifier<int> timer;
  final String account;
  final VoidCallback? onResend;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final String? value;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late TextEditingController otpController;

  @override
  void initState() {
    otpController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  String get account {
    if (widget.account.isEmpty || widget.account.toLowerCase() == 'null') {
      return '';
    }
    if (widget.account.contains('*') || isInputEmail(widget.account)) {
      return widget.account;
    }
    final lengthPhone = widget.account.length;
    return widget.account.replaceRange(
      0,
      lengthPhone - 3,
      List.generate(lengthPhone - 3, (_) => '*').join(''),
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of;
    final displayAccount = account;
    final isEmail = isInputEmail(displayAccount);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.otpVerification,
          textAlign: TextAlign.center,
          style: AppTextStyles.title.copyWith(fontSize: 30),
        ),
        h16,
        Text(
          isEmail
              ? 'Mã OTP đã được gửi tới email:\n$displayAccount'
              : 'Mã OTP đã được gửi tới số điện thoại:\n$displayAccount',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Palette.textPrimary2, height: 1.5),
        ),
        const SizedBox(height: 24),
        FormOTPField(
          hasError: !empty(widget.errorText),
          borderRadius: BorderRadius.circular(12),
          onChanged: widget.onChanged,
          builder: (code) {
            if (!empty(code) && code != widget.value) {
              widget.onChanged(code ?? '');
              safeCallback(() => otpController.text = code ?? '');
            }
          },
          controller: otpController,
          otpHeight: 52,
          otpWidth: 44,
        ),
        if (!empty(widget.errorText)) ...[
          h12,
          Text(
            widget.errorText!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Palette.redTxtColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        h16,
        if (widget.onResend != null)
          ValueListenableBuilder<int>(
            valueListenable: widget.timer,
            builder: (context, time, child) {
              if (time == 0) {
                if (displayAccount.isEmpty) return const SizedBox.shrink();
                return TextButton(
                  onPressed: () {
                    safeCallback(() => otpController.text = '');
                    widget.onResend?.call();
                  },
                  child: Text(
                    l10n.resendOtp,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Palette.primary,
                    ),
                  ),
                );
              }
              return Text(
                'Gửi lại mã (${_formatTime(time)})',
                style: const TextStyle(color: Palette.textPrimary4, fontSize: 14),
              );
            },
          ),
      ],
    );
  }
}
