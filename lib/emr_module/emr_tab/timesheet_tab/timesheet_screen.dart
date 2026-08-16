import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/timesheet_tab/timesheet_popup/add_event_popup.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/timesheet_tab/timesheet_popup/competed_visit_popup.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/timesheet_tab/timesheet_popup/deaily_summery_popup.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/timesheet_tab/timesheet_popup/pending_visit_popup.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/timesheet_tab/timesheet_popup/schedule_visit_popup.dart';

import '../../../../../app/services/api/managers/emr_module_manager/timesheet_tab_manager/timesheet_tab_manager.dart';
import '../../../../../app/services/token/token_manager.dart';
import '../../../../../data/api_data/emr_module_data/timesheet_tab_data/timesheet_data.dart';
import '../emr_const/calender_popup_const.dart';
import '../emr_const/dropdown_const.dart';
import '../../../../../app/resources/value_manager.dart';
import '../../../../widgets/widgets/custom_scrollbar.dart';

// ── Local UI model ────────────────────────────────────────────────────────────
class _CalendarCell {
  final int day;
  final int pendingVisits;
  final int completedVisits;
  final int scheduledVisits;
  final double revenue;
  final double target;
  final bool isWeekend;
  final bool isOverflow;
  final DateTime? date;

  const _CalendarCell({
    required this.day,
    this.pendingVisits   = 0,
    this.completedVisits = 0,
    this.scheduledVisits = 0,
    this.revenue   = 0,
    this.target    = 0,
    this.isWeekend  = false,
    this.isOverflow = false,
    this.date,
  });
}

// ── Calendar Builder ──────────────────────────────────────────────────────────

List<List<_CalendarCell>> _buildWeeks(
    DateTime month, Map<int, _CalendarCell> calendarData) {
  final firstDay    = DateTime(month.year, month.month, 1);
  final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
  final startOffset = firstDay.weekday % 7;

  final prevMonth  = DateTime(month.year, month.month - 1);
  final daysInPrev =
  DateUtils.getDaysInMonth(prevMonth.year, prevMonth.month);

  final flat = <_CalendarCell>[
    ...List.generate(startOffset, (i) {
      final d    = daysInPrev - startOffset + 1 + i;
      final date = DateTime(prevMonth.year, prevMonth.month, d);
      return _CalendarCell(
        day:        d,
        isWeekend:  date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday,
        isOverflow: true,
        date:       date,
      );
    }),
    ...List.generate(daysInMonth, (i) {
      final d        = i + 1;
      final date     = DateTime(month.year, month.month, d);
      final isSatSun = date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday;
      if (isSatSun) {
        return _CalendarCell(day: d, isWeekend: true, date: date);
      }
      final existing = calendarData[d];
      if (existing != null) {
        return _CalendarCell(
          day:             existing.day,
          pendingVisits:   existing.pendingVisits,
          completedVisits: existing.completedVisits,
          scheduledVisits: existing.scheduledVisits,
          revenue:         existing.revenue,
          target:          existing.target,
          isWeekend:       existing.isWeekend,
          date:            date,
        );
      }
      return _CalendarCell(day: d, date: date);
    }),
  ];

  final nextMonth = DateTime(month.year, month.month + 1);
  int trailingDay = 1;
  while (flat.length % 7 != 0) {
    final date = DateTime(nextMonth.year, nextMonth.month, trailingDay);
    flat.add(_CalendarCell(
      day:        trailingDay,
      isWeekend:  date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday,
      isOverflow: true,
      date:       date,
    ));
    trailingDay++;
  }

  final weeks = <List<_CalendarCell>>[];
  for (var i = 0; i < flat.length; i += 7) {
    weeks.add(flat.sublist(i, i + 7));
  }
  return weeks;
}

// ── Root Widget ───────────────────────────────────────────────────────────────

class TimesheetScreen extends StatefulWidget {
  const TimesheetScreen({super.key});

  @override
  State<TimesheetScreen> createState() => _TimesheetScreenState();
}

class _TimesheetScreenState extends State<TimesheetScreen> {
  DateTime _currentMonth = DateTime.now();
  final GlobalKey _datePillKey = GlobalKey();
  final ScrollController _horizontalScrollController = ScrollController();

  TodaysVisitData? _todaysVisitData;

  Map<int, _CalendarCell> _calendarData = {};
  bool _isLoadingCalendar = false;

  List<VisitRangeItemData> _visitRangeList = [];
  bool _isLoadingVisits = false;

  List<PayrollPeriodData> _payrollPeriods = [];
  PayrollPeriodData? _selectedPeriod;
  bool _isLoadingPeriods = false;

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchPayrollPeriods();
    _fetchCalendar(_currentMonth);
    _fetchTodaysVisitData();
  }

  Future<void> _fetchCalendar(DateTime month) async {
    setState(() => _isLoadingCalendar = true);

    final ClinicianMonthlyCalendarData? result =
    await getClinicianMonthlyCalendar(
      context,
      month.year,
      month.month,
    );

    if (result != null) {
      final Map<int, _CalendarCell> mapped = {};

      for (final ClinicianCalendarDayData day in result.days) {
        if (day.date.isEmpty) continue;
        final parsedDate = DateTime.tryParse(day.date);
        if (parsedDate == null) continue;

        final dayNum = parsedDate.day;

        mapped[dayNum] = _CalendarCell(
          day:             dayNum,
          pendingVisits:   day.visitStatus == 'Pending'   ? day.visitCount : 0,
          completedVisits: day.visitStatus == 'Completed' ? day.visitCount : 0,
          scheduledVisits: day.visitStatus == 'Scheduled' ? day.visitCount : 0,
          revenue:         day.earnedAmount,
          target:          day.expectedAmount,
        );
      }

      setState(() => _calendarData = mapped);
    }

    setState(() => _isLoadingCalendar = false);
  }

  Future<void> _fetchTodaysVisitData() async {
    final int employeeId = await TokenManager.getEmployeeId();
    final result = await getTodaysVisitData(
      context:     context,
      clinicianId: employeeId.toString(),
    );
    if (result != null) setState(() => _todaysVisitData = result);
  }

  Future<void> _fetchVisitRange(String dateFrom, String dateTo) async {
    setState(() => _isLoadingVisits = true);
    final result = await getVisitRangeList(
      context:  context,
      dateFrom: dateFrom,
      dateTo:   dateTo,
    );
    setState(() {
      _visitRangeList  = result?.visits ?? [];
      _isLoadingVisits = false;
    });
  }

  Future<void> _fetchPayrollPeriods() async {
    setState(() => _isLoadingPeriods = true);
    final result = await getPayrollPeriodCurrent(context: context);
    if (result != null && result.periods != null) {
      setState(() {
        _payrollPeriods = result.periods!;
        _selectedPeriod = null;
      });
    }
    setState(() => _isLoadingPeriods = false);
  }

  void _prev() {
    final newMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    setState(() => _currentMonth = newMonth);
    _fetchCalendar(newMonth);
  }

  void _next() {
    final newMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    setState(() => _currentMonth = newMonth);
    _fetchCalendar(newMonth);
  }

  String get _monthLabel {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[_currentMonth.month - 1]} ${_currentMonth.year}';
  }

  @override
  Widget build(BuildContext context) {
    final weeks    = _buildWeeks(_currentMonth, _calendarData);
    final today    = DateTime.now();
    final isCurrentMonth = today.year == _currentMonth.year &&
        today.month == _currentMonth.month;
    final todayDay = isCurrentMonth ? today.day : -1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 40, right: 15, top: 15),
        child: LayoutBuilder(builder: (context, constraints) {
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
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                  // ════════════════════════════════════════
                  // FLEX-6 : Left column
                  // ════════════════════════════════════════
                  Expanded(
                    flex: 6,
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [

                          // Left Row 1 : Total Revenue + Calendar nav
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                const Text(
                                  'Total Revenue of the Day : ',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color:    Colors.black54),
                                ),
                                Text(
                                  '\$${_todaysVisitData?.earned?.toStringAsFixed(2) ?? '0.00'}',
                                  style: const TextStyle(
                                    fontSize:   13,
                                    fontWeight: FontWeight.bold,
                                    color:      Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                _buildMonthNav(),
                              ],
                            ),
                          ),

                          // Left Row 2 : Calendar
                          Expanded(
                            child: _isLoadingCalendar
                                ? const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                                : Column(
                              children: [
                                _TimesheetWeekdayRow(),
                                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                                Expanded(
                                  child: _TimesheetCalendarGrid(
                                    weeks:    weeks,
                                    todayDay: todayDay,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 50),

                  // ════════════════════════════════════════
                  // FLEX-3 : Right column
                  // ════════════════════════════════════════
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [

                          // Right Row 1 : Dropdown + Add button
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: PayrollPeriodDropdown(
                                    items: _payrollPeriods,
                                    value: _selectedPeriod,
                                    hintText: '(Select payroll period)',
                                    onChanged: (period) {
                                      setState(() => _selectedPeriod = period);
                                      if (period != null) {
                                        _fetchVisitRange(
                                          period.startDate ?? '',
                                          period.endDate ?? '',
                                        );
                                      }
                                    },
                                  ),
                                ),
                                const Expanded(flex: 1, child: SizedBox()),
                                Expanded(
                                  flex: 1,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const AddEventPopup(),
                                      );
                                    },
                                    icon: const Icon(Icons.add, size: 14),
                                    label: const Text('Add',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ColorManager.bluebottom,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Right Row 2 : Visit ListView
                          Expanded(
                            child: _isLoadingVisits
                                ? const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                                : _visitRangeList.isEmpty
                                ? Center(
                              child: Text(
                                'No visits found',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade400),
                              ),
                            )
                                : ListView.builder(
                              padding: const EdgeInsets.only(top: 4),
                              itemCount: _visitRangeList.length,
                              itemBuilder: (_, i) =>
                                  _SideVisitTile(item: _visitRangeList[i]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),       // Column
                  ),  // SizedBox
                ),    // Padding
              ),       // SingleChildScrollView
            );         // CustomScrollbar
          }),           // LayoutBuilder
      ),
    );
  }

  Widget _buildMonthNav() {
    return Container(
      decoration: BoxDecoration(
        color:        Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _prev,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: const Icon(Icons.chevron_left, size: 18, color: Colors.black87),
            ),
          ),
          Container(width: 1, height: 18, color: Colors.grey.shade300),
          GestureDetector(
            key: _datePillKey,
            onTap: () async {
              final picked = await CalendarPickerHelper.show(
                context:          context,
                anchorKey:        _datePillKey,
                selectedDate:     _currentMonth,
                horizontalOffset: -100,
              );
              if (picked != null) {
                final newMonth = DateTime(picked.year, picked.month);
                setState(() => _currentMonth = newMonth);
                _fetchCalendar(newMonth);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('images/hh_emr/calendar.png',
                      width: 13, height: 13, color: Colors.black87),
                  const SizedBox(width: 5),
                  Text(
                    _monthLabel,
                    style: const TextStyle(
                      fontSize:   12,
                      fontWeight: FontWeight.w500,
                      color:      Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 18, color: Colors.grey.shade300),
          GestureDetector(
            onTap: _next,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: const Icon(Icons.chevron_right, size: 18, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weekday Row ───────────────────────────────────────────────────────────────

class _TimesheetWeekdayRow extends StatelessWidget {
  static const _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color:   Colors.blue.shade50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(_days.length, (i) {
          return Expanded(
            child: Center(
              child: Text(
                _days[i],
                style: const TextStyle(
                  fontSize:      11,
                  fontWeight:    FontWeight.w600,
                  letterSpacing: 0.3,
                  color:         Colors.black45,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Calendar Grid ─────────────────────────────────────────────────────────────

class _TimesheetCalendarGrid extends StatelessWidget {
  final List<List<_CalendarCell>> weeks;
  final int todayDay;

  const _TimesheetCalendarGrid({required this.weeks, required this.todayDay});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.builder(
        itemCount: weeks.length,
        itemBuilder: (_, weekIdx) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(
                  7,
                      (dayIdx) => Expanded(
                    child: _TimesheetCalendarCell(
                      data:    weeks[weekIdx][dayIdx],
                      isToday: !weeks[weekIdx][dayIdx].isOverflow &&
                          weeks[weekIdx][dayIdx].day == todayDay,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Calendar Cell ─────────────────────────────────────────────────────────────

class _TimesheetCalendarCell extends StatelessWidget {
  final _CalendarCell data;
  final bool isToday;

  const _TimesheetCalendarCell({required this.data, required this.isToday});

  static const _monthAbbr = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  bool get _isFirstOfMonth => data.day == 1;

  String get _monthAbbreviation =>
      data.date != null ? _monthAbbr[data.date!.month] : '';

  bool get _hasContent =>
      !data.isWeekend &&
          !data.isOverflow &&
          (data.pendingVisits > 0 ||
              data.completedVisits > 0 ||
              data.scheduledVisits > 0 ||
              data.target > 0);

  Color get _bgColor {
    if (data.isOverflow)          return Colors.white;
    if (data.pendingVisits > 0)   return const Color(0xFFFFF3F0);
    if (data.completedVisits > 0) return const Color(0xFFFFF3F0);
    // CHANGED: scheduled → transparent (no background tint)
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 90),
      decoration: BoxDecoration(
        color:  _bgColor,
        border: Border.all(color: Colors.grey.shade100, width: 0.6),
      ),
      padding: const EdgeInsets.all(5),
      child:   _buildDayCell(context),
    );
  }

  Widget _buildDayCell(BuildContext context) {
    final numberColor      = data.isOverflow ? Colors.black26 : Colors.black87;
    final monthLabelColor  = data.isOverflow ? Colors.black26 : Colors.black87;

    final bool onlyScheduled = data.scheduledVisits > 0 &&
        data.completedVisits == 0 &&
        data.pendingVisits == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Day number ──────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_isFirstOfMonth) ...[
              Text(
                _monthAbbreviation,
                style: TextStyle(
                  fontSize:      10,
                  fontWeight:    FontWeight.w700,
                  color:         monthLabelColor,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(width: 3),
            ],
            Container(
              width: 22, height: 22,
              decoration: isToday
                  ? BoxDecoration(
                color: Colors.blue.shade500,
                shape: BoxShape.circle,
              )
                  : null,
              child: Center(
                child: Text(
                  '${data.day}',
                  style: TextStyle(
                    fontSize:   11,
                    fontWeight: FontWeight.w600,
                    color: isToday ? Colors.white : numberColor,
                  ),
                ),
              ),
            ),
          ],
        ),

        // ── Visit badges + revenue ──────────────────────────────
        if (_hasContent) ...[
          const SizedBox(height: 6),

          if (data.pendingVisits > 0)
            GestureDetector(
              onTap: () => showDialog(
                context:      context,
                barrierColor: Colors.black26,
                builder: (_) => PendingVisitsPopup(
                  date: data.date != null
                      ? '${data.date!.year.toString().padLeft(4, '0')}-${data.date!.month.toString().padLeft(2, '0')}-${data.date!.day.toString().padLeft(2, '0')}'
                      : '',
                ),
              ),
              child: _VisitLabel(
                count: data.pendingVisits,
                label: 'Pending Visits',
                color: const Color(0xFFE53935),
              ),
            ),

          if (data.completedVisits > 0)
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => CompletedVisitsPopup(
                  date: data.date != null
                      ? '${data.date!.year.toString().padLeft(4, '0')}-${data.date!.month.toString().padLeft(2, '0')}-${data.date!.day.toString().padLeft(2, '0')}'
                      : '',
                ),
              ),
              child: _VisitLabel(
                count: data.completedVisits,
                label: 'Completed Visits',
                color: const Color(0xFF43A047),
              ),
            ),

          if (data.scheduledVisits > 0)
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => ScheduledVisitsPopup(
                  date: data.date != null
                      ? '${data.date!.year.toString().padLeft(4, '0')}-${data.date!.month.toString().padLeft(2, '0')}-${data.date!.day.toString().padLeft(2, '0')}'
                      : '',
                ),
              ),
              // CHANGED: grey color for scheduled, no background tint
              child: _VisitLabel(
                count: data.scheduledVisits,
                label: 'Scheduled Visits',
                color: Colors.grey.shade500,
              ),
            ),

          // ── earned / expected ───────────────────────────────
          if (data.target > 0) ...[
            const SizedBox(height: 4),
            if (onlyScheduled)
              Text(
                '\$${data.target.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize:   10,
                  fontWeight: FontWeight.w600,
                  color:      Colors.grey.shade500,
                ),
              )
            else
              GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => DailySummaryPopup(
                    date: data.date != null
                        ? '${data.date!.year.toString().padLeft(4, '0')}-${data.date!.month.toString().padLeft(2, '0')}-${data.date!.day.toString().padLeft(2, '0')}'
                        : '',
                  ),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      // CHANGED: earned → red, target → green
                      TextSpan(
                        text: '\$${data.revenue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize:   10,
                          color:      Color(0xFF43A047),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: '/\$${data.target.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize:   10,
                          color: data.pendingVisits > 0
                              ? const Color(0xFFE53935)
                              : const Color(0xFF43A047),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ],
    );
  }
}

// ── Visit Label (all types) ───────────────────────────────────────────────────
// CHANGED: no dot, uniform 10px, Flexible ellipsis

class _VisitLabel extends StatelessWidget {
  final int    count;
  final String label;
  final Color  color;

  const _VisitLabel({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count ',
            style: TextStyle(
              fontSize:   10,
              fontWeight: FontWeight.w700,
              color:      color,
            ),
          ),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize:   10,
                fontWeight: FontWeight.w600,
                color:      color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Side Visit Tile ───────────────────────────────────────────────────────────

class _SideVisitTile extends StatelessWidget {
  final VisitRangeItemData item;
  const _SideVisitTile({required this.item});

  // String get _initials {
  //   final parts = (item.patientName ?? '').trim().split(' ');
  //   if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  //   if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
  //   return '?';
  // }
  String get _initials {
    final parts = (item.patientName ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    final hour   = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute$period';
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.day.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final timeRange = '${_formatTime(item.timeFrom)}–${_formatTime(item.timeTo)}';
    final date      = _formatDate(item.timeFrom);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset:     const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Driving row ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.only(
                top: 12, bottom: 10, left: 10, right: 10),
            child: Row(
              children: [
                Icon(Icons.directions_car_sharp,
                    size: 18, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Driving to ${item.patientName ?? ''}',
                        style: TextStyle(
                          fontSize:   11,
                          color:      Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '(${item.distance?.toStringAsFixed(1) ?? '0'} mi)',
                        style: TextStyle(
                          fontSize:   11,
                          color:      Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Text(
                    '\$${item.visitCharge?.toStringAsFixed(2) ?? '0.00'}',
                    style: TextStyle(
                      fontSize:   11,
                      fontWeight: FontWeight.w600,
                      color:      ColorManager.greenDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Divider(height: 1, color: Colors.grey.shade100),
          ),

          // ── Visit detail ─────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color:        const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // date + time
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(date,
                              style: TextStyle(
                                  fontSize: 10,
                                  color:    Colors.grey.shade500)),
                          const SizedBox(height: 5),
                          Text(timeRange,
                              style: TextStyle(
                                fontSize:   10,
                                color:      Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              )),
                        ],
                      ),
                    ),

                    // avatar + name + visit type
                    Expanded(
                      flex: 5,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius:          15,
                            backgroundColor: ColorManager.circleColor,
                            child: Text(_initials,
                                style: TextStyle(
                                  color:      ColorManager.mediumgrey,
                                  fontSize:   10,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                Text(
                                  item.patientName ?? '',
                                  style: const TextStyle(
                                    fontSize:   11,
                                    fontWeight: FontWeight.w600,
                                    color:      Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item.visitTypeName ?? '',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color:    Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    // address
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on_outlined,
                                size:  18,
                                color: Colors.blueAccent.shade400),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                item.address ?? '',
                                style: TextStyle(
                                    fontSize: 11,
                                    color:    Colors.grey.shade500),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // ── Status row ────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Expanded(flex: 3, child: SizedBox()),
                    Text(
                      (item.visitLabel ?? '').isEmpty ? '-' : item.visitLabel!,
                      style: TextStyle(
                        fontSize:   10,
                        fontWeight: FontWeight.w600,
                        color: item.visitLabel == 'Completed'
                            ? ColorManager.greenDark
                            : item.visitLabel == 'Pending'
                            ? const Color(0xFFC62828)
                            : ColorManager.mediumgrey,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      (item.inZone ?? false) ? 'In Zone' : 'Out of Zone',
                      style: TextStyle(
                        fontSize:   11,
                        fontWeight: FontWeight.w600,
                        color: (item.inZone ?? false)
                            ? ColorManager.greenDark
                            : const Color(0xFFC62828),
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}