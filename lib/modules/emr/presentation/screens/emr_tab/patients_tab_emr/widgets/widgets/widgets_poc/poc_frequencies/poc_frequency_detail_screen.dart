import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/providers/hh_emr/visit_details_provider.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────

enum VisitType {
  ptSOC,
  ptRevisit,
  ptDisciplineDC,
  otRevisit,
  otDisciplineDC,
  stRevisit,
  stEvalOasis,
  ptaRevisit,
  ptaMissedVisit,
  episodeStarts,
  episodeEnds,
  startOf2nd30Days,
}

class CalendarVisitEvent {
  final DateTime date;
  final VisitType type;
  final bool isCompleted;

  CalendarVisitEvent({
    required this.date,
    required this.type,
    this.isCompleted = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SAMPLE DATA
// ─────────────────────────────────────────────────────────────────────────────

List<CalendarVisitEvent> getSampleEvents() {
  final now = DateTime.now();
  final y = now.year;
  final m = now.month;
  return [
    CalendarVisitEvent(date: DateTime(y, m, 2),      type: VisitType.episodeStarts),
    CalendarVisitEvent(date: DateTime(y, m, 2),      type: VisitType.ptSOC, isCompleted: true),
    CalendarVisitEvent(date: DateTime(y, m, 4),      type: VisitType.otRevisit, isCompleted: true),
    CalendarVisitEvent(date: DateTime(y, m, 5),      type: VisitType.ptRevisit, isCompleted: true),
    CalendarVisitEvent(date: DateTime(y, m, 8),      type: VisitType.ptRevisit, isCompleted: true),
    CalendarVisitEvent(date: DateTime(y, m, 10),     type: VisitType.ptRevisit),
    CalendarVisitEvent(date: DateTime(y, m, 10),     type: VisitType.otRevisit),
    CalendarVisitEvent(date: DateTime(y, m, 11),     type: VisitType.ptaMissedVisit),
    CalendarVisitEvent(date: DateTime(y, m, 15),     type: VisitType.stEvalOasis),
    CalendarVisitEvent(date: DateTime(y, m, 17),     type: VisitType.otRevisit),
    CalendarVisitEvent(date: DateTime(y, m, 19),     type: VisitType.ptRevisit),
    CalendarVisitEvent(date: DateTime(y, m, 24),     type: VisitType.otRevisit),
    CalendarVisitEvent(date: DateTime(y, m, 24),     type: VisitType.ptRevisit),
    CalendarVisitEvent(date: DateTime(y, m, 30),     type: VisitType.ptDisciplineDC),
    CalendarVisitEvent(date: DateTime(y, m + 1, 1),  type: VisitType.otDisciplineDC),
    CalendarVisitEvent(date: DateTime(y, m + 1, 2),  type: VisitType.stRevisit),
    CalendarVisitEvent(date: DateTime(y, m + 1, 3),  type: VisitType.startOf2nd30Days),
    CalendarVisitEvent(date: DateTime(y, m + 1, 9),  type: VisitType.stEvalOasis),
    CalendarVisitEvent(date: DateTime(y, m + 1, 26), type: VisitType.episodeEnds),
    CalendarVisitEvent(date: DateTime(y, m + 1, 30), type: VisitType.episodeStarts),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// FREQUENCY DETAIL SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class FrequencyDetailScreen extends StatefulWidget {
  const FrequencyDetailScreen({super.key});

  @override
  State<FrequencyDetailScreen> createState() => _FrequencyDetailScreenState();
}

class _FrequencyDetailScreenState extends State<FrequencyDetailScreen> {
  final List<CalendarVisitEvent> _events = getSampleEvents();
  String _selectedDiscipline = 'PT';
  final List<String> _disciplines = ['ALL', 'PT', 'OT', 'PTA', 'ST'];

  static const Map<String, String> _freqLabels = {
    'ALL': 'Multiple disciplines',
    'PT':  '2w2, 1w3 eff 4/2/2025',
    'OT':  '1w2, 2w1 eff 4/2/2025',
    'PTA': '3w1 eff 4/9/2025',
    'ST':  '2w2 eff 4/15/2025',
  };

  List<CalendarVisitEvent> get _filteredEvents {
    if (_selectedDiscipline == 'ALL') return _events;
    return _events.where((e) {
      switch (_selectedDiscipline) {
        case 'PT':
          return [
            VisitType.ptSOC, VisitType.ptRevisit, VisitType.ptDisciplineDC,
            VisitType.episodeStarts, VisitType.episodeEnds, VisitType.startOf2nd30Days,
          ].contains(e.type);
        case 'OT':
          return [
            VisitType.otRevisit, VisitType.otDisciplineDC,
            VisitType.episodeStarts, VisitType.episodeEnds, VisitType.startOf2nd30Days,
          ].contains(e.type);
        case 'PTA':
          return [
            VisitType.ptaRevisit, VisitType.ptaMissedVisit,
            VisitType.episodeStarts, VisitType.episodeEnds, VisitType.startOf2nd30Days,
          ].contains(e.type);
        case 'ST':
          return [
            VisitType.stRevisit, VisitType.stEvalOasis,
            VisitType.episodeStarts, VisitType.episodeEnds, VisitType.startOf2nd30Days,
          ].contains(e.type);
        default:
          return true;
      }
    }).toList();
  }

  void _onSave() => print("Save pressed");
  void _onCancel() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    final nav = context.read<EMRNavigationController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = constraints.maxHeight == double.infinity
            ? MediaQuery.of(context).size.height
            : constraints.maxHeight;

        return Container(
          color: Colors.white,
          height: totalHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top bar ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(
                  top: AppPadding.p16,
                  left: AppPadding.p25,
                  right: AppPadding.p20,
                  bottom: AppPadding.p8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => nav.closeFrequencyDetail(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: AppSize.s20),
                          Icon(Icons.arrow_back,
                              size: AppSize.s14, color: ColorManager.darkgrey),
                          const SizedBox(width: AppSize.s6),
                          Padding(
                            padding: const EdgeInsets.only(left: 100),
                            child: Text(
                              'Edit Frequencies',
                              style: TextStyle(
                                fontSize: FontSize.s13,
                                fontWeight: FontWeight.w600,
                                color: ColorManager.darkgrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 150),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Discipline',
                            style: TextStyle(
                              fontSize: FontSize.s12,
                              fontWeight: FontWeight.w500,
                              color: ColorManager.darkgrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _DisciplineDropdown(
                            value: _selectedDiscipline,
                            items: _disciplines,
                            onChanged: (v) {
                              if (v != null)
                                setState(() => _selectedDiscipline = v);
                            },
                          ),
                          const SizedBox(height: AppSize.s10),
                          Text(
                            _freqLabels[_selectedDiscipline] ?? '',
                            style: TextStyle(
                              fontSize: FontSize.s13,
                              fontWeight: FontWeight.w500,
                              color: ColorManager.mediumgrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable body ──────────────────────────────────────────
              Expanded(
                child: ScrollConfiguration(
                  behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppSize.s20),

                        // ── Continuous 2-month calendar ───────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppPadding.p150),
                          child: _ContinuousCalendarWidget(
                            startMonth: DateTime(
                                DateTime.now().year, DateTime.now().month),
                            monthCount: 2,
                            events: _filteredEvents,
                          ),
                        ),

                        const SizedBox(height: AppSize.s24),

                        // ── Buttons ───────────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _FooterButton(
                                label: 'Cancel',
                                onTap: _onCancel,
                                isPrimary: false),
                            const SizedBox(width: AppSize.s12),
                            _FooterButton(
                                label: 'Save',
                                onTap: _onSave,
                                isPrimary: true),
                          ],
                        ),

                        const SizedBox(height: AppSize.s24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DISCIPLINE DROPDOWN
// ─────────────────────────────────────────────────────────────────────────────

class _DisciplineDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DisciplineDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down,
              size: 18, color: ColorManager.mediumgrey),
          style: TextStyle(
            fontSize: FontSize.s13,
            fontWeight: FontWeight.w500,
            color: ColorManager.darkgrey,
          ),
          items: items
              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DaySlot — carries the date, whether it belongs to the current month block,
// and (for day 1 of each month) the month label to render inside the cell.
// ─────────────────────────────────────────────────────────────────────────────

class _DaySlot {
  final DateTime day;
  final bool isCurrentMonth; // false → blank white cell (leading/trailing pad)
  final String? monthLabel;  // non-null only on day 1 of each rendered month

  _DaySlot({
    required this.day,
    required this.isCurrentMonth,
    this.monthLabel,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTINUOUS CALENDAR
// Renders monthCount months as ONE continuous 7-column grid.
// Leading padding of month 1 → blank.
// Trailing padding of last month → blank.
// Between months: no gap — month 2 starts immediately after month 1's last day.
// Day 1 of every month shows the month name inside the cell above the date.
// ─────────────────────────────────────────────────────────────────────────────

class _ContinuousCalendarWidget extends StatelessWidget {
  final DateTime startMonth;
  final int monthCount;
  final List<CalendarVisitEvent> events;

  const _ContinuousCalendarWidget({
    required this.startMonth,
    required this.monthCount,
    required this.events,
  });

  static const List<String> _monthNames = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  List<CalendarVisitEvent> _eventsForDay(DateTime day) {
    return events
        .where((e) =>
    e.date.year == day.year &&
        e.date.month == day.month &&
        e.date.day == day.day)
        .toList();
  }

  /// Builds the flat list of all day-slots across all months:
  ///   - Leading blank pads for the first month only
  ///   - All real days for every month, with monthLabel set on day 1
  ///   - Trailing blank pads to complete the last week row
  List<_DaySlot> _buildAllSlots() {
    final slots = <_DaySlot>[];

    for (int mi = 0; mi < monthCount; mi++) {
      final month = DateTime(startMonth.year, startMonth.month + mi);
      final first = DateTime(month.year, month.month, 1);
      final last  = DateTime(month.year, month.month + 1, 0);

      if (mi == 0) {
        // Leading blank pads — only for the very first month
        final startPad = first.weekday % 7; // Sun=0 … Sat=6
        for (int i = startPad; i > 0; i--) {
          slots.add(_DaySlot(
            day: first.subtract(Duration(days: i)),
            isCurrentMonth: false,
          ));
        }
      }

      // Real days
      for (int d = 1; d <= last.day; d++) {
        final date = DateTime(month.year, month.month, d);
        slots.add(_DaySlot(
          day: date,
          isCurrentMonth: true,
          // day 1 of every month gets the label
          monthLabel: d == 1
              ? '${_monthNames[month.month]} ${month.year}'
              : null,
        ));
      }
    }

    // Trailing blank pads to fill the last partial row
    final remainder = slots.length % 7;
    if (remainder != 0) {
      final lastDay = slots.last.day;
      final trailingCount = 7 - remainder;
      for (int i = 1; i <= trailingCount; i++) {
        slots.add(_DaySlot(
          day: lastDay.add(Duration(days: i)),
          isCurrentMonth: false,
        ));
      }
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    const headers = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final allSlots = _buildAllSlots();
    final weekCount = allSlots.length ~/ 7;
    final rows = <TableRow>[];

    // ── Day-of-week header row ────────────────────────────────────────────
    rows.add(
      TableRow(
        children: headers.map((h) => Container(
          height: 28,
          alignment: Alignment.center,
          child: Text(
            h,
            style: TextStyle(
              fontSize: FontSize.s11,
              fontWeight: FontWeight.w500,
              color: ColorManager.mediumgrey,
            ),
          ),
        )).toList(),
      ),
    );

    // ── Week rows ─────────────────────────────────────────────────────────
    for (int w = 0; w < weekCount; w++) {
      final week = allSlots.sublist(w * 7, w * 7 + 7);
      rows.add(
        TableRow(
          children: week.map((slot) {
            final dayEvents = slot.isCurrentMonth
                ? _eventsForDay(slot.day)
                : <CalendarVisitEvent>[];
            return _DayCell(
              day: slot.day,
              isCurrentMonth: slot.isCurrentMonth,
              monthLabel: slot.monthLabel,
              events: dayEvents,
            );
          }).toList(),
        ),
      );
    }

    return Table(
      border: const TableBorder(
        horizontalInside: BorderSide(color: Colors.white, width: 4),
        verticalInside:   BorderSide(color: Colors.white, width: 3),
      ),
      children: rows,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DAY CELL
// ─────────────────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool isCurrentMonth;
  final String? monthLabel; // shown above the date on day 1
  final List<CalendarVisitEvent> events;

  const _DayCell({
    required this.day,
    required this.isCurrentMonth,
    required this.events,
    this.monthLabel,
  });

  Color _cellBackground() {
    final types = events.map((e) => e.type).toSet();
    if (types.contains(VisitType.episodeStarts) ||
        types.contains(VisitType.episodeEnds)) {
      return const Color(0xFFE8F5E9);
    }
    if (types.contains(VisitType.startOf2nd30Days)) return const Color(0xFFFFF9C4);
    if (types.any((t) => [
      VisitType.ptRevisit, VisitType.ptSOC, VisitType.ptDisciplineDC
    ].contains(t))) {
      return const Color(0xFFFCE4EC);
    }
    if (types.any((t) =>
        [VisitType.otRevisit, VisitType.otDisciplineDC].contains(t))) {
      return const Color(0xFFFFF3E0);
    }
    if (types.any((t) =>
        [VisitType.stRevisit, VisitType.stEvalOasis].contains(t))) {
      return const Color(0xFFE8F5E9);
    }
    if (types.any((t) =>
        [VisitType.ptaRevisit, VisitType.ptaMissedVisit].contains(t))) {
      return const Color(0xFFF3E5F5);
    }
    return const Color(0xFFFFF9F0);
  }

  bool get _isToday {
    final now = DateTime.now();
    return day.year == now.year &&
        day.month == now.month &&
        day.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    // ── Blank cell for out-of-month padding ──────────────────────────────
    if (!isCurrentMonth) {
      return Container(height: 90, color: Colors.white);
    }

    // ── Normal in-month cell ─────────────────────────────────────────────
    final episodeEvents = events
        .where((e) => [
      VisitType.episodeStarts,
      VisitType.episodeEnds,
      VisitType.startOf2nd30Days,
    ].contains(e.type))
        .toList();

    final visitEvents = events
        .where((e) => ![
      VisitType.episodeStarts,
      VisitType.episodeEnds,
      VisitType.startOf2nd30Days,
    ].contains(e.type))
        .toList();

    final visibleVisits = visitEvents.take(2).toList();
    final extraCount    = visitEvents.length - visibleVisits.length;

    return Container(
      height: 90,
      color: _cellBackground(),
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Day number (+ inline month name on day 1) ─────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _isToday
                  ? Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ColorManager.blueprime,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${day.day}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )
                  : Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: FontSize.s11,
                  fontWeight: FontWeight.w500,
                  color: ColorManager.darkgrey,
                ),
              ),
              if (monthLabel != null) ...[
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    // show only "May" / "June" — short form to fit cell width
                    monthLabel!.split(' ').first,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.darkgrey,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 2),
          ...episodeEvents.map((e) => _EpisodeBadge(type: e.type)),
          ...visibleVisits.map((e) => _VisitTag(event: e)),
          if (extraCount > 0)
            Text('More',
                style: TextStyle(fontSize: 9, color: ColorManager.blueprime)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EPISODE BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _EpisodeBadge extends StatelessWidget {
  final VisitType type;
  const _EpisodeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    switch (type) {
      case VisitType.episodeStarts:
        label = 'Episode Starts';
        color = const Color(0xFF1565C0);
        break;
      case VisitType.episodeEnds:
        label = 'Episode Ends';
        color = const Color(0xFFE65100);
        break;
      case VisitType.startOf2nd30Days:
        label = 'Start of 2nd 30 days';
        color = const Color(0xFFE65100);
        break;
      default:
        return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        label,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VISIT TAG
// ─────────────────────────────────────────────────────────────────────────────

class _VisitTag extends StatelessWidget {
  final CalendarVisitEvent event;
  const _VisitTag({required this.event});

  ({String text, Color color}) _style() {
    switch (event.type) {
      case VisitType.ptSOC:
        return (text: 'PT SOC',           color: const Color(0xFF185FA5));
      case VisitType.ptRevisit:
        return (text: 'PT Revisit',       color: const Color(0xFF185FA5));
      case VisitType.ptDisciplineDC:
        return (text: 'PT Discipline DC', color: const Color(0xFF5C3489));
      case VisitType.otRevisit:
        return (text: 'OT Revisit',       color: const Color(0xFFE65100));
      case VisitType.otDisciplineDC:
        return (text: 'OT Discipline DC', color: const Color(0xFFE65100));
      case VisitType.stRevisit:
        return (text: 'ST Revisit',       color: const Color(0xFF0F6E56));
      case VisitType.stEvalOasis:
        return (text: 'ST EC OASIS',      color: const Color(0xFF0F6E56));
      case VisitType.ptaRevisit:
        return (text: 'PTA Revisit',      color: const Color(0xFF6A1B9A));
      case VisitType.ptaMissedVisit:
        return (text: 'PTA Missed Visit', color: const Color(0xFFA32D2D));
      default:
        return (text: '', color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style();
    if (s.text.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              s.text,
              style: TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w600, color: s.color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (event.isCompleted) Icon(Icons.check, size: 9, color: s.color),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FOOTER BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _FooterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _FooterButton({
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary ? ColorManager.blueprime : Colors.white,
          border: Border.all(
            color: isPrimary ? ColorManager.blueprime : Colors.grey.shade400,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: FontSize.s13,
            fontWeight: FontWeight.w500,
            color: isPrimary ? Colors.white : ColorManager.darkgrey,
          ),
        ),
      ),
    );
  }
}