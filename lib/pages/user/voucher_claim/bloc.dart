import '../../../import.dart';

enum VoucherClaimMode { manual, qr }

class VoucherClaimSummary {
  const VoucherClaimSummary({required this.success, required this.total});

  final int success;
  final int total;
}

class VoucherClaimDialog {
  const VoucherClaimDialog({
    required this.code,
    required this.success,
    this.message,
  });

  final String code;
  final bool success;
  final String? message;
}

class VoucherClaimState {
  const VoucherClaimState({
    this.mode = VoucherClaimMode.manual,
    this.input = '',
    this.isProcessing = false,
    this.qrPaused = false,
    this.summary,
    this.dialog,
  });

  final VoucherClaimMode mode;
  final String input;
  final bool isProcessing;

  /// User đã bấm "Huỷ" sau khi quét → giữ ở QR mode nhưng không quét tiếp,
  /// đợi user tap "Quét tiếp" để resume.
  final bool qrPaused;
  final VoucherClaimSummary? summary;
  final VoucherClaimDialog? dialog;

  VoucherClaimState copyWith({
    VoucherClaimMode? mode,
    String? input,
    bool? isProcessing,
    bool? qrPaused,
    VoucherClaimSummary? summary,
    VoucherClaimDialog? dialog,
    bool clearSummary = false,
    bool clearDialog = false,
  }) {
    return VoucherClaimState(
      mode: mode ?? this.mode,
      input: input ?? this.input,
      isProcessing: isProcessing ?? this.isProcessing,
      qrPaused: qrPaused ?? this.qrPaused,
      summary: clearSummary ? null : (summary ?? this.summary),
      dialog: clearDialog ? null : (dialog ?? this.dialog),
    );
  }
}

/// Cubit cho luồng "Nhận voucher".
///
/// Theo convention dự án (xem `AccountProfileBloc`): gọi API trực tiếp qua
/// `ApiClient.dio(ApiService.X)` ngay trong bloc, bắt `DioException` và map
/// về state — không dùng lớp DataSource trung gian cho call đơn lẻ.
///
/// Endpoint là **absolute URL** (`AppApi.voucher.campaignByCode`), Dio bypass
/// baseUrl của `ApiService.coupon` nhưng vẫn áp dụng interceptors (auth /
/// logger / error) đã cài trên `ApiClient`.
class VoucherClaimCubit extends Cubit<VoucherClaimState> {
  VoucherClaimCubit({required ApiClient apiClient})
    : _apiClient = apiClient,
      super(const VoucherClaimState());

  final ApiClient _apiClient;

  static final _splitter = RegExp(r'[\s,]+');

  void switchMode(VoucherClaimMode mode) {
    if (state.isProcessing || state.mode == mode) return;
    emit(state.copyWith(mode: mode, qrPaused: false, clearDialog: true));
  }

  /// User bấm "Huỷ" ở dialog → đóng dialog, scanner KHÔNG quét tiếp.
  void pauseQr() {
    emit(state.copyWith(qrPaused: true, clearDialog: true));
  }

  /// User bấm "Tiếp tục quét" hoặc tap khi đang pause → resume.
  void resumeQr() {
    emit(state.copyWith(qrPaused: false, clearDialog: true));
  }

  void setInput(String value) {
    emit(state.copyWith(input: value));
  }

  List<String> _parseCodes(String raw) {
    final seen = <String>{};
    final out = <String>[];
    for (final token in raw.split(_splitter)) {
      final t = token.trim();
      if (t.isEmpty) continue;
      if (seen.add(t)) out.add(t);
    }
    return out;
  }

  /// GET `/campaigns/by-code/{code}` — 2xx = nhận thành công.
  Future<({bool success, String? message})> _claim(String code) async {
    try {
      final res = await _apiClient
          .dio(ApiService.coupon)
          .get(AppApi.voucher.campaignByCode(code));
      final ok = (res.statusCode ?? 0) >= 200 && (res.statusCode ?? 0) < 300;
      return (success: ok, message: null);
    } on DioException catch (e) {
      return (success: false, message: _mapError(e));
    } catch (_) {
      return (success: false, message: null);
    }
  }

  static String? _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message'] ?? data['error'] ?? data['detail'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return e.message;
  }

  Future<void> submitManual() async {
    if (state.isProcessing) return;
    final codes = _parseCodes(state.input);
    if (codes.isEmpty) return;

    emit(state.copyWith(isProcessing: true, clearSummary: true));

    var success = 0;
    for (final code in codes) {
      final res = await _claim(code);
      if (res.success) success++;
    }

    emit(
      state.copyWith(
        isProcessing: false,
        input: '',
        summary: VoucherClaimSummary(success: success, total: codes.length),
      ),
    );
  }

  Future<void> onQrDetected(String code) async {
    if (state.isProcessing) return;
    emit(state.copyWith(isProcessing: true, clearDialog: true));
    final res = await _claim(code);
    emit(
      state.copyWith(
        isProcessing: false,
        dialog: VoucherClaimDialog(
          code: code,
          success: res.success,
          message: res.message,
        ),
      ),
    );
  }

  /// Snackbar summary đã hiển thị, xóa để listener không trigger lại.
  void consumeSummary() {
    if (state.summary == null) return;
    emit(state.copyWith(clearSummary: true));
  }
}
