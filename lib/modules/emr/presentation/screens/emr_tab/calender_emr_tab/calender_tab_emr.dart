import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/calender_emr_tab/visit_details_screen.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/providers/hh_emr/visit_details_provider.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/calender_map_data/calender_map_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/calender_emr_tab/emr_calender_screen.dart';
import 'package:provider/provider.dart';

/// ── HOLIDAY STYLE CONSTANTS ────────────────────────────────────────────────
class HolidayStyle {
  static const Color border = Color(0xFFD32F2F);
  static const Color text = Color(0xFFD32F2F);
  static const Color cellBg = Color(0xFFFFF0F0);
  static const Color cellHoverBg = Color(0xFFFFE1E1);
  static const Color chipBg = Color(0xFFFDECEC);
  static const double borderWidth = 1.6;
}

const List<String> kFullMonthNames = [
  '', 'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

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

  static const double _hourHeight = 80.0;
  static const double _headerHeight = 60.0;
  static const int _startHour = 0;

  /// "yyyy-MM-dd" -> holiday
  Map<String, HolidayData> _holidayMap = {};

  @override
  void initState() {
    super.initState();
    _buildHolidayMap();
  }

  @override
  void didUpdateWidget(covariant CalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visits != widget.visits) {
      _buildHolidayMap();
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  /// Holidays sit at the response root, so every visit carries the same list.
  void _buildHolidayMap() {
    final List<HolidayData> list = widget.visits.isNotEmpty
        ? (widget.visits.first.holidayList ?? const [])
        : const [];
    _holidayMap = {for (final h in list) h.date: h};
  }

  String _dateKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  HolidayData? _holidayFor(DateTime day) => _holidayMap[_dateKey(day)];

  HolidayData? _holidayForDayOfCurrentMonth(int day) =>
      _holidayFor(DateTime(_currentDate.year, _currentDate.month, day));

  /// Holidays inside the month currently on screen, sorted by date.
  List<HolidayData> get _holidaysThisMonth {
    return _holidayMap.values.where((h) {
      final d = DateTime.tryParse(h.date);
      return d != null &&
          d.year == _currentDate.year &&
          d.month == _currentDate.month;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Holidays inside the week currently on screen, sorted by date.
  List<HolidayData> get _holidaysThisWeek {
    final start = DateTime(_weekStart.year, _weekStart.month, _weekStart.day);
    final end = start.add(const Duration(days: 7));
    return _holidayMap.values.where((h) {
      final d = DateTime.tryParse(h.date);
      if (d == null) return false;
      final day = DateTime(d.year, d.month, d.day);
      return !day.isBefore(start) && day.isBefore(end);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
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

  /// Formats an hour (0-23) as a 12-hour clock label, handling the
  /// midnight/noon edge cases correctly now that the grid covers 24 hrs.
  String _hourLabel(int h) {
    final displayHour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final ampm = h < 12 ? 'AM' : 'PM';
    return '$displayHour$ampm';
  }

  String _mName(int m) => const [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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
      if (v.visiteDateTimeFrom == null || v.visiteDateTimeFrom!.isEmpty) {
        return false;
      }
      try {
        final dt = DateTime.parse(v.visiteDateTimeFrom!).toLocal();
        return dt.year == date.year &&
            dt.month == date.month &&
            dt.day == date.day;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  int _visitCountForDay(int day) {
    final date = DateTime(_currentDate.year, _currentDate.month, day);
    return _visitsForDate(date).length;
  }

  /// Real first-day → last-day range of the month currently on screen,
  /// e.g. "08/01/2026 – 08/31/2026". Previously this was a hardcoded,
  /// incorrect "$m/15/$y – $m/17/$y" placeholder.
  String get _monthRangeLabel {
    final firstDay = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDay = DateTime(_currentDate.year, _currentDate.month + 1, 0);

    String fmt(DateTime d) =>
        '${d.month.toString().padLeft(2, '0')}/'
            '${d.day.toString().padLeft(2, '0')}/'
            '${d.year}';

    return '${fmt(firstDay)} – ${fmt(lastDay)}';
  }

  @override
  Widget build(BuildContext context) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final hours = List.generate(24, (i) => i + _startHour);
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
                // ── Controls Row ─────────────────────────────────────────
                Padding(
                  padding:
                  const EdgeInsets.only(left: AppSizeConst.A40,right: AppSize.s35, top: AppPadding.p8, bottom: AppPadding.p8),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          onTap: _prev,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 6),
                                            child: Icon(Icons.chevron_left,
                                                size: 20,
                                                color: ColorManager.blueprime),
                                          ),
                                        ),
                                        Container(
                                            width: 1,
                                            height: 20,
                                            color: Colors.grey.shade300),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          child: SizedBox(
                                            width: 140,
                                            child: Center(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.calendar_month_sharp,
                                                    size: 15,
                                                    color: ColorManager.blueprime,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    _isMonth
                                                        ? _monthLabel
                                                        : _weekLabel,
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w500,
                                                        color: ColorManager
                                                            .blueprime),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                            width: 1,
                                            height: 20,
                                            color: Colors.grey.shade300),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          onTap: _next,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 6),
                                            child: Icon(Icons.chevron_right,
                                                size: 20,
                                                color: ColorManager.blueprime),
                                          ),
                                        ),
                                      ]),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: ['Week', 'Month'].map((label) {
                                    final active = (label == 'Month') == _isMonth;
                                    return InkWell(
                                      splashColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () => setState(
                                              () => _isMonth = label == 'Month'),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: active
                                              ? const Color(0xFFBF360C)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(label,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: active
                                                  ? Colors.white
                                                  : Colors.grey.shade600,
                                              fontWeight: active
                                                  ? FontWeight.w700
                                                  : FontWeight.w600,
                                            )),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ]),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: !_isMonth
                                ? const SizedBox()
                                : Text(_monthRangeLabel,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600)),
                          ),
                        ),
                      ]),
                ),

                // ── Grid ─────────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppSizeConst.A40,right: 30),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: _isMonth
                                ? _buildMonthGrid(days, now, monthCells)
                                : _buildWeekGrid(days, hours, ws, now),
                          ),
                          if (_isMonth)
                            Expanded(flex: 2, child: _buildMonthList()),
                        ]),
                  ),
                ),
              ]),
            ),
          ),
        ),
      );
    });
  }

  // ── HOLIDAY LEGEND ───────────────────────────────────────────────────────
  /// Shared by the month and week views — just pass the relevant holidays.
  Widget _buildHolidayLegend(List<HolidayData> holidays) {
    if (holidays.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 12,
        runSpacing: 10,
        children: holidays.map((h) {
          final d = DateTime.tryParse(h.date);
          final label = d == null
              ? h.date
              : '${d.day.toString().padLeft(2, '0')} ${kFullMonthNames[d.month]}';

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: HolidayStyle.chipBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: HolidayStyle.border,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  h.holidayName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 24),
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── WEEK GRID ────────────────────────────────────────────────────────────
  Widget _buildWeekGrid(
      List<String> days, List<int> hours, DateTime ws, DateTime now) {
    return Column(
      children: [
        Expanded(
          child: ScrollConfiguration(
            behavior:
            ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // hour gutter
                    SizedBox(
                      width: 40,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(height: _headerHeight),
                            ...hours.map((h) => SizedBox(
                              height: _hourHeight,
                              child: Padding(
                                padding:
                                const EdgeInsets.only(right: 6, top: 2),
                                child: Text(
                                  _hourLabel(h),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                              ),
                            )),
                          ]),
                    ),
                    Expanded(
                      child: Column(children: [
                        // ── day headers ──────────────────────────────────
                        Row(
                          children: List.generate(7, (i) {
                            final d = ws.add(Duration(days: i));
                            final isToday = d.year == now.year &&
                                d.month == now.month &&
                                d.day == now.day;
                            final holiday = _holidayFor(d);
                            final isHoliday = holiday != null;

                            return Expanded(
                              child: Tooltip(
                                message: isHoliday ? holiday.holidayName : '',
                                child: Container(
                                  height: _headerHeight,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isHoliday
                                        ? HolidayStyle.cellBg
                                        : Colors.blue.shade50,
                                    border: isHoliday
                                        ? Border.all(
                                        color: HolidayStyle.border,
                                        width: 1)
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // weekday name — red when it's a holiday
                                      Text(
                                        days[i],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isHoliday
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          color: isHoliday
                                              ? HolidayStyle.text
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isToday
                                              ? ColorManager.blueprime
                                              : Colors.transparent,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text('${d.day}',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: isHoliday
                                                    ? FontWeight.w700
                                                    : FontWeight.w600,
                                                color: isToday
                                                    ? Colors.white
                                                    : (isHoliday
                                                    ? HolidayStyle.text
                                                    : Colors
                                                    .grey.shade600))),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        // ── hour columns ─────────────────────────────────
                        SizedBox(
                          height: _hourHeight * hours.length,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(7, (col) {
                              final colDate = ws.add(Duration(days: col));
                              final dayVisits = _visitsForDate(colDate);
                              final isHolidayCol = _holidayFor(colDate) != null;

                              return Expanded(
                                child: Stack(children: [
                                  Column(
                                    children: hours
                                        .map((_) => Container(
                                      height: _hourHeight,
                                      decoration: BoxDecoration(
                                        color: isHolidayCol
                                            ? HolidayStyle.cellBg
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: const Color(0xFFE0E0E0),
                                          width: 0.8,
                                        ),
                                      ),
                                    ))
                                        .toList(),
                                  ),
                                  ...dayVisits.map((v) {
                                    DateTime? startDt;
                                    DateTime? endDt;
                                    try {
                                      startDt =
                                          DateTime.parse(v.visiteDateTimeFrom!)
                                              .toLocal();
                                      endDt = DateTime.parse(v.visitDateTimeTo!)
                                          .toLocal();
                                    } catch (_) {}
                                    if (startDt == null) {
                                      return const SizedBox.shrink();
                                    }

                                    if (startDt.hour < _startHour) {
                                      return const SizedBox.shrink();
                                    }

                                    final startHour = startDt.hour;
                                    final startMinute = startDt.minute;

                                    final durationMins = endDt != null
                                        ? endDt
                                        .difference(startDt)
                                        .inMinutes
                                        .clamp(15, 9999)
                                        : 60;

                                    final top =
                                        ((startHour - _startHour) * _hourHeight) +
                                            (startMinute / 60.0 * _hourHeight);

                                    // Minimum visible height so very short
                                    // visits (e.g. 5-10 mins) still render a
                                    // usable, tappable card that can fit at
                                    // least the visit type label.
                                    const double _minCardHeight = 34.0;
                                    final rawHeight =
                                        (durationMins / 60.0) * _hourHeight - 2;
                                    final height = rawHeight < _minCardHeight
                                        ? _minCardHeight
                                        : rawHeight;

                                    return Positioned(
                                      top: top,
                                      left: 2,
                                      right: 2,
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        onTap: () =>
                                            _openVisitDetails(v.visitId!),
                                        child: _WeekApptCard(
                                            visit: v, height: height),
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
          ),
        ),
        // ── Holiday names + dates for the visible week ────────────────────
        _buildHolidayLegend(_holidaysThisWeek),
      ],
    );
  }

  // ── MONTH GRID ───────────────────────────────────────────────────────────
  Widget _buildMonthGrid(
      List<String> days, DateTime now, List<int?> monthCells) {
    const Color greenBg = Color(0xFFEEF7EE);

    final prevMonth = DateTime(_currentDate.year, _currentDate.month - 1);
    final daysInPrev = DateTime(_currentDate.year, _currentDate.month, 0).day;
    final nextMonth = DateTime(_currentDate.year, _currentDate.month + 1);
    final totalLeading = _monthStartWeekday;
    final totalCurrent = _daysInMonth;

    return Column(children: [
      Row(
        children: days
            .map((d) => Expanded(
          child: Container(
            height: 36,
            alignment: Alignment.center,
            color: Colors.blue.shade50,
            child: Text(d,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700)),
          ),
        ))
            .toList(),
      ),
      const SizedBox(height: 4),
      Expanded(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth = constraints.maxWidth / 7;
              final cellHeight = cellWidth / 1.1;

              final rows = <List<int?>>[];
              for (var i = 0; i < monthCells.length; i += 7) {
                rows.add(
                    monthCells.sublist(i, (i + 7).clamp(0, monthCells.length)));
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

                      // ── OVERFLOW CELL (prev / next month) ────────────
                      if (day == null) {
                        final isLeading = globalIndex < totalLeading;
                        final DateTime overflowDate;
                        if (isLeading) {
                          final d = daysInPrev - totalLeading + globalIndex + 1;
                          overflowDate =
                              DateTime(prevMonth.year, prevMonth.month, d);
                        } else {
                          final d =
                              globalIndex - totalLeading - totalCurrent + 1;
                          overflowDate =
                              DateTime(nextMonth.year, nextMonth.month, d);
                        }

                        final overflowHoliday = _holidayFor(overflowDate);
                        final isFirstOfMonth = overflowDate.day == 1;
                        final monthAbbr = [
                          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                        ][overflowDate.month - 1];

                        return SizedBox(
                          width: cellWidth,
                          height: cellHeight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: overflowHoliday != null
                                  ? Border.all(
                                  color:
                                  HolidayStyle.border.withOpacity(0.35),
                                  width: 1)
                                  : Border.all(color: const Color(0xFFEEEEEE)),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 6),
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
                                          color: Colors.black26,
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
                                        color: Colors.black26,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // ── CURRENT MONTH CELL ───────────────────────────
                      final isToday = _currentDate.year == now.year &&
                          _currentDate.month == now.month &&
                          day == now.day;
                      final isWeekend = col == 0 || col == 6;
                      final holiday = _holidayForDayOfCurrentMonth(day);
                      final isHoliday = holiday != null;
                      // Only weekdays are counted for visits (business rule
                      // preserved). If there's no visit data for the day,
                      // the cell stays blank/white — colors only appear
                      // when there's an actual holiday or actual visits.
                      final visits = isWeekend ? null : _visitCountForDay(day);
                      final hasVisits = visits != null && visits > 0;
                      final bg = isHoliday
                          ? HolidayStyle.cellBg
                          : hasVisits
                          ? greenBg
                          : Colors.white;
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
                          holiday: holiday,
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
      // ── Holiday names + dates for the visible month ────────────────────
      _buildHolidayLegend(_holidaysThisMonth),
    ]);
  }

  // ── MONTH LIST ───────────────────────────────────────────────────────────
  Widget _buildMonthList() {
    final monthVisits = widget.visits.where((v) {
      if (v.visiteDateTimeFrom == null || v.visiteDateTimeFrom!.isEmpty) {
        return false;
      }
      try {
        final dt = DateTime.parse(v.visiteDateTimeFrom!).toLocal();
        return dt.year == _currentDate.year && dt.month == _currentDate.month;
      } catch (_) {
        return false;
      }
    }).toList();

    return monthVisits.isEmpty
        ? Center(
        child: Text('No appointments!',
            style: AllNoDataAvailable.customTextStyle(context)))
        : ScrollConfiguration(
      behavior: ScrollBehavior().copyWith(scrollbars: false),
          child: ListView(
                padding: const EdgeInsets.only(left:10,bottom: 8),
                children:
                monthVisits.map((v) => _MonthListCard(visit: v)).toList(),
              ),
        );
  }
}

// ── Month Grid Cell ──────────────────────────────────────────────────────────
class _MonthGridCell extends StatefulWidget {
  final int day;
  final int month;
  final bool isToday;
  final bool hasVisits;
  final int? visits;
  final Color bg;
  final Color visitColor;
  final HolidayData? holiday;

  const _MonthGridCell({
    required this.day,
    required this.month,
    required this.isToday,
    required this.hasVisits,
    required this.visits,
    required this.bg,
    required this.visitColor,
    this.holiday,
  });

  bool get isHoliday => holiday != null;

  @override
  State<_MonthGridCell> createState() => _MonthGridCellState();
}

class _MonthGridCellState extends State<_MonthGridCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // holiday cells and cells with visits hover; empty/blank cells don't
      onEnter: (_) {
        if (widget.hasVisits || widget.isHoliday) {
          setState(() => _hovered = true);
        }
      },
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _hovered
              ? (widget.isHoliday
              ? HolidayStyle.cellHoverBg
              : const Color(0xFFF5F0FF))
              : widget.bg,
          border: _hovered
              ? Border(
            left: BorderSide(
              color: widget.isHoliday
                  ? HolidayStyle.border
                  : const Color(0xFF7C3AED),
              width: 3,
            ),
          )
              : widget.isHoliday
              ? Border.all(
              color: HolidayStyle.border,
              width: HolidayStyle.borderWidth)
              : Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: _hovered
            ? (widget.isHoliday ? _buildHolidayHovered() : _buildHovered())
            : _buildNormal(),
      ),
    );
  }

  Widget _buildNormal() {
    final isHoliday = widget.isHoliday;

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
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isHoliday ? HolidayStyle.text : Colors.black87,
                ),
              ),
              const SizedBox(width: 3),
            ],
            const SizedBox(width: 5),
            widget.isToday
                ? Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                  color: ColorManager.blueprime,
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
                    fontWeight:
                    isHoliday ? FontWeight.w700 : FontWeight.w600,
                    color: isHoliday
                        ? HolidayStyle.text
                        : Colors.grey.shade700)),
          ],
        ),
        const Spacer(),

        // Holiday name inside the cell
        if (isHoliday)
          Row(
            children: [
              const Spacer(),
              Flexible(
                child: Text(
                  widget.holiday!.holidayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: HolidayStyle.text,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),

        // Visit count box — only rendered when this specific day actually
        // has visit data. No visits & no holiday => cell stays blank.
        if (!isHoliday && widget.hasVisits)
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
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[(month - 1).clamp(0, 11)];
  }

  // ── hover content for a HOLIDAY cell ───────────────────────────────────
  Widget _buildHolidayHovered() {
    final h = widget.holiday!;
    final d = DateTime.tryParse(h.date);
    final dateLabel = d == null
        ? h.date
        : '${d.day.toString().padLeft(2, '0')} ${kFullMonthNames[d.month]}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 2),
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                  color: HolidayStyle.border, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            const Text('Holiday',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: HolidayStyle.text)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          h.holidayName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: HolidayStyle.text),
        ),
        const SizedBox(height: 3),
        Text(
          dateLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600),
        ),
        if (widget.hasVisits) ...[
          const SizedBox(height: 4),
          Text(
            'Total Visits ${widget.visits.toString().padLeft(2, '0')}',
            style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4CAF50)),
          ),
        ],
      ],
    );
  }

  // ── hover content for a NORMAL cell (only ever shown when hasVisits) ──
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

// ── Week Appointment Card ────────────────────────────────────────────────────
///
/// Redesigned so that even very short visits ALWAYS render a real card with
/// the visit type ("SOC") and — as height allows — the patient name and
/// remaining details stacked underneath, instead of collapsing into a blank
/// colored bar with no readable text.
class _WeekApptCard extends StatelessWidget {
  final ClinicianCalendarVisitData visit;
  final double height;
  const _WeekApptCard({required this.visit, required this.height});

  // Tunable break points for how much detail we can safely stack under
  // the type label without overflowing the card.
  static const double _showPatientAt = 30;
  static const double _showDiagnosisAt = 46;
  static const double _showDistanceAt = 58;
  static const double _showTimeAt = 68;
  static const double _showBadgeAt = 34;

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
      endDt = DateTime.parse(visit.visitDateTimeTo!).toLocal();
    } catch (_) {}

    final timeLabel = (startDt != null && endDt != null)
        ? '${_fmt(startDt)}–${_fmt(endDt)}'
        : '';

    final tooltipMessage = [
      if (type.isNotEmpty) type,
      if ((visit.patientName ?? '').isNotEmpty) visit.patientName!,
      if (timeLabel.isNotEmpty) timeLabel,
    ].join('\n');

    final showPatient = height > _showPatientAt;
    final showDiagnosis = height > _showDiagnosisAt;
    final showDistance = height > _showDistanceAt;
    final showTime = height > _showTimeAt && timeLabel.isNotEmpty;
    final showBadge = height > _showBadgeAt;

    return Tooltip(
      message: tooltipMessage,
      waitDuration: const Duration(milliseconds: 300),
      child: ClipRect(
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
            border: Border(left: BorderSide(color: accent, width: 3)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      type.isNotEmpty ? type : (visit.patientName ?? ''),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: accent),
                    ),
                  ),
                  if (showBadge)
                    Container(
                      height: 12,
                      width: 12,
                      margin: const EdgeInsets.only(left: 4),
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
              if (showPatient)
                Text(visit.patientName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
              if (showDiagnosis)
                Text(visit.primaryDiagnosis ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 8, color: Colors.grey.shade600)),
              if (showDistance)
                Text(visit.distance ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 8, color: Colors.grey.shade600)),
              if (showTime)
                Text(timeLabel,
                    style: TextStyle(fontSize: 8, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Month List Card ──────────────────────────────────────────────────────────
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
    return '$h:$m $ampm';
  }

  String _initials(String name) {
    final parts =
    name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.visit.visitTypeName ?? '';
    final accent = apptAccent(type);
    final bg = apptBg(type);
    final name = widget.visit.patientName ?? '';

    DateTime? startDt;
    DateTime? endDt;
    try {
      startDt = DateTime.parse(widget.visit.visiteDateTimeFrom!).toLocal();
      endDt = DateTime.parse(widget.visit.visitDateTimeTo!).toLocal();
    } catch (_) {}

    final mo = startDt != null ? startDt.month.toString().padLeft(2, '0') : '--';
    final d = startDt != null ? startDt.day.toString().padLeft(2, '0') : '--';
    final y = startDt != null ? startDt.year.toString() : '----';

    return
      ConstrainedBox(
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
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 18,
                    decoration: BoxDecoration(color: bg),
                    alignment: Alignment.center,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(type,
                          style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w800,
                              color: accent,
                              letterSpacing: 0.8)),
                    ),
                  ),
                  Expanded(
                    child:
                    _buildCardView(
                        bg, accent, name, mo, d, y, startDt, endDt),
                  ),
                ]),
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
                  fontSize: 12, color: accent, fontWeight: FontWeight.bold)),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 2),
              Text(widget.visit.primaryDiagnosis ?? '--',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              const SizedBox(height: 1),
              Text(widget.visit.distance ?? '--',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
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
              const SizedBox(width: 3),
              Text('$mo-$d-$y',
                  style: TextStyle(
                      fontSize: 12,
                      color: ColorManager.blueprime,
                      fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(height: 12),
            if (startDt != null && endDt != null)
              Text('${_fmt(startDt)}-${_fmt(endDt)}',
                style: AllNoDataAvailable.customTextStyle(context),),
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
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Note :',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFBF360C))),
          ]),
          const SizedBox(height: 6),
          Text('No Note here!',
              style: AllNoDataAvailable.customTextStyle(context)),
        ],
      ),
    );
  }
}