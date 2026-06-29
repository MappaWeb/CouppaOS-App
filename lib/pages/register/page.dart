import '../../import.dart';
import '../../widget/common/password_valid_note_map.dart';
import 'bloc.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => RegisterCubit(apiClient: ctx.read<ApiClient>()),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  static const _hPadding = 24.0;

  Future<void> _submit(BuildContext context) async {
    final cubit = context.read<RegisterCubit>();
    final ok = await cubit.submit();
    if (!context.mounted) return;
    if (ok) {
      appNavigator.pushNamed(
        RouterConstants.otp,
        arguments: {
          'phone': cubit.state.phone.trim(),
          'password': cubit.state.password,
        },
      );
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
      body: BlocListener<RegisterCubit, RegisterState>(
        listenWhen: (p, c) =>
            p.errorMessage != c.errorMessage && c.errorMessage != null,
        listener: (_, s) => showMessage(s.errorMessage!, type: 'error'),
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: _hPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const _Header(),
                  const _PhoneField(),
                  const _PasswordField(),
                  const SizedBox(height: 12),
                  const PasswordValidNoteMap<RegisterCubit, RegisterState>(
                    selector: _passwordSelector,
                  ),
                  const SizedBox(height: 24),
                  _SubmitButton(onPressed: () => _submit(context)),
                  const SizedBox(height: 24),
                  const _Footer(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _passwordSelector(RegisterState state) => state.password;

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tạo tài khoản',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Palette.textPrimary,
            height: 1.2,
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Đăng ký để bắt đầu săn coupon và tiết kiệm thông minh.',
          style: TextStyle(
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

class _PhoneField extends StatelessWidget {
  const _PhoneField();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<RegisterCubit, RegisterState, (String, String?)>(
      selector: (s) => (s.phone, s.phoneError),
      builder: (ctx, sel) => FieldText(
        value: sel.$1,
        labelText: 'Số điện thoại',
        hintText: 'Nhập số điện thoại',
        errorText: sel.$2,
        required: true,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        prefixIcon: const Icon(
          Icons.phone_outlined,
          size: 20,
          color: Palette.textPrimary4,
        ),
        onChanged: (v) => ctx.read<RegisterCubit>().setPhone(v),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<RegisterCubit, RegisterState, (String, String?, bool)>(
      selector: (s) => (s.password, s.passwordError, s.obscurePassword),
      builder: (ctx, sel) => FieldText(
        value: sel.$1,
        labelText: 'Mật khẩu',
        hintText: 'Nhập mật khẩu',
        errorText: sel.$2,
        required: true,
        obscureText: sel.$3,
        textInputAction: TextInputAction.done,
        onChanged: (v) => ctx.read<RegisterCubit>().setPassword(v),
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
          onPressed: () => ctx.read<RegisterCubit>().togglePasswordVisibility(),
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
    return BlocSelector<RegisterCubit, RegisterState, bool>(
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
              : const Text('Tiếp tục'),
        ),
      ),
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
          'Đã có tài khoản?',
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
