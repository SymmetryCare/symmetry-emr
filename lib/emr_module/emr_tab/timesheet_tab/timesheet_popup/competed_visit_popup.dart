import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../../app/resources/color.dart';
import '../../../../../../app/resources/value_manager.dart';
import '../../../../../../app/services/api/managers/emr_module_manager/timesheet_tab_manager/timesheet_tab_manager.dart';
import '../../../../../../data/api_data/emr_module_data/timesheet_tab_data/timesheet_data.dart';
import '../../popup_const_emr.dart';

class CompletedVisitsPopup extends StatefulWidget {
  final String date;
  const CompletedVisitsPopup({super.key, required this.date});

  @override
  State<CompletedVisitsPopup> createState() => _CompletedVisitsPopupState();
}

class _CompletedVisitsPopupState extends State<CompletedVisitsPopup> {
  final _stream = StreamController<List<CompletedVisitsPopupData>>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _stream.close();
    super.dispose();
  }

  Future<void> _load() async {
    final data = await getCompletedVisitsPopup(context, widget.date);
    _stream.add(data);
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplateNoButtonsColoum(
      width: 450,
      height: 350,
      title: 'Completed Visits',
      body: [
        StreamBuilder<List<CompletedVisitsPopupData>>(
          stream: _stream.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.data!.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'No completed visits!',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              );
            }
            final visits = snapshot.data!;
            return SizedBox(
              height: 260,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView.builder(
                  itemCount: visits.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppPadding.p10),
                    child: _CompletedVisitRow(
                      visitNumber: i + 1,
                      data: visits[i],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Single completed visit row ────────────────────────────────────────────────

class _CompletedVisitRow extends StatelessWidget {
  final int visitNumber;
  final CompletedVisitsPopupData data;

  const _CompletedVisitRow({
    required this.visitNumber,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final initials = data.patientName.trim().split(' ').length >= 2
        ? '${data.patientName.trim().split(' ').first[0]}${data.patientName.trim().split(' ').last[0]}'
        .toUpperCase()
        : data.patientName.trim().isNotEmpty
        ? data.patientName.trim()[0].toUpperCase()
        : '?';

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 0.8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // ── Colored left border indicator ─────────────────────────────────
          Container(
            width: 18,
            height: 80,
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: ColorManager.incidentskin,
              borderRadius: BorderRadius.circular(2),
            ),
            alignment: Alignment.center,
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                data.visitTypeName,
                style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Avatar ────────────────────────────────────────────────────────
          CircleAvatar(
            radius: 18,
            backgroundColor: ColorManager.circleColor,
            backgroundImage: data.patientImgUrl.isNotEmpty
                ? NetworkImage(data.patientImgUrl)
                : null,
            child: data.patientImgUrl.isEmpty
                ? Text(
              initials,
              style: TextStyle(
                color: ColorManager.mediumgrey,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            )
                : null,
          ),
          const SizedBox(width: 10),

          // ── Visit number + name + visit type ──────────────────────────────
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
                  data.patientName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${data.visitTypeName} Visit',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          // ── Amount ────────────────────────────────────────────────────────
          Expanded(
            flex: 2,
            child: Text(
              data.visitCharge != null
                  ? '\$${data.visitCharge!.toStringAsFixed(0)}'
                  : '-',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF43A047),
              ),
            ),
          ),

          // ── Date + Time ───────────────────────────────────────────────────
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
                      data.visitDate,
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
                  '${data.timeFrom}–${data.timeTo}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── Circular progress ─────────────────────────────────────────────
          _CircularProgressBadge(percent: data.completionPercentage),
        ],
      ),
    );
  }
}

// ── Circular progress badge ───────────────────────────────────────────────────

class _CircularProgressBadge extends StatelessWidget {
  final int percent;

  const _CircularProgressBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: percent / 100,
            strokeWidth: 5.5,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF43A047),
            ),
          ),
          Center(
            child: Text(
              '$percent%',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Color(0xFF43A047),
              ),
            ),
          ),
        ],
      ),
    );
  }
}