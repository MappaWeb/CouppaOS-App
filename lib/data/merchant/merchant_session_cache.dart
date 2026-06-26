// Cache MeMerchant trên Hive — tránh gọi lại /api/merchants/me sau khi app restart.
import 'dart:convert';

import 'package:core_storage/core_storage.dart';

import 'me_merchant.dart';

const _kBox = 'merchant_cache';
const _kKey = 'merchant_me_v1';

/// Box 'merchant_cache' phải được khai báo trong SharedStorage.init(boxes: [...]).
class MerchantSessionCache {
  final _box = Setting(_kBox);

  Future<MeMerchant?> read() async {
    final raw = _box.get<String>(_kKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return MeMerchant.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Exception {
      return null;
    }
  }

  Future<void> write(MeMerchant? merchant) async {
    if (merchant == null) {
      await _box.delete(_kKey);
    } else {
      await _box.put(_kKey, jsonEncode(merchant.toJson()));
    }
  }
}
