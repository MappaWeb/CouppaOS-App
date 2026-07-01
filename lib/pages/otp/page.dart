import '../../import.dart';
import 'bloc.dart';

class OtpPage extends StatelessWidget {
  const OtpPage(this.args, {super.key});

  final Map? args;

  @override
  Widget build(BuildContext context) {
    final phone = args?['phone']?.toString() ?? '';
    final password = args?['password']?.toString() ?? '';
    return BlocProvider(
      create: (ctx) => OtpCubit(
        apiClient: ctx.read<ApiClient>(),
        authSetup: AuthSetup.instance,
        phone: phone,
        password: password,
      )..start(),
      child: _OtpView(phone: phone),
    );
  }
}

class _OtpView extends StatelessWidget {
  const _OtpView({required this.phone});

  final String phone;

  static const _hPadding = 24.0;

  Future<void> _verify(BuildContext context) async {
    final ok = await context.read<OtpCubit>().verify();
    if (!context.mounted) return;
    if (ok) {
      final route = getRole() == UserRole.merchant
          ? RouterConstants.merchantCoupon
          : RouterConstants.userCoupon;
      appNavigator.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Palette.textPrimary),
          onPressed: () => appNavigator.pop(),
        ),
      ),
      body: BlocListener<OtpCubit, OtpState>(
        listenWhen: (p, c) =>
            p.errorMessage != c.errorMessage && c.errorMessage != null,
        listener: (_, s) => showMessage(s.errorMessage!, type: 'error'),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: _hPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                _Header(phone: phone),
                const SizedBox(height: 32),
                const _OtpInputField(),
                const SizedBox(height: 24),
                _SubmitButton(onPressed: () => _verify(context)),
                const SizedBox(height: 24),
                const _ResendRow(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nhập mã xác thực',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Palette.textPrimary,
            height: 1.2,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Mã gồm 6 chữ số đã được gửi tới $phone.',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Palette.textPrimary4,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _OtpInputField extends StatelessWidget {
  const _OtpInputField();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<OtpCubit, OtpState, (String, String?)>(
      selector: (s) => (s.code, s.codeError),
      builder: (ctx, sel) => _OtpBoxes(
        value: sel.$1,
        errorText: sel.$2,
        onChanged: (v) => ctx.read<OtpCubit>().setCode(v),
        onCompleted: () => ctx.read<OtpCubit>().verify().then((ok) {
          if (!ctx.mounted || !ok) return;
          final route = getRole() == UserRole.merchant
              ? RouterConstants.merchantCoupon
              : RouterConstants.userCoupon;
          appNavigator.go(route);
        }),
      ),
    );
  }
}

class _OtpBoxes extends StatefulWidget {
  const _OtpBoxes({
    required this.value,
    required this.errorText,
    required this.onChanged,
    required this.onCompleted,
  });

  final String value;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final VoidCallback onCompleted;

  @override
  State<_OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<_OtpBoxes> {
  static const _length = 6;

  late final TextEditingController _controller =
      TextEditingController(text: widget.value);
  final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(covariant _OtpBoxes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String raw) {
    widget.onChanged(raw);
    if (raw.length >= _length) {
      _focusNode.unfocus();
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_length, (i) {
                  final filled = i < widget.value.length;
                  final isError = widget.errorText != null;
                  return _Cell(
                    digit: filled ? widget.value[i] : '',
                    hasError: isError,
                  );
                }),
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    maxLength: _length,
                    showCursor: false,
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                    ),
                    onChanged: _onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: const TextStyle(
              fontSize: 13,
              color: Palette.redTxtColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.digit, required this.hasError});

  final String digit;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final hasDigit = digit.isNotEmpty;
    final borderColor = hasError
        ? Palette.redTxtColor
        : hasDigit
            ? Palette.primary
            : Palette.borderColor;
    return Container(
      width: 48,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: hasDigit ? 1.6 : 1.2,
        ),
      ),
      child: Text(
        digit,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Palette.textPrimary,
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<OtpCubit, OtpState, bool>(
      selector: (s) => s.isSubmitting,
      builder: (_, isSubmitting) => SizedBox(
        height: 56,
        child: FilledButton(
          onPressed: isSubmitting ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Palette.primary,
            disabledBackgroundColor: Palette.primary.withValues(alpha: 0.5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
          child: isSubmitting
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : const Text('Xác nhận'),
        ),
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<OtpCubit, OtpState, (int, bool, bool)>(
      selector: (s) => (s.secondsLeft, s.canResend, s.isHardBlocked),
      builder: (ctx, sel) {
        final secondsLeft = sel.$1;
        final canResend = sel.$2;
        final isHardBlocked = sel.$3;
        if (isHardBlocked) return const SizedBox.shrink();
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Không nhận được mã?',
              style: TextStyle(
                fontSize: 14,
                color: Palette.textPrimary4,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (canResend)
              TextButton(
                onPressed: () => ctx.read<OtpCubit>().resend(),
                style: TextButton.styleFrom(
                  foregroundColor: Palette.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Gửi lại mã'),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Text(
                  'Gửi lại sau ${_formatCountdown(secondsLeft)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Palette.textPrimary4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  static String _formatCountdown(int seconds) {
    if (seconds >= 3600) {
      final h = seconds ~/ 3600;
      final m = (seconds % 3600) ~/ 60;
      final s = seconds % 60;
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}';
    }
    if (seconds >= 60) {
      final m = seconds ~/ 60;
      final s = seconds % 60;
      return '${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}';
    }
    return '${seconds}s';
  }
}
