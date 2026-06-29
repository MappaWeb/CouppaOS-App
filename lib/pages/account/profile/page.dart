import '../../../import.dart';
import 'bloc.dart';

class AccountProfilePage extends StatelessWidget {
  const AccountProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccountProfileBloc(
        apiClient: context.read<ApiClient>(),
        authSetup: AuthSetup.instance,
      ),
      child: const _AccountProfileView(),
    );
  }
}

class _AccountProfileView extends StatelessWidget {
  const _AccountProfileView();

  @override
  Widget build(BuildContext context) {
    return SystemFormScaffold<AccountProfileBloc, SystemFormState>(
      appBarBuilder: (context, state) => BaseAppBar(
        title: const Text('Thông tin cá nhân'),
        context: context,
      ),
      scaffoldBackgroundColor: Palette.cardColor,
      bottomNavigationBar: (context, state, submitBtn) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: state.isSubmitting
                ? null
                : () => context
                      .read<AccountProfileBloc>()
                      .add(SubmitSystemForm()),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(state.isSubmitting ? 'Đang lưu...' : 'Lưu'),
            ),
          ),
        ),
      ),
      builder: (context, state, wrapper) {
        return BlocListener<AccountProfileBloc, SystemFormState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            if (state.isSuccess) {
              final noop = state.response['noop'] == '1';
              if (!noop) {
                showMessage(
                  'Cập nhật thông tin thành công',
                  type: 'success',
                );
              }
              appNavigator.pop();
            } else if (state.isFail && state.message != null) {
              showMessage(state.message!, type: 'error');
            }
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            children: [
              wrapper<String>(
                'phoneNumber',
                builder: (context, data, onChanged) => FieldText(
                  labelText: 'Số điện thoại',
                  value: data.getValue() as String?,
                  enabled: false,
                ),
              ),
              const SizedBox(height: 12),
              wrapper<String>(
                'displayName',
                builder: (context, data, onChanged) => FieldText(
                  labelText: 'Tên hiển thị',
                  value: data.getValue() as String?,
                  errorText: data.error,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(height: 12),
              wrapper<String>(
                'address',
                builder: (context, data, onChanged) => FieldText(
                  labelText: 'Địa chỉ',
                  value: data.getValue() as String?,
                  errorText: data.error,
                  maxLines: 2,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
