import 'package:core_auth/core_auth.dart';

/// Alias cho AuthGuard.instance.isAuthenticated — dùng bởi UI cũ.
/// Tất cả auth state giờ đến từ AuthSessionBloc qua AuthGuard.
bool get isSupabaseLoggedIn => AuthGuard.instance.isAuthenticated;
