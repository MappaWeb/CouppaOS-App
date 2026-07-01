import '../../../../import.dart';

/// Form thêm/sửa chi nhánh.
///
/// Create mode (args null hoặc không có 'id'): POST /merchants/me/stores
/// Edit mode   (args có 'id'):                  PATCH /merchants/me/stores/{id}
class MerchantStoreFormBloc extends SystemFormBloc<SystemFormState> {
  MerchantStoreFormBloc({required ApiClient apiClient, Map? initialData})
    : this._(apiClient, initialData);

  MerchantStoreFormBloc._(this._apiClient, Map? initialData)
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

  bool get _isCreate => _id == null || _id.isEmpty;

  static Map<String, dynamic> _buildInitialFields(Map? data) {
    if (data == null || data['id'] == null) {
      return <String, dynamic>{
        'isPrimary': false,
        'images': <FileRef>[],
      };
    }
    return <String, dynamic>{
      'name': data['name']?.toString() ?? '',
      'address': data['address']?.toString() ?? '',
      'phone': data['phone']?.toString() ?? '',
      'lat': (data['lat'] as num?)?.toDouble(),
      'lng': (data['lng'] as num?)?.toDouble(),
      'isPrimary': data['isPrimary'] == true,
      'images': _parseImages(data['images']),
    };
  }

  static List<FileRef> _parseImages(dynamic raw) {
    if (raw is! List) return const <FileRef>[];
    return raw
        .whereType<Map>()
        .map((img) {
          final url = img['url']?.toString() ?? '';
          final id = (img['id'] as String?)?.isNotEmpty == true ? img['id']!.toString() : url;
          return FileRef.fromMap({...Map<String, dynamic>.from(img), 'id': id});
        })
        .where((f) => f.id.isNotEmpty)
        .toList();
  }

  static Map<String, Rules> _validationRules() => {
    'name': Rules(required: 'Vui lòng nhập tên cơ sở'),
    'address': Rules(required: 'Vui lòng nhập địa chỉ'),
    'phone': Rules(
      required: 'Vui lòng nhập số điện thoại',
      checkData: (data) => _validateVnPhone(data.value?.toString() ?? ''),
    ),
    'lat': Rules(required: 'Vui lòng chọn vị trí trên bản đồ'),
    'lng': Rules(required: 'Vui lòng chọn vị trí trên bản đồ'),
  };

  @override
  Future<void> onSubmit(
    Emitter emit, {
    Map<String, dynamic>? extraParams,
    Map<String, dynamic>? extraFields,
  }) async {
    final f = state.fields;
    final images = (f['images'] as List?)?.whereType<FileRef>().toList() ?? <FileRef>[];

    final payload = <String, dynamic>{
      'name': (f['name'] as String?)?.trim() ?? '',
      'address': (f['address'] as String?)?.trim() ?? '',
      'phone': (f['phone'] as String?)?.trim() ?? '',
      'lat': f['lat'],
      'lng': f['lng'],
      'isPrimary': f['isPrimary'] == true,
      'images': images
          .where((img) => img.url != null)
          .map((img) => <String, dynamic>{'url': img.url!})
          .toList(),
    };

    try {
      final dio = _apiClient.dio(ApiService.merchant);
      if (_isCreate) {
        await dio.post(AppApi.partner.stores, data: payload);
      } else {
        await dio.patch(AppApi.partner.storeById(_id!), data: payload);
      }
    } on DioException catch (e) {
      emit(state.copyWith(status: SystemFormStateStatus.fail, message: _mapError(e)));
      return;
    } catch (_) {
      emit(
        state.copyWith(
          status: SystemFormStateStatus.fail,
          message: _isCreate ? 'Tạo chi nhánh thất bại' : 'Cập nhật chi nhánh thất bại',
        ),
      );
      return;
    }

    await onSuccess(const {'status': 'SUCCESS'}, emit);
  }

  static String? _validateVnPhone(String raw) {
    if (raw.isEmpty) return null;
    final digits = raw.replaceAll(RegExp(r'[\s.-]'), '');
    String normalized = digits;
    if (normalized.startsWith('+84')) {
      normalized = '0${normalized.substring(3)}';
    } else if (normalized.startsWith('84') && normalized.length == 11) {
      normalized = '0${normalized.substring(2)}';
    }
    final vnMobile = RegExp(r'^0(3[2-9]|5[25689]|7[06-9]|8[1-9]|9[0-46-9])\d{7}$');
    if (!vnMobile.hasMatch(normalized)) return 'Số điện thoại không hợp lệ';
    return null;
  }

  static String _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
      final error = data['error'];
      if (error is Map) {
        final errMsg = error['message']?.toString();
        if (errMsg != null && errMsg.isNotEmpty) return errMsg;
      }
    }
    return 'Thao tác thất bại';
  }
}
