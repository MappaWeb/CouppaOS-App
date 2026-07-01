import '../../../import.dart';

class MerchantProfileBloc extends SystemFormBloc<SystemFormState> {
  MerchantProfileBloc({required this._apiClient})
      : super(fetchOnInit: true, rules: _validationRules());

  final ApiClient _apiClient;

  static Map<String, Rules> _validationRules() => {
        '_merchantName': Rules(required: 'Vui lòng nhập tên cửa hàng'),
        'storeName': Rules(required: 'Vui lòng nhập tên cơ sở'),
        'phone': Rules(
          required: 'Vui lòng nhập số điện thoại',
          checkData: (data) => _validateVnPhone(data.value?.toString() ?? ''),
        ),
        'address': Rules(required: 'Vui lòng nhập địa chỉ'),
        'lat': Rules(
          checkData: (data) {
            final lat = data.fields['lat'];
            final lng = data.fields['lng'];
            if (lat == null || lng == null) return 'Vui lòng chọn vị trí cơ sở';
            return null;
          },
        ),
      };

  @override
  Future<void> onFetchData(Emitter emit) async {
    try {
      final res = await _apiClient.dio(ApiService.merchant).get(AppApi.partner.me);
      final body = Map<String, dynamic>.from(res.data as Map);
      final stores = (body['stores'] as List?) ?? [];

      Map<String, dynamic> primary = {};
      for (final s in stores) {
        if (s is Map && s['isPrimary'] == true) {
          primary = Map<String, dynamic>.from(s);
          break;
        }
      }
      if (primary.isEmpty && stores.isNotEmpty) {
        primary = Map<String, dynamic>.from(stores.first as Map);
      }

      final images = (primary['images'] as List?)
              ?.whereType<Map>()
              .map((img) {
                final url = img['url']?.toString() ?? '';
                final id = (img['id'] as String?)?.isNotEmpty == true
                    ? img['id']!.toString()
                    : url;
                return FileRef.fromMap({
                  ...Map<String, dynamic>.from(img),
                  'id': id,
                });
              })
              .where((f) => f.id.isNotEmpty)
              .toList() ??
          <FileRef>[];

      emit(state.copyWith(
        status: SystemFormStateStatus.loaded,
        data: body,
        fields: {
          '_merchantName': body['name']?.toString() ?? '',
          '_storeId': primary['id']?.toString() ?? '',
          'storeName': primary['name']?.toString() ?? '',
          'phone': primary['phone']?.toString() ?? '',
          'address': primary['address']?.toString() ?? '',
          'lat': (primary['lat'] as num?)?.toDouble(),
          'lng': (primary['lng'] as num?)?.toDouble(),
          'images': images,
        },
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        status: SystemFormStateStatus.loaded,
        message: _mapError(e),
      ));
    } catch (_) {
      emit(state.copyWith(
        status: SystemFormStateStatus.loaded,
        message: 'Không thể tải thông tin cửa hàng',
      ));
    }
  }

  @override
  Future<void> onSubmit(
    Emitter emit, {
    Map<String, dynamic>? extraParams,
    Map<String, dynamic>? extraFields,
  }) async {
    final f = state.fields;
    final storeId = f['_storeId']?.toString() ?? '';

    if (storeId.isEmpty) {
      emit(state.copyWith(
        status: SystemFormStateStatus.fail,
        message: 'Không tìm thấy thông tin cơ sở',
      ));
      return;
    }

    final merchantName = (f['_merchantName'] as String?)?.trim() ?? '';
    final images = (f['images'] as List?)?.whereType<FileRef>().toList() ?? <FileRef>[];
    final storePayload = <String, dynamic>{
      'name': (f['storeName'] as String?)?.trim() ?? '',
      'phone': (f['phone'] as String?)?.trim() ?? '',
      'address': (f['address'] as String?)?.trim() ?? '',
      'lat': f['lat'],
      'lng': f['lng'],
      'images': images
          .where((img) => img.url != null)
          .map((img) => <String, dynamic>{'url': img.url!})
          .toList(),
    };

    try {
      final dio = _apiClient.dio(ApiService.merchant);
      await Future.wait([
        dio.patch(AppApi.partner.me, data: {'name': merchantName}),
        dio.patch(AppApi.partner.storeById(storeId), data: storePayload),
      ]);
    } on DioException catch (e) {
      emit(state.copyWith(
        status: SystemFormStateStatus.fail,
        message: _mapError(e),
      ));
      return;
    } catch (_) {
      emit(state.copyWith(
        status: SystemFormStateStatus.fail,
        message: 'Cập nhật thông tin cơ sở thất bại',
      ));
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
    }
    return 'Cập nhật thông tin cơ sở thất bại';
  }
}
