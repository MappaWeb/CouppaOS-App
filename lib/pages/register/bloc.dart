import '../../import.dart';

class RegisterState {
  const RegisterState({
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

  RegisterState copyWith({
    String? phone,
    String? password,
    String? phoneError,
    String? passwordError,
    bool? isSubmitting,
    bool? obscurePassword,
    String? errorMessage,
  }) {
    return RegisterState(
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

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(const RegisterState());

  final ApiClient _apiClient;

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

  /// Trả về `true` nếu đăng ký thành công và sẵn sàng chuyển sang màn OTP.
  Future<bool> submit() async {
    if (state.isSubmitting) return false;

    final phone = state.phone.trim();
    final password = state.password;
    final phoneError = _validateVnPhone(phone);
    final passwordError = _validatePassword(password);
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
      await dio.post(
        '/auth/register',
        data: {'phone': phone, 'password': password},
      );
      emit(state.copyWith(isSubmitting: false));
      return true;
    } on DioException catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: _mapError(e)));
      return false;
    } catch (_) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Đăng ký thất bại',
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

  /// Mật khẩu phải đạt đủ 5 tiêu chí hiển thị trong [PasswordValidNoteMap].
  static String? _validatePassword(String password) {
    if (password.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (password.length < 8) return 'Mật khẩu phải có tối thiểu 8 ký tự';
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Mật khẩu cần ít nhất 1 chữ viết hoa';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Mật khẩu cần ít nhất 1 chữ viết thường';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Mật khẩu cần ít nhất 1 chữ số';
    }
    if (!RegExp(r'[!@#\$%\^&*]').hasMatch(password)) {
      return 'Mật khẩu cần ít nhất 1 ký tự đặc biệt';
    }
    return null;
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
      case 'PHONE_EXISTS':
      case 'USER_EXISTS':
      case 'USER_ALREADY_EXISTS':
        return 'Số điện thoại đã được đăng ký';
      case 'VALIDATION_ERROR':
        return (message != null && message.isNotEmpty)
            ? message
            : 'Thông tin đăng ký không hợp lệ';
      default:
        if (message != null && message.isNotEmpty) return message;
        return 'Đăng ký thất bại';
    }
  }
}
