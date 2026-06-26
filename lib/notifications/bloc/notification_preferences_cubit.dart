import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/notification_data_source.dart';
import '../models/notification_preferences.dart';

class NotificationPreferencesState {
  const NotificationPreferencesState({
    this.preferences = const NotificationPreferences(),
    this.isLoading = true,
    this.isSaving = false,
    this.hasError = false,
  });

  final NotificationPreferences preferences;
  final bool isLoading;
  final bool isSaving;
  final bool hasError;

  NotificationPreferencesState copyWith({
    NotificationPreferences? preferences,
    bool? isLoading,
    bool? isSaving,
    bool? hasError,
  }) {
    return NotificationPreferencesState(
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      hasError: hasError ?? this.hasError,
    );
  }
}

class NotificationPreferencesCubit
    extends Cubit<NotificationPreferencesState> {
  NotificationPreferencesCubit({required NotificationDataSource dataSource})
      : _dataSource = dataSource,
        super(const NotificationPreferencesState());

  final NotificationDataSource _dataSource;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, hasError: false));
    final prefs = await _dataSource.fetchPreferences();
    if (isClosed) return;
    if (prefs == null) {
      emit(state.copyWith(isLoading: false, hasError: true));
      return;
    }
    emit(state.copyWith(preferences: prefs, isLoading: false, hasError: false));
  }

  Future<void> setRedeemAlerts(bool value) =>
      _save(state.preferences.copyWith(redeemAlerts: value));

  Future<void> setLinkRequests(bool value) =>
      _save(state.preferences.copyWith(linkRequests: value));

  Future<void> _save(NotificationPreferences next) async {
    final previous = state.preferences;
    emit(state.copyWith(preferences: next, isSaving: true));
    final success = await _dataSource.updatePreferences(next);
    if (isClosed) return;
    if (!success) {
      emit(state.copyWith(preferences: previous, isSaving: false));
      return;
    }
    emit(state.copyWith(isSaving: false));
  }
}
