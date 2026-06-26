import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/notification_data_source.dart';
import '../data/notification_sse_service.dart';

class NotificationCountCubit extends Cubit<int> {
  NotificationCountCubit({
    required NotificationDataSource dataSource,
    NotificationSseService? sseService,
  })  : _dataSource = dataSource,
        super(0) {
    _sseSub = sseService?.events.listen(_onSseEvent);
    refresh();
  }

  final NotificationDataSource _dataSource;
  StreamSubscription<NotificationSseEvent>? _sseSub;

  Future<void> refresh() async {
    final count = await _dataSource.fetchUnreadCount();
    if (!isClosed) emit(count);
  }

  void decrement([int by = 1]) {
    if (!isClosed && state > 0) emit(state - by);
  }

  void reset() {
    if (!isClosed) emit(0);
  }

  void _onSseEvent(NotificationSseEvent event) {
    switch (event.type) {
      case 'new_notification':
      case 'count_update':
        refresh();
      case 'read':
        decrement();
    }
  }

  @override
  Future<void> close() {
    _sseSub?.cancel();
    return super.close();
  }
}
