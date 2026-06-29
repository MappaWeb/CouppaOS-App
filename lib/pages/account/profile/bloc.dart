import '../../../import.dart';

/// Form xem & cập nhật thông tin cá nhân — PATCH `/auth/me` (identity service).
///
/// Field keys: `phoneNumber` (read-only), `displayName`, `address`. Khi submit
/// chỉ gửi field nào khác giá trị ban đầu; nếu không có thay đổi nào, vẫn pop
/// nhưng không gọi API.
class AccountProfileBloc extends SystemFormBloc<SystemFormState> {
  AccountProfileBloc({
    required ApiClient apiClient,
    required AuthSetup authSetup,
  }) : this._(apiClient, authSetup, currentUser);

  AccountProfileBloc._(this._apiClient, this._authSetup, MeUser? me)
    : _initialDisplayName = me?.displayName ?? '',
      _initialAddress = me?.address ?? '',
      super(
        query: FormQuery(
          initialFields: {
            'phoneNumber': me?.phoneNumber ?? '',
            'displayName': me?.displayName ?? '',
            'address': me?.address ?? '',
          },
        ),
      );

  final ApiClient _apiClient;
  final AuthSetup _authSetup;
  final String _initialDisplayName;
  final String _initialAddress;

  @override
  Future<void> onSubmit(
    Emitter emit, {
    Map<String, dynamic>? extraParams,
    Map<String, dynamic>? extraFields,
  }) async {
    final me = currentUser;
    if (me == null) {
      emit(state.copyWith(
        status: SystemFormStateStatus.fail,
        message: 'Phiên đăng nhập không hợp lệ',
      ));
      return;
    }

    final newDisplayName =
        (state.fields['displayName'] as String?)?.trim() ?? '';
    final newAddress = (state.fields['address'] as String?)?.trim() ?? '';

    final payload = <String, dynamic>{};
    if (newDisplayName != _initialDisplayName) {
      payload['displayName'] = newDisplayName;
    }
    if (newAddress != _initialAddress) {
      payload['address'] = newAddress;
    }

    if (payload.isEmpty) {
      await onSuccess(const {'status': 'SUCCESS', 'noop': '1'}, emit);
      return;
    }

    try {
      await _apiClient.dio(ApiService.auth).patch('/auth/me', data: payload);
    } on DioException catch (e) {
      emit(state.copyWith(
        status: SystemFormStateStatus.fail,
        message: _mapError(e),
      ));
      return;
    } catch (_) {
      emit(state.copyWith(
        status: SystemFormStateStatus.fail,
        message: 'Cập nhật thông tin thất bại',
      ));
      return;
    }

    _authSetup.authSessionBloc.add(
      SessionUserUpdated(
        MeUser(
          id: me.id,
          username: me.username,
          fullName: me.fullName,
          displayName: payload.containsKey('displayName')
              ? newDisplayName
              : me.displayName,
          email: me.email,
          role: me.role,
          phoneNumber: me.phoneNumber,
          avatarUrl: me.avatarUrl,
          status: me.status,
          isVerified: me.isVerified,
          mfaEnabled: me.mfaEnabled,
          isSupportStaff: me.isSupportStaff,
          locale: me.locale,
          metadata: me.metadata,
          address: payload.containsKey('address') ? newAddress : me.address,
          provinceId: me.provinceId,
          departmentIds: me.departmentIds,
        ),
      ),
    );

    await onSuccess(const {'status': 'SUCCESS'}, emit);
  }

  static String _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return 'Cập nhật thông tin thất bại';
  }
}
