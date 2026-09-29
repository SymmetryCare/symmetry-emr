import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/setting_profile_manager/time_off_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/setting_profile_data/time_off_data.dart';

import 'package:flutter/material.dart';

class ViewHistoryPopup extends StatefulWidget {
  final int employeeId;
  const ViewHistoryPopup({super.key, required this.employeeId});

  @override
  State<ViewHistoryPopup> createState() => _ViewHistoryPopupState();
}

class _ViewHistoryPopupState extends State<ViewHistoryPopup> {
  late Future<List<TimeOffHistoryData>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = getTimeOffHistory(
      context: context,
      employeeId: widget.employeeId,
    );
  }

  void _retry() {
    setState(() {
      _historyFuture = getTimeOffHistory(
        context: context,
        employeeId: widget.employeeId,
      );
    });
  }

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: SizedBox(
        width: 450,
        height: 460,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: _close,
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 18,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'View History',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // ── Body ──────────────────────────────────────────────────────
              Expanded(
                child: FutureBuilder<List<TimeOffHistoryData>>(
                  future: _historyFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return  Center(
                        child: CircularProgressIndicator(
                          color: ColorManager.blueprime,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Color(0xFFC62828), size: 36),
                            const SizedBox(height: 8),
                            const Text(
                              'Failed to load history.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF757575)),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _retry,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final items = snapshot.data ?? [];

                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          'No history found!',
                          style: AllNoDataAvailable.customTextStyle(context)),
                      );
                    }

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: items
                            .map((item) => _HistoryCard(item: item))
                            .toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final TimeOffHistoryData item;

  const _HistoryCard({required this.item});

  String get _status => item.status?.trim() ?? 'pending';

  ({Color bg, Color text}) get _statusColors {
    switch (_status.toLowerCase()) {
      case 'approved':
        return (bg: const Color(0xFFE8F5E9), text: const Color(0xFF2E7D32));
      case 'rejected':
        return (bg: const Color(0xFFFFEBEE), text: const Color(0xFFC62828));
      case 'pending':
      default:
        return (bg: const Color(0xFFFFF3E0), text: const Color(0xFFE65100));
    }
  }

  /// Formats ISO date string "2026-04-14T00:00:00.000Z" → "14/04/2026"
  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors;

    final String employeeName = item.employeeName ?? 'Employee';
    final String leaveType    = item.timeOffTypeName ?? '-';
    final String startDate    = _formatDate(item.startDate);
    final String endDate      = _formatDate(item.endDate);
    final String? reason =
    (item.reason != null && item.reason!.isNotEmpty) ? item.reason : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Employee name + Status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 16, color: Color(0xFF757575)),
                  const SizedBox(width: 6),
                  Text(
                    employeeName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              _StatusBadge(
                label: _status,
                backgroundColor: colors.bg,
                textColor: colors.text,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Leave type (from API: timeOffTypeName)
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Color(0xFF757575)),
              const SizedBox(width: 6),
              Text(
                leaveType,
                style:  TextStyle(
                  fontSize: 13,
                  color: ColorManager.blueprime,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Date range
          Row(
            children: [
              const Icon(Icons.access_time_outlined,
                  size: 14, color: Color(0xFF757575)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$startDate  to  $endDate',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF757575)),
                ),
              ),
            ],
          ),

          // Reason (only if not null/empty)
          if (reason != null) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.help_outline,
                    size: 14, color: Color(0xFF757575)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    reason,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF757575)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _StatusBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.isNotEmpty
            ? '${label[0].toUpperCase()}${label.substring(1).toLowerCase()}'
            : '-',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}