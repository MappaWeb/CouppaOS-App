import '../../../import.dart';
import '../../../widget/scanner/qr_scanner_view.dart';
import 'bloc.dart';

class MerchantRedeemPage extends StatelessWidget {
  const MerchantRedeemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MerchantRedeemCubit(),
      child: const _MerchantRedeemView(),
    );
  }
}

class _MerchantRedeemView extends StatefulWidget {
  const _MerchantRedeemView();

  @override
  State<_MerchantRedeemView> createState() => _MerchantRedeemViewState();
}

class _MerchantRedeemViewState extends State<_MerchantRedeemView> {
  Key _scannerKey = UniqueKey();

  void _onCodeDetected(String code) {
    final cubit = context.read<MerchantRedeemCubit>();
    cubit.onScanned(code);
  }

  Future<void> _showManualInput() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Nhập mã coupon'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              hintText: 'Nhập mã thủ công',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) => Navigator.of(ctx).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Huỷ'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(controller.text.trim()),
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (code != null && code.isNotEmpty) {
      _onCodeDetected(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Quét mã coupon',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<MerchantRedeemCubit, MerchantRedeemState>(
        listenWhen: (p, c) => p.lastScannedCode != c.lastScannedCode,
        listener: (context, state) async {
          if (state.lastScannedCode != null) {
            await appNavigator.pushNamed(
              RouterConstants.merchantRedeemConfirm,
              arguments: {'code': state.lastScannedCode},
            );
            if (!context.mounted) return;
            context.read<MerchantRedeemCubit>().resume();
            setState(() => _scannerKey = UniqueKey());
          }
        },
        builder: (context, state) {
          final processing = !state.isScanning;
          return Stack(
            children: [
              Positioned.fill(
                child: QrScannerView(
                  key: _scannerKey,
                  isProcessing: processing,
                  hintText: 'Đưa mã QR coupon vào khung để quét',
                  onCodeDetected: _onCodeDetected,
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
                      onPressed: processing ? null : _showManualInput,
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
