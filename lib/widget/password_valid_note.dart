import '../import.dart';

class PasswordValidNoteVMap extends StatelessWidget {
  const PasswordValidNoteVMap({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> notesList =  [
      'Mật khẩu tối thiểu có 8 ký tự bao gồm cả chữ hoa, chữ thường, số và ký tự đặc biệt',
      'Mật khẩu không chứa 3 ký tự lặp lại liên tiếp. VD: 111, aaa, ...',
      'Mật khẩu không chứa 3 ký tự tăng dần liền nhau. VD: 123,...',
      'Mật khẩu không được trùng với 5 lần đổi mật khẩu gần nhất',
      'Mật khẩu không chứa tài khoản đăng nhập',
      'Không được đặt các mật khẩu dễ đoán và thông dụng',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = notesList[index];
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(ViIcons.check_circle_solid, color: AppColors.green700),
                w8,
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
          separatorBuilder: (context, index) => h8,
          itemCount: notesList.length,
        ).marginOnly(left: 8)
      ],
    );
  }
}
