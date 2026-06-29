import 'package:flutter/services.dart';

import '../../../../import.dart';
import 'bloc.dart';

/// Form phát hành lô voucher mới (`/Merchant/Coupon/Batch`).
///
/// Submit thành công → snackbar success → `pop(true)`. List sẽ refresh.
class MerchantCouponBatchPage extends StatelessWidget {
  const MerchantCouponBatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MerchantCouponBatchBloc(apiClient: context.read<ApiClient>()),
      child: const _MerchantCouponBatchView(),
    );
  }
}

class _MerchantCouponBatchView extends StatelessWidget {
  const _MerchantCouponBatchView();

  static const _scopeItems = [
    {'id': 'all', 'title': 'Mọi cơ sở'},
    {'id': 'stores', 'title': 'Chọn cơ sở'},
  ];

  static const _daysOfWeekItems = [
    {'id': '1', 'title': 'T2'},
    {'id': '2', 'title': 'T3'},
    {'id': '3', 'title': 'T4'},
    {'id': '4', 'title': 'T5'},
    {'id': '5', 'title': 'T6'},
    {'id': '6', 'title': 'T7'},
    {'id': '0', 'title': 'CN'},
  ];

  @override
  Widget build(BuildContext context) {
    return SystemFormScaffold<MerchantCouponBatchBloc, SystemFormState>(
      scaffoldBackgroundColor: AppColors.white,
      appBarBuilder: (ctx, state) => BaseAppBar(
        context: ctx,
        title: const Text('Phát hành lô voucher'),
      ),
      bottomNavigationBar: (ctx, state, submitBtn) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: state.isSubmitting
                ? null
                : () => ctx.read<MerchantCouponBatchBloc>().add(SubmitSystemForm()),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(state.isSubmitting ? 'Đang phát hành...' : 'Phát hành'),
            ),
          ),
        ),
      ),
      builder: (context, state, wrapper) {
        return BlocListener<MerchantCouponBatchBloc, SystemFormState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (ctx, st) {
            if (st.isSuccess) {
              showMessage('Phát hành lô voucher thành công', type: 'success');
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
                    // required: true,
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
                  builder: (ctx, data, onChanged) => FieldGroup(
                    labelText: 'Ngày trong tuần',
                    errorText: data.error,
                    child: FieldSelect.chips(
                      items: _daysOfWeekItems,
                      value: (data.getValue() as List?)?.cast<int>(),
                      isMulti: true,
                      onChanged: (csv) {
                        if (csv.isEmpty) {
                          onChanged(null);
                          return;
                        }
                        final next = csv
                            .split(',')
                            .where((s) => s.isNotEmpty)
                            .map(int.parse)
                            .toList()
                          ..sort();
                        onChanged(next.isEmpty ? null : next);
                      },
                    ),
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
