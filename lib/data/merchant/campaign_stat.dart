class CampaignStat {
  const CampaignStat({
    required this.campaignId,
    required this.name,
    required this.status,
    required this.totalQuantity,
    required this.issuedCount,
    required this.claimedCount,
    required this.redeemedCount,
    required this.unclaimedCount,
    required this.unusedCount,
  });

  final String campaignId;
  final String name;
  final String status;
  final int totalQuantity;
  final int issuedCount;
  final int claimedCount;
  final int redeemedCount;
  final int unclaimedCount;
  final int unusedCount;

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  factory CampaignStat.fromJson(Map<String, dynamic> json) => CampaignStat(
        campaignId: (json['campaignId'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        status: (json['status'] ?? '').toString(),
        totalQuantity: _int(json['totalQuantity']),
        issuedCount: _int(json['issuedCount']),
        claimedCount: _int(json['claimedCount']),
        redeemedCount: _int(json['redeemedCount']),
        unclaimedCount: _int(json['unclaimedCount']),
        unusedCount: _int(json['unusedCount']),
      );

  Map<String, dynamic> toJson() => {
        'campaignId': campaignId,
        'name': name,
        'status': status,
        'totalQuantity': totalQuantity,
        'issuedCount': issuedCount,
        'claimedCount': claimedCount,
        'redeemedCount': redeemedCount,
        'unclaimedCount': unclaimedCount,
        'unusedCount': unusedCount,
      };
}
