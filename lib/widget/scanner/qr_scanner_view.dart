import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import 'scanner_overlay_painter.dart';

typedef QrCodeCallback = void Function(String code);

class QrScannerView extends StatefulWidget {
  const QrScannerView({
    required this.onCodeDetected,
    this.isProcessing = false,
    this.cutOutSize = 260,
    this.hintText,
    this.allowGalleryPick = true,
    super.key,
  });

  final QrCodeCallback onCodeDetected;
  final bool isProcessing;
  final double cutOutSize;
  final String? hintText;
  final bool allowGalleryPick;

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late MobileScannerController _controller;
  late final AnimationController _lineCtrl;
  late final AnimationController _cornerCtrl;
  late final AnimationController _feedbackCtrl;

  ScannerFrameStatus _status = ScannerFrameStatus.idle;
  bool _hasError = false;
  bool _processingLocal = false;
  String? _lastCode;
  Timer? _resetStatusTimer;
  Future<void>? _startFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = _buildController();

    _lineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _cornerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _feedbackCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _start();
  }

  MobileScannerController _buildController() {
    return MobileScannerController(
      // We own start/stop via _start() + lifecycle handlers. With autoStart on,
      // MobileScanner widget's _initializeController races our manual start().
      autoStart: false,
      detectionSpeed: DetectionSpeed.normal,
      formats: const [BarcodeFormat.qrCode],
      facing: CameraFacing.back,
    );
  }

  Future<void> _start() async {
    // Serialize start() calls — mobile_scanner throws controllerInitializing
    // if a prior start() is still running.
    final inflight = _startFuture;
    if (inflight != null) {
      try {
        await inflight;
      } catch (_) {}
      return;
    }
    final future = _controller.start();
    _startFuture = future;
    try {
      await future;
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    } finally {
      if (identical(_startFuture, future)) _startFuture = null;
    }
  }

  @override
  void didUpdateWidget(covariant QrScannerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isProcessing && !widget.isProcessing) {
      _resetForNextScan();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resetStatusTimer?.cancel();
    _lineCtrl.dispose();
    _cornerCtrl.dispose();
    _feedbackCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_hasError) {
        _retryCamera();
      } else {
        unawaited(_start());
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      unawaited(_controller.stop().catchError((_) {}));
    }
  }

  void _resetForNextScan() {
    if (!mounted) return;
    setState(() {
      _processingLocal = false;
      _lastCode = null;
      _status = ScannerFrameStatus.idle;
    });
    unawaited(_start());
  }

  Future<void> _retryCamera() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (status.isGranted) {
      setState(() => _hasError = false);
      try {
        await _controller.dispose();
      } catch (_) {}
      _controller = _buildController();
      _cornerCtrl.forward(from: 0);
      _start();
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  Future<void> _handleCode(String raw) async {
    final code = raw.trim();
    if (code.isEmpty) return;
    if (_processingLocal || widget.isProcessing) return;
    if (_lastCode == code) return;

    setState(() {
      _processingLocal = true;
      _lastCode = code;
      _status = ScannerFrameStatus.success;
    });

    unawaited(HapticFeedback.mediumImpact());
    _feedbackCtrl.forward(from: 0);

    try {
      await _controller.stop();
    } catch (_) {}

    widget.onCodeDetected(code);
  }

  void _flashError() {
    setState(() => _status = ScannerFrameStatus.error);
    HapticFeedback.heavyImpact();
    _feedbackCtrl.forward(from: 0);
    _resetStatusTimer?.cancel();
    _resetStatusTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _status = ScannerFrameStatus.idle);
    });
  }

  Future<void> _pickFromGallery() async {
    if (widget.isProcessing || _processingLocal) return;
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;
    final BarcodeCapture? capture = await _controller.analyzeImage(file.path);
    if (!mounted) return;
    if (capture == null || capture.barcodes.isEmpty) {
      _flashError();
      return;
    }
    for (final b in capture.barcodes) {
      final raw = b.rawValue;
      if (raw != null && raw.isNotEmpty) {
        await _handleCode(raw);
        return;
      }
    }
    _flashError();
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Rect _cutOutRect(Size size) {
    final s = widget.cutOutSize.clamp(0.0, size.shortestSide - 32);
    final left = (size.width - s) / 2;
    final top = (size.height - s) / 2 - 40;
    return Rect.fromLTWH(left, top, s, s);
  }

  Color get _lineColor {
    switch (_status) {
      case ScannerFrameStatus.success:
        return const Color(0xFF22C55E);
      case ScannerFrameStatus.error:
        return const Color(0xFFEF4444);
      case ScannerFrameStatus.idle:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _PermissionErrorView(onRetry: _retryCamera);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final cutOut = _cutOutRect(size);
        return Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _controller,
              fit: BoxFit.cover,
              scanWindow: cutOut,
              // We handle lifecycle ourselves via didChangeAppLifecycleState.
              useAppLifecycleState: false,
              errorBuilder: (context, error) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_hasError) {
                    setState(() => _hasError = true);
                  }
                });
                return const ColoredBox(color: Colors.black);
              },
              onDetect: (capture) {
                if (_processingLocal || widget.isProcessing) return;
                for (final b in capture.barcodes) {
                  final raw = b.rawValue;
                  if (raw != null && raw.isNotEmpty) {
                    _handleCode(raw);
                    return;
                  }
                }
              },
            ),
            AnimatedBuilder(
              animation: Listenable.merge([_cornerCtrl, _feedbackCtrl]),
              builder: (_, _) {
                return CustomPaint(
                  painter: ScannerOverlayPainter(
                    cutOutRect: cutOut,
                    status: _status,
                    cornerProgress: _cornerCtrl.value,
                  ),
                  size: size,
                );
              },
            ),
            AnimatedBuilder(
              animation: _lineCtrl,
              builder: (_, _) {
                if (_status != ScannerFrameStatus.idle) {
                  return const SizedBox.shrink();
                }
                return CustomPaint(
                  painter: ScanningLinePainter(
                    cutOutRect: cutOut,
                    progress: _lineCtrl.value,
                    color: _lineColor,
                  ),
                  size: size,
                );
              },
            ),
            // Success / error glow pulse
            AnimatedBuilder(
              animation: _feedbackCtrl,
              builder: (_, _) {
                if (_status == ScannerFrameStatus.idle) {
                  return const SizedBox.shrink();
                }
                final t = Curves.easeOut.transform(_feedbackCtrl.value);
                return IgnorePointer(
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(0, cutOut.center.dy - size.height / 2),
                      child: Container(
                        width: widget.cutOutSize * (0.4 + 0.4 * t),
                        height: widget.cutOutSize * (0.4 + 0.4 * t),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _lineColor.withValues(alpha: 0.18 * (1 - t)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Hint text below frame
            if (widget.hintText != null)
              Positioned(
                left: 24,
                right: 24,
                top: cutOut.bottom + 16,
                child: Center(
                  child: Text(
                    widget.hintText!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Bottom action bar (torch + gallery)
            Positioned(
              left: 0,
              right: 0,
              bottom: 100,
              child: SafeArea(
                top: false,
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    final torchOn = _controller.value.torchState == TorchState.on;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CircleAction(
                          icon: torchOn ? Icons.flash_on : Icons.flash_off,
                          highlighted: torchOn,
                          onTap: _toggleTorch,
                        ),
                        if (widget.allowGalleryPick) ...[
                          const SizedBox(width: 24),
                          _CircleAction(
                            icon: Icons.photo_library_outlined,
                            onTap: _pickFromGallery,
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted
          ? const Color(0xFFFFA726)
          : Colors.white.withValues(alpha: 0.15),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _PermissionErrorView extends StatelessWidget {
  const _PermissionErrorView({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_photography_outlined,
              size: 72,
              color: Colors.white70,
            ),
            const SizedBox(height: 16),
            Text(
              'Không thể truy cập camera',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng cấp quyền camera để quét mã QR coupon.',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => onRetry(),
              icon: const Icon(Icons.videocam_rounded),
              label: const Text('Cấp quyền camera'),
            ),
          ],
        ),
      ),
    );
  }
}
