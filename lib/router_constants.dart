
import 'pages/account/page.dart';
import 'pages/account/profile/page.dart';
import 'pages/become_merchant/location/page.dart';
import 'pages/become_merchant/page.dart';
import 'pages/change_password/page.dart';
import 'pages/forgot_password/page.dart';
import 'pages/loading/page.dart';
import 'pages/login/page.dart';
import 'pages/merchant/coupon/batch/page.dart';
import 'pages/merchant/coupon/campaign/page.dart';
import 'pages/merchant/coupon/detail/page.dart';
import 'pages/merchant/coupon/issue/page.dart';
import 'pages/merchant/coupon/page.dart';
import 'pages/merchant/partners/page.dart';
import 'pages/merchant/redeem/confirm/page.dart';
import 'pages/merchant/redeem/page.dart';
import 'pages/merchant/report/page.dart';
import 'pages/otp/page.dart';
import 'pages/register/page.dart';
import 'pages/start/page.dart';
import 'pages/user/coupon/detail/page.dart';
import 'pages/user/coupon/page.dart';
import 'pages/user/voucher_claim/page.dart';
class RouterConstants {
  const RouterConstants._();
  static String get root => '/';

  ///Router to [AccountPage]
  static String get account => '/Account';

  ///Router to [AccountProfilePage]
  static String get accountProfile => '/Account/Profile';

  ///Router to [BecomeMerchantLocationPage]
  static String get becomeMerchantLocation => '/BecomeMerchant/Location';

  ///Router to [BecomeMerchantPage]
  static String get becomeMerchant => '/BecomeMerchant';

  ///Router to [ChangePasswordPage]
  static String get changePassword => '/ChangePassword';

  ///Router to [ForgotPasswordPage]
  static String get forgotPassword => '/ForgotPassword';

  ///Router to [LoadingPage]
  static String get loading => '/Loading';

  ///Router to [LoginPage]
  static String get login => '/Login';

  ///Router to [MerchantCouponBatchPage]
  static String get merchantCouponBatch => '/Merchant/Coupon/Batch';

  ///Router to [MerchantCouponCampaignPage]
  static String get merchantCouponCampaign => '/Merchant/Coupon/Campaign';

  ///Router to [MerchantCouponDetailPage]
  static String get merchantCouponDetail => '/Merchant/Coupon/Detail';

  ///Router to [MerchantCouponIssuePage]
  static String get merchantCouponIssue => '/Merchant/Coupon/Issue';

  ///Router to [MerchantCouponPage]
  static String get merchantCoupon => '/Merchant/Coupon';

  ///Router to [MerchantPartnersPage]
  static String get merchantPartners => '/Merchant/Partners';

  ///Router to [MerchantRedeemConfirmPage]
  static String get merchantRedeemConfirm => '/Merchant/Redeem/Confirm';

  ///Router to [MerchantRedeemPage]
  static String get merchantRedeem => '/Merchant/Redeem';

  ///Router to [MerchantReportPage]
  static String get merchantReport => '/Merchant/Report';

  ///Router to [OtpPage]
  static String get otp => '/Otp';

  ///Router to [RegisterPage]
  static String get register => '/Register';

  ///Router to [StartPage]
  static String get start => '/Start';

  ///Router to [UserCouponDetailPage]
  static String get userCouponDetail => '/User/Coupon/Detail';

  ///Router to [UserCouponPage]
  static String get userCoupon => '/User/Coupon';

  ///Router to [UserVoucherClaimPage]
  static String get userVoucherClaim => '/User/VoucherClaim';
}
