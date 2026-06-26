import '../import.dart';
import 'bloc/notification_preferences_cubit.dart';
import 'data/notification_data_source.dart';

class NotificationPreferencesPage extends StatelessWidget {
  const NotificationPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationPreferencesCubit(
        dataSource: NotificationDataSource(ApiService.notify.dio),
      )..load(),
      child: const _NotificationPreferencesView(),
    );
  }
}

class _NotificationPreferencesView extends StatelessWidget {
  const _NotificationPreferencesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.bgColor,
      appBar: BaseAppBar(
        context: context,
        title: Text(context.l10n.notificationSettings),
      ),
      body: BlocBuilder<NotificationPreferencesCubit,
          NotificationPreferencesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final cubit = context.read<NotificationPreferencesCubit>();
          final prefs = state.preferences;
          return ListView(
            padding: basePadding,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _PreferenceRow(
                      label: context.l10n.redeemAlerts,
                      value: prefs.redeemAlerts,
                      enabled: !state.isSaving,
                      onChanged: cubit.setRedeemAlerts,
                    ),
                    const Divider(height: 1),
                    _PreferenceRow(
                      label: context.l10n.linkRequests,
                      value: prefs.linkRequests,
                      enabled: !state.isSaving,
                      onChanged: cubit.setLinkRequests,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Palette.textPrimary,
              ),
            ),
          ),
          FieldSwitch(
            value: value,
            enabled: enabled,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
