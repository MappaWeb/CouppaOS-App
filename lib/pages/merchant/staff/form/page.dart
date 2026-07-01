import 'package:flutter/services.dart';

import '../../../../import.dart';
import 'bloc.dart';

class MerchantStaffFormPage extends StatelessWidget {
  const MerchantStaffFormPage(this.args, {super.key});

  final Map? args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MerchantStaffFormBloc(
        apiClient: context.read<ApiClient>(),
        initialData: args,
      ),
      child: _MerchantStaffFormView(isEdit: args?['id'] != null),
    );
  }
}

class _MerchantStaffFormView extends StatelessWidget {
  const _MerchantStaffFormView({required this.isEdit});

  final bool isEdit;

  static const _roleItems = [
    {'id': 'merchant_admin', 'title': 'Quản trị viên'},
    {'id': 'super_staff', 'title': 'Trưởng nhóm'},
    {'id': 'accounting', 'title': 'Kế toán'},
    {'id': 'staff', 'title': 'Nhân viên'},
  ];

  @override
  Widget build(BuildContext context) {
    return SystemFormScaffold<MerchantStaffFormBloc, SystemFormState>(
      scaffoldBackgroundColor: Palette.cardColor,
      appBarBuilder: (ctx, state) => BaseAppBar(
        context: ctx,
        title: Text(isEdit ? 'Sửa nhân viên' : 'Thêm nhân viên'),
      ),
      bottomNavigationBar: (ctx, state, _) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: state.isSubmitting
                ? null
                : () => ctx.read<MerchantStaffFormBloc>().add(SubmitSystemForm()),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                state.isSubmitting
                    ? (isEdit ? 'Đang lưu...' : 'Đang mời...')
                    : (isEdit ? 'Lưu thay đổi' : 'Mời nhân viên'),
              ),
            ),
          ),
        ),
      ),
      builder: (context, state, wrapper) {
        return BlocListener<MerchantStaffFormBloc, SystemFormState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (ctx, st) {
            if (st.isSuccess) {
              showMessage(
                isEdit ? 'Cập nhật nhân viên thành công' : 'Đã mời nhân viên thành công',
                type: 'success',
              );
              appNavigator.pop(true);
            } else if (st.isFail && st.message != null) {
              showMessage(st.message!, type: 'error');
            }
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            children: [
              if (!isEdit) ...[
                wrapper<String>(
                  'phone',
                  builder: (ctx, data, onChanged) => FieldText(
                    labelText: 'Số điện thoại',
                    required: true,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                      LengthLimitingTextInputFormatter(15),
                    ],
                    value: data.getValue() as String?,
                    errorText: data.error,
                    onChanged: onChanged,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              wrapper<String>(
                'role',
                builder: (ctx, data, onChanged) => FieldGroup(
                  labelText: 'Vai trò',
                  required: true,
                  errorText: data.error,
                  child: FieldSelect.radioGroup(
                    items: _roleItems,
                    value: data.getValue() as String?,
                    onChanged: (v) => onChanged(v as String?),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              wrapper<String>(
                'storeId',
                builder: (ctx, data, onChanged) => FieldSelect.picker(
                  labelText: 'Chi nhánh làm việc',
                  dataSource: ApiService.merchant.apiPath(AppApi.partner.stores),
                  service: AppApi.partner.stores,
                  valueKey: 'id',
                  labelKey: 'name',
                  value: data.getValue() as String?,
                  errorText: data.error,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
