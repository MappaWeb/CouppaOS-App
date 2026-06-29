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
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _PreferenceRow(
                      title: context.l10n.promoAlerts,
                      subtitle: context.l10n.promoAlertsDescription,
                      value: prefs.promoAlerts,
                      enabled: !state.isSaving,
                      onChanged: cubit.setPromoAlerts,
                    ),
                    const Divider(height: 1, color: Palette.dividerColor),
                    _PreferenceRow(
                      title: context.l10n.voucherExpiryAlerts,
                      subtitle: context.l10n.voucherExpiryAlertsDescription,
                      value: prefs.voucherExpiryAlerts,
                      enabled: !state.isSaving,
                      onChanged: cubit.setVoucherExpiryAlerts,
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
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Palette.textPrimary3,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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
