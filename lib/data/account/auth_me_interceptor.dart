// Bắt response /auth/me để app tự nạp roles vào [AccountRoles],
// độc lập với cách AppCore parse MeUser.role.
import 'package:dio/dio.dart';

import 'account_roles.dart';

class AuthMeRolesInterceptor extends Interceptor {
  const AuthMeRolesInterceptor();

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.path.contains('/auth/me')) {
      AccountRoles.instance.setFromMeResponse(response.data);
    }
    handler.next(response);
  }
}
