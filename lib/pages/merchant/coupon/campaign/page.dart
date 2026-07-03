import 'package:flutter/services.dart';

import '../../../../import.dart';
import 'bloc.dart';

/// Form tạo / sửa chiến dịch (`/Merchant/Coupon/Campaign`).
///
/// Submit thành công → snackbar success → `pop(true)`.
class MerchantCouponCampaignPage extends StatelessWidget {
  const MerchantCouponCampaignPage(this.args, {super.key});

  final Map? args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MerchantCouponCampaignFormBloc(apiClient: context.read<ApiClient>(), initialData: args),
      child: _MerchantCouponCampaignView(isEdit: args?['id'] != null),
    );
  }
}

class _MerchantCouponCampaignView extends StatelessWidget {
  const _MerchantCouponCampaignView({required this.isEdit});

  final bool isEdit;

  static const _scopeItems = [
    {'id': 'all', 'title': 'Mọi cơ sở'},
    {'id': 'stores', 'title': 'Chọn cơ sở'},
  ];

  static const _claimLayoutItems = [
    {'id': 'A', 'title': 'Vé'},
    {'id': 'B', 'title': 'Tràn ảnh'},
    {'id': 'C', 'title': 'Tối giản'},
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
    return SystemFormScaffold<MerchantCouponCampaignFormBloc, SystemFormState>(
      scaffoldBackgroundColor: Palette.bgColor,
      appBarBuilder: (ctx, state) =>
          BaseAppBar(context: ctx, title: Text(isEdit ? 'Sửa chiến dịch' : 'Tạo chiến dịch')),
      bottomNavigationBar: (ctx, state, submitBtn) => Container(
        decoration: const BoxDecoration(
          color: Palette.cardColor,
          border: Border(top: BorderSide(color: Palette.dividerColor)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: SizedBox(
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: state.isSubmitting
                    ? null
                    : () => ctx.read<MerchantCouponCampaignFormBloc>().add(SubmitSystemForm()),
                child: Text(
                  state.isSubmitting
                      ? (isEdit ? 'Đang lưu...' : 'Đang tạo...')
                      : (isEdit ? 'Lưu thay đổi' : 'Tạo chiến dịch'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
      ),
      builder: (context, state, wrapper) {
        return BlocListener<MerchantCouponCampaignFormBloc, SystemFormState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (ctx, st) {
            if (st.isSuccess) {
              showMessage(
                isEdit ? 'Cập nhật chiến dịch thành công' : 'Tạo chiến dịch thành công',
                type: 'success',
              );
              appNavigator.pop(true);
            } else if (st.isFail && st.message != null) {
              showMessage(st.message!, type: 'error');
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FormSection(
                  title: 'Thông tin & Mệnh giá',
                  children: [
                    wrapper<String>(
                      'name',
                      builder: (ctx, data, onChanged) => FieldText(
                        labelText: 'Tên chiến dịch',
                        required: true,
                        value: data.getValue() as String?,
                        errorText: data.error,
                        onChanged: onChanged,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: wrapper<String>(
                            'faceValue',
                            builder: (ctx, data, onChanged) => FieldText(
                              labelText: 'Mệnh giá',
                              value: data.getValue() as String?,
                              errorText: data.error,
                              keyboardType: TextInputType.number,
                              inputFormatters: [_ThousandsFormatter()],
                              onChanged: onChanged,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: wrapper<String>(
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
                        ),
                      ],
                    ),
                    wrapper<String>(
                      'code',
                      builder: (ctx, data, onChanged) => FieldText(
                        labelText: 'Mã link',
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
                        maxLines: 2,
                        onChanged: onChanged,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _FormSection(
                  title: 'Thời gian hiệu lực',
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: wrapper<String>(
                            'validFrom',
                            builder: (ctx, data, onChanged) => FieldDateTime(
                              labelText: 'Bắt đầu',
                              required: true,
                              value: data.getValue() as String?,
                              errorText: data.error,
                              onChanged: onChanged,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: wrapper<String>(
                            'validTo',
                            builder: (ctx, data, onChanged) => FieldDateTime(
                              labelText: 'Kết thúc',
                              required: true,
                              value: data.getValue() as String?,
                              errorText: data.error,
                              onChanged: onChanged,
                            ),
                          ),
                        ),
                      ],
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
                        const SizedBox(width: 10),
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
                  ],
                ),
                const SizedBox(height: 12),
                _FormSection(
                  title: 'Phạm vi & Giao diện',
                  children: [
                    wrapper<String>(
                      'scope',
                      builder: (ctx, data, onChanged) => FieldGroup(
                        labelText: 'Nơi thanh toán',
                        required: true,
                        errorText: data.error,
                        child: FieldSelect.radioGroup(
                          items: _scopeItems,
                          value: (data.getValue() as String?) ?? 'all',
                          onChanged: (v) => onChanged(
                            v as String?,
                            removeFields: v == 'all' ? const ['storeIds'] : null,
                          ),
                        ),
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
                      'claimLayout',
                      builder: (ctx, data, onChanged) => FieldGroup(
                        labelText: 'Giao diện trang nhận quà',
                        required: true,
                        errorText: data.error,
                        child: FieldSelect.radioGroup(
                          items: _claimLayoutItems,
                          value: (data.getValue() as String?) ?? 'A',
                          onChanged: (v) => onChanged(v as String?),
                        ),
                      ),
                    ),
                    wrapper<bool>(
                      'otpRequired',
                      builder: (ctx, data, onChanged) => FieldCheckbox(
                        labelText: 'Yêu cầu OTP khi nhận quà',
                        value: (data.getValue() as bool?) ?? false,
                        onChanged: onChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Palette.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Palette.textPrimary2,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(children.length, (i) {
            return Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
              child: children[i],
            );
          }),
        ],
      ),
    );
  }
}

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
