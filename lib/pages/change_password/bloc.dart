import '../../import.dart';

class ChangePasswordState {
  const ChangePasswordState({
    this.oldPassword = '',
    this.oldPasswordError,
    this.obscureOld = true,
    this.newPassword = '',
    this.newPasswordError,
    this.obscureNew = true,
    this.confirmPassword = '',
    this.confirmPasswordError,
    this.obscureConfirm = true,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String oldPassword;
  final String? oldPasswordError;
  final bool obscureOld;
  final String newPassword;
  final String? newPasswordError;
  final bool obscureNew;
  final String confirmPassword;
  final String? confirmPasswordError;
  final bool obscureConfirm;
  final bool isSubmitting;
  final String? errorMessage;

  ChangePasswordState copyWith({
    String? oldPassword,
    String? oldPasswordError,
    bool? obscureOld,
    String? newPassword,
    String? newPasswordError,
    bool? obscureNew,
    String? confirmPassword,
    String? confirmPasswordError,
    bool? obscureConfirm,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return ChangePasswordState(
      oldPassword: oldPassword ?? this.oldPassword,
      oldPasswordError: oldPasswordError,
      obscureOld: obscureOld ?? this.obscureOld,
      newPassword: newPassword ?? this.newPassword,
      newPasswordError: newPasswordError,
      obscureNew: obscureNew ?? this.obscureNew,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      confirmPasswordError: confirmPasswordError,
      obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(const ChangePasswordState());

  final ApiClient _apiClient;

  void setOldPassword(String value) {
    emit(state.copyWith(
      oldPassword: value,
      oldPasswordError: null,
      newPasswordError: state.newPasswordError,
      confirmPasswordError: state.confirmPasswordError,
    ));
  }

  void setNewPassword(String value) {
    emit(state.copyWith(
      newPassword: value,
      oldPasswordError: state.oldPasswordError,
      newPasswordError: null,
      confirmPasswordError: state.confirmPasswordError,
    ));
  }

  void setConfirmPassword(String value) {
    emit(state.copyWith(
      confirmPassword: value,
      oldPasswordError: state.oldPasswordError,
      newPasswordError: state.newPasswordError,
      confirmPasswordError: null,
    ));
  }

  void toggleOldVisibility() {
    emit(state.copyWith(
      obscureOld: !state.obscureOld,
      oldPasswordError: state.oldPasswordError,
      newPasswordError: state.newPasswordError,
      confirmPasswordError: state.confirmPasswordError,
    ));
  }

  void toggleNewVisibility() {
    emit(state.copyWith(
      obscureNew: !state.obscureNew,
      oldPasswordError: state.oldPasswordError,
      newPasswordError: state.newPasswordError,
      confirmPasswordError: state.confirmPasswordError,
    ));
  }

  void toggleConfirmVisibility() {
    emit(state.copyWith(
      obscureConfirm: !state.obscureConfirm,
      oldPasswordError: state.oldPasswordError,
      newPasswordError: state.newPasswordError,
      confirmPasswordError: state.confirmPasswordError,
    ));
  }

  Future<bool> submit() async {
    if (state.isSubmitting) return false;

    final oldPwd = state.oldPassword;
    final newPwd = state.newPassword;
    final confirm = state.confirmPassword;

    final oldError = _validateOld(oldPwd);
    final newError = _validateNew(newPwd, oldPwd);
    final confirmError = _validateConfirm(newPwd, confirm);
    if (oldError != null || newError != null || confirmError != null) {
      emit(state.copyWith(
        oldPasswordError: oldError,
        newPasswordError: newError,
        confirmPasswordError: confirmError,
      ));
      return false;
    }

    emit(state.copyWith(
      isSubmitting: true,
      oldPasswordError: null,
      newPasswordError: null,
      confirmPasswordError: null,
    ));

    try {
      final dio = _apiClient.dio(ApiService.auth);
      await dio.post(
        '/auth/password',
        data: {
          'oldPassword': oldPwd,
          'newPassword': newPwd,
        },
      );
      emit(state.copyWith(isSubmitting: false));
      return true;
    } on DioException catch (e) {
      final msg = _mapError(e);
      emit(state.copyWith(
        isSubmitting: false,
        oldPasswordError: _isWrongOldPassword(e) ? msg : null,
        errorMessage: _isWrongOldPassword(e) ? null : msg,
      ));
      return false;
    } catch (_) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Đổi mật khẩu thất bại',
      ));
      return false;
    }
  }

  static String? _validateOld(String value) {
    if (value.isEmpty) return 'Vui lòng nhập mật khẩu hiện tại';
    return null;
  }

  static String? _validateNew(String password, String oldPassword) {
    if (password.isEmpty) return 'Vui lòng nhập mật khẩu mới';
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
    if (password == oldPassword) {
      return 'Mật khẩu mới phải khác mật khẩu hiện tại';
    }
    return null;
  }

  static String? _validateConfirm(String newPassword, String confirm) {
    if (confirm.isEmpty) return 'Vui lòng nhập lại mật khẩu mới';
    if (confirm != newPassword) return 'Mật khẩu nhập lại không khớp';
    return null;
  }

  bool _isWrongOldPassword(DioException e) {
    final code = _readErrorCode(e);
    return code == 'INVALID_CREDENTIALS' ||
        code == 'WRONG_PASSWORD' ||
        code == 'INVALID_PASSWORD' ||
        code == 'OLD_PASSWORD_INVALID';
  }

  String? _readErrorCode(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final error = data['error'];
      if (error is Map) {
        final c = error['code']?.toString();
        if (c != null && c.isNotEmpty) return c;
      }
      final c = data['code']?.toString() ?? data['errorCode']?.toString();
      if (c != null && c.isNotEmpty) return c;
    }
    return null;
  }

  String _mapError(DioException e) {
    final data = e.response?.data;
    String? message;
    if (data is Map) {
      final error = data['error'];
      if (error is Map) {
        message = error['message']?.toString();
      }
      message ??= data['message']?.toString();
    }
    final code = _readErrorCode(e);
    switch (code) {
      case 'INVALID_CREDENTIALS':
      case 'WRONG_PASSWORD':
      case 'INVALID_PASSWORD':
      case 'OLD_PASSWORD_INVALID':
        return 'Mật khẩu hiện tại không đúng';
      case 'SAME_PASSWORD':
      case 'NEW_PASSWORD_SAME':
        return 'Mật khẩu mới phải khác mật khẩu hiện tại';
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
