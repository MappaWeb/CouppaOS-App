import 'dart:async';

import '../../import.dart';
import '../data/notification_data_source.dart';
import '../models/notification_model.dart';
import 'notification_list_event.dart';

class NotificationListBloc extends AppListBloc<NotificationModel> {
  NotificationListBloc({Map<String, dynamic>? initialFilters})
      : _actionSource = NotificationDataSource(ApiService.notify.dio),
        super(
          empty: const NotificationModel.empty(),
          dataSource: ApiService.notify.apiPath('/notifications'),
          query: ListQuery.fromMap(initialFilters ?? {})
        ) {
    on<MarkNotificationRead>(_onMarkRead);
    on<MarkAllNotificationsRead>(_onMarkAllRead);
  }

  final NotificationDataSource _actionSource;

  Future<void> _onMarkRead(
    MarkNotificationRead event,
    Emitter<SystemListState<NotificationModel>> emit,
  ) async {
    final current = state.originItems[event.id];
    if (current == null || current.isRead) return;

    _emitItemUpdate(emit, event.id, current.copyWith(isRead: true));
    unawaited(_actionSource.markAsRead(event.id));
  }

  Future<void> _onMarkAllRead(
    MarkAllNotificationsRead event,
    Emitter<SystemListState<NotificationModel>> emit,
  ) async {
    final toggled = <String, NotificationModel>{
      for (final entry in state.originItems.entries)
        entry.key:
            entry.value.isRead ? entry.value : entry.value.copyWith(isRead: true),
    };
    if (toggled.isEmpty) return;

    emit(state.copyWith(
      originItems: toggled,
      filteredItems: _mergeFiltered(toggled),
    ));

    unawaited(_actionSource.markAllAsRead());
  }

  void _emitItemUpdate(
    Emitter<SystemListState<NotificationModel>> emit,
    String id,
    NotificationModel updated,
  ) {
    if (!state.originItems.containsKey(id)) return;
    final newOriginItems = <String, NotificationModel>{
      ...state.originItems,
      id: updated,
    };
    emit(state.copyWith(
      originItems: newOriginItems,
      filteredItems: _mergeFiltered(newOriginItems),
    ));
  }

  Map<String, NotificationModel>? _mergeFiltered(
    Map<String, NotificationModel> originItems,
  ) {
    final filtered = state.filteredItems;
    if (filtered == null) return null;
    final merged = <String, NotificationModel>{...filtered};
    for (final key in filtered.keys) {
      final value = originItems[key];
      if (value != null) merged[key] = value;
    }
    return merged;
  }
}
