
import '../../import.dart';
import '../data/notification_data_source.dart';
import '../models/notification_model.dart';
import 'notification_list_event.dart';

class NotificationListBloc extends AppListBloc<NotificationModel> {
  NotificationListBloc({Map<String, dynamic>? initialFilters})
      : _actionSource = NotificationDataSource(ApiService.notify.dio),
        super(
          empty: const NotificationModel.empty(),
          dataSource: ApiService.notify.apiPath(ApiAddress.notify.notifications),
          filters: initialFilters,
        ) {
    on<MarkNotificationRead>(_onMarkRead);
    on<MarkAllNotificationsRead>(_onMarkAllRead);
  }

  final NotificationDataSource _actionSource;

  Future<void> _onMarkRead(
    MarkNotificationRead event,
    Emitter<SystemListState<NotificationModel>> emit,
  ) async {
    final success = await _actionSource.markAsRead(event.id);
    if (success && state.originItems.containsKey(event.id)) {
      final updated = state.originItems[event.id]!.copyWith(isRead: true);
      add(UpdateItemBaseList<NotificationModel>(event.id,
          data: updated, force: true));
    }
  }

  Future<void> _onMarkAllRead(
    MarkAllNotificationsRead event,
    Emitter<SystemListState<NotificationModel>> emit,
  ) async {
    final success = await _actionSource.markAllAsRead();
    if (!success) return;
    for (final entry in state.originItems.entries) {
      final item = entry.value;
      if (!item.isRead) {
        add(UpdateItemBaseList<NotificationModel>(
          entry.key,
          data: item.copyWith(isRead: true),
          force: true,
        ));
      }
    }
    add(RefreshBaseList(clearItems: true));
  }
}
