import '../../../import.dart';

class MerchantRedeemState {
  const MerchantRedeemState({
    this.isScanning = true,
    this.lastScannedCode,
    this.error,
  });

  final bool isScanning;
  final String? lastScannedCode;
  final String? error;

  MerchantRedeemState copyWith({
    bool? isScanning,
    String? lastScannedCode,
    String? error,
  }) {
    return MerchantRedeemState(
      isScanning: isScanning ?? this.isScanning,
      lastScannedCode: lastScannedCode ?? this.lastScannedCode,
      error: error,
    );
  }
}

class MerchantRedeemCubit extends Cubit<MerchantRedeemState> {
  MerchantRedeemCubit() : super(const MerchantRedeemState());

  void onScanned(String code) {
    emit(state.copyWith(isScanning: false, lastScannedCode: code));
  }

  void resume() => emit(state.copyWith(isScanning: true, lastScannedCode: null));
}
