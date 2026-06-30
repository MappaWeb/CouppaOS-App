/// Endpoint paths riêng của app — bổ sung cho `ApiAddress` của core_rest.
///
/// Pattern lấy cảm hứng từ `package:core_rest/.../api_address.dart`:
/// - Path tương đối (relative) → gọi qua `ApiService.X.apiPath(...)`.
/// - Path tuyệt đối (absolute URL) → service có domain riêng nằm ngoài
///   `ApiService` enum; Dio sẽ bypass baseUrl khi gặp URL bắt đầu bằng `https://`.
///
/// Ví dụ:
/// ```dart
/// ApiService.merchant.apiPath(AppApi.merchant.me);
/// ApiService.coupon.apiPath(AppApi.voucher.campaigns);
/// ```
abstract final class AppApi {
  /// Merchant management — relative paths cho `ApiService.merchant`
  /// (`https://merchant.api.suyxet.com`).
  static const merchant = _MerchantPaths();

  /// Voucher / Coupon campaigns — absolute URLs (domain riêng,
  /// không có trong `ApiService` enum).
  /// Base: `https://voucher.api-qr.iotcommunication.net`.
  static final voucher = _VoucherPaths();

  /// Merchant Partner / Link APIs — absolute URLs (domain riêng).
  /// Base: `https://merchant.api-qr.iotcommunication.net`.
  static final partner = _PartnerPaths();

  /// Campaign statistics — absolute URLs (domain riêng).
  /// Base: `https://stats.api-qr.iotcommunication.net`.
  static final stats = _StatsPaths();
}

// ═════════════════════════════════════════════════════════════════════
// Merchant — https://merchant.api.suyxet.com
// ═════════════════════════════════════════════════════════════════════

final class _MerchantPaths {
  const _MerchantPaths();

  // ── /merchants ──────────────────────────────────────────────

  /// POST /merchants — Đăng ký merchant + store
  final register = '/merchants';

  /// GET   /merchants/me — Merchant của tôi
  /// PATCH /merchants/me — Cập nhật hồ sơ merchant (admin)
  final me = '/merchants/me';

  /// GET  /merchants/me/staff — Danh sách nhân viên
  /// POST /merchants/me/staff — Thêm nhân viên theo SĐT (admin)
  final staff = '/merchants/me/staff';

  /// PATCH  /merchants/me/staff/{id} — Đổi role nhân viên (admin)
  /// DELETE /merchants/me/staff/{id} — Thu hồi nhân viên (admin)
  String staffById(String id) => '/merchants/me/staff/$id';

  /// GET  /merchants/me/stores — Danh sách cơ sở của merchant
  /// POST /merchants/me/stores — Thêm cơ sở (manager)
  final stores = '/merchants/me/stores';

  /// PATCH  /merchants/me/stores/{id} — Cập nhật cơ sở
  /// DELETE /merchants/me/stores/{id} — Xoá cơ sở (manager)
  String storeById(String id) => '/merchants/me/stores/$id';

  /// GET  /merchants/me/links — Danh sách liên kết (gửi đi + nhận về)
  /// POST /merchants/me/links — Gửi yêu cầu liên kết đối tác
  final links = '/merchants/me/links';

  /// POST /merchants/me/links/{id}/respond — Đồng ý / từ chối yêu cầu liên kết
  String linkRespond(String id) => '/merchants/me/links/$id/respond';

  /// GET /merchants/me/partners — Đối tác đã liên kết + cơ sở của họ
  final partners = '/merchants/me/partners';

  // ── /admin/merchants — [system_admin] ────────────────────────

  /// GET  /admin/merchants — Tất cả merchant
  /// POST /admin/merchants — Tạo merchant mới (chủ theo SĐT)
  final adminMerchants = '/admin/merchants';

  /// GET   /admin/merchants/{id} — Chi tiết merchant (stores + staff)
  /// PATCH /admin/merchants/{id} — Sửa thông tin merchant
  String adminMerchantById(String id) => '/admin/merchants/$id';

  /// POST /admin/merchants/{id}/stores — Thêm cơ sở cho merchant
  String adminMerchantStores(String merchantId) =>
      '/admin/merchants/$merchantId/stores';

  /// PATCH  /admin/merchants/stores/{storeId} — Sửa cơ sở của merchant
  /// DELETE /admin/merchants/stores/{storeId} — Xoá cơ sở
  String adminStoreById(String storeId) =>
      '/admin/merchants/stores/$storeId';

  /// POST /admin/merchants/{id}/links — Thêm liên kết đối tác (ACCEPTED)
  String adminMerchantLinks(String merchantId) =>
      '/admin/merchants/$merchantId/links';

  /// DELETE /admin/merchants/links/{linkId} — Gỡ liên kết đối tác
  String adminLinkById(String linkId) => '/admin/merchants/links/$linkId';

  /// POST /admin/merchants/{id}/staff — Thêm nhân sự cho merchant
  String adminMerchantStaff(String merchantId) =>
      '/admin/merchants/$merchantId/staff';

  /// PATCH  /admin/merchants/staff/{staffId} — Sửa nhân sự (vai trò / chi nhánh)
  /// DELETE /admin/merchants/staff/{staffId} — Thu hồi nhân sự
  String adminStaffById(String staffId) => '/admin/merchants/staff/$staffId';

  /// PATCH /admin/merchants/{id}/verify — Duyệt / từ chối merchant
  String adminMerchantVerify(String id) => '/admin/merchants/$id/verify';

  // ── /internal ─────────────────────────────────────────────────

  /// GET /internal/merchants/{id}/verified
  String internalVerified(String id) => '/internal/merchants/$id/verified';

  /// GET /internal/users/{userId}/merchant
  String internalUserMerchant(String userId) =>
      '/internal/users/$userId/merchant';

  /// GET /internal/merchants/{id}/stores
  String internalStores(String id) => '/internal/merchants/$id/stores';

  /// GET /internal/merchants/{id}/brand
  String internalBrand(String id) => '/internal/merchants/$id/brand';

  /// GET /internal/merchants/{id}/partners
  String internalPartners(String id) => '/internal/merchants/$id/partners';

  /// GET /internal/merchants/{id}/managers
  String internalManagers(String id) => '/internal/merchants/$id/managers';

  /// POST /internal/names
  final internalNames = '/internal/names';

  /// POST /internal/store-locations
  final internalStoreLocations = '/internal/store-locations';
}

// ═════════════════════════════════════════════════════════════════════
// Voucher — https://voucher.api-qr.iotcommunication.net  (absolute URLs)
// ═════════════════════════════════════════════════════════════════════

final class _VoucherPaths {
  _VoucherPaths();

  static const _base = 'https://voucher.api-qr.iotcommunication.net';

  /// Ghép `_base` với path tương đối → URL tuyệt đối cho Dio.
  static String _abs(String path) => '$_base$path';

  // ── Campaigns (self) ─────────────────────────────────────────

  /// GET  /campaigns — Danh sách campaign của merchant
  /// POST /campaigns — Tạo campaign (DRAFT)
  final campaigns = _abs('/campaigns');

  /// POST /campaigns/issue-direct — Phát hành lô voucher trực tiếp (bearer)
  final campaignIssueDirect = _abs('/campaigns/issue-direct');

  /// GET /campaigns/by-code/{code} — Thông tin campaign theo code (công khai)
  String campaignByCode(String code) => _abs('/campaigns/by-code/$code');

  /// GET   /campaigns/{id} — Chi tiết campaign
  /// PATCH /campaigns/{id} — Sửa campaign
  String campaignById(String id) => _abs('/campaigns/$id');

  /// PATCH /campaigns/{id}/status — Đổi trạng thái campaign
  String campaignStatus(String id) => _abs('/campaigns/$id/status');

  // ── Vouchers (codes trong campaign) ──────────────────────────

  /// POST /campaigns/{id}/vouchers — Sinh voucher theo lô + QR ký HMAC
  /// GET  /campaigns/{id}/vouchers — Liệt kê voucher code của campaign
  String campaignVouchers(String id) => _abs('/campaigns/$id/vouchers');

  /// GET /campaigns/{id}/batches — Danh sách đợt phát voucher của campaign
  String campaignBatches(String id) => _abs('/campaigns/$id/batches');

  /// GET /vouchers/branch-list — Danh sách voucher tại chi nhánh
  /// (NV thu ngân / kế toán)
  final voucherBranchList = _abs('/vouchers/branch-list');

  // ── Templates ────────────────────────────────────────────────

  /// GET  /templates — Chợ template (mẫu thiết kế đã publish)
  /// POST /templates — Tạo template (editor v2)
  final templates = _abs('/templates');

  /// GET /templates/mine — Template của merchant hiện tại (editor v2)
  final templatesMine = _abs('/templates/mine');

  /// GET   /templates/{id} — Chi tiết template (kèm layout document)
  /// PATCH /templates/{id} — Cập nhật template của merchant (editor v2)
  String templateById(String id) => _abs('/templates/$id');

  // ── Claim & Redeem ───────────────────────────────────────────

  /// POST /vouchers/claims — Nhận 1 voucher từ campaign (atomic, chống trùng)
  final voucherClaims = _abs('/vouchers/claims');

  /// GET /vouchers/mine — Voucher đã nhận của tôi (kèm QR cố định)
  final vouchersMine = _abs('/vouchers/mine');

  /// POST /vouchers/redeem-nonce — Khách tạo nonce QR động cho voucher của mình
  final voucherRedeemNonce = _abs('/vouchers/redeem-nonce');

  /// POST /vouchers/redeem — Nhân viên redeem voucher (row-lock)
  final voucherRedeem = _abs('/vouchers/redeem');

  /// POST /vouchers/verify — Kiểm tra voucher (không đổi trạng thái)
  final voucherVerify = _abs('/vouchers/verify');

  // ── Admin — [system_admin] ───────────────────────────────────

  /// GET /admin/campaigns — Campaign toàn hệ thống (lọc theo merchantId)
  final adminCampaigns = _abs('/admin/campaigns');

  /// GET /admin/campaigns/{id}/vouchers — Mã voucher của campaign (đã che 1 phần)
  String adminCampaignVouchers(String id) => _abs('/admin/campaigns/$id/vouchers');

  /// POST /admin/campaigns/{merchantId} — Tạo campaign cho merchant
  String adminCampaignByMerchant(String merchantId) =>
      _abs('/admin/campaigns/$merchantId');

  /// POST /admin/campaigns/{merchantId}/issue-direct — Phát hành lô voucher
  String adminCampaignIssueDirect(String merchantId) =>
      _abs('/admin/campaigns/$merchantId/issue-direct');

  /// PATCH /admin/campaigns/{id} — Sửa campaign
  String adminCampaignById(String id) => _abs('/admin/campaigns/$id');

  /// PATCH /admin/campaigns/{id}/status — Đổi trạng thái campaign
  String adminCampaignStatus(String id) => _abs('/admin/campaigns/$id/status');

  /// PATCH /admin/campaigns/codes/{codeId}/revoke — Thu hồi (hết hạn) 1 mã
  String adminCodeRevoke(String codeId) =>
      _abs('/admin/campaigns/codes/$codeId/revoke');

  /// GET  /admin/templates — Tất cả mẫu template
  /// POST /admin/templates — Tạo mẫu template (ảnh nền + vị trí trường)
  final adminTemplates = _abs('/admin/templates');

  /// PATCH  /admin/templates/{id} — Cập nhật mẫu (vị trí trường, publish…)
  /// DELETE /admin/templates/{id} — Xoá mẫu
  String adminTemplateById(String id) => _abs('/admin/templates/$id');

  // ── Internal & QR ────────────────────────────────────────────

  /// GET /internal/codes/{id}
  String internalCodeById(String id) => _abs('/internal/codes/$id');

  /// GET /qr/verify — Verify QR (công khai)
  final qrVerify = _abs('/qr/verify');
}

// ═════════════════════════════════════════════════════════════════════
// Merchant Partner / Link — https://merchant.api-qr.iotcommunication.net
// ═════════════════════════════════════════════════════════════════════

final class _PartnerPaths {
  _PartnerPaths();

  static const _base = 'https://merchant.api-qr.iotcommunication.net';

  static String _abs(String path) => '$_base$path';

  /// GET /merchants/me/partners — Đối tác đã liên kết + cơ sở của họ
  final partners = _abs('/merchants/me/partners');

  /// GET  /merchants/me/links — Danh sách yêu cầu liên kết (incoming + outgoing)
  /// POST /merchants/me/links — Gửi yêu cầu liên kết (body: `{"partnerPhone": "..."}`)
  final links = _abs('/merchants/me/links');

  /// POST /merchants/me/links/{id}/respond — Đồng ý / từ chối yêu cầu
  /// (body: `{"accept": true|false}`)
  String linkRespond(String id) => _abs('/merchants/me/links/$id/respond');
}

// ═════════════════════════════════════════════════════════════════════
// Stats — https://stats.api-qr.iotcommunication.net
// ═════════════════════════════════════════════════════════════════════

final class _StatsPaths {
  _StatsPaths();

  static const _base = 'https://stats.api-qr.iotcommunication.net';

  static String _abs(String path) => '$_base$path';

  /// GET /stats/campaigns — Thống kê tất cả campaign của merchant
  final campaigns = _abs('/stats/campaigns');
}
