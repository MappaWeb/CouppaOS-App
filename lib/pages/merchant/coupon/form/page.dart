import 'package:flutter/services.dart';

import '../../../../import.dart';
import 'bloc.dart';
import 'widgets/days_of_week_picker.dart';

/// Form tạo chiến dịch mới (`/Merchant/Coupon/Form`).
///
/// Submit thành công → snackbar success → `pop(true)`. List sẽ refresh.
class MerchantCouponFormPage extends StatelessWidget {
  const MerchantCouponFormPage(this.args, {super.key});

  final Map? args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MerchantCouponFormBloc(apiClient: context.read<ApiClient>()),
      child: const _MerchantCouponFormView(),
    );
  }
}

class _MerchantCouponFormView extends StatelessWidget {
  const _MerchantCouponFormView();

  static const _scopeItems = [
    {'id': 'all', 'title': 'Mọi cơ sở'},
    {'id': 'stores', 'title': 'Chọn cơ sở'},
  ];

  @override
  Widget build(BuildContext context) {
    return SystemFormScaffold<MerchantCouponFormBloc, SystemFormState>(
      scaffoldBackgroundColor: AppColors.white,
      appBarBuilder: (ctx, state) => BaseAppBar(context: ctx, title: const Text('Tạo chiến dịch')),
      bottomNavigationBar: (ctx, state, submitBtn) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: state.isSubmitting
                ? null
                : () => ctx.read<MerchantCouponFormBloc>().add(SubmitSystemForm()),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(state.isSubmitting ? 'Đang tạo...' : 'Tạo chiến dịch'),
            ),
          ),
        ),
      ),
      builder: (context, state, wrapper) {
        return BlocListener<MerchantCouponFormBloc, SystemFormState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (ctx, st) {
            if (st.isSuccess) {
              showMessage('Tạo chiến dịch thành công', type: 'success');
              appNavigator.pop(true);
            } else if (st.isFail && st.message != null) {
              showMessage(st.message!, type: 'error');
            }
          },
          child: SingleChildScrollView(
            padding: basePadding,
            child: Column(
              spacing: 12,
              crossAxisAlignment: .start,
              children: [
                wrapper<String>(
                  'name',
                  builder: (ctx, data, onChanged) => FieldText(
                    labelText: 'Tên đợt phát hành',
                    value: data.getValue() as String?,
                    errorText: data.error,
                    onChanged: onChanged,
                  ),
                ),
                wrapper<String>(
                  'faceValue',
                  builder: (ctx, data, onChanged) => FieldText(
                    labelText: 'Mệnh giá',
                    required: true,
                    value: data.getValue() as String?,
                    errorText: data.error,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_ThousandsFormatter()],
                    onChanged: onChanged,
                  ),
                ),
                wrapper<String>(
                  'quantity',
                  builder: (ctx, data, onChanged) => FieldText(
                    labelText: 'Số lượng',
                    required: true,
                    value: data.getValue() as String?,
                    errorText: data.error,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_ThousandsFormatter()],
                    onChanged: onChanged,
                  ),
                ),
                wrapper<String>(
                  'validFrom',
                  builder: (ctx, data, onChanged) => FieldDateTime(
                    labelText: 'Ngày bắt đầu',
                    value: data.getValue() as String?,
                    errorText: data.error,
                    onChanged: onChanged,
                  ),
                ),
                wrapper<String>(
                  'validTo',
                  builder: (ctx, data, onChanged) => FieldDateTime(
                    labelText: 'Ngày kết thúc',
                    value: data.getValue() as String?,
                    errorText: data.error,
                    onChanged: onChanged,
                  ),
                ),
                wrapper<List<int>>(
                  'daysOfWeek',
                  isMultiple: true,
                  builder: (ctx, data, onChanged) => DaysOfWeekPicker(
                    value: (data.getValue() as List?)?.cast<int>(),
                    errorText: data.error,
                    onChanged: onChanged,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: wrapper<String>(
                        'timeStart',
                        builder: (ctx, data, onChanged) => FieldTime(
                          labelText: 'Giờ bắt đầu',
                          value: data.getValue() as String?,
                          errorText: data.error,
                          onChanged: onChanged,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: wrapper<String>(
                        'timeEnd',
                        builder: (ctx, data, onChanged) => FieldTime(
                          labelText: 'Giờ kết thúc',
                          value: data.getValue() as String?,
                          errorText: data.error,
                          onChanged: onChanged,
                        ),
                      ),
                    ),
                  ],
                ),
                wrapper<String>(
                  'scope',
                  builder: (ctx, data, onChanged) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          'Nơi thanh toán *',
                          style: TextStyle(fontSize: 13, color: Palette.textPrimary4),
                        ),
                      ),
                      FieldSelect.radioGroup(
                        items: _scopeItems,
                        value: (data.getValue() as String?) ?? 'all',
                        errorText: data.error,
                        onChanged: (v) => onChanged(
                          v as String?,
                          removeFields: v == 'all' ? const ['storeIds'] : null,
                        ),
                      ),
                    ],
                  ),
                ),
                wrapper<String>(
                  'storeIds',
                  checkEnable: (fields) => fields['scope'] == 'stores',
                  builder: (ctx, data, onChanged) {
                    if (!data.enabled) return const SizedBox.shrink();
                    return FieldSelect.picker(
                      labelText: 'Chọn cơ sở',
                      required: true,
                      isMulti: true,
                      dataSource: ApiService.merchant.apiPath(AppApi.merchant.stores),
                      service: AppApi.merchant.stores,
                      valueKey: 'id',
                      labelKey: 'name',
                      value: data.getValue() as String?,
                      errorText: data.error,
                      onChanged: onChanged,
                    );
                  },
                ),
                wrapper<String>(
                  'partnerIds',
                  builder: (ctx, data, onChanged) => FieldSelect.picker(
                    labelText: 'Thanh toán tại đối tác',
                    isMulti: true,
                    dataSource: ApiService.merchant.apiPath(AppApi.merchant.partners),
                    service: AppApi.merchant.partners,
                    valueKey: 'merchantId',
                    labelKey: 'name',
                    value: data.getValue() as String?,
                    errorText: data.error,
                    onChanged: onChanged,
                  ),
                ),
                wrapper<String>(
                  'note',
                  builder: (ctx, data, onChanged) => FieldText(
                    labelText: 'Ghi chú',
                    value: data.getValue() as String?,
                    errorText: data.error,
                    maxLines: 3,
                    onChanged: onChanged,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Format số với dấu chấm phân cách 3 chữ số (vd `1234567` → `1.234.567`).
class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
      buf.write(digits[i]);
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
