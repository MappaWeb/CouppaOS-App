import '../../../import.dart';
import '../../../widget/scanner/qr_scanner_view.dart';
import 'bloc.dart';

class UserVoucherClaimPage extends StatelessWidget {
  const UserVoucherClaimPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => VoucherClaimCubit(apiClient: ctx.read<ApiClient>()),
      child: const _VoucherClaimView(),
    );
  }
}

class _VoucherClaimView extends StatefulWidget {
  const _VoucherClaimView();

  @override
  State<_VoucherClaimView> createState() => _VoucherClaimViewState();
}

class _VoucherClaimViewState extends State<_VoucherClaimView> {
  Key _scannerKey = UniqueKey();

  void _onSummaryShown(VoucherClaimSummary s) {
    final l10n = context.l10n;
    final type = s.success == s.total && s.total > 0 ? 'success' : 'error';
    showMessage(l10n.voucherClaim_summary(s.success, s.total), type: type);
    context.read<VoucherClaimCubit>().consumeSummary();
  }

  Future<void> _showResultDialog(VoucherClaimDialog payload) async {
    final l10n = context.l10n;
    final cubit = context.read<VoucherClaimCubit>();
    final title = payload.success
        ? l10n.voucherClaim_dialogSuccess
        : l10n.voucherClaim_dialogFail;
    final message = payload.success
        ? l10n.voucherClaim_dialogSuccessMessage(payload.code)
        : (payload.message?.isNotEmpty == true
              ? payload.message!
              : l10n.voucherClaim_dialogFailMessage(payload.code));

    await AppDialogs.showConfirmDialog(
      context: context,
      title: title,
      message: message,
      showCloseButton: false,
      barrierDismissible: false,
      textConfirm: l10n.voucherClaim_continueScan,
      textCancel: l10n.voucherClaim_cancel,
      onConfirm: () {
        cubit.resumeQr();
        setState(() => _scannerKey = UniqueKey());
        appNavigator.pop();
      },
      onCancel: () {
        cubit.pauseQr();
        appNavigator.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.voucherClaim_title),
        backgroundColor: Colors.white,
        foregroundColor: Palette.textPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: BlocConsumer<VoucherClaimCubit, VoucherClaimState>(
          listenWhen: (p, c) =>
              p.summary != c.summary || p.dialog != c.dialog,
          listener: (_, state) {
            if (state.summary != null) _onSummaryShown(state.summary!);
            if (state.dialog != null) _showResultDialog(state.dialog!);
          },
          builder: (context, state) {
            return Column(
              children: [
                const SizedBox(height: 12),
                _ModeToggle(
                  mode: state.mode,
                  enabled: !state.isProcessing,
                  onChanged: (m) =>
                      context.read<VoucherClaimCubit>().switchMode(m),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: switch (state.mode) {
                    VoucherClaimMode.manual => _ManualPanel(state: state),
                    VoucherClaimMode.qr => _ScannerPanel(
                      state: state,
                      scannerKey: _scannerKey,
                    ),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.mode,
    required this.enabled,
    required this.onChanged,
  });

  final VoucherClaimMode mode;
  final bool enabled;
  final ValueChanged<VoucherClaimMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _ToggleTab(
              label: l10n.voucherClaim_modeManual,
              icon: Icons.edit_outlined,
              selected: mode == VoucherClaimMode.manual,
              enabled: enabled,
              onTap: () => onChanged(VoucherClaimMode.manual),
            ),
            _ToggleTab(
              label: l10n.voucherClaim_modeQr,
              icon: Icons.qr_code_scanner,
              selected: mode == VoucherClaimMode.qr,
              enabled: enabled,
              onTap: () => onChanged(VoucherClaimMode.qr),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  const _ToggleTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: selected ? Palette.primary : Palette.textPrimary4,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? Palette.primary : Palette.textPrimary4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ManualPanel extends StatelessWidget {
  const _ManualPanel({required this.state});

  final VoucherClaimState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<VoucherClaimCubit>();
    final canSubmit = !state.isProcessing && state.input.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FieldText(
            value: state.input,
            labelText: l10n.voucherClaim_inputLabel,
            hintText: l10n.voucherClaim_inputHint,
            maxLines: null,
            minLines: 8,
            enabled: !state.isProcessing,
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.characters,
            onChanged: cubit.setInput,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Palette.primary,
                disabledBackgroundColor: Palette.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: canSubmit ? cubit.submitManual : null,
              child: state.isProcessing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      l10n.voucherClaim_submit,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerPanel extends StatelessWidget {
  const _ScannerPanel({required this.state, required this.scannerKey});

  final VoucherClaimState state;
  final Key scannerKey;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<VoucherClaimCubit>();
    final processing = state.isProcessing || state.qrPaused;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: QrScannerView(
                key: scannerKey,
                isProcessing: processing,
                hintText: l10n.voucherClaim_scanHint,
                onCodeDetected: cubit.onQrDetected,
              ),
            ),
            if (state.qrPaused && !state.isProcessing)
              Positioned.fill(
                child: _ResumeOverlay(onResume: cubit.resumeQr),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResumeOverlay extends StatelessWidget {
  const _ResumeOverlay({required this.onResume});

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.65),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.pause_circle_outline,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.voucherClaim_scanPaused,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Palette.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onResume,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.voucherClaim_continueScan),
            ),
          ],
        ),
      ),
    );
  }
}
