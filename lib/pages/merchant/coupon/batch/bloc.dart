import '../../../../import.dart';
import '../coupon_form_helpers.dart';

/// Form phát hành lô voucher trực tiếp — `POST {AppApi.voucher.campaignIssueDirect}`.
///
/// Field keys (flat trong `state.fields`):
/// - `name` String? (optional)
/// - `faceValue` String (formatted với dấu chấm, parse về int khi submit) — required
/// - `quantity` String (formatted với dấu chấm, parse về int khi submit) — required
/// - `validFrom` String ISO datetime? — optional; nếu có 1 trong 2 (`validFrom`/`validTo`) thì required cả 2
/// - `validTo` String ISO datetime? — optional, > validFrom; nếu có `validFrom` thì required
/// - `daysOfWeek` `List<int>?` (CN=0, T2=1 … T7=6) — optional
/// - `timeStart`, `timeEnd` String 'HH:mm' — optional, nếu có 1 thì cả 2 required
/// - `scope` String — 'all' | 'stores' — required (default 'all')
/// - `storeIds` String? — comma-separated ids; required nếu `scope == 'stores'` (split khi submit)
/// - `partnerIds` String? — comma-separated ids; optional, split khi submit (output `[{merchantId, scope:'all'}]`)
/// - `note` String? — optional
class MerchantCouponBatchBloc extends SystemFormBloc<SystemFormState> {
  MerchantCouponBatchBloc({required ApiClient apiClient, bool isQuickCreate = false})
    : this._(apiClient, isQuickCreate);

  MerchantCouponBatchBloc._(this._apiClient, bool isQuickCreate)
    : super(
        rules: _validationRules(),
        initialState: SystemFormState(
          status: SystemFormStateStatus.initial,
          fields: isQuickCreate
              ? _quickCreateFields()
              : const {
                  'scope': 'all',
                  'daysOfWeek': [0, 1, 2, 3, 4, 5, 6],
                },
          data: const {},
        ),
      );

  final ApiClient _apiClient;

  static Map<String, dynamic> _quickCreateFields() {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final to = from.add(const Duration(days: 30));
    return {
      'name': 'Lô voucher test ${from.day}/${from.month}',
      'faceValue': '50.000',
      'quantity': '10',
      'validFrom': CouponFormHelpers.formatDateTime(from),
      'validTo': CouponFormHelpers.formatDateTime(to),
      'scope': 'all',
      'note': 'Tạo nhanh để test',
      'daysOfWeek': [0, 1, 2, 3, 4, 5, 6],
    };
  }

  static Map<String, Rules> _validationRules() => {
    'faceValue': Rules(
      checkData: (data) => CouponFormHelpers.validatePositiveInt(data.value, 'Mệnh giá phải > 0'),
    ),
    'quantity': Rules(
      required: 'Vui lòng nhập số lượng',
      checkData: (data) => CouponFormHelpers.validatePositiveInt(data.value, 'Số lượng phải > 0'),
    ),
    'validFrom': Rules(
      checkData: (data) {
        final from = CouponFormHelpers.parseDateTime(data.value);
        final to = CouponFormHelpers.parseDateTime(data.fields['validTo']);
        if (from == null && to != null) return 'Vui lòng chọn ngày bắt đầu';
        return null;
      },
    ),
    'validTo': Rules(
      checkData: (data) {
        final to = CouponFormHelpers.parseDateTime(data.value);
        final from = CouponFormHelpers.parseDateTime(data.fields['validFrom']);
        if (to == null && from != null) return 'Vui lòng chọn ngày kết thúc';
        if (from != null && to != null && !to.isAfter(from)) {
          return 'Ngày kết thúc phải sau ngày bắt đầu';
        }
        return null;
      },
    ),
    'timeStart': Rules(
      checkData: (data) {
        final start = data.value?.toString();
        final end = data.fields['timeEnd']?.toString();
        if ((end != null && end.isNotEmpty) && (start == null || start.isEmpty)) {
          return 'Vui lòng chọn giờ bắt đầu';
        }
        return null;
      },
    ),
    'timeEnd': Rules(
      checkData: (data) {
        final end = data.value?.toString();
        final start = data.fields['timeStart']?.toString();
        if ((start != null && start.isNotEmpty) && (end == null || end.isEmpty)) {
          return 'Vui lòng chọn giờ kết thúc';
        }
        if (start != null && start.isNotEmpty && end != null && end.isNotEmpty) {
          if (end.compareTo(start) <= 0) return 'Giờ kết thúc phải sau giờ bắt đầu';
        }
        return null;
      },
    ),
    'scope': Rules(required: 'Vui lòng chọn nơi thanh toán'),
    'storeIds': Rules(
      checkData: (data) {
        if (data.fields['scope'] != 'stores') return null;
        if (CouponFormHelpers.splitIds(data.value).isEmpty) return 'Vui lòng chọn ít nhất 1 cơ sở';
        return null;
      },
    ),
  };

  @override
  Future<void> onSubmit(
    Emitter emit, {
    Map<String, dynamic>? extraParams,
    Map<String, dynamic>? extraFields,
  }) async {
    final f = state.fields;
    final usage = CouponFormHelpers.buildUsage(f);
    final validFrom = CouponFormHelpers.toIsoUtc(f['validFrom']);
    final validTo = CouponFormHelpers.toIsoUtc(f['validTo']);

    final payload = <String, dynamic>{
      if ((f['name'] as String?)?.trim().isNotEmpty ?? false) 'name': (f['name'] as String).trim(),
      'quantity': CouponFormHelpers.parseInt(f['quantity']),
      'faceValue': CouponFormHelpers.parseInt(f['faceValue']).toString(),
      if ((f['note'] as String?)?.trim().isNotEmpty ?? false) 'note': (f['note'] as String).trim(),
      if (validFrom != null) 'validFrom': validFrom,
      if (validTo != null) 'validTo': validTo,
      if (usage != null) 'usage': usage,
      'acceptance': CouponFormHelpers.buildAcceptance(f),
    };

    try {
      final dio = _apiClient.dio(ApiService.coupon);
      await dio.post(AppApi.voucher.campaignIssueDirect, data: payload);
    } on DioException catch (e) {
      emit(state.copyWith(status: SystemFormStateStatus.fail, message: _mapError(e)));
      return;
    } catch (_) {
      emit(
        state.copyWith(
          status: SystemFormStateStatus.fail,
          message: 'Phát hành lô voucher thất bại',
        ),
      );
      return;
    }

    await onSuccess(const {'status': 'SUCCESS'}, emit);
  }

  static String _mapError(DioException e) {
    final data = e.response?.data;
    String? code;
    String? message;
    if (data is Map) {
      final error = data['error'];
      if (error is Map) {
        code = error['code']?.toString();
        message = error['message']?.toString();
      }
      code ??= data['code']?.toString() ?? data['errorCode']?.toString();
      message ??= data['message']?.toString();
    }
    switch (code) {
      case 'VALIDATION_ERROR':
        return (message != null && message.isNotEmpty) ? message : 'Thông tin không hợp lệ';
      case 'CAMPAIGN_QUOTA_EXCEEDED':
        return 'Đã vượt hạn mức phát hành';
      default:
        if (message != null && message.isNotEmpty) return message;
        return 'Phát hành lô voucher thất bại';
    }
  }
}
