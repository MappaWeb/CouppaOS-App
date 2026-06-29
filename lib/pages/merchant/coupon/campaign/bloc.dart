import '../../../../import.dart';

/// Form tạo/sửa campaign — `POST {AppApi.voucher.campaigns}` / `PATCH {AppApi.voucher.campaignById(id)}`.
///
/// Cấu trúc field cơ bản giống form phát hành lô voucher,
/// thay đổi:
/// - Required: `name`, `quantity`, `validFrom`, `validTo`
/// - Thêm: `code` (optional), `claimLayout` ('A'|'B'|'C', mặc định 'A'),
///   `otpRequired` (bool, mặc định false)
/// - Payload: `totalQuantity` (thay vì `quantity`), bỏ `faceValue` khỏi root,
///   thêm `claimLayout`, `policy.otpRequired`, `code` (khi có).
class MerchantCouponCampaignFormBloc extends SystemFormBloc<SystemFormState> {
  MerchantCouponCampaignFormBloc({required ApiClient apiClient, Map? initialData})
      : this._(apiClient, initialData);

  MerchantCouponCampaignFormBloc._(this._apiClient, Map? initialData)
      : _id = initialData?['id']?.toString(),
        super(
          rules: _validationRules(),
          initialState: SystemFormState(
            status: SystemFormStateStatus.initial,
            fields: _buildInitialFields(initialData),
            data: const {},
          ),
        );

  final ApiClient _apiClient;
  final String? _id;
  bool get _isEdit => _id != null && _id.isNotEmpty;

  static Map<String, dynamic> _buildInitialFields(Map? data) {
    if (data == null) {
      return {
        'scope': 'all',
        'claimLayout': 'A',
        'otpRequired': false,
      };
    }

    String? formatThousands(dynamic v) {
      if (v == null) return null;
      final n = v is num ? v.toInt() : int.tryParse(v.toString());
      if (n == null || n <= 0) return null;
      final s = n.toString();
      final buf = StringBuffer();
      for (var i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
        buf.write(s[i]);
      }
      return buf.toString();
    }

    String? formatDateTime(dynamic v) {
      if (v == null) return null;
      final dt = v is DateTime ? v.toLocal() : DateTime.tryParse(v.toString())?.toLocal();
      if (dt == null) return null;
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
    }

    final windows = data['usageWindows'];
    String? timeStart;
    String? timeEnd;
    if (windows is List && windows.isNotEmpty && windows.first is Map) {
      final w = windows.first as Map;
      timeStart = (w['start'] ?? w['from'])?.toString();
      timeEnd = (w['end'] ?? w['to'])?.toString();
    }

    final days = data['usageDaysOfWeek'];
    final daysList = days is List
        ? days.map((e) => e is int ? e : int.tryParse('$e') ?? 0).toList()
        : <int>[];

    final acceptance = data['acceptance'];
    String scope = 'all';
    String? storeIds;
    String? partnerIds;
    if (acceptance is Map) {
      scope = (acceptance['scope']?.toString() ?? 'all');
      final s = acceptance['storeIds'];
      if (s is List) storeIds = s.join(',');
      final partners = acceptance['partners'];
      if (partners is List) {
        partnerIds = partners
            .whereType<Map>()
            .map((p) => p['merchantId']?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .join(',');
      }
    }

    return {
      if ((data['name'] ?? '').toString().isNotEmpty) 'name': data['name'].toString(),
      if (formatThousands(data['faceValue']) != null) 'faceValue': formatThousands(data['faceValue']),
      if (formatThousands(data['totalQuantity']) != null) 'quantity': formatThousands(data['totalQuantity']),
      if (formatDateTime(data['validFrom']) != null) 'validFrom': formatDateTime(data['validFrom']),
      if (formatDateTime(data['validTo']) != null) 'validTo': formatDateTime(data['validTo']),
      if (daysList.isNotEmpty) 'daysOfWeek': daysList,
      if (timeStart != null && timeStart.isNotEmpty) 'timeStart': timeStart,
      if (timeEnd != null && timeEnd.isNotEmpty) 'timeEnd': timeEnd,
      'scope': scope,
      if (storeIds != null && storeIds.isNotEmpty) 'storeIds': storeIds,
      if (partnerIds != null && partnerIds.isNotEmpty) 'partnerIds': partnerIds,
      if ((data['code'] ?? '').toString().isNotEmpty) 'code': data['code'].toString(),
      'claimLayout': (data['claimLayout']?.toString().isNotEmpty ?? false)
          ? data['claimLayout'].toString()
          : 'A',
      'otpRequired': data['otpRequired'] == true,
      if ((data['note'] ?? '').toString().isNotEmpty) 'note': data['note'].toString(),
    };
  }

  static Map<String, Rules> _validationRules() => {
        'name': Rules(required: 'Vui lòng nhập tên chiến dịch'),
        'faceValue': Rules(
          checkData: (data) => _validatePositiveInt(data.value, 'Mệnh giá phải > 0'),
        ),
        'quantity': Rules(
          required: 'Vui lòng nhập số lượng',
          checkData: (data) => _validatePositiveInt(data.value, 'Số lượng phải > 0'),
        ),
        'validFrom': Rules(
          required: 'Vui lòng chọn ngày bắt đầu',
        ),
        'validTo': Rules(
          required: 'Vui lòng chọn ngày kết thúc',
          checkData: (data) {
            final to = _parseDateTime(data.value);
            final from = _parseDateTime(data.fields['validFrom']);
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
        'claimLayout': Rules(required: 'Vui lòng chọn giao diện trang nhận quà'),
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
      'name': (f['name'] as String).trim(),
      'claimLayout': (f['claimLayout'] as String?) ?? 'A',
      'totalQuantity': _parseInt(f['quantity']),
      'validFrom': _toIsoUtc(f['validFrom']),
      'validTo': _toIsoUtc(f['validTo']),
      'policy': {'otpRequired': (f['otpRequired'] as bool?) ?? false},
      'acceptance': _buildAcceptance(f),
      if ((f['code'] as String?)?.trim().isNotEmpty ?? false) 'code': (f['code'] as String).trim(),
      if (_parseInt(f['faceValue']) > 0) 'faceValue': _parseInt(f['faceValue']).toString(),
      if ((f['note'] as String?)?.trim().isNotEmpty ?? false) 'note': (f['note'] as String).trim(),
      if (_buildUsage(f) != null) 'usage': _buildUsage(f),
    };

    try {
      final dio = _apiClient.dio(ApiService.coupon);
      final editId = _id;
      if (editId != null && editId.isNotEmpty) {
        await dio.patch(AppApi.voucher.campaignById(editId), data: payload);
      } else {
        await dio.post(AppApi.voucher.campaigns, data: payload);
      }
    } on DioException catch (e) {
      emit(state.copyWith(status: SystemFormStateStatus.fail, message: _mapError(e)));
      return;
    } catch (_) {
      emit(state.copyWith(
        status: SystemFormStateStatus.fail,
        message: _isEdit ? 'Cập nhật chiến dịch thất bại' : 'Tạo chiến dịch thất bại',
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

  String _mapError(DioException e) {
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
      case 'CAMPAIGN_CODE_TAKEN':
        return 'Mã link đã được sử dụng';
      case 'CAMPAIGN_QUOTA_EXCEEDED':
        return 'Đã vượt hạn mức phát hành';
      default:
        if (message != null && message.isNotEmpty) return message;
        return _isEdit ? 'Cập nhật chiến dịch thất bại' : 'Tạo chiến dịch thất bại';
    }
  }
}
