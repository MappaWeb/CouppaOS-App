import 'package:flutter/services.dart';

import '../../../../import.dart';

/// Hiển thị dialog nhập số điện thoại đối tác để gửi yêu cầu liên kết.
/// Trả về số điện thoại đã nhập (đã trim) nếu user bấm "Gửi", null nếu huỷ.
Future<String?> showSendLinkDialog(BuildContext context) async {
  final result = await AppDialogs.showActionDialog(
    context: context,
    labelText: 'Gửi yêu cầu liên kết',
    showCloseButton: false,
    content: const _SendLinkForm(),
  );
  if (result is String && result.isNotEmpty) return result;
  return null;
}

class _SendLinkForm extends StatefulWidget {
  const _SendLinkForm();

  @override
  State<_SendLinkForm> createState() => _SendLinkFormState();
}

class _SendLinkFormState extends State<_SendLinkForm> {
  String _phone = '';
  String? _error;

  bool get _canSubmit => _phone.trim().length >= 9;

  void _submit() {
    final phone = _phone.trim();
    if (phone.length < 9) {
      setState(() => _error = 'Số điện thoại không hợp lệ');
      return;
    }
    appNavigator.pop(phone);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Nhập số điện thoại của đối tác để gửi yêu cầu liên kết.',
          style: TextStyle(color: Palette.textPrimary4, fontSize: 13),
        ),
        const SizedBox(height: 12),
        FieldText(
          labelText: 'Số điện thoại',
          hintText: 'VD: 0987654321',
          keyboardType: TextInputType.phone,
          autofocus: true,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
            LengthLimitingTextInputFormatter(15),
          ],
          errorText: _error,
          onChanged: (v) {
            setState(() {
              _phone = v;
              if (_error != null) _error = null;
            });
          },
          onSubmitted: (_) {
            if (_canSubmit) _submit();
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Palette.textPrimary,
                  side: const BorderSide(color: Palette.borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => appNavigator.pop(),
                child: const Text('Huỷ'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Palette.primary,
                  disabledBackgroundColor: Palette.primary.withValues(
                    alpha: 0.4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _canSubmit ? _submit : null,
                child: const Text('Gửi'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
