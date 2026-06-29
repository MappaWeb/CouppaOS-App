import '../import.dart';
import 'bloc/notification_count_cubit.dart';
import 'bloc/notification_list_bloc.dart';
import 'bloc/notification_list_event.dart';
import 'models/notification_model.dart';
import 'notification_preferences_page.dart';
import 'widgets/notification_item_widget.dart';

class NotificationListPage extends StatelessWidget {
  const NotificationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationListBloc(),
      child: const _NotificationListContent(),
    );
  }
}

class _NotificationListContent extends StatelessWidget {
  const _NotificationListContent();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NotificationListBloc>();

    return SystemListScaffold<
        NotificationListBloc,
        SystemListState<NotificationModel>,
        NotificationModel>(
      appBar: BaseAppBar(
        context: context,
        title: Text(context.l10n.notifications),
        actions: [
          IconButton(
            tooltip: context.l10n.markAllRead,
            icon: const Icon(Icons.done_all),
            onPressed: () {
              bloc.add(MarkAllNotificationsRead());
              context.read<NotificationCountCubit>().reset();
            },
          ),
          IconButton(
            tooltip: context.l10n.notificationSettings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () =>
                appNavigator.push(const NotificationPreferencesPage()),
          ),
        ],
      ),
      detailBuilder: (context, item, isSelected) {
        return NotificationItemWidget(
          item,
          onTap: () => _onNotificationTap(context, bloc, item),
        );
      },
    );
  }

  void _onNotificationTap(
    BuildContext context,
    NotificationListBloc bloc,
    NotificationModel notification,
  ) {
    final wasUnread = !notification.isRead;
    bloc.add(MarkNotificationRead(notification.id));
    if (wasUnread) {
      context.read<NotificationCountCubit>().decrement();
    }

    final screen = notification.screen;
    if (!empty(screen)) {
      appNavigator.pushNamed(
        screen!,
        arguments: <String, dynamic>{
          if (notification.referenceId != null) 'id': notification.referenceId,
          if (notification.params != null) ...notification.params!,
        },
      );
    } else {
      _showDetailDialog(context, notification);
    }
  }

  void _showDetailDialog(BuildContext context, NotificationModel notification) {
    showConfirmDialog(
      title: context.l10n.notificationContent,
      showCloseButton: true,
      barrierDismissible: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (notification.createdAt != null) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(ViIcons.calendar, size: 18),
                w8,
                Text(date(
                  notification.createdAt!.toIso8601String(),
                  'dd/MM/yyyy HH:mm',
                )),
              ],
            ),
            h12,
          ],
          Text(
            notification.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (notification.body.isNotEmpty &&
              notification.body.toLowerCase() !=
                  notification.title.toLowerCase()) ...[
            h12,
            Text(notification.body, style: const TextStyle(fontSize: 16)),
          ],
        ],
      ),
      context: context,
    );
  }
}
