import '../../../../import.dart';

/// Form mời nhân viên mới / sửa vai trò + chi nhánh.
///
/// Create mode (args không có 'id'): POST /merchants/me/staff
/// Edit mode (args có 'id'):         PATCH /merchants/me/staff/{id}
class MerchantStaffFormBloc extends SystemFormBloc<SystemFormState> {
  MerchantStaffFormBloc({required ApiClient apiClient, Map? initialData})
      : this._(apiClient, initialData);

  MerchantStaffFormBloc._(this._apiClient, Map? initialData)
      : _id = initialData?['id']?.toString(),
        super(
          rules: _validationRules(isCreate: initialData == null || initialData['id'] == null),
          initialState: SystemFormState(
            status: SystemFormStateStatus.initial,
            fields: _buildInitialFields(initialData),
            data: const {},
          ),
        );

  final ApiClient _apiClient;
  final String? _id;

  bool get _isCreate => _id == null || _id.isEmpty;

  static Map<String, dynamic> _buildInitialFields(Map? data) {
    if (data == null || data['id'] == null) return {};
    return {
      'role': data['role']?.toString(),
      if ((data['storeId'] as String?) != null) 'storeId': data['storeId'].toString(),
    };
  }

  static Map<String, Rules> _validationRules({required bool isCreate}) => {
        if (isCreate)
          'phone': Rules(
            required: 'Vui lòng nhập số điện thoại',
            checkData: (data) {
              final v = (data.value ?? '').toString().trim();
              if (v.isEmpty) return null;
              if (v.length < 9) return 'Số điện thoại không hợp lệ';
              return null;
            },
          ),
        'role': Rules(required: 'Vui lòng chọn vai trò'),
      };

  @override
  Future<void> onSubmit(
    Emitter emit, {
    Map<String, dynamic>? extraParams,
    Map<String, dynamic>? extraFields,
  }) async {
    final f = state.fields;
    final role = f['role'] as String?;
    final storeId = (f['storeId'] as String?)?.trim();

    try {
      final dio = _apiClient.dio(ApiService.merchant);
      if (_isCreate) {
        final payload = <String, dynamic>{
          'phone': (f['phone'] as String).trim(),
          'role': role,
          if (storeId != null && storeId.isNotEmpty) 'storeId': storeId,
        };
        await dio.post(AppApi.partner.staff, data: payload);
      } else {
        final payload = <String, dynamic>{
          'role': role,
          if (storeId != null && storeId.isNotEmpty) 'storeId': storeId,
        };
        await dio.patch(AppApi.partner.staffById(_id!), data: payload);
      }
    } on DioException catch (e) {
      emit(state.copyWith(
        status: SystemFormStateStatus.fail,
        message: _mapError(e),
      ));
      return;
    } catch (_) {
      emit(state.copyWith(
        status: SystemFormStateStatus.fail,
        message: _isCreate ? 'Mời nhân viên thất bại' : 'Cập nhật thất bại',
      ));
      return;
    }

    await onSuccess(const {'status': 'SUCCESS'}, emit);
  }

  static String _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
      final error = data['error'];
      if (error is Map) {
        final errMsg = error['message']?.toString();
        if (errMsg != null && errMsg.isNotEmpty) return errMsg;
      }
    }
    return 'Thao tác thất bại';
  }
}
