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
    this.campaignName,
    this.merchantName,
  });

  final String code;
  final bool success;
  final String? message;
  final String? campaignName;
  final String? merchantName;
}

class VoucherClaimState {
  const VoucherClaimState({
    this.mode = VoucherClaimMode.manual,
    this.input = '',
    this.isProcessing = false,
    this.qrPaused = false,
    this.summary,
    this.dialog,
    this.pendingCampaign,
  });

  final VoucherClaimMode mode;
  final String input;
  final bool isProcessing;

  /// User đã bấm "Huỷ" sau khi quét → giữ ở QR mode nhưng không quét tiếp,
  /// đợi user tap "Quét tiếp" để resume.
  final bool qrPaused;
  final VoucherClaimSummary? summary;
  final VoucherClaimDialog? dialog;

  /// Quét QR + `by-code` thành công → dữ liệu campaign cần điều hướng sang màn
  /// claim. Page lắng nghe field này để `pushNamed` rồi gọi [consumePendingCampaign].
  final Map? pendingCampaign;

  VoucherClaimState copyWith({
    VoucherClaimMode? mode,
    String? input,
    bool? isProcessing,
    bool? qrPaused,
    VoucherClaimSummary? summary,
    VoucherClaimDialog? dialog,
    Map? pendingCampaign,
    bool clearSummary = false,
    bool clearDialog = false,
    bool clearPendingCampaign = false,
  }) {
    return VoucherClaimState(
      mode: mode ?? this.mode,
      input: input ?? this.input,
      isProcessing: isProcessing ?? this.isProcessing,
      qrPaused: qrPaused ?? this.qrPaused,
      summary: clearSummary ? null : (summary ?? this.summary),
      dialog: clearDialog ? null : (dialog ?? this.dialog),
      pendingCampaign: clearPendingCampaign
          ? null
          : (pendingCampaign ?? this.pendingCampaign),
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

  /// QR voucher có thể chứa URL dạng `https://qr.iotcommunication.net/r/NBSPSCLKBFTH`.
  /// Lấy code ở path segment cuối (sau `/r/`). Nếu không phải URL hợp lệ thì
  /// coi như giá trị đã là code thuần và trả về nguyên trạng (đã trim).
  static String parseQrCode(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return value;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) return value;
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return value;
    return segments.last;
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

  /// 1) GET `/campaigns/by-code/{code}` để lấy `campaignId` + thông tin hiển thị.
  /// 2) POST `/vouchers/claims` với body `{"campaignId": ...}` để nhận voucher.
  /// Cả hai đều 2xx mới coi là thành công; khi đó tick `voucherWalletDirty`
  /// để tab "Coupon của tôi" tự refresh.
  Future<
    ({bool success, String? message, String? campaignName, String? merchantName})
  >
  _claim(String code) async {
    try {
      final lookup = await _apiClient
          .dio(ApiService.coupon)
          .get(AppApi.voucher.campaignByCode(code));
      final lookupOk =
          (lookup.statusCode ?? 0) >= 200 && (lookup.statusCode ?? 0) < 300;
      if (!lookupOk) {
        return (
          success: false,
          message: null,
          campaignName: null,
          merchantName: null,
        );
      }

      final data = lookup.data is Map ? lookup.data as Map : const {};
      final campaignId = data['id'] as String?;
      final campaignName = data['name'] as String?;
      final merchantName = data['merchantName'] as String?;
      if (campaignId == null || campaignId.isEmpty) {
        return (
          success: false,
          message: null,
          campaignName: campaignName,
          merchantName: merchantName,
        );
      }

      final claim = await _apiClient
          .dio(ApiService.coupon)
          .post(
            AppApi.voucher.voucherClaims,
            data: {'campaignId': campaignId},
          );
      final claimOk =
          (claim.statusCode ?? 0) >= 200 && (claim.statusCode ?? 0) < 300;
      if (claimOk) markVoucherWalletDirty();
      return (
        success: claimOk,
        message: null,
        campaignName: campaignName,
        merchantName: merchantName,
      );
    } on DioException catch (e) {
      return (
        success: false,
        message: _mapError(e),
        campaignName: null,
        merchantName: null,
      );
    } catch (_) {
      return (
        success: false,
        message: null,
        campaignName: null,
        merchantName: null,
      );
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

  /// Chỉ tra cứu campaign theo code (`GET /campaigns/by-code/{code}`), KHÔNG
  /// claim. Thành công → trả về Map dữ liệu campaign để điều hướng sang màn claim.
  Future<({bool success, String? message, Map? data})> _lookupCampaign(
    String code,
  ) async {
    try {
      final res = await _apiClient
          .dio(ApiService.coupon)
          .get(AppApi.voucher.campaignByCode(code));
      final ok = (res.statusCode ?? 0) >= 200 && (res.statusCode ?? 0) < 300;
      final data = res.data is Map ? res.data as Map : null;
      if (!ok || data == null || (data['id'] ?? '').toString().isEmpty) {
        return (success: false, message: null, data: null);
      }
      return (success: true, message: null, data: data);
    } on DioException catch (e) {
      return (success: false, message: _mapError(e), data: null);
    } catch (_) {
      return (success: false, message: null, data: null);
    }
  }

  /// Quét QR → parse code → tra cứu by-code. Thành công thì set [pendingCampaign]
  /// để page điều hướng sang màn claim; thất bại thì hiện dialog lỗi, giữ ở scanner.
  Future<void> onQrDetected(String raw) async {
    if (state.isProcessing) return;
    final code = parseQrCode(raw);
    if (code.isEmpty) return;
    emit(state.copyWith(isProcessing: true, clearDialog: true));
    final res = await _lookupCampaign(code);
    if (res.success && res.data != null) {
      emit(state.copyWith(isProcessing: false, pendingCampaign: res.data));
    } else {
      emit(
        state.copyWith(
          isProcessing: false,
          dialog: VoucherClaimDialog(
            code: code,
            success: false,
            message: res.message,
          ),
        ),
      );
    }
  }

  /// Page đã điều hướng sang màn claim → xoá tín hiệu để không trigger lại.
  void consumePendingCampaign() {
    if (state.pendingCampaign == null) return;
    emit(state.copyWith(clearPendingCampaign: true));
  }

  /// Snackbar summary đã hiển thị, xóa để listener không trigger lại.
  void consumeSummary() {
    if (state.summary == null) return;
    emit(state.copyWith(clearSummary: true));
  }
}
