import '../../import.dart';
import '../models/notification_model.dart';

class NotificationItemWidget extends StatelessWidget {
  const NotificationItemWidget(this.notification, {super.key, this.onTap});

  final NotificationModel notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead
              ? Palette.dividerColor
              : Palette.primary.withValues(alpha: 0.2),
          width: isRead ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeading(isRead),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(isRead),
                      const SizedBox(height: 8),
                      _buildTitle(isRead),
                      if (notification.body.isNotEmpty &&
                          notification.body != notification.title) ...[
                        const SizedBox(height: 6),
                        Text(
                          notification.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Palette.textPrimary2,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      _buildTimestamp(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(bool isRead) {
    if (notification.imageUrl != null && notification.imageUrl!.isNotEmpty) {
      return ClipOval(
        child: ImageViewer(
          notification.imageUrl,
          width: 48,
          height: 48,
          notThumb: true,
        ),
      );
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isRead
            ? Palette.bgColor
            : Palette.primary.withValues(alpha: 0.1),
      ),
      child: Icon(
        Icons.notifications_outlined,
        color: isRead ? Palette.textPrimary3 : Palette.primary,
        size: 24,
      ),
    );
  }

  Widget _buildHeader(bool isRead) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Palette.redTxtColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.campaign, size: 14, color: Palette.redTxtColor),
              SizedBox(width: 4),
              Text(
                'Mappa',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Palette.redTxtColor,
                ),
              ),
            ],
          ),
        ),
        if (!isRead) ...[
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Palette.primary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTitle(bool isRead) {
    return Text(
      notification.title,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 15,
        fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
        color: Palette.textPrimary,
        height: 1.3,
      ),
    );
  }

  Widget _buildTimestamp() {
    if (notification.createdAt == null) return const SizedBox.shrink();
    return Row(
      children: [
        const Icon(Icons.access_time, size: 12, color: Palette.textPrimary3),
        const SizedBox(width: 4),
        Expanded(
          child: TimeAgo(
            notification.createdAt!,
            style: const TextStyle(fontSize: 12, color: Palette.textPrimary3),
          ),
        ),
      ],
    );
  }
}
