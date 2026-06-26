import '../../import.dart';

class LoginState {
  const LoginState({
    this.phone = '',
    this.password = '',
    this.phoneError,
    this.passwordError,
    this.isSubmitting = false,
    this.obscurePassword = true,
    this.errorMessage,
  });

  final String phone;
  final String password;
  final String? phoneError;
  final String? passwordError;
  final bool isSubmitting;
  final bool obscurePassword;
  final String? errorMessage;

  LoginState copyWith({
    String? phone,
    String? password,
    String? phoneError,
    String? passwordError,
    bool? isSubmitting,
    bool? obscurePassword,
    String? errorMessage,
  }) {
    return LoginState(
      phone: phone ?? this.phone,
      password: password ?? this.password,
      phoneError: phoneError,
      passwordError: passwordError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      errorMessage: errorMessage,
    );
  }
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required ApiClient apiClient, required AuthSetup authSetup})
      : _apiClient = apiClient,
        _authSetup = authSetup,
        super(const LoginState());

  final ApiClient _apiClient;
  final AuthSetup _authSetup;

  void setPhone(String value) {
    emit(state.copyWith(
      phone: value,
      phoneError: null,
      passwordError: state.passwordError,
    ));
  }

  void setPassword(String value) {
    emit(state.copyWith(
      password: value,
      phoneError: state.phoneError,
      passwordError: null,
    ));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(
      obscurePassword: !state.obscurePassword,
      phoneError: state.phoneError,
      passwordError: state.passwordError,
    ));
  }

  Future<bool> submit() async {
    if (state.isSubmitting) return false;

    final phone = state.phone.trim();
    final password = state.password;
    final phoneError = _validateVnPhone(phone);
    final passwordError = password.isEmpty ? 'Vui lòng nhập mật khẩu' : null;
    if (phoneError != null || passwordError != null) {
      emit(state.copyWith(
        phoneError: phoneError,
        passwordError: passwordError,
      ));
      return false;
    }

    emit(state.copyWith(
      isSubmitting: true,
      phoneError: null,
      passwordError: null,
    ));

    try {
      final dio = _apiClient.dio(ApiService.auth);
      final res = await dio.post(
        '/auth/login',
        data: {'phone': phone, 'password': password},
      );

      final raw = res.data;
      if (raw is! Map) {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: 'Phản hồi không hợp lệ từ máy chủ',
        ));
        return false;
      }
      final body = raw.cast<String, dynamic>();
      await _authSetup.repository.persistTokensFromAuthResponseBody(body);

      final session = await _authSetup.repository.getMe();
      if (session == null) {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: 'Không lấy được thông tin tài khoản',
        ));
        return false;
      }

      await _authSetup.repository.saveCachedSession(session);
      _authSetup.authSessionBloc.add(LoggedIn(session.asSharedUser()));

      emit(state.copyWith(isSubmitting: false));
      return true;
    } on DioException catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: _mapError(e)));
      return false;
    } catch (_) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Đăng nhập thất bại',
      ));
      return false;
    }
  }

  /// Validate số điện thoại Việt Nam.
  /// Hợp lệ: 10 số bắt đầu bằng 0 + đầu số di động 3/5/7/8/9, hoặc tiền tố +84/84.
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

  String _mapError(DioException e) {
    final data = e.response?.data;
    String? code;
    String? message;
    if (data is Map) {
      // BE bọc lỗi trong `{ error: { code, message, ... } }`.
      final error = data['error'];
      if (error is Map) {
        code = error['code']?.toString();
        message = error['message']?.toString();
      }
      code ??= data['code']?.toString() ?? data['errorCode']?.toString();
      message ??= data['message']?.toString();
    }
    switch (code) {
      case 'OTP_REQUIRED':
        return 'Tài khoản cần xác thực OTP trước khi đăng nhập';
      case 'VALIDATION_ERROR':
        return (message != null && message.isNotEmpty)
            ? message
            : 'Số điện thoại hoặc mật khẩu không hợp lệ';
      case 'INVALID_CREDENTIALS':
      case 'WRONG_PASSWORD':
        return 'Sai số điện thoại hoặc mật khẩu';
      case 'USER_NOT_FOUND':
        return 'Tài khoản không tồn tại';
      case 'ACCOUNT_LOCKED':
        return 'Tài khoản đã bị khóa';
      default:
        if (message != null && message.isNotEmpty) return message;
        return 'Đăng nhập thất bại';
    }
  }
}
