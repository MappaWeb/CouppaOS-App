import '../../../import.dart';
import '../../../widget/scanner/qr_scanner_view.dart';
import 'bloc.dart';

class MerchantRedeemPage extends StatelessWidget {
  const MerchantRedeemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => MerchantRedeemCubit(apiClient: ctx.read<ApiClient>()),
      child: const _MerchantRedeemView(),
    );
  }
}

class _MerchantRedeemView extends StatelessWidget {
  const _MerchantRedeemView();

  Future<void> _showManualInput(BuildContext context) async {
    String inputValue = '';

    await AppDialogs.showActionDialog(
      context: context,
      labelText: 'Nhập mã coupon',
      showCloseButton: false,
      content: StatefulBuilder(
        builder: (ctx, setState) => FieldText(
          value: inputValue,
          onChanged: (v) => inputValue = v,
          hintText: 'Nhập mã thủ công',
          labelText: 'Mã coupon',
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          onSubmitted: (_) => appNavigator.pop(),
        ),
      ),
      actions: [
        BaseButton.outlined(
          onPressed: appNavigator.pop,
          child: const Text('Huỷ'),
        ),
        BaseButton(
          onPressed: appNavigator.pop,
          child: const Text('Xác nhận'),
        ),
      ],
    );

    final code = inputValue.trim();
    if (code.isNotEmpty) {
      if (!context.mounted) return;
      context.read<MerchantRedeemCubit>().onScanned(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: BaseAppBar(
        context: context,
        title: const Text(
          'Quét mã coupon',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: appNavigator.pop,
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<MerchantRedeemCubit, MerchantRedeemState>(
        listenWhen: (p, c) =>
            (p.verifyData == null && c.verifyData != null) ||
            (p.error != c.error && c.error != null),
        listener: (context, state) async {
          if (state.error != null) {
            showMessage(state.error!, type: 'error');
            return;
          }
          if (state.verifyData != null) {
            await appNavigator.pushNamed(
              RouterConstants.merchantRedeemConfirm,
              arguments: {
                'code': state.checkedCode ?? '',
                'verifyData': state.verifyData,
              },
            );
            if (!context.mounted) return;
            context.read<MerchantRedeemCubit>().resume();
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Positioned.fill(
                child: QrScannerView(
                  isProcessing: state.isProcessing,
                  hintText: 'Đưa mã QR coupon vào khung để quét',
                  onCodeDetected: (code) =>
                      context.read<MerchantRedeemCubit>().onScanned(code),
                ),
              ),
              // Overlay loading khi đang gọi verify API
              if (state.isChecking)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black54,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 12),
                        Text(
                          'Đang kiểm tra mã...',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 0,
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: state.isProcessing
                          ? null
                          : () => _showManualInput(context),
                      icon: const Icon(Icons.keyboard_alt_outlined),
                      label: const Text('Nhập mã thủ công'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
