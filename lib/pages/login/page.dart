import '../../import.dart';
import 'bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => LoginCubit(
        apiClient: ctx.read<ApiClient>(),
        authSetup: AuthSetup.instance,
      ),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  static const _hPadding = 24.0;

  Future<void> _submit(BuildContext context) async {
    final ok = await context.read<LoginCubit>().submit();
    if (!context.mounted) return;
    if (ok) {
      final route = getRole() == UserRole.merchant
          ? RouterConstants.merchantCoupon
          : RouterConstants.userCoupon;
      appNavigator.go(route);
    }
  }

  void _goRegister() {
    appNavigator.pushNamed(RouterConstants.register);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<LoginCubit, LoginState>(
        listenWhen: (p, c) =>
            p.errorMessage != c.errorMessage && c.errorMessage != null,
        listener: (_, s) => showMessage(s.errorMessage!, type: 'error'),
        child: GestureDetector(
          onTap: (){
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: _hPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.sizeOf(context).height -
                      MediaQuery.paddingOf(context).vertical,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 48),
                      const _Brand(),
                      const SizedBox(height: 40),
                      const _Header(),
                      const _PhoneField(),
                      const SizedBox(height: 12,),
                      const _PasswordField(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => appNavigator
                              .pushNamed(RouterConstants.forgotPassword),
                          style: TextButton.styleFrom(
                            foregroundColor: Palette.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          child: const Text('Quên mật khẩu?'),
                        ),
                      ),
                      _SubmitButton(onPressed: () => _submit(context)),
                      const Spacer(),
                      const SizedBox(height: 32),
                      _Footer(onRegister: _goRegister),
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
            Icons.local_offer_outlined,
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chào mừng trở lại',
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
          'Đăng nhập để săn coupon và tiết kiệm thông minh.',
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
    return BlocSelector<LoginCubit, LoginState, (String, String?)>(
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
        onChanged: (v) => ctx.read<LoginCubit>().setPhone(v),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<LoginCubit, LoginState, (String, String?, bool)>(
      selector: (s) => (s.password, s.passwordError, s.obscurePassword),
      builder: (ctx, sel) => FieldText(
        value: sel.$1,
        labelText: 'Mật khẩu',
        hintText: 'Nhập mật khẩu',
        errorText: sel.$2,
        required: true,
        obscureText: sel.$3,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) async {
          final ok = await ctx.read<LoginCubit>().submit();
          if (!ctx.mounted) return;
          if (ok) {
            final route = getRole() == UserRole.merchant
                ? RouterConstants.merchantCoupon
                : RouterConstants.userCoupon;
            appNavigator.go(route);
          }
        },
        onChanged: (v) => ctx.read<LoginCubit>().setPassword(v),
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
          onPressed: () => ctx.read<LoginCubit>().togglePasswordVisibility(),
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
    return BlocSelector<LoginCubit, LoginState, bool>(
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
              : const Text('Đăng nhập'),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.onRegister});

  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Chưa có tài khoản?',
          style: TextStyle(
            fontSize: 14,
            color: Palette.textPrimary4,
            fontWeight: FontWeight.w400,
          ),
        ),
        TextButton(
          onPressed: onRegister,
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
          child: const Text('Đăng ký'),
        ),
      ],
    );
  }
}
