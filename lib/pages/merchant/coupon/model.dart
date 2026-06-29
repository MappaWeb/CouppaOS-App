import 'package:core_data/core_data.dart';

class VoucherModel implements JsonModel<VoucherModel> {
  const VoucherModel({
    required this.id,
    this.merchantId = '',
    this.slug = '',
    this.code = '',
    this.name = '',
    this.faceValue,
    this.claimLayout,
    this.note,
    this.issueMode,
    this.status = '',
    this.totalQuantity = 0,
    this.issuedCount = 0,
    this.validFrom,
    this.validTo,
    this.maxPerUser = 0,
    this.maxPerPhone = 0,
    this.maxPerDevice = 0,
    this.webClaimAllowed = false,
    this.otpRequired = false,
    this.reserveTtlSeconds = 0,
    this.usageDaysOfWeek = const [],
    this.usageDates,
    this.usageWindows = const [],
    this.createdAt,
  });

  const VoucherModel.empty() : this(id: '');

  @override
  final String id;
  final String merchantId;
  final String slug;
  final String code;
  final String name;
  final num? faceValue;
  final String? claimLayout;
  final String? note;
  final String? issueMode;
  final String status;
  final int totalQuantity;
  final int issuedCount;
  final DateTime? validFrom;
  final DateTime? validTo;
  final int maxPerUser;
  final int maxPerPhone;
  final int maxPerDevice;
  final bool webClaimAllowed;
  final bool otpRequired;
  final int reserveTtlSeconds;
  final List<int> usageDaysOfWeek;
  final List<dynamic>? usageDates;
  final List<dynamic> usageWindows;
  final DateTime? createdAt;

  @override
  String get idField => 'id';

  static DateTime? _date(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static List<int> _intList(dynamic v) {
    if (v is List) return v.map(_int).toList();
    return const [];
  }

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      merchantId: (json['merchantId'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      faceValue: json['faceValue'] is num ? json['faceValue'] as num : null,
      claimLayout: json['claimLayout']?.toString(),
      note: json['note']?.toString(),
      issueMode: json['issueMode']?.toString(),
      status: (json['status'] ?? '').toString(),
      totalQuantity: _int(json['totalQuantity']),
      issuedCount: _int(json['issuedCount']),
      validFrom: _date(json['validFrom']),
      validTo: _date(json['validTo']),
      maxPerUser: _int(json['maxPerUser']),
      maxPerPhone: _int(json['maxPerPhone']),
      maxPerDevice: _int(json['maxPerDevice']),
      webClaimAllowed: json['webClaimAllowed'] == true,
      otpRequired: json['otpRequired'] == true,
      reserveTtlSeconds: _int(json['reserveTtlSeconds']),
      usageDaysOfWeek: _intList(json['usageDaysOfWeek']),
      usageDates: json['usageDates'] is List
          ? List<dynamic>.from(json['usageDates'] as List)
          : null,
      usageWindows: json['usageWindows'] is List
          ? List<dynamic>.from(json['usageWindows'] as List)
          : const [],
      createdAt: _date(json['createdAt']),
    );
  }

  @override
  VoucherModel fromJson(Map<String, dynamic> json) =>
      VoucherModel.fromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'merchantId': merchantId,
        'slug': slug,
        'code': code,
        'name': name,
        'faceValue': faceValue,
        'claimLayout': claimLayout,
        'note': note,
        'issueMode': issueMode,
        'status': status,
        'totalQuantity': totalQuantity,
        'issuedCount': issuedCount,
        'validFrom': validFrom?.toIso8601String(),
        'validTo': validTo?.toIso8601String(),
        'maxPerUser': maxPerUser,
        'maxPerPhone': maxPerPhone,
        'maxPerDevice': maxPerDevice,
        'webClaimAllowed': webClaimAllowed,
        'otpRequired': otpRequired,
        'reserveTtlSeconds': reserveTtlSeconds,
        'usageDaysOfWeek': usageDaysOfWeek,
        'usageDates': usageDates,
        'usageWindows': usageWindows,
        'createdAt': createdAt?.toIso8601String(),
      };
}
