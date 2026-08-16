import 'package:flutter/material.dart';
import 'package:prohealth/app/services/api/managers/emr_module_manager/emr_dashboard_tab_manager/dashboard_notification_tab.dart';
import '../../../../../app/resources/color.dart';
import '../../../../../app/resources/font_manager.dart';

enum _NotifType { approval, warning, rejected, authorized, correction, hha, declined, visitRequest }

_NotifType _typeFromString(String type) {
  switch (type.toLowerCase()) {
    case 'approval':               return _NotifType.approval;
    case 'oasis_correction':       return _NotifType.warning;
    case 'rejected':               return _NotifType.rejected;
    case 'authorized':             return _NotifType.authorized;
    case 'correction':             return _NotifType.correction;
    case 'lupa_risk':              return _NotifType.hha;
    case 'declined':               return _NotifType.declined;
    case 'visit_request_received': return _NotifType.visitRequest;
    default:                       return _NotifType.approval;
  }
}

String? _actionLabelFromType(_NotifType type) {
  switch (type) {
    case _NotifType.approval:   return 'OASIS_CORRECTION';
    case _NotifType.warning:    return 'Create Order';
    case _NotifType.correction: return 'Correct';
    case _NotifType.hha:        return 'Patient Schedule';
    case _NotifType.declined:   return 'My Schedule';
    default:                    return null;
  }
}

bool _showAcceptDecline(_NotifType type) => type == _NotifType.visitRequest;

// ── Panel ─────────────────────────────────────────────────────────────────────
class EMRNotificationPanel extends StatefulWidget {
  final VoidCallback onClose;

  const EMRNotificationPanel({
    super.key,
    required this.onClose,
  });

  @override
  State<EMRNotificationPanel> createState() => _EMRNotificationPanelState();
}

class _EMRNotificationPanelState extends State<EMRNotificationPanel> {
  List<NotificationData> _notifications = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  int _page = 1;
  int _totalPages = 1;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNotifications();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100 &&
        !_isLoadingMore &&
        _page < _totalPages) {
      _loadMoreNotifications();
    }
  }

  // @@@ initial / refresh load — always resets to page 1
  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _page = 1;
      _notifications = [];
    });

    try {
      final data = await getNotificationData(context);
      if (!mounted) return;
      setState(() {
        _notifications = data;
        // @@@ set _totalPages here when your API returns it
        // _totalPages = response.totalPages;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load notifications';
        _isLoading = false;
      });
    }
  }

  // @@@ separate method for load-more to avoid flag conflicts
  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _page + 1;
      final data = await getNotificationData(context); // @@@ pass nextPage when API supports it
      if (!mounted) return;
      setState(() {
        _notifications.addAll(data);
        _page = nextPage;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  void _dismiss(int index) => setState(() => _notifications.removeAt(index));

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 10, left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: FontSize.s14,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.darkgrey,
                ),
              ),
              InkWell(
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                onTap: widget.onClose,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 20, color: ColorManager.mediumgrey),
                ),
              ),
            ],
          ),

          // ── Body ──────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade300, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: TextStyle(
                      fontSize: FontSize.s12,
                      color: ColorManager.mediumgrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _loadNotifications,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
                : _notifications.isEmpty
                ? Center(
              child: Text(
                'No notifications!',
                style: TextStyle(
                  fontSize: FontSize.s13,
                  color: ColorManager.mediumgrey,
                ),
              ),
            )
                : ListView.separated(
              controller: _scrollController,
              itemCount: _notifications.length + (_isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                if (index == _notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final notif = _notifications[index];
                final notifType = _typeFromString(notif.type);
                return _NotifTile(
                  notifType: notifType,
                  title: notif.title,
                  body: notif.body,
                  createdAt: notif.createdAt,
                  isRead: notif.isRead,
                  actionLabel: _actionLabelFromType(notifType),
                  showAcceptDecline: _showAcceptDecline(notifType),
                  onDismiss: () => _dismiss(index),
                  colorData: notif.color == "RED"
                      ? ColorManager.redDark
                      : notif.color == "GREEN"
                      ? ColorManager.green
                      : notif.color == "YELLOW"
                      ? ColorManager.yellowBright
                      : ColorManager.orange,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Icon Config ───────────────────────────────────────────────────────────────
class _IconConfig {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  const _IconConfig(this.icon, this.iconColor, this.bgColor);
}

// ── Notification Tile ─────────────────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  final _NotifType notifType;
  final String title;
  final String body;
  final String createdAt;
  final bool isRead;
  final String? actionLabel;
  final bool showAcceptDecline;
  final VoidCallback onDismiss;
  final Color colorData;

  const _NotifTile({
    required this.colorData,
    required this.notifType,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    required this.onDismiss,
    this.actionLabel,
    this.showAcceptDecline = false,
  });

  _IconConfig _iconData(_NotifType type) {
    switch (type) {
      case _NotifType.approval:
        return _IconConfig(
            Icons.thumb_up_alt_outlined, Colors.blue.shade600, Colors.blue.shade50);
      case _NotifType.warning:
        return _IconConfig(
            Icons.event_note_outlined, colorData, Colors.red.shade50);
      case _NotifType.rejected:
        return _IconConfig(Icons.close, colorData, Colors.red.shade50);
      case _NotifType.authorized:
        return _IconConfig(
            Icons.check_circle_outline, Colors.green.shade600, Colors.green.shade50);
      case _NotifType.correction:
        return _IconConfig(
            Icons.check_circle_outline, Colors.orange.shade600, Colors.orange.shade50);
      case _NotifType.hha:
        return _IconConfig(
            Icons.warning_amber_outlined, Colors.orange.shade700, Colors.orange.shade50);
      case _NotifType.declined:
        return _IconConfig(
            Icons.thumb_down_alt_outlined, Colors.red.shade400, Colors.red.shade50);
      case _NotifType.visitRequest:
        return _IconConfig(
            Icons.add_circle_outline, colorData, Colors.yellow.shade50);
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _iconData(notifType);

    return Container(
      color: isRead ? Colors.white : Colors.blue.shade50.withOpacity(0.4),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon badge ────────────────────────────────────────────
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorData,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon.icon, size: 18, color: icon.iconColor),
          ),
          const SizedBox(width: 10),
          // ── Content ───────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty) ...[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: FontSize.s11,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.darkgrey,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  body,
                  style: TextStyle(
                    fontSize: FontSize.s11,
                    color: ColorManager.darkgrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  createdAt,
                  style: TextStyle(
                    fontSize: 10,
                    color: ColorManager.mediumgrey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // ── Dismiss ───────────────────────────────────────────────
          InkWell(
            onTap: onDismiss,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.close, size: 14, color: ColorManager.mediumgrey),
            ),
          ),
        ],
      ),
    );
  }
}