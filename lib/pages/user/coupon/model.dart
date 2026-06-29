import 'package:core_data/core_data.dart';

class MyVoucherModel implements JsonModel<MyVoucherModel> {
  const MyVoucherModel({
    required this.voucherCodeId,
    this.code = '',
    this.campaignId = '',
    this.campaignName = '',
    this.merchantId = '',
    this.merchantName = '',
    this.faceValue,
    this.status = '',
    this.expiresAt,
    this.claimedAt,
    this.qr = '',
  });

  const MyVoucherModel.empty() : this(voucherCodeId: '');

  final String voucherCodeId;
  final String code;
  final String campaignId;
  final String campaignName;
  final String merchantId;
  final String merchantName;
  final num? faceValue;
  final String status;
  final DateTime? expiresAt;
  final DateTime? claimedAt;
  final String qr;

  @override
  String get id => voucherCodeId;

  @override
  String get idField => 'voucherCodeId';

  bool get isUsable {
    if (status.toUpperCase() != 'ISSUED') return false;
    final exp = expiresAt;
    if (exp == null) return true;
    return exp.isAfter(DateTime.now());
  }

  static DateTime? _date(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  factory MyVoucherModel.fromJson(Map<String, dynamic> json) {
    return MyVoucherModel(
      voucherCodeId: (json['voucherCodeId'] ?? json['id'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      campaignId: (json['campaignId'] ?? '').toString(),
      campaignName: (json['campaignName'] ?? '').toString(),
      merchantId: (json['merchantId'] ?? '').toString(),
      merchantName: (json['merchantName'] ?? '').toString(),
      faceValue: json['faceValue'] is num ? json['faceValue'] as num : null,
      status: (json['status'] ?? '').toString(),
      expiresAt: _date(json['expiresAt']),
      claimedAt: _date(json['claimedAt']),
      qr: (json['qr'] ?? '').toString(),
    );
  }

  @override
  MyVoucherModel fromJson(Map<String, dynamic> json) =>
      MyVoucherModel.fromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        'voucherCodeId': voucherCodeId,
        'code': code,
        'campaignId': campaignId,
        'campaignName': campaignName,
        'merchantId': merchantId,
        'merchantName': merchantName,
        'faceValue': faceValue,
        'status': status,
        'expiresAt': expiresAt?.toIso8601String(),
        'claimedAt': claimedAt?.toIso8601String(),
        'qr': qr,
      };
}
