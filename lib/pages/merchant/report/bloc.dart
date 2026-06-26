import '../../../import.dart';

class MerchantReportState {
  const MerchantReportState({
    this.isLoading = false,
    this.totalRevenue = 0,
    this.totalRedeemed = 0,
    this.totalIssued = 0,
    this.error,
  });

  final bool isLoading;
  final double totalRevenue;
  final int totalRedeemed;
  final int totalIssued;
  final String? error;

  MerchantReportState copyWith({
    bool? isLoading,
    double? totalRevenue,
    int? totalRedeemed,
    int? totalIssued,
    String? error,
  }) {
    return MerchantReportState(
      isLoading: isLoading ?? this.isLoading,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalRedeemed: totalRedeemed ?? this.totalRedeemed,
      totalIssued: totalIssued ?? this.totalIssued,
      error: error,
    );
  }
}

class MerchantReportCubit extends Cubit<MerchantReportState> {
  MerchantReportCubit() : super(const MerchantReportState());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    // TODO: fetch report data from repository
    emit(state.copyWith(isLoading: false));
  }
}
