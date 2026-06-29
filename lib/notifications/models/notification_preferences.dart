class NotificationPreferences {
  const NotificationPreferences({
    this.redeemAlerts = true,
    this.linkRequests = true,
    this.promoAlerts = false,
    this.voucherExpiryAlerts = false,
  });

  final bool redeemAlerts;
  final bool linkRequests;
  final bool promoAlerts;
  final bool voucherExpiryAlerts;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      redeemAlerts: json['redeemAlerts'] != false,
      linkRequests: json['linkRequests'] != false,
      promoAlerts: json['promoAlerts'] == true,
      voucherExpiryAlerts: json['voucherExpiryAlerts'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'redeemAlerts': redeemAlerts,
        'linkRequests': linkRequests,
        'promoAlerts': promoAlerts,
        'voucherExpiryAlerts': voucherExpiryAlerts,
      };

  NotificationPreferences copyWith({
    bool? redeemAlerts,
    bool? linkRequests,
    bool? promoAlerts,
    bool? voucherExpiryAlerts,
  }) {
    return NotificationPreferences(
      redeemAlerts: redeemAlerts ?? this.redeemAlerts,
      linkRequests: linkRequests ?? this.linkRequests,
      promoAlerts: promoAlerts ?? this.promoAlerts,
      voucherExpiryAlerts: voucherExpiryAlerts ?? this.voucherExpiryAlerts,
    );
  }
}
