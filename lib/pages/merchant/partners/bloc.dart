import '../../../import.dart';

/// Danh sách đối tác đã liên kết.
/// Endpoint: `GET /merchants/me/partners` (api-qr domain).
class MerchantPartnersBloc extends SystemListBloc<SystemListState<Map>, Map> {
  MerchantPartnersBloc() : super(dataSource: ApiService.merchant.apiPath(AppApi.partner.partners));
}

/// Danh sách yêu cầu liên kết (cả incoming + outgoing).
/// Endpoint: `GET /merchants/me/links` (api-qr domain).
class MerchantLinksBloc extends SystemListBloc<SystemListState<Map>, Map> {
  MerchantLinksBloc() : super(dataSource: ApiService.merchant.apiPath(AppApi.partner.links));
}

// ═══════════════════════════════════════════════════════════════════
// Action cubit — gửi yêu cầu liên kết + phản hồi yêu cầu
// ═══════════════════════════════════════════════════════════════════

enum PartnerActionStatus { idle, submitting, success, fail }

enum PartnerActionKind { send, accept, reject }

class PartnerActionState {
  const PartnerActionState({this.status = PartnerActionStatus.idle, this.kind, this.message});

  final PartnerActionStatus status;
  final PartnerActionKind? kind;
  final String? message;

  bool get isSubmitting => status == PartnerActionStatus.submitting;

  PartnerActionState copyWith({
    PartnerActionStatus? status,
    PartnerActionKind? kind,
    String? message,
    bool clearMessage = false,
  }) {
    return PartnerActionState(
      status: status ?? this.status,
      kind: kind ?? this.kind,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

class PartnerActionCubit extends Cubit<PartnerActionState> {
  PartnerActionCubit({required this._apiClient}) : super(const PartnerActionState());

  final ApiClient _apiClient;

  /// POST /merchants/me/links — body `{"partnerPhone": "..."}`.
  Future<void> sendRequest(String phone) async {
    if (state.isSubmitting) return;
    emit(
      state.copyWith(
        status: PartnerActionStatus.submitting,
        kind: PartnerActionKind.send,
        clearMessage: true,
      ),
    );
    try {
      await _apiClient
          .dio(ApiService.merchant)
          .post(AppApi.partner.links, data: {'partnerPhone': phone});
      emit(
        state.copyWith(
          status: PartnerActionStatus.success,
          kind: PartnerActionKind.send,
          message: 'Đã gửi yêu cầu liên kết',
        ),
      );
    } on DioException catch (e) {
      emit(
        state.copyWith(
          status: PartnerActionStatus.fail,
          kind: PartnerActionKind.send,
          message: _extractError(e) ?? 'Gửi yêu cầu thất bại',
        ),
      );
    }
  }

  /// POST /merchants/me/links/{id}/respond — body `{"accept": bool}`.
  Future<void> respond({required String linkId, required bool accept}) async {
    if (state.isSubmitting) return;
    final kind = accept ? PartnerActionKind.accept : PartnerActionKind.reject;
    emit(state.copyWith(status: PartnerActionStatus.submitting, kind: kind, clearMessage: true));
    try {
      await _apiClient
          .dio(ApiService.merchant)
          .post(AppApi.partner.linkRespond(linkId), data: {'accept': accept});
      emit(
        state.copyWith(
          status: PartnerActionStatus.success,
          kind: kind,
          message: accept ? 'Đã duyệt yêu cầu' : 'Đã từ chối yêu cầu',
        ),
      );
    } on DioException catch (e) {
      emit(
        state.copyWith(
          status: PartnerActionStatus.fail,
          kind: kind,
          message: _extractError(e) ?? 'Phản hồi thất bại',
        ),
      );
    }
  }

  void reset() => emit(const PartnerActionState());

  String? _extractError(DioException e) {
    final data = e.response?.data;
    print('------$data');
    if (data is Map) {
      final msg = data['message'] ?? '';
      if (msg is String && msg.isNotEmpty) return msg;
    }
    if (data['error'] is Map) {
      final msg = data['error']['message'] ?? '';
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return e.message;
  }
}
