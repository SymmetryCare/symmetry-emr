import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/timesheet_tab_manager/timesheet_tab_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/timesheet_tab_data/timesheet_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';

class PendingVisitsPopup extends StatefulWidget {
  final String date;

  const PendingVisitsPopup({super.key, required this.date});

  @override
  State<PendingVisitsPopup> createState() => _PendingVisitsPopupState();
}

class _PendingVisitsPopupState extends State<PendingVisitsPopup> {
  bool _isLoading = true;
  List<PendingVisitItemData> _visits = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await getPendingVisitsPopup(context, widget.date);
    setState(() {
      _visits = data?.visits ?? [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplateNoButtonsColoum(
      width: 450,
      height: 350,
      title: 'Pending Visits',
      body: [
        if (_isLoading)
          const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_visits.isEmpty)
          const SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'No pending visits!',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          )
        else
          SizedBox(
            height: 260,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: AppPadding.p16),
                itemCount: _visits.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppPadding.p10),
                  child: _PendingVisitRow(item: _visits[i], visitNumber: i + 1),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Single pending visit row ──────────────────────────────────────────────────

class _PendingVisitRow extends StatelessWidget {
  final PendingVisitItemData item;
  final int visitNumber;

  const _PendingVisitRow({required this.item, required this.visitNumber});

  String get _initials {
    final parts = item.patientName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // ── Colored left border indicator ──────────────────────────────
          Container(
            width: 18,
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: ColorManager.incidentskin,
              borderRadius: BorderRadius.circular(2),
            ),
            alignment: Alignment.center,
            child: RotatedBox(
              quarterTurns: 3,
              child: SizedBox(
                width: 76,
                child: _VisitTypeLabel(text: item.visitTypeName),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Avatar ────────────────────────────────────────────────────
          CircleAvatar(
            radius: 18,
            backgroundColor: ColorManager.circleColor,
            child: Text(
              _initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Visit number + name + visit type ──────────────────────────
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visit $visitNumber',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.patientName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.visitTypeName,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          // ── Amount ────────────────────────────────────────────────────
          Expanded(
            flex: 2,
            child: Text(
              item.visitCharge != null
                  ? '\$${item.visitCharge!.toStringAsFixed(2)}'
                  : '--',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade600,
              ),
            ),
          ),

          // ── Date + Time ───────────────────────────────────────────────
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 11, color: Colors.blue.shade400),
                    const SizedBox(width: 4),
                    Text(
                      item.visitDate,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.timeFrom}–${item.timeTo}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── Circular progress badge ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: AppPadding.p5),
            child: _PendingProgressBadge(percent: item.completionPercentage),
          ),

        ],
      ),
    );
  }
}

// ── Auto-fit visit type label: full text if it fits in 1 line, else initials ──

class _VisitTypeLabel extends StatelessWidget {
  final String text;

  const _VisitTypeLabel({required this.text});

  String get _initials {
    final words = text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    return words.map((w) => w[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w800,
      color: Colors.white,
      letterSpacing: 0.5,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final fits = !painter.didExceedMaxLines;

        return Text(
          fits ? text : _initials,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: style,
        );
      },
    );
  }
}

// ── Circular progress badge ───────────────────────────────────────────────────

class _PendingProgressBadge extends StatelessWidget {
  final int percent;

  const _PendingProgressBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    final double value = percent / 100.0;
    const Color activeColor = Color(0xFF00ACC1);

    return SizedBox(
      width: 38,
      height: 38,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 5.5,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(activeColor),
          ),
          Center(
            child: Text(
              '$percent%',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: activeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}