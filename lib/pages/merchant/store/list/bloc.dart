import '../../../../import.dart';

class DeleteStoreRequested extends SystemListEvent {
  DeleteStoreRequested(this.id);
  final String id;
}

class MerchantStoreListBloc extends SystemListBloc<SystemListState<Map>, Map> {
  MerchantStoreListBloc({required this.apiClient})
      : super(dataSource: ApiService.merchant.apiPath(AppApi.partner.stores)) {
    on<DeleteStoreRequested>(_onDelete);
  }

  final ApiClient apiClient;

  Future<void> _onDelete(
    DeleteStoreRequested event,
    Emitter<SystemListState<Map>> emit,
  ) async {
    try {
      await apiClient
          .dio(ApiService.merchant)
          .delete(AppApi.partner.storeById(event.id));
      emit(state.copyWith(extraData: {
        'actionResult': 'success',
        'actionMessage': 'Đã xoá chi nhánh',
      }));
      add(RefreshBaseList());
    } on DioException catch (e) {
      emit(state.copyWith(extraData: {
        'actionResult': 'fail',
        'actionMessage': _mapError(e),
      }));
    } catch (_) {
      emit(state.copyWith(extraData: {
        'actionResult': 'fail',
        'actionMessage': 'Xoá chi nhánh thất bại',
      }));
    }
  }

  static String _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return 'Xoá chi nhánh thất bại';
  }
}
