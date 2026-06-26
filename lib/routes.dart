import 'package:core/core.dart' show RouteBase, GoRoute;

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
    path: '/Loading',
    builder: (context, state) => const LoadingPage(),
  ),
  GoRoute(
    path: '/Login',
    builder: (context, state) => const LoginPage(),
  ),
  GoRoute(
    path: '/Merchant/Coupon/Detail',
    builder: (context, state) => MerchantCouponDetailPage(state.uri.queryParameters.isNotEmpty
    ? state.uri.queryParameters : state.extra as Map?),
  ),
  GoRoute(
    path: '/Merchant/Coupon/Form',
    builder: (context, state) => MerchantCouponFormPage(state.uri.queryParameters.isNotEmpty
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
    path: '/Start',
    builder: (context, state) => const StartPage(),
    redirect: StartPage.redirect,
  ),
  GoRoute(
    path: '/Start/WithoutLogin',
    builder: (context, state) => const StartWithoutLoginPage(),
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
];
