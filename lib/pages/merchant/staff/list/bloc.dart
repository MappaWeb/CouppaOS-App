import '../../../../import.dart';

/// BLoC danh sách nhân viên — GET /merchants/me/staff (api-qr domain).
class MerchantStaffListBloc extends SystemListBloc<SystemListState<Map>, Map> {
  MerchantStaffListBloc()
      : super(dataSource: ApiService.merchant.apiPath(AppApi.partner.staff));
}

// ═══════════════════════════════════════════════════════════════════
// Action cubit — thu hồi nhân viên
// ═══════════════════════════════════════════════════════════════════

enum StaffActionStatus { idle, submitting, success, fail }

class MerchantStaffActionState {
  const MerchantStaffActionState({
    this.status = StaffActionStatus.idle,
    this.message,
  });

  final StaffActionStatus status;
  final String? message;

  bool get isSubmitting => status == StaffActionStatus.submitting;
  bool get isSuccess => status == StaffActionStatus.success;
  bool get isFail => status == StaffActionStatus.fail;

  MerchantStaffActionState copyWith({
    StaffActionStatus? status,
    String? message,
    bool clearMessage = false,
  }) {
    return MerchantStaffActionState(
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

class MerchantStaffActionCubit extends Cubit<MerchantStaffActionState> {
  MerchantStaffActionCubit({required ApiClient apiClient})
      : this._(apiClient);

  MerchantStaffActionCubit._(this._apiClient) : super(const MerchantStaffActionState());

  final ApiClient _apiClient;

  /// DELETE /merchants/me/staff/{id} — Thu hồi nhân viên.
  Future<void> revoke(String id) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(status: StaffActionStatus.submitting, clearMessage: true));
    try {
      await _apiClient.dio(ApiService.merchant).delete(AppApi.partner.staffById(id));
      emit(state.copyWith(
        status: StaffActionStatus.success,
        message: 'Đã thu hồi nhân viên',
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        status: StaffActionStatus.fail,
        message: _extractError(e),
      ));
    }
  }

  void reset() => emit(const MerchantStaffActionState());

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return 'Thu hồi nhân viên thất bại';
  }
}
