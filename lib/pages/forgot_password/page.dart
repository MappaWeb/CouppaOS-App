import '../../import.dart';
import 'bloc.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ForgotPasswordCubit(
        apiClient: ctx.read<ApiClient>(),
      ),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatelessWidget {
  const _ForgotPasswordView();

  static const _hPadding = 24.0;

  Future<void> _onPrimaryPressed(BuildContext context) async {
    final cubit = context.read<ForgotPasswordCubit>();
    final step = cubit.state.step;
    if (step == ForgotPasswordStep.phone) {
      final ok = await cubit.requestOtp();
      if (ok) {
        showMessage(
          'Đã gửi mã OTP đặt lại mật khẩu (nếu SĐT có tài khoản).',
          type: 'info',
        );
      }
      return;
    }
    final ok = await cubit.submitReset();
    if (!context.mounted) return;
    if (ok) {
      showMessage('Đặt lại mật khẩu thành công', type: 'success');
      appNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
        listenWhen: (p, c) =>
            p.errorMessage != c.errorMessage && c.errorMessage != null,
        listener: (_, s) => showMessage(s.errorMessage!, type: 'error'),
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: _hPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height -
                      MediaQuery.paddingOf(context).vertical,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _TopBar(),
                      const SizedBox(height: 24),
                      const _Brand(),
                      const SizedBox(height: 40),
                      const _Header(),
                      const SizedBox(height: 8),
                      const _Body(),
                      const SizedBox(height: 8),
                      _PrimaryButton(onPressed: () => _onPrimaryPressed(context)),
                      const Spacer(),
                      const SizedBox(height: 32),
                      const _Footer(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        icon: const Icon(
          Icons.arrow_back,
          color: Palette.textPrimary,
        ),
        onPressed: () => appNavigator.pop(),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Palette.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.lock_reset,
            size: 32,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Couppa Mini',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Palette.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ForgotPasswordCubit, ForgotPasswordState,
        (ForgotPasswordStep, String)>(
      selector: (s) => (s.step, s.phone),
      builder: (_, sel) {
        final isPhoneStep = sel.$1 == ForgotPasswordStep.phone;
        final title = isPhoneStep ? 'Quên mật khẩu' : 'Đặt lại mật khẩu';
        final subtitle = isPhoneStep
            ? 'Nhập số điện thoại để nhận mã xác thực.'
            : 'Mã xác thực đã gửi tới ${_maskPhone(sel.$2)}.';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Palette.textPrimary,
                height: 1.2,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Palette.textPrimary4,
                height: 1.45,
              ),
            ),
          ],
        );
      },
    );
  }

  static String _maskPhone(String phone) {
    final p = phone.trim();
    if (p.length < 4) return p;
    final tail = p.substring(p.length - 2);
    final head = p.substring(0, p.length - 6 < 0 ? 0 : p.length - 6);
    return '$head****$tail';
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ForgotPasswordCubit, ForgotPasswordState,
        ForgotPasswordStep>(
      selector: (s) => s.step,
      builder: (_, step) =>
          step == ForgotPasswordStep.phone ? const _PhoneStep() : const _ResetStep(),
    );
  }
}

class _PhoneStep extends StatelessWidget {
  const _PhoneStep();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ForgotPasswordCubit, ForgotPasswordState,
        (String, String?)>(
      selector: (s) => (s.phone, s.phoneError),
      builder: (ctx, sel) => FieldText(
        value: sel.$1,
        labelText: 'Số điện thoại',
        hintText: 'Nhập số điện thoại',
        errorText: sel.$2,
        required: true,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        prefixIcon: const Icon(
          Icons.phone_outlined,
          size: 20,
          color: Palette.textPrimary4,
        ),
        onChanged: (v) => ctx.read<ForgotPasswordCubit>().setPhone(v),
        onSubmitted: (_) => ctx.read<ForgotPasswordCubit>().requestOtp(),
      ),
    );
  }
}

class _ResetStep extends StatelessWidget {
  const _ResetStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () =>
                context.read<ForgotPasswordCubit>().backToPhoneStep(),
            style: TextButton.styleFrom(
              foregroundColor: Palette.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Đổi số điện thoại'),
          ),
        ),
        const SizedBox(height: 8),
        const _CodeField(),
        const SizedBox(height: 12),
        const _PasswordField(),
        const SizedBox(height: 12),
        const _ConfirmField(),
      ],
    );
  }
}

class _CodeField extends StatelessWidget {
  const _CodeField();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ForgotPasswordCubit, ForgotPasswordState,
        (String, String?)>(
      selector: (s) => (s.code, s.codeError),
      builder: (ctx, sel) => FieldText(
        value: sel.$1,
        labelText: 'Mã xác thực',
        hintText: 'Nhập 6 chữ số',
        errorText: sel.$2,
        required: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        prefixIcon: const Icon(
          Icons.verified_user_outlined,
          size: 20,
          color: Palette.textPrimary4,
        ),
        onChanged: (v) => ctx.read<ForgotPasswordCubit>().setCode(v),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ForgotPasswordCubit, ForgotPasswordState,
        (String, String?, bool)>(
      selector: (s) => (s.password, s.passwordError, s.obscurePassword),
      builder: (ctx, sel) => FieldText(
        value: sel.$1,
        labelText: 'Mật khẩu mới',
        hintText: 'Nhập mật khẩu mới',
        errorText: sel.$2,
        required: true,
        obscureText: sel.$3,
        textInputAction: TextInputAction.next,
        onChanged: (v) => ctx.read<ForgotPasswordCubit>().setPassword(v),
        prefixIcon: const Icon(
          Icons.lock_outline,
          size: 20,
          color: Palette.textPrimary4,
        ),
        suffixIcon: IconButton(
          splashRadius: 20,
          icon: Icon(
            sel.$3 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
            color: Palette.textPrimary4,
          ),
          onPressed: () =>
              ctx.read<ForgotPasswordCubit>().togglePasswordVisibility(),
        ),
      ),
    );
  }
}

class _ConfirmField extends StatelessWidget {
  const _ConfirmField();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ForgotPasswordCubit, ForgotPasswordState,
        (String, String?, bool)>(
      selector: (s) =>
          (s.confirmPassword, s.confirmPasswordError, s.obscureConfirm),
      builder: (ctx, sel) => FieldText(
        value: sel.$1,
        labelText: 'Nhập lại mật khẩu',
        hintText: 'Nhập lại mật khẩu mới',
        errorText: sel.$2,
        required: true,
        obscureText: sel.$3,
        textInputAction: TextInputAction.done,
        onChanged: (v) =>
            ctx.read<ForgotPasswordCubit>().setConfirmPassword(v),
        onSubmitted: (_) => ctx.read<ForgotPasswordCubit>().submitReset(),
        prefixIcon: const Icon(
          Icons.lock_outline,
          size: 20,
          color: Palette.textPrimary4,
        ),
        suffixIcon: IconButton(
          splashRadius: 20,
          icon: Icon(
            sel.$3 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
            color: Palette.textPrimary4,
          ),
          onPressed: () =>
              ctx.read<ForgotPasswordCubit>().toggleConfirmVisibility(),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ForgotPasswordCubit, ForgotPasswordState,
        (ForgotPasswordStep, bool)>(
      selector: (s) => (s.step, s.isSubmitting),
      builder: (_, sel) {
        final label = sel.$1 == ForgotPasswordStep.phone
            ? 'Gửi mã xác thực'
            : 'Đặt lại mật khẩu';
        final isSubmitting = sel.$2;
        return SizedBox(
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
                : Text(label),
          ),
        );
      },
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Đã nhớ mật khẩu?',
          style: TextStyle(
            fontSize: 14,
            color: Palette.textPrimary4,
            fontWeight: FontWeight.w400,
          ),
        ),
        TextButton(
          onPressed: () => appNavigator.pop(),
          style: TextButton.styleFrom(
            foregroundColor: Palette.primary,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('Đăng nhập'),
        ),
      ],
    );
  }
}
