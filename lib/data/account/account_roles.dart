// Role của tài khoản — app tự parse từ mảng `roles` của /auth/me.
// Không dùng MeUser.role của AppCore (vốn không xử lý được roles dạng object
// `{role, scopeMerchantId}` nên trả ra giá trị rác).
import 'dart:convert';

import 'package:core_storage/core_storage.dart';
import 'package:flutter/foundation.dart';

/// Các role được coi là merchant.
const _kMerchantRoles = {
  'merchant',
  'merchant_admin',
  'super_staff',
  'staff',
};

const _kBox = 'auth_cache';
const _kKey = 'account_roles_v1';

/// Một phần tử trong mảng `roles`: `{role, scopeMerchantId}`.
@immutable
class AccountRoleEntry {
  const AccountRoleEntry({required this.role, this.scopeMerchantId});

  final String role;
  final String? scopeMerchantId;

  bool get isMerchant => _kMerchantRoles.contains(role.toLowerCase());

  factory AccountRoleEntry.fromJson(Map<dynamic, dynamic> json) =>
      AccountRoleEntry(
        role: json['role']?.toString() ?? '',
        scopeMerchantId: json['scopeMerchantId']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'role': role,
        if (scopeMerchantId != null) 'scopeMerchantId': scopeMerchantId,
      };

  /// Parse cả dạng list-of-object lẫn list-of-string.
  static List<AccountRoleEntry> listFrom(Object? raw) {
    if (raw is! List) return const [];
    final out = <AccountRoleEntry>[];
    for (final e in raw) {
      if (e is Map) {
        out.add(AccountRoleEntry.fromJson(e));
      } else if (e is String && e.isNotEmpty) {
        out.add(AccountRoleEntry(role: e));
      }
    }
    return out;
  }
}

/// Store app-owned cho roles. Nguồn cập nhật: interceptor bắt /auth/me
/// ([AuthMeRolesInterceptor]). Persist xuống Hive để role đúng ngay khi
/// restart (trước khi recheck /me hoàn tất).
class AccountRoles {
  AccountRoles._();
  static final AccountRoles instance = AccountRoles._();

  final _box = Setting(_kBox);
  final ValueNotifier<List<AccountRoleEntry>> roles =
      ValueNotifier<List<AccountRoleEntry>>(const []);

  bool get isMerchant => roles.value.any((r) => r.isMerchant);

  /// merchantId của role merchant đầu tiên có scope (nếu có).
  String? get merchantId {
    for (final r in roles.value) {
      if (r.isMerchant && (r.scopeMerchantId?.isNotEmpty ?? false)) {
        return r.scopeMerchantId;
      }
    }
    return null;
  }

  /// Cập nhật từ body /auth/me — hỗ trợ flat, `{data:{...}}`, `{user:{...}}`.
  void setFromMeResponse(Object? body) {
    final container = _rolesContainer(body);
    if (container == null) return;
    final parsed = AccountRoleEntry.listFrom(container['roles']);
    roles.value = parsed;
    _box.put(_kKey, jsonEncode(parsed.map((e) => e.toJson()).toList()));
  }

  /// Đọc lại từ Hive (gọi lúc app start, trước khi /auth/me trả về).
  Future<void> hydrate() async {
    final raw = _box.get<String>(_kKey);
    if (raw == null || raw.isEmpty) return;
    try {
      roles.value = AccountRoleEntry.listFrom(jsonDecode(raw));
    } on Exception {
      // bỏ qua cache hỏng
    }
  }

  void clear() {
    roles.value = const [];
    _box.delete(_kKey);
  }

  static Map<String, dynamic>? _rolesContainer(Object? body) {
    if (body is! Map) return null;
    if (body['roles'] is List) return body.cast<String, dynamic>();
    final data = body['data'];
    if (data is Map && data['roles'] is List) {
      return data.cast<String, dynamic>();
    }
    final user = body['user'];
    if (user is Map && user['roles'] is List) {
      return user.cast<String, dynamic>();
    }
    return null;
  }
}
