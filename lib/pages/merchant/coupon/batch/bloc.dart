import '../../../../import.dart';

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
  MerchantCouponBatchBloc({required ApiClient apiClient})
    : this._(apiClient);

  MerchantCouponBatchBloc._(this._apiClient)
    : super(
        rules: _validationRules(),
        initialState: SystemFormState(
          status: SystemFormStateStatus.initial,
          fields: const {'scope': 'all'},
          data: const {},
        ),
      );

  final ApiClient _apiClient;

  static Map<String, Rules> _validationRules() => {
    'faceValue': Rules(
    //   required: 'Vui lòng nhập mệnh giá',
      checkData: (data) => _validatePositiveInt(data.value, 'Mệnh giá phải > 0'),
    ),
    'quantity': Rules(
      required: 'Vui lòng nhập số lượng',
      checkData: (data) => _validatePositiveInt(data.value, 'Số lượng phải > 0'),
    ),
    'validFrom': Rules(
      checkData: (data) {
        final from = _parseDateTime(data.value);
        final to = _parseDateTime(data.fields['validTo']);
        if (from == null && to != null) {
          return 'Vui lòng chọn ngày bắt đầu';
        }
        return null;
      },
    ),
    'validTo': Rules(
      checkData: (data) {
        final to = _parseDateTime(data.value);
        final from = _parseDateTime(data.fields['validFrom']);
        if (to == null && from != null) {
          return 'Vui lòng chọn ngày kết thúc';
        }
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
          if (end.compareTo(start) <= 0) {
            return 'Giờ kết thúc phải sau giờ bắt đầu';
          }
        }
        return null;
      },
    ),
    'scope': Rules(required: 'Vui lòng chọn nơi thanh toán'),
    'storeIds': Rules(
      checkData: (data) {
        if (data.fields['scope'] != 'stores') return null;
        if (_splitIds(data.value).isEmpty) return 'Vui lòng chọn ít nhất 1 cơ sở';
        return null;
      },
    ),
  };

  static String? _validatePositiveInt(dynamic raw, String message) {
    final cleaned = (raw ?? '').toString().replaceAll('.', '').trim();
    if (cleaned.isEmpty) return null;
    final n = int.tryParse(cleaned);
    if (n == null || n <= 0) return message;
    return null;
  }

  @override
  Future<void> onSubmit(
    Emitter emit, {
    Map<String, dynamic>? extraParams,
    Map<String, dynamic>? extraFields,
  }) async {
    final f = state.fields;

    final payload = <String, dynamic>{
      if ((f['name'] as String?)?.trim().isNotEmpty ?? false) 'name': (f['name'] as String).trim(),
      'quantity': _parseInt(f['quantity']),
      'faceValue': _parseInt(f['faceValue']).toString(),
      if ((f['note'] as String?)?.trim().isNotEmpty ?? false) 'note': (f['note'] as String).trim(),
      if (_toIsoUtc(f['validFrom']) != null) 'validFrom': _toIsoUtc(f['validFrom']),
      if (_toIsoUtc(f['validTo']) != null) 'validTo': _toIsoUtc(f['validTo']),
      'usage': _buildUsage(f),
      'acceptance': _buildAcceptance(f),
    }..removeWhere((_, v) => v == null);

    try {
      final dio = _apiClient.dio(ApiService.coupon);
      await dio.post(AppApi.voucher.campaignIssueDirect, data: payload);
    } on DioException catch (e) {
      emit(state.copyWith(status: SystemFormStateStatus.fail, message: _mapError(e)));
      return;
    } catch (_) {
      emit(state.copyWith(
        status: SystemFormStateStatus.fail,
        message: 'Phát hành lô voucher thất bại',
      ));
      return;
    }

    await onSuccess(const {'status': 'SUCCESS'}, emit);
  }

  static int _parseInt(dynamic raw) {
    final cleaned = (raw ?? '').toString().replaceAll('.', '').trim();
    return int.tryParse(cleaned) ?? 0;
  }

  static String? _toIsoUtc(dynamic raw) {
    final dt = _parseDateTime(raw);
    if (dt == null) return null;
    return dt.toUtc().toIso8601String();
  }

  /// Parse format từ `FieldDateTime` (`dd/MM/yyyy HH:mm`). Fallback: ISO-8601.
  static DateTime? _parseDateTime(dynamic raw) {
    final s = raw?.toString().trim();
    if (s == null || s.isEmpty) return null;
    final parts = s.split(' ');
    if (parts.length == 2) {
      final d = parts[0].split('/');
      final t = parts[1].split(':');
      if (d.length == 3 && t.length >= 2) {
        final year = int.tryParse(d[2]);
        final month = int.tryParse(d[1]);
        final day = int.tryParse(d[0]);
        final hour = int.tryParse(t[0]);
        final min = int.tryParse(t[1]);
        if (year != null && month != null && day != null && hour != null && min != null) {
          return DateTime(year, month, day, hour, min);
        }
      }
    }
    return DateTime.tryParse(s);
  }

  static Map<String, dynamic>? _buildUsage(Map<String, dynamic> f) {
    final days = ((f['daysOfWeek'] as List?) ?? const []).cast<int>();
    final start = ((f['timeStart'] as String?) ?? '').trim();
    final end = ((f['timeEnd'] as String?) ?? '').trim();
    final hasWindow = start.isNotEmpty && end.isNotEmpty;
    if (days.isEmpty && !hasWindow) return null;
    return {
      if (days.isNotEmpty) 'daysOfWeek': days,
      if (hasWindow)
        'windows': [
          {'start': start, 'end': end},
        ],
    };
  }

  static Map<String, dynamic> _buildAcceptance(Map<String, dynamic> f) {
    final scope = (f['scope'] as String?) ?? 'all';
    final storeIds = _splitIds(f['storeIds']);
    final partnerIds = _splitIds(f['partnerIds']);
    return {
      'scope': scope,
      if (scope == 'stores' && storeIds.isNotEmpty) 'storeIds': storeIds,
      if (partnerIds.isNotEmpty)
        'partners': partnerIds.map((id) => {'merchantId': id, 'scope': 'all'}).toList(),
    };
  }

  static List<String> _splitIds(dynamic raw) {
    final s = raw?.toString() ?? '';
    if (s.isEmpty) return const [];
    return s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
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
