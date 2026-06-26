import '../../import.dart';
import '../../data/merchant/merchant_session_cubit.dart';

/// Form đăng ký trở thành cửa hàng — dùng [SystemFormBloc] (override [onSubmit]
/// vì submit qua REST `POST /merchants`, không qua submitService).
///
/// Field keys: name, taxCode, storeName, address, phone (String); lat, lng
/// (double); images (`List<FileRef>`). Vị trí được validate qua rule `lat`.
class BecomeMerchantBloc extends SystemFormBloc<SystemFormState> {
  BecomeMerchantBloc({
    required this._apiClient,
    required this._authSetup,
    required this._merchantSession,
  }) : super(rules: _validationRules());

  final ApiClient _apiClient;
  final AuthSetup _authSetup;
  final MerchantSessionCubit _merchantSession;

  static Map<String, Rules> _validationRules() => {
    'name': Rules(required: 'Vui lòng nhập tên pháp nhân'),
    'taxCode': Rules(required: 'Vui lòng nhập mã số thuế'),
    'storeName': Rules(required: 'Vui lòng nhập tên cửa hàng'),
    'address': Rules(required: 'Vui lòng nhập địa chỉ'),
    'phone': Rules(
      required: 'Vui lòng nhập số điện thoại',
      checkData: (data) => _validateVnPhone((data.value ?? '').toString()),
    ),
    'lat': Rules(
      checkData: (data) {
        final lat = data.fields['lat'];
        final lng = data.fields['lng'];
        if (lat == null || lng == null) return 'Vui lòng chọn vị trí cửa hàng';
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
    final fields = state.fields;
    final images = (fields['images'] as List<FileRef>?) ?? const <FileRef>[];
    final payload = {
      'name': (fields['name'] as String?)?.trim(),
      'taxCode': (fields['taxCode'] as String?)?.trim(),
      'store': {
        'name': (fields['storeName'] as String?)?.trim(),
        'address': (fields['address'] as String?)?.trim(),
        'lat': fields['lat'],
        'lng': fields['lng'],
        'phone': (fields['phone'] as String?)?.trim(),
        'images': images.map((f) => {'fileId': f.id, if (f.url != null) 'url': f.url}).toList(),
      },
    };

    try {
      await _apiClient.dio(ApiService.merchant).post('/merchants', data: payload);
    } on DioException catch (e) {
      emit(state.copyWith(status: SystemFormStateStatus.fail, message: _mapError(e)));
      return;
    } catch (_) {
      emit(
        state.copyWith(status: SystemFormStateStatus.fail, message: 'Đăng ký cửa hàng thất bại'),
      );
      return;
    }

    // Đăng ký xong: refresh auth session để nâng role + nạp merchant session.
    try {
      final session = await _authSetup.repository.getMe();
      if (session != null) {
        await _authSetup.repository.saveCachedSession(session);
        _authSetup.authSessionBloc.add(LoggedIn(session.asSharedUser()));
      }
      await _merchantSession.fetchMe();
    } catch (_) {
      // Đăng ký đã thành công ở server; lỗi refresh để caller tự điều hướng.
    }

    await onSuccess(const {'status': 'SUCCESS'}, emit);
  }

  /// Validate số điện thoại Việt Nam (10 số bắt đầu bằng 0, hoặc tiền tố +84/84).
  static String? _validateVnPhone(String raw) {
    if (raw.isEmpty) return 'Vui lòng nhập số điện thoại';
    final digits = raw.replaceAll(RegExp(r'[\s.-]'), '');
    String normalized = digits;
    if (normalized.startsWith('+84')) {
      normalized = '0${normalized.substring(3)}';
    } else if (normalized.startsWith('84') && normalized.length == 11) {
      normalized = '0${normalized.substring(2)}';
    }
    final vnMobile = RegExp(r'^0(3[2-9]|5[25689]|7[06-9]|8[1-9]|9[0-46-9])\d{7}$');
    if (!vnMobile.hasMatch(normalized)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
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
      case 'MERCHANT_EXISTS':
      case 'ALREADY_MERCHANT':
        return 'Tài khoản đã là cửa hàng';
      case 'TAX_CODE_EXISTS':
        return 'Mã số thuế đã được đăng ký';
      case 'VALIDATION_ERROR':
        return (message != null && message.isNotEmpty) ? message : 'Thông tin đăng ký không hợp lệ';
      default:
        if (message != null && message.isNotEmpty) return message;
        return 'Đăng ký cửa hàng thất bại';
    }
  }
}
