// State holder cho MeMerchant — load từ /api/merchants/me, cache Hive.
import 'package:core_rest/core_rest.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'me_merchant.dart';
import 'merchant_session_cache.dart';

class MerchantSessionCubit extends Cubit<MeMerchant?> {
  MerchantSessionCubit({
    required this._apiClient,
    MerchantSessionCache? cache,
  })  : _cache = cache ?? MerchantSessionCache(),
        super(null);

  final ApiClient _apiClient;
  final MerchantSessionCache _cache;

  // Bật log khi debug; gắn cờ chung với [Auth:*] để tắt cùng release.
  static const bool _kDebug = true;

  /// Hydrate state từ cache (gọi khi app start).
  Future<void> hydrateFromCache() async {
    final cached = await _cache.read();
    if (cached != null) {
      emit(cached);
    }
  }

  /// Gọi GET /api/merchants/me, cập nhật state + cache.
  /// Trả về `MeMerchant?` để caller biết kết quả; không throw.
  Future<MeMerchant?> fetchMe() async {
    if (_kDebug) debugPrint('[Merchant:Me] 🔄 Gọi /merchants/me');
    try {
      final res = await _apiClient.get<Map<String, dynamic>>(
        ApiService.merchant,
        '/merchants/me',
      );
      final body = res.data;
      if (body == null) {
        if (_kDebug) debugPrint('[Merchant:Me] ⚠️ Body rỗng');
        return null;
      }
      final merchant = MeMerchant.fromJson(body);
      if (merchant.businessName.isEmpty && merchant.taxCode.isEmpty && merchant.owners.isEmpty) {
        if (_kDebug) debugPrint('[Merchant:Me] ⚠️ Parse trống — body keys: ${body.keys.toList()}');
        return null;
      }
      await _cache.write(merchant);
      emit(merchant);
      if (_kDebug) {
        debugPrint('[Merchant:Me] ✅ Thành công — businessName: ${merchant.businessName} | owners: ${merchant.owners.length} | licenses: ${merchant.licenses.length}');
      }
      return merchant;
    } on DioException catch (e) {
      if (_kDebug) {
        debugPrint('[Merchant:Me] ❌ DioException HTTP ${e.response?.statusCode} — ${e.message}');
      }
      return null;
    } on Exception catch (e) {
      if (_kDebug) debugPrint('[Merchant:Me] ❌ Exception — $e');
      return null;
    }
  }

  Future<void> clear() async {
    await _cache.write(null);
    emit(null);
  }
}
