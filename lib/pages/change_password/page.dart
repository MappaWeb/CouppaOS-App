import '../../import.dart';
import 'bloc.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ChangePasswordCubit(
        apiClient: ctx.read<ApiClient>(),
      ),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatelessWidget {
  const _ChangePasswordView();

  static const _hPadding = 24.0;

  Future<void> _onSubmit(BuildContext context) async {
    final cubit = context.read<ChangePasswordCubit>();
    final ok = await cubit.submit();
    if (!context.mounted) return;
    if (ok) {
      showMessage('Đổi mật khẩu thành công', type: 'success');
      appNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<ChangePasswordCubit, ChangePasswordState>(
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
                      const _OldPasswordField(),
                      const SizedBox(height: 12),
                      const _NewPasswordField(),
                      const SizedBox(height: 12),
                      const _ConfirmField(),
                      const SizedBox(height: 8),
                      _PrimaryButton(onPressed: () => _onSubmit(context)),
                      const Spacer(),
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
            Icons.lock_outline,
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
          'Đổi mật khẩu',
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
          'Cập nhật mật khẩu mới để bảo vệ tài khoản của bạn.',
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

class _OldPasswordField extends StatelessWidget {
  const _OldPasswordField();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ChangePasswordCubit, ChangePasswordState,
        (String, String?, bool)>(
      selector: (s) => (s.oldPassword, s.oldPasswordError, s.obscureOld),
      builder: (ctx, sel) => FieldText(
        value: sel.$1,
        labelText: 'Mật khẩu hiện tại',
        hintText: 'Nhập mật khẩu hiện tại',
        errorText: sel.$2,
        required: true,
        obscureText: sel.$3,
        textInputAction: TextInputAction.next,
        onChanged: (v) => ctx.read<ChangePasswordCubit>().setOldPassword(v),
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
              ctx.read<ChangePasswordCubit>().toggleOldVisibility(),
        ),
      ),
    );
  }
}

class _NewPasswordField extends StatelessWidget {
  const _NewPasswordField();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ChangePasswordCubit, ChangePasswordState,
        (String, String?, bool)>(
      selector: (s) => (s.newPassword, s.newPasswordError, s.obscureNew),
      builder: (ctx, sel) => FieldText(
        value: sel.$1,
        labelText: 'Mật khẩu mới',
        hintText: 'Nhập mật khẩu mới',
        errorText: sel.$2,
        required: true,
        obscureText: sel.$3,
        textInputAction: TextInputAction.next,
        onChanged: (v) => ctx.read<ChangePasswordCubit>().setNewPassword(v),
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
              ctx.read<ChangePasswordCubit>().toggleNewVisibility(),
        ),
      ),
    );
  }
}

class _ConfirmField extends StatelessWidget {
  const _ConfirmField();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ChangePasswordCubit, ChangePasswordState,
        (String, String?, bool)>(
      selector: (s) =>
          (s.confirmPassword, s.confirmPasswordError, s.obscureConfirm),
      builder: (ctx, sel) => FieldText(
        value: sel.$1,
        labelText: 'Nhập lại mật khẩu mới',
        hintText: 'Nhập lại mật khẩu mới',
        errorText: sel.$2,
        required: true,
        obscureText: sel.$3,
        textInputAction: TextInputAction.done,
        onChanged: (v) =>
            ctx.read<ChangePasswordCubit>().setConfirmPassword(v),
        onSubmitted: (_) => ctx.read<ChangePasswordCubit>().submit(),
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
              ctx.read<ChangePasswordCubit>().toggleConfirmVisibility(),
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
    return BlocSelector<ChangePasswordCubit, ChangePasswordState, bool>(
      selector: (s) => s.isSubmitting,
      builder: (_, isSubmitting) {
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
                : const Text('Cập nhật mật khẩu'),
          ),
        );
      },
    );
  }
}
