// Profile merchant của user hiện tại — lấy từ GET /api/merchants/me.
import 'package:equatable/equatable.dart';

/// Helpers parse — tolerant với type mismatch giữa BE và FE.
String _str(dynamic v) => v?.toString() ?? '';
int _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}
double _double(dynamic v) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}
bool _bool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v.toLowerCase() == 'true' || v == '1';
  return false;
}
List<String> _strList(dynamic v) {
  if (v is List) return v.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
  return const [];
}

class MerchantOwner extends Equatable {
  const MerchantOwner({
    required this.id,
    required this.merchantId,
    required this.fullName,
    required this.phone,
    required this.phone2,
    required this.identityNo,
    required this.email,
    required this.birthYear,
    required this.birthDate,
    required this.gender,
    required this.avatarUrl,
    required this.idCardImageUrl,
    required this.idCardIssuedDate,
    required this.idCardIssuedPlace,
  });

  final String id;
  final String merchantId;
  final String fullName;
  final String phone;
  final String phone2;
  final String identityNo;
  final String email;
  final int birthYear;
  final String birthDate;
  final int gender;
  final String avatarUrl;
  final String idCardImageUrl;
  final String idCardIssuedDate;
  final String idCardIssuedPlace;

  factory MerchantOwner.fromJson(Map<String, dynamic> j) => MerchantOwner(
    id: _str(j['_id'] ?? j['id']),
    merchantId: _str(j['merchantId']),
    fullName: _str(j['fullName']),
    phone: _str(j['phone']),
    phone2: _str(j['phone2']),
    identityNo: _str(j['identityNo']),
    email: _str(j['email']),
    birthYear: _int(j['birthYear']),
    birthDate: _str(j['birthDate']),
    gender: _int(j['gender']),
    avatarUrl: _str(j['avatarUrl']),
    idCardImageUrl: _str(j['idCardImageUrl']),
    idCardIssuedDate: _str(j['idCardIssuedDate']),
    idCardIssuedPlace: _str(j['idCardIssuedPlace']),
  );

  @override
  List<Object?> get props => [id, merchantId, fullName, phone, identityNo, idCardIssuedDate, idCardIssuedPlace];
}

class MerchantLicense extends Equatable {
  const MerchantLicense({
    required this.id,
    required this.merchantId,
    required this.licenseType,
    required this.licenseNumber,
    required this.issuedDate,
    required this.expiryDate,
    required this.status,
    required this.issuedByName,
    required this.fileUrl,
    required this.approvalStatus,
    required this.holderName,
    required this.businessField,
    required this.approvalStatusName,
  });

  final String id;
  final String merchantId;
  final String licenseType;
  final String licenseNumber;
  final String issuedDate;
  final String expiryDate;
  final String status;
  final String issuedByName;
  final String fileUrl;
  final int approvalStatus;
  final String holderName;
  final String businessField;
  final String approvalStatusName;

  factory MerchantLicense.fromJson(Map<String, dynamic> j) => MerchantLicense(
    id: _str(j['_id'] ?? j['id']),
    merchantId: _str(j['merchantId']),
    licenseType: _str(j['licenseType']),
    licenseNumber: _str(j['licenseNumber']),
    issuedDate: _str(j['issuedDate']),
    expiryDate: _str(j['expiryDate']),
    status: _str(j['status']),
    issuedByName: _str(j['issuedByName']),
    fileUrl: _str(j['fileUrl']),
    approvalStatus: _int(j['approvalStatus']),
    holderName: _str(j['holderName']),
    businessField: _str(j['businessField']),
    approvalStatusName: _str(j['approvalStatusName']),
  );

  @override
  List<Object?> get props => [id, licenseNumber, status, approvalStatusName];
}

class MerchantPhoto extends Equatable {
  const MerchantPhoto({
    required this.id,
    required this.merchantId,
    required this.url,
    required this.type,
    required this.capturedDate,
    required this.notes,
  });

  final String id;
  final String merchantId;
  final String url;
  final String type;
  final String capturedDate;
  final String notes;

  factory MerchantPhoto.fromJson(Map<String, dynamic> j) => MerchantPhoto(
    id: _str(j['_id'] ?? j['id']),
    merchantId: _str(j['merchantId']),
    url: _str(j['url']),
    type: _str(j['type']),
    capturedDate: _str(j['capturedDate']),
    notes: _str(j['notes']),
  );

  @override
  List<Object?> get props => [id, url];
}

class MerchantTax extends Equatable {
  const MerchantTax({
    required this.id,
    required this.merchantId,
    required this.taxNumber,
    required this.monthlyRevenue,
    required this.totalTax,
  });

  final String id;
  final String merchantId;
  final String taxNumber;
  final double monthlyRevenue;
  final double totalTax;

  factory MerchantTax.fromJson(Map<String, dynamic> j) => MerchantTax(
    id: _str(j['_id'] ?? j['id']),
    merchantId: _str(j['merchantId']),
    taxNumber: _str(j['taxNumber']),
    monthlyRevenue: _double(j['monthlyRevenue']),
    totalTax: _double(j['totalTax']),
  );

  @override
  List<Object?> get props => [id, taxNumber];
}

class MerchantLocation extends Equatable {
  const MerchantLocation({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.merchantId,
    required this.houseNo,
    required this.street,
    required this.ward,
    required this.district,
    required this.province,
    required this.latitude,
    required this.longitude,
    required this.isPrimary,
    required this.note,
    required this.businessHours,
  });

  final String id;
  final String createdAt;
  final String updatedAt;
  final String deletedAt;
  final String merchantId;
  final String houseNo;
  final String street;
  final String ward;
  final String district;
  final String province;
  final double latitude;
  final double longitude;
  final bool isPrimary;
  final String note;
  final Map<String, dynamic> businessHours;

  factory MerchantLocation.fromJson(Map<String, dynamic> j) => MerchantLocation(
    id: _str(j['_id'] ?? j['id']),
    createdAt: _str(j['createdAt']),
    updatedAt: _str(j['updatedAt']),
    deletedAt: _str(j['deletedAt']),
    merchantId: _str(j['merchantId']),
    houseNo: _str(j['houseNo']),
    street: _str(j['street']),
    ward: _str(j['ward']),
    district: _str(j['district']),
    province: _str(j['province']),
    latitude: _double(j['latitude']),
    longitude: _double(j['longitude']),
    isPrimary: _bool(j['isPrimary']),
    note: _str(j['note']),
    businessHours: j['businessHours'] is Map
        ? Map<String, dynamic>.from(j['businessHours'] as Map)
        : const {},
  );

  @override
  List<Object?> get props => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    merchantId,
    houseNo,
    street,
    ward,
    district,
    province,
    latitude,
    longitude,
    isPrimary,
    note,
    businessHours,
  ];
}

/// Profile merchant của user hiện tại (GET /api/merchants/me).
///
/// Field BE thêm về sau mà chưa có trong class này — truy cập qua [extra].
class MeMerchant extends Equatable {
  const MeMerchant({
    required this.businessName,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerId,
    required this.taxCode,
    required this.address,
    required this.houseNo,
    required this.street,
    required this.provinceId,
    required this.province,
    required this.district,
    required this.wardId,
    required this.ward,
    required this.departmentId,
    required this.businessType,
    required this.status,
    required this.licenseStatus,
    required this.licenseCount,
    required this.lastInspection,
    required this.establishedDate,
    required this.monthlyRevenue,
    required this.totalTax,
    required this.latitude,
    required this.longitude,
    required this.isHot,
    required this.verified,
    required this.complaintCount,
    required this.riskLevel,
    required this.note,
    required this.businessPhone,
    required this.businessEmail,
    required this.website,
    required this.storeArea,
    required this.governanceStatus,
    required this.registrationNo,
    required this.charterCapital,
    required this.mainBusinessLine,
    required this.changeVersion,
    required this.categoryIds,
    required this.owners,
    required this.licenses,
    required this.photos,
    required this.tax,
    required this.merchantStaff,
    required this.merchantLawDocs,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.riskScore,
    required this.riskLevelAuto,
    required this.riskScoredAt,
    required this.riskLevelManual,
    required this.isHotManual,
    required this.riskManualReason,
    required this.riskManualBy,
    required this.riskManualAt,
    required this.riskManualUntil,
    required this.businessHours,
    required this.businessTypeName,
    required this.categoryId,
    required this.locations,
    required this.raw,
  });

  final String businessName;
  final String ownerName;
  final String ownerPhone;
  final String ownerId;
  final String taxCode;

  final String address;
  final String houseNo;
  final String street;
  final String provinceId;
  final String province;
  final String district;
  final String wardId;
  final String ward;
  final String departmentId;

  final String businessType;
  final String status;
  final String licenseStatus;
  final int licenseCount;
  final String lastInspection;
  final String establishedDate;

  // BE trả String cho doanh thu/thuế — giữ nguyên type để khỏi mất format.
  final String monthlyRevenue;
  final String totalTax;

  final double latitude;
  final double longitude;

  final bool isHot;
  final bool verified;
  final int complaintCount;
  final int riskLevel;

  final String note;
  final String businessPhone;
  final String businessEmail;
  final String website;
  final double storeArea;

  final String governanceStatus;
  final String registrationNo;
  final String charterCapital;
  final String mainBusinessLine;
  final int changeVersion;

  final List<String> categoryIds;
  final List<MerchantOwner> owners;
  final List<MerchantLicense> licenses;
  final List<MerchantPhoto> photos;
  final MerchantTax? tax;

  final Map<String, dynamic> merchantStaff;
  final Map<String, dynamic> merchantLawDocs;

  final String createdAt;
  final String updatedAt;
  final String deletedAt;
  final double riskScore;
  final int riskLevelAuto;
  final String riskScoredAt;
  final int riskLevelManual;
  final bool isHotManual;
  final String riskManualReason;
  final String riskManualBy;
  final String riskManualAt;
  final String riskManualUntil;
  final Map<String, dynamic> businessHours;
  final String businessTypeName;
  final String categoryId;
  final List<MerchantLocation> locations;

  /// Payload gốc — dùng khi BE bổ sung field mới mà class chưa cập nhật.
  final Map<String, dynamic> raw;

  /// Đọc field tùy ý từ payload gốc (cho field mới chưa được đưa lên class).
  T? extra<T>(String key) {
    final v = raw[key];
    return v is T ? v : null;
  }

  /// Lấy _id hoặc id thực tế của merchant từ response /api/merchants/me
  String get id => raw['_id'] ?? raw['id'] ?? '';

  /// id đại diện — không có field `id` trực tiếp, lấy từ owners[0].merchantId.
  String get merchantId {
    if (owners.isEmpty) return '';
    return owners.first.merchantId;
  }

  factory MeMerchant.fromJson(Map<String, dynamic> json) {
    // Hỗ trợ cả response `{success, data: {...}}` lẫn payload phẳng.
    final dataRaw = json['data'];
    final body = dataRaw is Map<String, dynamic> ? dataRaw : json;

    List<T> _list<T>(dynamic raw, T Function(Map<String, dynamic>) parse) {
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((e) => parse(Map<String, dynamic>.from(e)))
          .toList();
    }

    return MeMerchant(
      businessName: _str(body['businessName']),
      ownerName: _str(body['ownerName']),
      ownerPhone: _str(body['ownerPhone']),
      ownerId: _str(body['ownerId']),
      taxCode: _str(body['taxCode']),
      address: _str(body['address']),
      houseNo: _str(body['houseNo']),
      street: _str(body['street']),
      provinceId: _str(body['provinceId']),
      province: _str(body['province']),
      district: _str(body['district']),
      wardId: _str(body['wardId']),
      ward: _str(body['ward']),
      departmentId: _str(body['departmentId']),
      businessType: _str(body['businessType']),
      status: _str(body['status']),
      licenseStatus: _str(body['licenseStatus']),
      licenseCount: _int(body['licenseCount']),
      lastInspection: _str(body['lastInspection']),
      establishedDate: _str(body['establishedDate']),
      monthlyRevenue: _str(body['monthlyRevenue']),
      totalTax: _str(body['totalTax']),
      latitude: _double(body['latitude']),
      longitude: _double(body['longitude']),
      isHot: _bool(body['isHot']),
      verified: _bool(body['verified']),
      complaintCount: _int(body['complaintCount']),
      riskLevel: _int(body['riskLevel']),
      note: _str(body['note']),
      businessPhone: _str(body['businessPhone']),
      businessEmail: _str(body['businessEmail']),
      website: _str(body['website']),
      storeArea: _double(body['storeArea']),
      governanceStatus: _str(body['governanceStatus']),
      registrationNo: _str(body['registrationNo']),
      charterCapital: _str(body['charterCapital']),
      mainBusinessLine: _str(body['mainBusinessLine']),
      changeVersion: _int(body['changeVersion']),
      categoryIds: _strList(body['categoryIds']),
      owners: _list(body['owners'], MerchantOwner.fromJson),
      licenses: _list(body['licenses'], MerchantLicense.fromJson),
      photos: _list(body['photos'], MerchantPhoto.fromJson),
      tax: body['tax'] is Map<String, dynamic>
          ? MerchantTax.fromJson(body['tax'] as Map<String, dynamic>)
          : null,
      merchantStaff: body['merchantStaff'] is Map
          ? Map<String, dynamic>.from(body['merchantStaff'] as Map)
          : const {},
      merchantLawDocs: body['merchantLawDocs'] is Map
          ? Map<String, dynamic>.from(body['merchantLawDocs'] as Map)
          : const {},
      createdAt: _str(body['createdAt']),
      updatedAt: _str(body['updatedAt']),
      deletedAt: _str(body['deletedAt']),
      riskScore: _double(body['riskScore']),
      riskLevelAuto: _int(body['riskLevelAuto']),
      riskScoredAt: _str(body['riskScoredAt']),
      riskLevelManual: _int(body['riskLevelManual']),
      isHotManual: _bool(body['isHotManual']),
      riskManualReason: _str(body['riskManualReason']),
      riskManualBy: _str(body['riskManualBy']),
      riskManualAt: _str(body['riskManualAt']),
      riskManualUntil: _str(body['riskManualUntil']),
      businessHours: body['businessHours'] is Map
          ? Map<String, dynamic>.from(body['businessHours'] as Map)
          : const {},
      businessTypeName: _str(body['businessTypeName']),
      categoryId: _str(body['categoryId']),
      locations: _list(body['locations'], MerchantLocation.fromJson),
      raw: Map<String, dynamic>.from(body),
    );
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);

  @override
  List<Object?> get props => [
    businessName,
    ownerId,
    taxCode,
    status,
    changeVersion,
    owners.length,
    licenses.length,
    photos.length,
    merchantStaff,
    merchantLawDocs,
    createdAt,
    updatedAt,
    deletedAt,
    riskScore,
    riskLevelAuto,
    riskScoredAt,
    riskLevelManual,
    isHotManual,
    riskManualReason,
    riskManualBy,
    riskManualAt,
    riskManualUntil,
    businessHours,
    businessTypeName,
    categoryId,
    locations.length,
  ];
}
