import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/calender_emr_tab/visit_details_screen.dart';
import '../../../../../app/resources/color.dart';
import '../../../../../app/resources/provider/hh_emr/visit_details_provider.dart';
import '../../../../../app/resources/value_manager.dart';
import '../../../../../data/api_data/emr_module_data/calender_map_data/calender_map_data.dart';
import '../../../../widgets/widgets/custom_scrollbar.dart';
import 'emr_calender_screen.dart';
import 'package:provider/provider.dart';

class CalendarView extends StatefulWidget {
  final List<ClinicianCalendarVisitData> visits;
  const CalendarView({super.key, required this.visits});
  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final ScrollController _horizontalScrollController = ScrollController();
  bool _isMonth = false;
  DateTime _currentDate = DateTime.now();

  static const double _hourHeight = 56.0;
  static const double _headerHeight = 48.0;
  static const int _startHour = 7;

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _openVisitDetails(int visitId) {
    context.read<EMRNavigationController>().passVisitId(id: visitId);
    context.read<EMRNavigationController>().openVisit();
  }

  DateTime get _weekStart =>
      _currentDate.subtract(Duration(days: _currentDate.weekday % 7));

  String get _weekLabel {
    final s = _weekStart;
    final e = s.add(const Duration(days: 6));
    return '${s.day}–${e.day} ${_mName(s.month)} ${s.year}';
  }

  String get _monthLabel => '${_mName(_currentDate.month)} ${_currentDate.year}';

  String _mName(int m) => const [
    '', 'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ][m];

  int get _daysInMonth =>
      DateTime(_currentDate.year, _currentDate.month + 1, 0).day;

  int get _monthStartWeekday =>
      DateTime(_currentDate.year, _currentDate.month, 1).weekday % 7;

  void _prev() => setState(() {
    _currentDate = _isMonth
        ? DateTime(_currentDate.year, _currentDate.month - 1, 1)
        : _currentDate.subtract(const Duration(days: 7));
  });

  void _next() => setState(() {
    _currentDate = _isMonth
        ? DateTime(_currentDate.year, _currentDate.month + 1, 1)
        : _currentDate.add(const Duration(days: 7));
  });

  List<ClinicianCalendarVisitData> _visitsForDate(DateTime date) {
    return widget.visits.where((v) {
      if (v.visiteDateTimeFrom == null || v.visiteDateTimeFrom!.isEmpty) return false;
      try {
        final dt = DateTime.parse(v.visiteDateTimeFrom!).toLocal();
        return dt.year == date.year && dt.month == date.month && dt.day == date.day;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  int _visitCountForDay(int day) {
    final date = DateTime(_currentDate.year, _currentDate.month, day);
    return _visitsForDate(date).length;
  }

  String get _monthRangeLabel {
    final m = _currentDate.month.toString().padLeft(2, '0');
    final y = _currentDate.year;
    return '$m/15/$y – $m/17/$y';
  }

  @override
  Widget build(BuildContext context) {
    const days = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
    final hours = List.generate(16, (i) => i + _startHour);
    final ws = _weekStart;
    final now = DateTime.now();

    final List<int?> monthCells = [
      ...List.filled(_monthStartWeekday, null),
      ...List.generate(_daysInMonth, (i) => i + 1),
      ...List.filled((7 - ((_monthStartWeekday + _daysInMonth) % 7)) % 7, null),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      const double minContentWidth = 1200;
      final double contentWidth = constraints.maxWidth > minContentWidth
          ? constraints.maxWidth
          : minContentWidth;
      return CustomScrollbar(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppPadding.p10),
            child: SizedBox(
              width: contentWidth,
              height: constraints.maxHeight,
              child: Column(children: [
      // ── Controls Row ───────────────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            flex: 6,
            child: Row(children: [
              const SizedBox(width: 18),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  GestureDetector(
                    onTap: _prev,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: Icon(Icons.chevron_left, size: 20, color: Colors.blue.shade700),
                    ),
                  ),
                  Container(width: 1, height: 20, color: Colors.grey.shade300),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: SizedBox(
                      width: 140,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('images/hh_emr/calendar.png', width: 13, height: 13),
                            const SizedBox(width: 6),
                            Text(
                              _isMonth ? _monthLabel : _weekLabel,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, height: 20, color: Colors.grey.shade300),
                  GestureDetector(
                    onTap: _next,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: Icon(Icons.chevron_right, size: 20, color: Colors.blue.shade700),
                    ),
                  ),
                ]),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: ['Week', 'Month'].map((label) {
                  final active = (label == 'Month') == _isMonth;
                  return GestureDetector(
                    onTap: () => setState(() => _isMonth = label == 'Month'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFFBF360C) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(label, style: TextStyle(
                        fontSize: 12,
                        color: active ? Colors.white : Colors.grey.shade600,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                      )),
                    ),
                  );
                }).toList(),
              ),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: !_isMonth
                ?SizedBox()
              //     ? Container(
              //   decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(8),
              //       border: Border.all(color: Colors.blue.shade200)),
              //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              //   child: Row(mainAxisSize: MainAxisSize.min, children: [
              //     Icon(Icons.edit_outlined, size: 13, color: Colors.blue.shade700),
              //     const SizedBox(width: 4),
              //     Text('Edit', style: TextStyle(
              //         fontSize: 12,
              //         color: Colors.blue.shade700,
              //         fontWeight: FontWeight.w500)),
              //   ]),
              // )
                  : Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Text(_monthRangeLabel, style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600)),
                  ),
            ),
          ),
        ]),
      ),

      // ── Grid ───────────────────────────────────────────────────────────
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: _isMonth
                    ? _buildMonthGrid(days, now, monthCells)
                    : _buildWeekGrid(days, hours, ws, now),
              ),
            ),
            if (_isMonth)
              Expanded(flex: 2, child: _buildMonthList()),
          ]),
        ),
      ),
      ]),      // Column
        ),     // SizedBox
      ),       // Padding
    ),         // SingleChildScrollView
  );           // CustomScrollbar
    }
    );
  }

  // ── WEEK GRID ─────────────────────────────────────────────────────────────
  Widget _buildWeekGrid(List<String> days, List<int> hours, DateTime ws, DateTime now) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 44,
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const SizedBox(height: _headerHeight),
              ...hours.map((h) => SizedBox(
                height: _hourHeight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 6, top: 2),
                  child: Text(
                    '${h <= 12 ? h : h - 12}${h < 12 ? "AM" : "PM"}',
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                ),
              )),
            ]),
          ),
          Expanded(
            child: Column(children: [
              Row(
                children: List.generate(7, (i) {
                  final d = ws.add(Duration(days: i));
                  final isToday = d.year == now.year &&
                      d.month == now.month && d.day == now.day;
                  return Expanded(
                    child: Container(
                      height: _headerHeight,
                      alignment: Alignment.center,
                      color: Colors.blue.shade50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(days[i], style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700)),
                          const SizedBox(height: 2),
                          Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isToday
                                    ? Colors.blue.shade700
                                    : Colors.transparent),
                            alignment: Alignment.center,
                            child: Text('${d.day}', style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isToday ? Colors.white : Colors.blue.shade700)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(
                height: _hourHeight * hours.length,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(7, (col) {
                    final colDate = ws.add(Duration(days: col));
                    final dayVisits = _visitsForDate(colDate);
                    return Expanded(
                      child: Stack(children: [
                        Column(
                          children: hours.map((_) => Container(
                            height: _hourHeight,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade100),
                                left: BorderSide(color: Colors.grey.shade100),
                              ),
                            ),
                          )).toList(),
                        ),
                        ...dayVisits.map((v) {
                          DateTime? startDt;
                          DateTime? endDt;
                          try {
                            startDt = DateTime.parse(v.visiteDateTimeFrom!).toLocal();
                            endDt = DateTime.parse(v.visitDateTimeTo!).toLocal();
                          } catch (_) {}
                          if (startDt == null) return const SizedBox.shrink();
      
                          // FIX: skip visits that start before the visible window
                          if (startDt.hour < _startHour) return const SizedBox.shrink();
      
                          final startHour = startDt.hour;
                          final startMinute = startDt.minute;
      
                          // FIX: clamp durationMins to minimum 15 to avoid zero/negative height
                          final durationMins = endDt != null
                              ? endDt.difference(startDt).inMinutes.clamp(15, 9999)
                              : 60;
      
                          final top = ((startHour - _startHour) * _hourHeight) +
                              (startMinute / 60.0 * _hourHeight);
      
                          // FIX: clamp height to never be negative
                          final height = ((durationMins / 60.0) * _hourHeight - 2)
                              .clamp(0.0, double.infinity);
      
                          // FIX: skip rendering if height is too small
                          if (height < 1) return const SizedBox.shrink();
      
                          return Positioned(
                            top: top,
                            left: 2, right: 2,
                            child: GestureDetector(
                              onTap: () => _openVisitDetails(v.visitId!),
                              child: _WeekApptCard(visit: v, height: height),
                            ),
                          );
                        }),
                      ]),
                    );
                  }),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── MONTH GRID ────────────────────────────────────────────────────────────
  Widget _buildMonthGrid(List<String> days, DateTime now, List<int?> monthCells) {
    const Color greenBg = Color(0xFFEEF7EE);
    const Color pinkBg  = Color(0xFFFFF0F0);

    final prevMonth   = DateTime(_currentDate.year, _currentDate.month - 1);
    final daysInPrev  = DateTime(_currentDate.year, _currentDate.month, 0).day;
    final nextMonth   = DateTime(_currentDate.year, _currentDate.month + 1);
    final totalLeading = _monthStartWeekday;
    final totalCurrent = _daysInMonth;

    return Column(children: [
      Row(
        children: days.map((d) => Expanded(
          child: Container(
            height: 36,
            alignment: Alignment.center,
            color: Colors.blue.shade50,
            child: Text(d, style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700)),
          ),
        )).toList(),
      ),
      const SizedBox(height: 4),
      Expanded(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth  = constraints.maxWidth / 7;
              final cellHeight = cellWidth / 1.1;

              final rows = <List<int?>>[];
              for (var i = 0; i < monthCells.length; i += 7) {
                rows.add(monthCells.sublist(i, (i + 7).clamp(0, monthCells.length)));
              }

              return ListView.separated(
                physics: const ClampingScrollPhysics(),
                itemCount: rows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (_, rowIndex) {
                  final rowCells = rows[rowIndex];
                  return Row(
                    children: List.generate(rowCells.length, (col) {
                      final day = rowCells[col];
                      final globalIndex = rowIndex * 7 + col;

                      // ── OVERFLOW CELL (prev / next month) ──────────────
                      if (day == null) {
                        final isLeading = globalIndex < totalLeading;
                        final DateTime overflowDate;
                        if (isLeading) {
                          final d = daysInPrev - totalLeading + globalIndex + 1;
                          overflowDate = DateTime(prevMonth.year, prevMonth.month, d);
                        } else {
                          final d = globalIndex - totalLeading - totalCurrent + 1;
                          overflowDate = DateTime(nextMonth.year, nextMonth.month, d);
                        }

                        const isOverflow = true;
                        const numberColor = isOverflow ? Colors.black26 : Colors.black87;
                        const monthLabelColor = isOverflow ? Colors.black26 : Colors.black87;
                        final isFirstOfMonth = overflowDate.day == 1;
                        final monthAbbr = ['Jan','Feb','Mar','Apr','May','Jun',
                          'Jul','Aug','Sep','Oct','Nov','Dec'][overflowDate.month - 1];

                        return SizedBox(
                          width: cellWidth,
                          height: cellHeight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFEEEEEE)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isFirstOfMonth) ...[
                                      Text(
                                        monthAbbr,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: monthLabelColor,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                    ],
                                    const SizedBox(width: 5),
                                    Text(
                                      '${overflowDate.day}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: numberColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // ── CURRENT MONTH CELL ─────────────────────────────
                      final isToday = _currentDate.year == now.year &&
                          _currentDate.month == now.month && day == now.day;
                      final isWeekend = col == 0 || col == 6;
                      final visits = isWeekend ? null : _visitCountForDay(day);
                      final hasVisits = visits != null && visits > 0;
                      final bg = isWeekend
                          ? Colors.white
                          : (globalIndex % 2 == 0) ? greenBg : pinkBg;
                      const visitColor = Color(0xFF4CAF50);

                      return SizedBox(
                        width: cellWidth,
                        height: cellHeight,
                        child: _MonthGridCell(
                          day: day,
                          month: _currentDate.month,
                          isToday: isToday,
                          hasVisits: hasVisits,
                          visits: visits,
                          bg: bg,
                          visitColor: visitColor,
                        ),
                      );
                    }),
                  );
                },
              );
            },
          ),
        ),
      ),
    ]);
  }

  // ── MONTH LIST ────────────────────────────────────────────────────────────
  Widget _buildMonthList() {
    final monthVisits = widget.visits.where((v) {
      if (v.visiteDateTimeFrom == null || v.visiteDateTimeFrom!.isEmpty) return false;
      try {
        final dt = DateTime.parse(v.visiteDateTimeFrom!).toLocal();
        return dt.year == _currentDate.year && dt.month == _currentDate.month;
      } catch (_) {
        return false;
      }
    }).toList();

    return Container(
      margin: EdgeInsets.only(left: 10),
      //decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.grey.shade200))),
      child: monthVisits.isEmpty
          ? Center(child: Text('No appointments!',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400)))
          : ListView(
        padding: const EdgeInsets.only(left: 8,right: 8,bottom: 8),
        children: monthVisits.map((v) => _MonthListCard(visit: v)).toList(),
      ),
    );
  }
}

// ── Month Grid Cell ───────────────────────────────────────────────────────────
class _MonthGridCell extends StatefulWidget {
  final int day;
  final int month;
  final bool isToday;
  final bool hasVisits;
  final int? visits;
  final Color bg;
  final Color visitColor;

  const _MonthGridCell({
    required this.day,
    required this.month,
    required this.isToday,
    required this.hasVisits,
    required this.visits,
    required this.bg,
    required this.visitColor,
  });

  @override
  State<_MonthGridCell> createState() => _MonthGridCellState();
}

class _MonthGridCellState extends State<_MonthGridCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) { if (widget.hasVisits) setState(() => _hovered = true); },
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFFF5F0FF) : widget.bg,
          border: _hovered
              ? const Border(left: BorderSide(color: Color(0xFF7C3AED), width: 3))
              : Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: _hovered ? _buildHovered() : _buildNormal(),
      ),
    );
  }

  Widget _buildNormal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.day == 1) ...[
              const SizedBox(width: 5),
              Text(
                _monthAbbr(widget.month),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 3),
            ],
            const SizedBox(width: 5),
            widget.isToday
                ? Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                  color: ColorManager.bluebottom,
                  shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text('${widget.day}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            )
                : Text('${widget.day}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700)),
          ],
        ),
        const Spacer(),
        if (widget.visits != null)
          Row(
            children: [
              const Spacer(),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Total Visits ',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: widget.visits.toString().padLeft(2, '0'),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4CAF50)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        const SizedBox(height: 2),
      ],
    );
  }

  String _monthAbbr(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[(month - 1).clamp(0, 11)];
  }

  Widget _buildHovered() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        if (widget.visits != null)
          Text(
            'Pending Visits ${widget.visits.toString().padLeft(2, '0')}',
            style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5B21B6)),
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 3),
        const Text('SOC Visits',
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5B21B6)),
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        const Text('Recent Visit',
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5B21B6)),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

// ── Week Appointment Card ─────────────────────────────────────────────────────
class _WeekApptCard extends StatelessWidget {
  final ClinicianCalendarVisitData visit;
  final double height;
  const _WeekApptCard({required this.visit, required this.height});

  String _fmt(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m$ampm';
  }

  @override
  Widget build(BuildContext context) {
    final type = visit.visitTypeName ?? '';
    final bg = apptBg(type);
    final accent = apptAccent(type);

    DateTime? startDt;
    DateTime? endDt;
    try {
      startDt = DateTime.parse(visit.visiteDateTimeFrom!).toLocal();
      endDt   = DateTime.parse(visit.visitDateTimeTo!).toLocal();
    } catch (_) {}

    // FIX: use ClipRect + OverflowBox to prevent Column overflow inside tiny cards
    return ClipRect(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: Border(left: BorderSide(color: accent, width: 3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(type,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700, color: accent)),
                ),
                Container(
                  height: 12,
                  width: 12,
                  margin: const EdgeInsets.all(4),
                  color: Colors.lightBlue.shade100,
                  alignment: Alignment.center,
                  child: const Text(
                    "A",
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
            if (height > 30)
              Text(visit.patientName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
            if (height > 44)
              Text(visit.primaryDiagnosis ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 8, color: Colors.grey.shade600)),
            if (height > 52)
              Text(visit.distance ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 8, color: Colors.grey.shade600)),
            if (height > 60 && startDt != null && endDt != null)
              Text('${_fmt(startDt)}–${_fmt(endDt)}',
                  style: TextStyle(fontSize: 8, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

// ── Month List Card ───────────────────────────────────────────────────────────
class _MonthListCard extends StatefulWidget {
  final ClinicianCalendarVisitData visit;
  const _MonthListCard({required this.visit});

  @override
  State<_MonthListCard> createState() => _MonthListCardState();
}

class _MonthListCardState extends State<_MonthListCard> {
  bool _showNote = false;

  String _fmt(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m$ampm';
  }

  // String _initials(String name) {
  //   final parts = name.trim().split(' ');
  //   if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  //   if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
  //   return '?';
  // }
  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final type   = widget.visit.visitTypeName ?? '';
    final accent = apptAccent(type);
    final bg     = apptBg(type);
    final name   = widget.visit.patientName ?? '';

    DateTime? startDt;
    DateTime? endDt;
    try {
      startDt = DateTime.parse(widget.visit.visiteDateTimeFrom!).toLocal();
      endDt   = DateTime.parse(widget.visit.visitDateTimeTo!).toLocal();
    } catch (_) {}

    final mo = startDt != null ? startDt.month.toString().padLeft(2, '0') : '--';
    final d  = startDt != null ? startDt.day.toString().padLeft(2, '0')   : '--';
    final y  = startDt != null ? startDt.year.toString()                   : '----';

    return GestureDetector(
      onTap: () => setState(() => _showNote = !_showNote),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 76),
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 3,
                  offset: const Offset(0, 1))
            ],
          ),
          child: IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (!_showNote)
                Container(
                  width: 18,
                  decoration: BoxDecoration(color: bg),
                  alignment: Alignment.center,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(type, style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                        color: accent,
                        letterSpacing: 0.8)),
                  ),
                ),
              Expanded(
                child: _showNote
                    ? _buildNoteView(accent)
                    : _buildCardView(bg, accent, name, mo, d, y, startDt, endDt),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildCardView(Color bg, Color accent, String name, String mo,
      String d, String y, DateTime? startDt, DateTime? endDt) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Padding(
        padding: const EdgeInsets.only(left: 8, right: 12, top: 10, bottom: 10),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: bg,
          child: Text(_initials(name),
              style: TextStyle(
                  fontSize: 11,
                  color: accent,
                  fontWeight: FontWeight.bold)),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name, style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
              const SizedBox(height: 2),
              Text(widget.visit.primaryDiagnosis ?? '--',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              const SizedBox(height: 1),
              Text(widget.visit.distance ?? '--',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              SvgPicture.asset("images/emr_clinician/Today.svg"),
              //Icon(Icons.calen, size: 10, color: Colors.blue.shade400),
              const SizedBox(width: 3),
              Text('$mo-$d-$y', style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue.shade400,
                  fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(height: 12),
            if (startDt != null && endDt != null)
              Text('${_fmt(startDt)}-${_fmt(endDt)}', style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue.shade400,
                  fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    ]);
  }

  Widget _buildNoteView(Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Note :', style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFBF360C))),
            // Row(mainAxisSize: MainAxisSize.min,
            //     children: [
            //   Icon(Icons.edit_outlined, size: 14, color: Colors.grey.shade500),
            //   const SizedBox(width: 8),
            //   Icon(Icons.delete_outline, size: 14, color: Colors.grey.shade500),
            // ]),
          ]),
          const SizedBox(height: 6),
          Text('No Note here', style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade400,
              fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}