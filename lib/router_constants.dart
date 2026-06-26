
import 'pages/account/page.dart';
import 'pages/loading/page.dart';
import 'pages/login/page.dart';
import 'pages/merchant/coupon/detail/page.dart';
import 'pages/merchant/coupon/form/page.dart';
import 'pages/merchant/coupon/issue/page.dart';
import 'pages/merchant/coupon/page.dart';
import 'pages/merchant/redeem/confirm/page.dart';
import 'pages/merchant/redeem/page.dart';
import 'pages/merchant/report/page.dart';
import 'pages/start/page.dart';
import 'pages/start/without_login/page.dart';
import 'pages/user/coupon/detail/page.dart';
import 'pages/user/coupon/page.dart';
class RouterConstants {
  const RouterConstants._();
  static String get root => '/';

  ///Router to [AccountPage]
  static String get account => '/Account';

  ///Router to [LoadingPage]
  static String get loading => '/Loading';

  ///Router to [LoginPage]
  static String get login => '/Login';

  ///Router to [MerchantCouponDetailPage]
  static String get merchantCouponDetail => '/Merchant/Coupon/Detail';

  ///Router to [MerchantCouponFormPage]
  static String get merchantCouponForm => '/Merchant/Coupon/Form';

  ///Router to [MerchantCouponIssuePage]
  static String get merchantCouponIssue => '/Merchant/Coupon/Issue';

  ///Router to [MerchantCouponPage]
  static String get merchantCoupon => '/Merchant/Coupon';

  ///Router to [MerchantRedeemConfirmPage]
  static String get merchantRedeemConfirm => '/Merchant/Redeem/Confirm';

  ///Router to [MerchantRedeemPage]
  static String get merchantRedeem => '/Merchant/Redeem';

  ///Router to [MerchantReportPage]
  static String get merchantReport => '/Merchant/Report';

  ///Router to [StartPage]
  static String get start => '/Start';

  ///Router to [StartWithoutLoginPage]
  static String get startWithoutLogin => '/Start/WithoutLogin';

  ///Router to [UserCouponDetailPage]
  static String get userCouponDetail => '/User/Coupon/Detail';

  ///Router to [UserCouponPage]
  static String get userCoupon => '/User/Coupon';
}
