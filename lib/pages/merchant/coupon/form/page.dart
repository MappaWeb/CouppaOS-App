import '../../../../import.dart';
import 'bloc.dart';

class MerchantCouponFormPage extends StatelessWidget {
  const MerchantCouponFormPage(this.args, {super.key});

  final Map? args;

  String? get id => args?['id']?.toString();
  bool get isEdit => id != null && id!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MerchantCouponFormCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? 'Sửa coupon' : 'Thêm coupon'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Tiêu đề coupon',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Giảm giá (vd: 20% hoặc 50.000đ)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              BlocConsumer<MerchantCouponFormCubit, MerchantCouponFormState>(
                listener: (context, state) {
                  if (state.success) appNavigator.pop();
                },
                builder: (context, state) {
                  return FilledButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () => context.read<MerchantCouponFormCubit>().submit(
                              id: id,
                              title: '',
                              discount: '',
                            ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(state.isSubmitting
                          ? 'Đang lưu...'
                          : (isEdit ? 'Lưu thay đổi' : 'Tạo coupon')),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
