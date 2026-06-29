import '../../import.dart';

enum ForgotPasswordStep { phone, reset }

class ForgotPasswordState {
  const ForgotPasswordState({
    this.step = ForgotPasswordStep.phone,
    this.phone = '',
    this.phoneError,
    this.code = '',
    this.codeError,
    this.password = '',
    this.passwordError,
    this.obscurePassword = true,
    this.confirmPassword = '',
    this.confirmPasswordError,
    this.obscureConfirm = true,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final ForgotPasswordStep step;
  final String phone;
  final String? phoneError;
  final String code;
  final String? codeError;
  final String password;
  final String? passwordError;
  final bool obscurePassword;
  final String confirmPassword;
  final String? confirmPasswordError;
  final bool obscureConfirm;
  final bool isSubmitting;
  final String? errorMessage;

  ForgotPasswordState copyWith({
    ForgotPasswordStep? step,
    String? phone,
    String? phoneError,
    String? code,
    String? codeError,
    String? password,
    String? passwordError,
    bool? obscurePassword,
    String? confirmPassword,
    String? confirmPasswordError,
    bool? obscureConfirm,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return ForgotPasswordState(
      step: step ?? this.step,
      phone: phone ?? this.phone,
      phoneError: phoneError,
      code: code ?? this.code,
      codeError: codeError,
      password: password ?? this.password,
      passwordError: passwordError,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      confirmPasswordError: confirmPasswordError,
      obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(const ForgotPasswordState());

  static const _otpLength = 6;

  final ApiClient _apiClient;

  void setPhone(String value) {
    emit(state.copyWith(
      phone: value,
      phoneError: null,
    ));
  }

  void setCode(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final code = digits.length > _otpLength
        ? digits.substring(0, _otpLength)
        : digits;
    emit(state.copyWith(
      code: code,
      codeError: null,
      passwordError: state.passwordError,
      confirmPasswordError: state.confirmPasswordError,
    ));
  }

  void setPassword(String value) {
    emit(state.copyWith(
      password: value,
      codeError: state.codeError,
      passwordError: null,
      confirmPasswordError: state.confirmPasswordError,
    ));
  }

  void setConfirmPassword(String value) {
    emit(state.copyWith(
      confirmPassword: value,
      codeError: state.codeError,
      passwordError: state.passwordError,
      confirmPasswordError: null,
    ));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(
      obscurePassword: !state.obscurePassword,
      codeError: state.codeError,
      passwordError: state.passwordError,
      confirmPasswordError: state.confirmPasswordError,
    ));
  }

  void toggleConfirmVisibility() {
    emit(state.copyWith(
      obscureConfirm: !state.obscureConfirm,
      codeError: state.codeError,
      passwordError: state.passwordError,
      confirmPasswordError: state.confirmPasswordError,
    ));
  }

  /// Quay về step nhập số điện thoại (giữ nguyên dữ liệu đã nhập).
  void backToPhoneStep() {
    emit(state.copyWith(
      step: ForgotPasswordStep.phone,
      codeError: null,
      passwordError: null,
      confirmPasswordError: null,
    ));
  }

  /// Step 1: gửi yêu cầu OTP. Trả `true` nếu thành công (đã chuyển sang step reset).
  Future<bool> requestOtp() async {
    if (state.isSubmitting) return false;

    final phone = state.phone.trim();
    final phoneError = _validateVnPhone(phone);
    if (phoneError != null) {
      emit(state.copyWith(phoneError: phoneError));
      return false;
    }

    emit(state.copyWith(isSubmitting: true, phoneError: null));

    try {
      final dio = _apiClient.dio(ApiService.auth);
      await dio.post(
        '/auth/forgot-password',
        data: {'phone': phone},
      );
      emit(state.copyWith(
        isSubmitting: false,
        step: ForgotPasswordStep.reset,
      ));
      return true;
    } on DioException catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: _mapError(e)));
      return false;
    } catch (_) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gửi mã xác thực thất bại',
      ));
      return false;
    }
  }

  /// Step 2: xác nhận OTP + đặt lại mật khẩu. Trả `true` nếu thành công.
  Future<bool> submitReset() async {
    if (state.isSubmitting) return false;

    final code = state.code.trim();
    final password = state.password;
    final confirm = state.confirmPassword;

    final codeError = _validateCode(code);
    final passwordError = _validatePassword(password);
    final confirmError = _validateConfirm(password, confirm);
    if (codeError != null || passwordError != null || confirmError != null) {
      emit(state.copyWith(
        codeError: codeError,
        passwordError: passwordError,
        confirmPasswordError: confirmError,
      ));
      return false;
    }

    emit(state.copyWith(
      isSubmitting: true,
      codeError: null,
      passwordError: null,
      confirmPasswordError: null,
    ));

    try {
      final dio = _apiClient.dio(ApiService.auth);
      await dio.post(
        '/auth/reset-password',
        data: {
          'phone': state.phone.trim(),
          'code': code,
          'password': password,
        },
      );
      emit(state.copyWith(isSubmitting: false));
      return true;
    } on DioException catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: _mapError(e)));
      return false;
    } catch (_) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Đặt lại mật khẩu thất bại',
      ));
      return false;
    }
  }

  /// Validate số điện thoại Việt Nam (đồng nhất với Login/Register).
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

  /// Mật khẩu — cùng tiêu chí với Register.
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

  static String? _validateCode(String code) {
    if (code.isEmpty) return 'Vui lòng nhập mã xác thực';
    if (code.length != _otpLength) {
      return 'Mã xác thực phải có đủ $_otpLength chữ số';
    }
    return null;
  }

  static String? _validateConfirm(String password, String confirm) {
    if (confirm.isEmpty) return 'Vui lòng nhập lại mật khẩu';
    if (confirm != password) return 'Mật khẩu nhập lại không khớp';
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
      case 'USER_NOT_FOUND':
        return 'Số điện thoại chưa được đăng ký';
      case 'INVALID_OTP':
      case 'OTP_INVALID':
        return 'Mã xác thực không đúng';
      case 'OTP_EXPIRED':
        return 'Mã xác thực đã hết hạn';
      case 'RATE_LIMITED':
      case 'TOO_MANY_REQUESTS':
        return 'Bạn thao tác quá nhanh, vui lòng thử lại sau';
      case 'VALIDATION_ERROR':
        return (message != null && message.isNotEmpty)
            ? message
            : 'Thông tin không hợp lệ';
      default:
        if (message != null && message.isNotEmpty) return message;
        return 'Đã xảy ra lỗi, vui lòng thử lại';
    }
  }
}
