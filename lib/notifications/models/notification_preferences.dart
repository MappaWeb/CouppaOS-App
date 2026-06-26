class NotificationPreferences {
  const NotificationPreferences({
    this.redeemAlerts = true,
    this.linkRequests = true,
  });

  final bool redeemAlerts;
  final bool linkRequests;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      redeemAlerts: json['redeemAlerts'] != false,
      linkRequests: json['linkRequests'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
        'redeemAlerts': redeemAlerts,
        'linkRequests': linkRequests,
      };

  NotificationPreferences copyWith({bool? redeemAlerts, bool? linkRequests}) {
    return NotificationPreferences(
      redeemAlerts: redeemAlerts ?? this.redeemAlerts,
      linkRequests: linkRequests ?? this.linkRequests,
    );
  }
}
