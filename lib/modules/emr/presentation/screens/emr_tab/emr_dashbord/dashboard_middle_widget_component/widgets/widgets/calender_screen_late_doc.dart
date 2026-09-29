import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/calender_popup_const.dart';

// ── Models ───────────────────────────────────────────────────────────────────

class LateVisitItem {
  final String initials;
  final Color avatarColor;
  final String name;
  final String role;
  final String time;
  final int percent;

  const LateVisitItem({
    required this.initials,
    required this.avatarColor,
    required this.name,
    required this.role,
    required this.time,
    required this.percent,
  });
}

class CalendarDayData {
  final int day;
  final int lateVisits;
  const CalendarDayData({required this.day, required this.lateVisits});
}

// ── Sample late visits data (day -> count) ───────────────────────────────────

const Map<int, int> _lateVisitsData = {
  1: 3, 2: 6, 3: 4, 4: 3, 5: 1, 9: 1,
};

// ── Sample side list ─────────────────────────────────────────────────────────

final List<LateVisitItem> _sideList = [
  const LateVisitItem(initials: 'LG', avatarColor: Color(0xFF7B5EA7), name: 'Lucas Garcia',  role: 'Anicity', time: '9:00AM–11:30AM', percent: 40),
  const LateVisitItem(initials: 'RG', avatarColor: Color(0xFFE57373), name: 'Ross Geller',   role: 'Anicity', time: '9:00AM–11:30AM', percent: 48),
  const LateVisitItem(initials: 'LS', avatarColor: Color(0xFF4CAF50), name: 'Lara Scott',    role: 'Anicity', time: '9:00AM–11:30AM', percent: 40),
  const LateVisitItem(initials: 'KW', avatarColor: Color(0xFFFFB74D), name: 'Kia Williams',  role: 'Anicity', time: '9:00AM–11:30AM', percent: 40),
  const LateVisitItem(initials: 'LG', avatarColor: Color(0xFF7B5EA7), name: 'Lucas Garcia',  role: 'Anicity', time: '9:00AM–11:30AM', percent: 40),
  const LateVisitItem(initials: 'KW', avatarColor: Color(0xFFFFB74D), name: 'Kia Williams',  role: 'Anicity', time: '9:00AM–11:30AM', percent: 48),
  const LateVisitItem(initials: 'LG', avatarColor: Color(0xFF7B5EA7), name: 'Lucas Garcia',  role: 'Anicity', time: '9:00AM–11:30AM', percent: 40),
  const LateVisitItem(initials: 'KW', avatarColor: Color(0xFFFFB74D), name: 'Kia Williams',  role: 'Anicity', time: '9:00AM–11:30AM', percent: 48),
];

// ── Helper: build week grid dynamically for any month ────────────────────────

List<List<CalendarDayData>> _buildWeeks(DateTime month) {
  final firstDay = DateTime(month.year, month.month, 1);
  final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
  // Convert Mon=1..Sun=7 → Sun=0 offset
  final startOffset = firstDay.weekday % 7;

  final flat = <CalendarDayData>[
    ...List.generate(startOffset, (_) => const CalendarDayData(day: 0, lateVisits: 0)),
    ...List.generate(daysInMonth, (i) {
      final d = i + 1;
      return CalendarDayData(day: d, lateVisits: _lateVisitsData[d] ?? 0);
    }),
  ];

  while (flat.length % 7 != 0) {
    flat.add(const CalendarDayData(day: 0, lateVisits: 0));
  }

  final weeks = <List<CalendarDayData>>[];
  for (var i = 0; i < flat.length; i += 7) {
    weeks.add(flat.sublist(i, i + 7));
  }
  return weeks;
}

// ── Root Widget ───────────────────────────────────────────────────────────────

class CalenderScreenLateDocumentation extends StatefulWidget {
  const CalenderScreenLateDocumentation({super.key});

  @override
  State<CalenderScreenLateDocumentation> createState() =>
      _CalenderScreenLateDocumentationState();
}

class _CalenderScreenLateDocumentationState
    extends State<CalenderScreenLateDocumentation> {
  DateTime _currentMonth = DateTime.now();

  void _prev() => setState(() =>
  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1));

  void _next() => setState(() =>
  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1));

  String get _monthLabel {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[_currentMonth.month - 1]} ${_currentMonth.year}';
  }


// 1. Add a GlobalKey for the date pill anchor
  final GlobalKey _datePillKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final weeks = _buildWeeks(_currentMonth);
    final today = DateTime.now();
    final isCurrentMonth = today.year == _currentMonth.year &&
        today.month == _currentMonth.month;
    final todayDay = isCurrentMonth ? today.day : -1;

    return Container(
      child: // Centered message
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p40),
          child: Text(
            'Dependency on forms builder which is under development!',
            textAlign: TextAlign.center,
            style: AllNoDataAvailable.customTextStyle(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _prev,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: Icon(Icons.chevron_left, size: 20, color: Colors.blue.shade700),
                  ),
                ),
                Container(width: 1, height: 20, color: Colors.grey.shade300),

                // ── Tappable date pill ──────────────────────────────────────
                GestureDetector(
                  key: _datePillKey,
                  onTap: () async {
                    final picked = await CalendarPickerHelper.show(
                      context: context,
                      anchorKey: _datePillKey,
                      selectedDate: _currentMonth,
                    );
                    if (picked != null) {
                      setState(() {
                        _currentMonth = DateTime(picked.year, picked.month); // ← sync grid
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: SizedBox(
                      width: 140,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Swap to: Image.asset('images/hh_emr/calendar.png', width: 13, height: 13)
                            Icon(Icons.calendar_today, size: 13, color: Colors.blue.shade700),
                            const SizedBox(width: 6),
                            Text(
                              _monthLabel,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // ───────────────────────────────────────────────────────────

                Container(width: 1, height: 20, color: Colors.grey.shade300),
                GestureDetector(
                  onTap: _next,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: Icon(Icons.chevron_right, size: 20, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weekday Row ───────────────────────────────────────────────────────────────

class _WeekdayRow extends StatelessWidget {
  static const _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.shade50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: _days
            .map((d) => Expanded(
          child: Center(
            child: Text(
              d,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black45,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ))
            .toList(),
      ),
    );
  }
}

// ── Calendar Grid ─────────────────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  final List<List<CalendarDayData>> weeks;
  final int todayDay;

  const _CalendarGrid({required this.weeks, required this.todayDay});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: weeks.length,
      itemBuilder: (_, weekIdx) {
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(
              7,
                  (dayIdx) => Expanded(
                child: _CalendarCell(
                  data: weeks[weekIdx][dayIdx],
                  isToday: weeks[weekIdx][dayIdx].day != 0 &&
                      weeks[weekIdx][dayIdx].day == todayDay,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Calendar Cell ─────────────────────────────────────────────────────────────

class _CalendarCell extends StatefulWidget {
  final CalendarDayData data;
  final bool isToday;

  const _CalendarCell({required this.data, required this.isToday});

  @override
  State<_CalendarCell> createState() => _CalendarCellState();
}

class _CalendarCellState extends State<_CalendarCell> {
  bool _hovered = false;

  bool get _isPadding => widget.data.day == 0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = !_isPadding && widget.data.lateVisits > 0),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: const BoxConstraints(minHeight: 64),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: _hovered && !_isPadding
              ? const Color(0xFFF5F0FF)
              : Colors.white,
          border: _hovered && !_isPadding
              ? const Border(
            left: BorderSide(color: Color(0xFF7C3AED), width: 3),
          )
              : Border.all(color: Colors.grey.shade100, width: 0.8),

        ),
        padding: const EdgeInsets.all(5),
        child: _hovered && !_isPadding
            ? _buildHoveredContent()
            : _buildNormalContent(),
      ),
    );
  }

  // ── Normal cell ────────────────────────────────────────────────────────────
  Widget _buildNormalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_isPadding)
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 22,
              height: 22,
              decoration: widget.isToday
                  ? BoxDecoration(
                color: Colors.blue.shade500,
                shape: BoxShape.circle,
              )
                  : null,
              child: Center(
                child: Text(
                  '${widget.data.day}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: widget.isToday ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        if (!_isPadding && widget.data.lateVisits > 0)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(child: _LateVisitsBadge(count: widget.data.lateVisits)),
          ),
      ],
    );
  }

  // ── Hovered cell ───────────────────────────────────────────────────────────
  Widget _buildHoveredContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Day number ────────────────────────────────────────────────
        const SizedBox(height: 6),

        // ── Pending Visits ────────────────────────────────────────────
        if (widget.data.lateVisits > 0)
          Text(
            'Pending Visits ${widget.data.lateVisits}',
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5B21B6),
            ),
            overflow: TextOverflow.ellipsis,
          ),

        const SizedBox(height: 4),

        // ── SOC Visits ────────────────────────────────────────────────
        const Text(
          'SOC Visits',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5B21B6),
          ),
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // ── Recent Visit ──────────────────────────────────────────────
        const Text(
          'Recent Visit',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5B21B6),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ── Late Visits Badge ─────────────────────────────────────────────────────────

class _LateVisitsBadge extends StatelessWidget {
  final int count;
  const _LateVisitsBadge({required this.count});

  Color get _color {
    if (count >= 5) return const Color(0xFFE53935);
    if (count >= 3) return const Color(0xFFFF7043);
    return const Color(0xFFFFCA28);
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
        children: [
          const TextSpan(
            text: 'Late Visits ',
            style: TextStyle(color: Colors.grey),
          ),
          TextSpan(
            text: '$count',
            style: TextStyle(color: _color),
          ),
        ],
      ),
    );
  }
}

// ── Side List Panel ───────────────────────────────────────────────────────────

class _SideListPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '04/03/2025',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: _sideList.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Colors.grey.shade100,
              indent: 12,
              endIndent: 12,
            ),
            itemBuilder: (_, i) => _SideListTile(item: _sideList[i]),
          ),
        ),
      ],
    );
  }
}

// ── Side List Tile ────────────────────────────────────────────────────────────

class _SideListTile extends StatelessWidget {
  final LateVisitItem item;
  const _SideListTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 48,
            decoration: BoxDecoration(
              color: item.avatarColor,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: item.avatarColor,
            child: Text(
              item.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(item.role,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                const SizedBox(height: 3),
                Text(item.time,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              ],
            ),
          ),
          _CircularPercent(percent: item.percent, color: item.avatarColor),
        ],
      ),
    );
  }
}

// ── Circular Percent ──────────────────────────────────────────────────────────

class _CircularPercent extends StatelessWidget {
  final int percent;
  final Color color;
  const _CircularPercent({required this.percent, required this.color});

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
            strokeWidth: 4,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Center(
            child: Text(
              '$percent%',
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}