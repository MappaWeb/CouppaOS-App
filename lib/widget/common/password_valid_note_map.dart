import 'package:flutter/material.dart';
import 'package:core_auth/core_auth.dart';
import 'package:core_foundation/core_foundation.dart';
import 'package:core_state/core_state.dart';

class PasswordValidNoteMap<B extends StateStreamable<S>, S>
    extends StatelessWidget {
  final BlocWidgetSelector<S, String> selector;

  const PasswordValidNoteMap({super.key, required this.selector});

  Map<String, String> get notes => {
    'minLength': 'Tối thiểu 8 ký tự'.lang(),
    'hasUppercaseChar': 'Ít nhất 1 chữ viết hoa (A-Z)'.lang(),
    'hasLowercaseChar': 'Ít nhất 1 ký tự viết thường (a-z)'.lang(),
    'hasNumberChar': 'Ít nhất 1 chữ số (0-9)'.lang(),
    'hasSpecialChar':
    'Ít nhất 1 ký tự đặc biệt (!, @, #, \$, %, ^, &)',
  };

  bool isValid(String key, String password) {
    if (empty(password)) {
      return false;
    }
    switch (key) {
      case 'minLength':
        return password.length >= 8;
      case 'hasUppercaseChar':
        return RegExp(r'[A-Z]').hasMatch(password);
      case 'hasLowercaseChar':
        return RegExp(r'[a-z]').hasMatch(password);
      case 'hasNumberChar':
        return RegExp(r'[0-9]').hasMatch(password);
      case 'hasSpecialChar':
        return RegExp(r'[!@#\$%\^&*]').hasMatch(password);
      case 'has':
        return RegExp(r'[!@#\$%\^&*]').hasMatch(password);
      case 'noUsernameOrEmail':
        final authState = AuthSetup.instance.authSessionBloc.state;
        final authUser = authState is AuthAuthenticated ? authState.session.user : null;
        if (password.toUpperCase().contains((authUser?.username ?? '').toUpperCase())) {
          return false;
        }
        if (password.toUpperCase().contains((authUser?.email ?? '').toUpperCase())) {
          return false;
        }
        return true;
      case 'noCommonPassword':
        final List<String> commonPasswords = [
          'password',
          '123456',
          '123456789',
          '12345',
          '1234',
          '123',
          '12345678',
          'qwerty',
          'abc123',
          'password123',
          'letmein',
          'welcome',
          'admin',
          'monkey',
          'qwertyuiop',
          '123qwe',
          '1qaz2wsx',
          'Demo@123',
          '123456aA@',
          '1234567aA@',
        ];
        if(password.length > 3) {
          return true;
        }
        if (commonPasswords.contains(password.toLowerCase())) {
          return false;
        }

        if (RegExp(r'(\d)\1\1\1').hasMatch(password) ||
            RegExp(r'(abc|def|ghi|jkl|mno|pqr|stu|vwx|yz)')
                .hasMatch(password.toLowerCase())) {
          return false;
        }

        return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<B, S, String>(
        selector: selector,
        builder: (context, password) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: notes.entries.map((e) {
              final isActive = isValid(e.key, password);
              final color = isActive ? AppColors.green500 : null;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: AnimatedOpacity(
                  opacity: isActive ? 1 : 0.75,
                  duration: const Duration(milliseconds: 300),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? ViIcons.check : ViIcons.x_small,
                        color: color,
                      ),
                      w12,
                      Text(e.value, style: TextStyle(color: color),)
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        });
  }
}
