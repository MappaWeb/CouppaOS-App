import 'package:core/core.dart' show RouteBase, GoRoute;

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
import 'pages/user/voucher_campaign/page.dart';
import 'pages/user/voucher_claim/page.dart';

List<RouteBase> get routes => <RouteBase>[
  GoRoute(
    path: '/',
    builder: (context, state) => const StartPage(),
    redirect: StartPage.redirect,
  ),
  GoRoute(
    path: '/Account',
    builder: (context, state) => const AccountPage(),
  ),
  GoRoute(
    path: '/Account/Profile',
    builder: (context, state) => const AccountProfilePage(),
  ),
  GoRoute(
    path: '/BecomeMerchant/Location',
    builder: (context, state) => BecomeMerchantLocationPage(state.uri.queryParameters.isNotEmpty
    ? state.uri.queryParameters : state.extra as Map?),
  ),
  GoRoute(
    path: '/BecomeMerchant',
    builder: (context, state) => const BecomeMerchantPage(),
  ),
  GoRoute(
    path: '/ChangePassword',
    builder: (context, state) => const ChangePasswordPage(),
  ),
  GoRoute(
    path: '/ForgotPassword',
    builder: (context, state) => const ForgotPasswordPage(),
  ),
  GoRoute(
    path: '/Loading',
    builder: (context, state) => const LoadingPage(),
  ),
  GoRoute(
    path: '/Login',
    builder: (context, state) => const LoginPage(),
  ),
  GoRoute(
    path: '/Merchant/Coupon/Batch',
    builder: (context, state) => MerchantCouponBatchPage(state.uri.queryParameters.isNotEmpty
    ? state.uri.queryParameters : state.extra as Map?),
  ),
  GoRoute(
    path: '/Merchant/Coupon/Campaign',
    builder: (context, state) => MerchantCouponCampaignPage(state.uri.queryParameters.isNotEmpty
    ? state.uri.queryParameters : state.extra as Map?),
  ),
  GoRoute(
    path: '/Merchant/Coupon/Detail',
    builder: (context, state) => MerchantCouponDetailPage(state.uri.queryParameters.isNotEmpty
    ? state.uri.queryParameters : state.extra as Map?),
  ),
  GoRoute(
    path: '/Merchant/Coupon/Issue',
    builder: (context, state) => MerchantCouponIssuePage(state.uri.queryParameters.isNotEmpty
    ? state.uri.queryParameters : state.extra as Map?),
  ),
  GoRoute(
    path: '/Merchant/Coupon',
    builder: (context, state) => const MerchantCouponPage(),
  ),
  GoRoute(
    path: '/Merchant/Partners',
    builder: (context, state) => const MerchantPartnersPage(),
  ),
  GoRoute(
    path: '/Merchant/Redeem/Confirm',
    builder: (context, state) => MerchantRedeemConfirmPage(state.uri.queryParameters.isNotEmpty
    ? state.uri.queryParameters : state.extra as Map?),
  ),
  GoRoute(
    path: '/Merchant/Redeem',
    builder: (context, state) => const MerchantRedeemPage(),
  ),
  GoRoute(
    path: '/Merchant/Report',
    builder: (context, state) => const MerchantReportPage(),
  ),
  GoRoute(
    path: '/Otp',
    builder: (context, state) => OtpPage(state.uri.queryParameters.isNotEmpty
    ? state.uri.queryParameters : state.extra as Map?),
  ),
  GoRoute(
    path: '/Register',
    builder: (context, state) => const RegisterPage(),
  ),
  GoRoute(
    path: '/Start',
    builder: (context, state) => const StartPage(),
    redirect: StartPage.redirect,
  ),
  GoRoute(
    path: '/User/Coupon/Detail',
    builder: (context, state) => UserCouponDetailPage(state.uri.queryParameters.isNotEmpty
    ? state.uri.queryParameters : state.extra as Map?),
  ),
  GoRoute(
    path: '/User/Coupon',
    builder: (context, state) => const UserCouponPage(),
  ),
  GoRoute(
    path: '/User/VoucherCampaign',
    builder: (context, state) => UserVoucherCampaignPage(state.uri.queryParameters.isNotEmpty
    ? state.uri.queryParameters : state.extra as Map?),
  ),
  GoRoute(
    path: '/User/VoucherClaim',
    builder: (context, state) => const UserVoucherClaimPage(),
  ),
];
