import 'dart:async';

import '../../import.dart';

class OtpState {
  const OtpState({
    this.code = '',
    this.codeError,
    this.isSubmitting = false,
    this.isResending = false,
    this.secondsLeft = 0,
    this.isHardBlocked = false,
    this.errorMessage,
  });

  final String code;
  final String? codeError;
  final bool isSubmitting;
  final bool isResending;
  final int secondsLeft;
  final bool isHardBlocked;
  final String? errorMessage;

  bool get canResend =>
      secondsLeft <= 0 && !isResending && !isHardBlocked;

  OtpState copyWith({
    String? code,
    String? codeError,
    bool? isSubmitting,
    bool? isResending,
    int? secondsLeft,
    bool? isHardBlocked,
    String? errorMessage,
  }) {
    return OtpState(
      code: code ?? this.code,
      codeError: codeError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isResending: isResending ?? this.isResending,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      isHardBlocked: isHardBlocked ?? this.isHardBlocked,
      errorMessage: errorMessage,
    );
  }
}

class OtpCubit extends Cubit<OtpState> {
  OtpCubit({
    required this._apiClient,
    required this._authSetup,
    required this._phone,
    required this._password,
  })  : super(const OtpState());

  static const _otpLength = 6;
  static const _defaultCountdownSeconds = 60;

  final ApiClient _apiClient;
  final AuthSetup _authSetup;
  final String _phone;
  final String _password;

  Timer? _timer;

  void start() {
    _sendOtp(initial: true);
  }

  void setCode(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final code = digits.length > _otpLength
        ? digits.substring(0, _otpLength)
        : digits;
    emit(state.copyWith(code: code, codeError: null));
  }

  void _startCountdown([int seconds = _defaultCountdownSeconds]) {
    _timer?.cancel();
    if (seconds <= 0) {
      emit(state.copyWith(secondsLeft: 0));
      return;
    }
    emit(state.copyWith(secondsLeft: seconds));
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final next = state.secondsLeft - 1;
      if (next <= 0) {
        t.cancel();
        emit(state.copyWith(secondsLeft: 0));
      } else {
        emit(state.copyWith(secondsLeft: next));
      }
    });
  }

  Future<void> _sendOtp({bool initial = false}) async {
    if (state.isResending) return;
    emit(state.copyWith(isResending: true));
    try {
      final dio = _apiClient.dio(ApiService.auth);
      await dio.post('/auth/otp/send', data: {'phone': _phone});
      emit(state.copyWith(isResending: false));
      _startCountdown();
      if (!initial) showMessage('Đã gửi lại mã xác thực', type: 'success');
    } on DioException catch (e) {
      final wait = _parseRiskBlockedSeconds(e);
      final hardBlocked = wait != null && wait >= 3600;
      emit(state.copyWith(
        isResending: false,
        isHardBlocked: hardBlocked,
        errorMessage: _mapError(e),
      ));
      if (wait != null) {
        _startCountdown(wait);
      } else if (initial) {
        _startCountdown();
      }
    } catch (_) {
      emit(state.copyWith(
        isResending: false,
        errorMessage: initial ? 'Gửi mã thất bại' : 'Gửi lại mã thất bại',
      ));
      if (initial) _startCountdown();
    }
  }

  /// Parse phần thời gian chờ trong message RISK_BLOCKED, ví dụ:
  ///  - "Vui lòng đợi 53 giây trước khi lấy mã mới." -> 53
  ///  - "... thử lại sau 6 giờ." -> 21600
  int? _parseRiskBlockedSeconds(DioException e) {
    final data = e.response?.data;
    if (data is! Map) return null;
    final error = data['error'];
    if (error is! Map) return null;
    if (error['code']?.toString() != 'RISK_BLOCKED') return null;
    final message = error['message']?.toString();
    if (message == null || message.isEmpty) return null;

    final hr = RegExp(r'(\d+)\s*giờ').firstMatch(message);
    final min = RegExp(r'(\d+)\s*phút').firstMatch(message);
    final sec = RegExp(r'(\d+)\s*giây').firstMatch(message);
    if (hr == null && min == null && sec == null) return null;

    final total = (int.tryParse(hr?.group(1) ?? '0') ?? 0) * 3600 +
        (int.tryParse(min?.group(1) ?? '0') ?? 0) * 60 +
        (int.tryParse(sec?.group(1) ?? '0') ?? 0);
    return total > 0 ? total : null;
  }

  /// Xác thực OTP (kích hoạt tài khoản) rồi tự đăng nhập để lấy token.
  /// `/auth/otp/verify` chỉ trả `{status:"ACTIVE"}` (không có token), nên cần
  /// gọi tiếp `/auth/login` bằng SĐT + mật khẩu đã đăng ký.
  Future<bool> verify() async {
    if (state.isSubmitting) return false;

    final code = state.code.trim();
    if (code.length != _otpLength) {
      emit(state.copyWith(codeError: 'Vui lòng nhập đủ $_otpLength chữ số'));
      return false;
    }

    emit(state.copyWith(isSubmitting: true, codeError: null));

    final dio = _apiClient.dio(ApiService.auth);
    try {
      await dio.post(
        '/auth/otp/verify',
        data: {'phone': _phone, 'code': code},
      );
    } on DioException catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: _mapError(e)));
      return false;
    } catch (_) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Xác thực thất bại',
      ));
      return false;
    }

    try {
      final res = await dio.post(
        '/auth/login',
        data: {'phone': _phone, 'password': _password},
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
    } on DioException catch (_) {
      // Tài khoản đã kích hoạt nhưng auto-login lỗi → để user tự đăng nhập.
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Xác thực thành công. Vui lòng đăng nhập lại.',
      ));
      return false;
    } catch (_) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Xác thực thành công. Vui lòng đăng nhập lại.',
      ));
      return false;
    }
  }

  Future<void> resend() async {
    if (!state.canResend) return;
    await _sendOtp();
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
    if (code == 'VALIDATION_ERROR') {
      final msg = message ?? '';
      if (msg.contains('TOO_MANY')) {
        return 'Bạn đã nhập sai quá nhiều lần, vui lòng thử lại sau';
      }
      if (msg.contains('MISMATCH')) {
        return 'Mã xác thực không đúng, vui lòng kiểm tra lại';
      }
      return 'Mã xác thực không đúng hoặc đã hết hạn';
    }
    switch (code) {
      case 'RISK_BLOCKED':
        return message ?? 'Yêu cầu tạm thời bị chặn, vui lòng thử lại sau';
      default:
        if (message != null && message.isNotEmpty) return message;
        return 'Xác thực thất bại';
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
