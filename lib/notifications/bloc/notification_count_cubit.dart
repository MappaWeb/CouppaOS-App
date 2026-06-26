import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/notification_data_source.dart';

class NotificationCountCubit extends Cubit<int> {
  NotificationCountCubit({required this._dataSource})
      : super(0) {
    refresh();
  }

  final NotificationDataSource _dataSource;

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
}
