import 'package:core_data/core_data.dart';

class NotificationModel implements JsonModel<NotificationModel> {
  const NotificationModel({
    required this.id,
    required this.title,
    this.body = '',
    this.type,
    this.isRead = false,
    this.createdAt,
    this.screen,
    this.referenceId,
    this.imageUrl,
    this.params,
  });

  const NotificationModel.empty()
      : id = '',
        title = '',
        body = '',
        type = null,
        isRead = false,
        createdAt = null,
        screen = null,
        referenceId = null,
        imageUrl = null,
        params = null;

  final String id;
  final String title;
  final String body;
  final String? type;
  final bool isRead;
  final DateTime? createdAt;
  final String? screen;
  final String? referenceId;
  final String? imageUrl;
  final Map<String, dynamic>? params;

  @override
  String get idField => 'id';

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : null;
    return NotificationModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? json['description'] ?? json['content'] ?? '')
          .toString(),
      type: json['type']?.toString(),
      isRead: json['read'] == true ||
          json['is_read'] == true ||
          json['isRead'] == true,
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
      screen: json['screen']?.toString(),
      referenceId: (json['reference_id'] ??
              json['referenceId'] ??
              json['reportId'] ??
              data?['voucherCodeId'] ??
              data?['campaignId'])
          ?.toString(),
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? json['image'])
          ?.toString(),
      params: data,
    );
  }

  @override
  NotificationModel fromJson(Map<String, dynamic> json) =>
      NotificationModel.fromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        if (type != null) 'type': type,
        'read': isRead,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (screen != null) 'screen': screen,
        if (referenceId != null) 'reference_id': referenceId,
        if (imageUrl != null) 'image_url': imageUrl,
        if (params != null) 'data': params,
      };

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      screen: screen,
      referenceId: referenceId,
      imageUrl: imageUrl,
      params: params,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
