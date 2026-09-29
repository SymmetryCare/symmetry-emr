import 'dart:async';
import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';

import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_patient_manager/patient_schedule_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/patient_tab_data/patient_schedule_data.dart';

// ─── Episode Dropdown Widget ──────────────────────────────────────────────────
class EpisodeChartDropdown extends StatefulWidget {
  final EpisodeChartDropdownData? value;
  final List<EpisodeChartDropdownData> items;
  final void Function(EpisodeChartDropdownData?)? onChanged;
  final double? width;
  final double? height;

  const EpisodeChartDropdown({
    Key? key,
    this.value,
    required this.items,
    this.onChanged,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<EpisodeChartDropdown> createState() => _EpisodeChartDropdownState();
}

class _EpisodeChartDropdownState extends State<EpisodeChartDropdown> {
  EpisodeChartDropdownData? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  void didUpdateWidget(EpisodeChartDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      setState(() => _selectedValue = widget.value);
    }
  }

  void _showDropdownDialog() async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final result = await showDialog<EpisodeChartDropdownData>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: widget.width ?? size.width,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.items.length,
                        itemBuilder: (context, index) {
                          final ep = widget.items[index];
                          final isSelected =
                              _selectedValue?.ptEpisodeId == ep.ptEpisodeId;
                          return InkWell(
                            onTap: () => Navigator.of(context).pop(ep),
                            child: Container(
                              color: isSelected
                                  ? Colors.blue.shade50
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Text(
                                ep.label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color:  Color(0xFF444444),
                                  fontWeight: FontWeight.w500,

                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedValue = result;
        widget.onChanged?.call(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = widget.items.isNotEmpty;
    return SizedBox(
      width: widget.width ?? 260,
      height: widget.height ?? 28,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        // No point opening the picker if there's nothing to pick.
        onTap: hasItems ? _showDropdownDialog : null,
        child: Container(
          padding:
          const EdgeInsets.only(bottom: 3, top: 5, left: 12, right: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  !hasItems
                      ? 'No episodes found!'
                      : (_selectedValue?.label ?? 'Select Episode'),
                  style: const TextStyle(
                    fontSize: 11, color: Color(0xFF444444), fontWeight: FontWeight.w500,),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_drop_down,
                  size: 16, color: Color(0xFF888888)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
String _dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

// Zone colors for episode-date-range based highlighting.
// A "60-day episode" is split into two 30-day halves:
//   1st 30 days: episodeFrom -> mid30DayDate   (light green)
//   2nd 30 days: mid30DayDate -> episodeTo     (light red)
// Anything outside [episodeFrom, episodeTo] is neutral grey.
const _kColorBeforeEpisode = Color(0xFFF5F5F5); // before episodeFrom
const _kColorFirst30 = Color(0xFFEDF7ED);       // episodeFrom -> mid30DayDate (light green)
const _kColorSecond30 = Color(0xFFFCECEC);      // mid30DayDate -> episodeTo (light red)
const _kColorAfterEpisode = Color(0xFFECECEC);  // after episodeTo (distinct grey)
const _kColorOutOfRange = Color(0xFFF9F9F9);    // no episode data at all / fallback

// ─── CalEvent model ───────────────────────────────────────────────────────────
class CalEvent {
  final String label;
  final Color color;
  final bool hasCheck;
  CalEvent(this.label, this.color, {this.hasCheck = false});
}

// ─── Episode range model ──────────────────────────────────────────────────────
// One entry per episode (all episodes, not just the selected one). Used by
// _MultiMonthGrid to zone-color every date on the calendar according to
// whichever episode it falls under, so all episodes are visible at once.
class _EpisodeRange {
  final int ptEpisodeId;
  final DateTime from;
  final DateTime mid;
  final DateTime to;
  _EpisodeRange({
    required this.ptEpisodeId,
    required this.from,
    required this.mid,
    required this.to,
  });
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class PatientSchedulePage extends StatefulWidget {
  final int ptId;
  const PatientSchedulePage({super.key, required this.ptId});

  @override
  State<PatientSchedulePage> createState() => _PatientSchedulePageState();
}

class _PatientSchedulePageState extends State<PatientSchedulePage> {
  // ── Episode dropdown ────────────────────────────────────────────────────────
  List<EpisodeChartDropdownData> _episodeList = [];
  EpisodeChartDropdownData? _selectedEpisode;

  // ── Schedule data for ALL episodes ──────────────────────────────────────────
  // We fetch every episode's schedule up front and cache it here. Only the
  // selected episode's schedule is actually shown on the calendar, but
  // caching all of them means switching the dropdown doesn't need a new
  // network call, and lets us find the true last episode's end date.
  List<PatientScheduleData> _schedules = [];
  // LUPA numbers only apply to whichever episode is picked in the dropdown.
  LupaData? _lupaData;

  // ── Episode date ranges (drives calendar cell coloring) ─────────────────────
  // One _EpisodeRange per episode, derived from _schedules. We keep every
  // episode's range around — not just the selected one — because the
  // calendar grid needs to know the *last* episode's end date so it can
  // extend that far, even though only the selected episode gets colored.
  List<_EpisodeRange> _episodeRanges = [];

  // ── Daily visit list (right panel) ─────────────────────────────────────────
  final _dailyStream =
  StreamController<List<PatientDailyVisitData>>();
  DateTime? _selected;

  bool _loadingEpisodes = true;
  bool _loadingSchedules = false;

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
  }

  @override
  void dispose() {
    _dailyStream.close();
    super.dispose();
  }

  // ── Load episode dropdown ───────────────────────────────────────────────────
  Future<void> _loadEpisodes() async {
    setState(() => _loadingEpisodes = true);
    final data =
    await getEpisodeChartDropdown(context, widget.ptId);
    setState(() {
      _episodeList = data;
      _loadingEpisodes = false;
      // auto-select first episode
      if (data.isNotEmpty) {
        _selectedEpisode = data.first;
      }
    });
    if (data.isNotEmpty) {
      await _loadAllSchedules(data);
      await _loadLupaForSelected(_selectedEpisode!);
    }
  }

  // ── Load schedules for every episode (cached; only the selected one is
  // shown, but we need every episode's range to know where the *last*
  // episode ends) ─────────────────────────────────────────────────────────────
  Future<void> _loadAllSchedules(
      List<EpisodeChartDropdownData> episodes) async {
    setState(() {
      _loadingSchedules = true;
      _schedules = [];
      _episodeRanges = [];
      _selected = null;
    });

    // Fetch every episode's schedule in parallel.
    final results = await Future.wait(
      episodes.map(
            (ep) => getPatientSchedule(context, widget.ptId, ep.ptEpisodeId),
      ),
    );
    final schedules = results.whereType<PatientScheduleData>().toList();

    // One _EpisodeRange per episode, sorted chronologically by start date —
    // used only to find the true last episode's end date for the grid span.
    final ranges = schedules
        .map((s) => _EpisodeRange(
      ptEpisodeId: s.episode.ptEpisodeId,
      from: DateTime.parse(s.episode.episodeFrom),
      mid: DateTime.parse(s.episode.mid30DayDate),
      to: DateTime.parse(s.episode.episodeTo),
    ))
        .toList()
      ..sort((a, b) => a.from.compareTo(b.from));

    setState(() {
      _schedules = schedules;
      _episodeRanges = ranges;
      _loadingSchedules = false;
    });

    // clear daily panel
    _dailyStream.add([]);
  }

  // ── Load LUPA numbers for whichever episode is picked in the dropdown ──────
  Future<void> _loadLupaForSelected(EpisodeChartDropdownData episode) async {
    setState(() => _lupaData = null);
    final lupa = await getLupa(context, widget.ptId, episode.ptEpisodeId);
    if (!mounted) return;
    setState(() => _lupaData = lupa);
  }

  // ── Derived: the selected episode's cached schedule ─────────────────────────
  // No network call — the schedule was already fetched in _loadAllSchedules.
  PatientScheduleData? get _selectedSchedule {
    if (_selectedEpisode == null) return null;
    for (final s in _schedules) {
      if (s.episode.ptEpisodeId == _selectedEpisode!.ptEpisodeId) return s;
    }
    return null;
  }

  // ── Derived: only the SELECTED episode's events (start/mid/end + visits) ───
  Map<String, List<CalEvent>> get _selectedEvents {
    final schedule = _selectedSchedule;
    if (schedule == null) return {};
    return _buildEventsFromSchedule(schedule);
  }

  // ── Derived: only the SELECTED episode's date range, for zone coloring ─────
  _EpisodeRange? get _selectedRange {
    final schedule = _selectedSchedule;
    if (schedule == null) return null;
    return _EpisodeRange(
      ptEpisodeId: schedule.episode.ptEpisodeId,
      from: DateTime.parse(schedule.episode.episodeFrom),
      mid: DateTime.parse(schedule.episode.mid30DayDate),
      to: DateTime.parse(schedule.episode.episodeTo),
    );
  }

  // ── Build events map from real schedule data ────────────────────────────────
  Map<String, List<CalEvent>> _buildEventsFromSchedule(
      PatientScheduleData schedule) {
    final Map<String, List<CalEvent>> result = {};

    // Episode start marker
    final epFrom = schedule.episode.episodeFrom;
    final epFromKey = epFrom.substring(0, 10); // YYYY-MM-DD
    result.putIfAbsent(epFromKey, () => []);
    result[epFromKey]!
        .insert(0, CalEvent('Episode Starts',  ColorManager.blueprime));

    // 2nd 30 day start marker
    final mid = schedule.episode.mid30DayDate;
    final midKey = mid.substring(0, 10);
    result.putIfAbsent(midKey, () => []);
    result[midKey]!
        .insert(0, CalEvent('Start of 2nd 30 days', ColorManager.blueprime));

    // Episode end marker
    final epTo = schedule.episode.episodeTo;
    final epToKey = epTo.substring(0, 10);
    result.putIfAbsent(epToKey, () => []);
    result[epToKey]!
        .insert(0, CalEvent('Episode Ends', const Color(0xFFC62828)));

    // Visits
    for (final visit in schedule.visits) {
      final key = visit.visitDate.substring(0, 10);
      result.putIfAbsent(key, () => []);
      result[key]!.add(
        CalEvent(
          '${visit.discipline.abbreviation} ${visit.visitTypeName}',
          Color(int.parse(
              visit.discipline.color.replaceFirst('#', '0xFF'))),
        ),
      );
    }

    return result;
  }

  // ── Load daily visits for selected date ─────────────────────────────────────
  Future<void> _loadDailyVisits(DateTime date) async {
    final dateStr = _dateKey(date);
    final data = await getPatientDailyVisitList(
        context, widget.ptId, dateStr);
    _dailyStream.add(data);
  }

  // ── Base month: the SELECTED episode's start month ──────────────────────────
  // Only the selected episode is colored/shown, so the grid starts where that
  // episode starts. (Falls back to the earliest episode, or today, if no
  // schedule has loaded yet.)
  DateTime get _baseMonth {
    final sel = _selectedRange;
    if (sel != null) return DateTime(sel.from.year, sel.from.month);
    if (_episodeRanges.isNotEmpty) {
      final earliest = _episodeRanges.first.from;
      return DateTime(earliest.year, earliest.month);
    }
    return DateTime(DateTime.now().year, DateTime.now().month);
  }

  // How many consecutive calendar months the grid needs to cover, starting
  // at the selected episode's start month and running all the way through
  // the LAST episode's end month overall — not stopping right after the
  // selected episode's own end date. This lets the calendar reach into
  // future episodes (uncolored, since only the selected one is highlighted)
  // instead of cutting off.
  int get _monthsCount {
    final start = _baseMonth;
    if (_episodeRanges.isEmpty) return 2;
    final latestTo = _episodeRanges
        .map((r) => r.to)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final months = (latestTo.year * 12 + latestTo.month) -
        (start.year * 12 + start.month) +
        1;
    return months.clamp(1, 36);
  }

  @override
  Widget build(BuildContext context) {
    // Concrete height for the calendar/visit-list row, computed from the
    // grid's actual row count — this row no longer sits under a bounded
    // Expanded ancestor, so it needs to size itself explicitly rather than
    // relying on CrossAxisAlignment.stretch against an unbounded parent.
    final gridRows = _MultiMonthGrid.rowCountFor(_baseMonth, _monthsCount);
    const double calendarHeaderH = 44;
    const double weekdayHeaderH = 28;
    const double cellH = 95;
    final double calendarBlockHeight =
        calendarHeaderH + weekdayHeaderH + gridRows * cellH;

    return ColoredBox(
      color: Colors.white,
      child: _loadingEpisodes
          ?  Center(child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: CircularProgressIndicator(color: ColorManager.blueprime,),
      ))
          : Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: calendarBlockHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Left: header + calendar ──────────────────
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                    children: [
                      _CalendarHeader(
                        episodeList: _episodeList,
                        selectedEpisode: _selectedEpisode,
                        lupaData: _lupaData,
                        onEpisodeChanged: (ep) {
                          if (ep == null) return;
                          // Schedule is already cached from _loadAllSchedules,
                          // so switching episodes is just a state update plus
                          // a LUPA refresh — no calendar reload needed.
                          setState(() {
                            _selectedEpisode = ep;
                            _selected = null;
                          });
                          _dailyStream.add([]);
                          _loadLupaForSelected(ep);
                        },
                      ),
                      Expanded(
                        child: _loadingSchedules
                            ? const Center(
                            child:
                            CircularProgressIndicator())
                            : _MultiMonthGrid(
                          baseMonth: _baseMonth,
                          monthsCount: _monthsCount,
                          events: _selectedEvents,
                          selected: _selected,
                          selectedRange: _selectedRange,
                          onDateTap: (d) {
                            setState(() => _selected = d);
                            _loadDailyVisits(d);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Right: header + visit list ────────────────
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                    children: [
                      _VisitListHeader(selectedDate: _selected),
                      Expanded(
                        child: _DailyVisitList(
                            stream: _dailyStream.stream),
                      ),
                    ],
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

// ─── Calendar Header ──────────────────────────────────────────────────────────
class _CalendarHeader extends StatelessWidget {
  final List<EpisodeChartDropdownData> episodeList;
  final EpisodeChartDropdownData? selectedEpisode;
  final LupaData? lupaData;
  final void Function(EpisodeChartDropdownData?) onEpisodeChanged;

  const _CalendarHeader({
    required this.episodeList,
    required this.selectedEpisode,
    required this.lupaData,
    required this.onEpisodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final f30 = lupaData?.first30;
    final s30 = lupaData?.second30;

    return Container(
      height: 44,
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 15),
          EpisodeChartDropdown(
            value: selectedEpisode,
            items: episodeList,
            width: 260,
            onChanged: onEpisodeChanged,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: lupaData == null
                  ? const SizedBox()
                  : RichText(
                text: TextSpan(
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  children: [
                    const TextSpan(
                      text: 'LUPA:  ',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333)),
                    ),
                    const TextSpan(
                      text: '1st 30',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32)),
                    ),
                    TextSpan(
                      text:
                      ' - ${f30?.completedVisits ?? 0}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32)),
                    ),
                    const TextSpan(
                      text: ',  ',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32)),
                    ),
                    const TextSpan(
                      text: '2nd 30',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD32F2F)),
                    ),
                    TextSpan(
                      text:
                      ' - ${s30?.completedVisits ?? 0}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD32F2F)),
                    ),
                    const TextSpan(
                        text: '                        '),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Visit List Header ────────────────────────────────────────────────────────
class _VisitListHeader extends StatelessWidget {
  final DateTime? selectedDate;
  const _VisitListHeader({this.selectedDate});

  String get _dateLabel {
    final d = selectedDate ?? DateTime.now();
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}/$mm/$dd';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Text(
            _dateLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Multi-Month Grid ─────────────────────────────────────────────────────────
// Renders baseMonth through baseMonth + (monthsCount - 1), all in one
// continuous grid. Only the SELECTED episode gets colored (see
// _zoneColor()), but the grid's month span can extend further than that
// episode's own end date — all the way to the true last episode overall —
// so switching the dropdown to a later episode doesn't require a reload.
class _MultiMonthGrid extends StatelessWidget {
  final DateTime baseMonth;
  final int monthsCount;
  final Map<String, List<CalEvent>> events;
  final DateTime? selected;
  final _EpisodeRange? selectedRange;
  final ValueChanged<DateTime> onDateTap;

  static const _dow = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  ];

  const _MultiMonthGrid({
    required this.baseMonth,
    required this.monthsCount,
    required this.events,
    required this.selected,
    required this.selectedRange,
    required this.onDateTap,
  });

  // Row count for a given base month + span — used by the parent to compute
  // a concrete height for this grid, since it no longer relies on an
  // Expanded ancestor to size itself.
  //
  // `DateTime(baseMonth.year, baseMonth.month + monthsCount, 0)` is the
  // classic Dart "day 0" trick: month (N + monthsCount), day 0, rolls back to
  // the last day of month (N + monthsCount - 1) — i.e. the last day of the
  // final month in the span. That's what makes this a genuine
  // `monthsCount`-calendar-month span, which can reach beyond the selected
  // episode's own end date to cover the true last episode.
  static int rowCountFor(DateTime baseMonth, int monthsCount) {
    final m1Start = DateTime(baseMonth.year, baseMonth.month, 1);
    final mEnd = DateTime(baseMonth.year, baseMonth.month + monthsCount, 0);
    final gridStart = m1Start.subtract(Duration(days: m1Start.weekday % 7));
    final daysToSat = (6 - mEnd.weekday % 7) % 7;
    final gridEnd = mEnd.add(Duration(days: daysToSat));
    final totalDays = gridEnd.difference(gridStart).inDays + 1;
    return totalDays ~/ 7;
  }

  List<DateTime> _buildDays() {
    final m1Start =
    DateTime(baseMonth.year, baseMonth.month, 1);
    final mEnd =
    DateTime(baseMonth.year, baseMonth.month + monthsCount, 0);
    final gridStart =
    m1Start.subtract(Duration(days: m1Start.weekday % 7));
    final daysToSat = (6 - mEnd.weekday % 7) % 7;
    final gridEnd = mEnd.add(Duration(days: daysToSat));
    final days = <DateTime>[];
    for (var d = gridStart;
    !d.isAfter(gridEnd);
    d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    return days;
  }

  bool _isInRange(DateTime d) {
    final m1 = DateTime(baseMonth.year, baseMonth.month, 1);
    final mEnd =
    DateTime(baseMonth.year, baseMonth.month + monthsCount, 0);
    return !d.isBefore(m1) && !d.isAfter(mEnd);
  }

  // ── Zone color based on the SELECTED episode's actual date range ───────────
  // 4 zones: before start (grey) / 1st 30 (green) / 2nd 30 (red) / after end
  // (grey #2). "After end" also covers everything up through the grid's
  // extended tail — i.e. months belonging to later episodes stay neutral
  // grey here, since only the selected episode is highlighted.
  Color _zoneColor(DateTime date) {
    if (selectedRange == null) {
      return _kColorOutOfRange;
    }
    final d = DateTime(date.year, date.month, date.day);
    final from = DateTime(
        selectedRange!.from.year, selectedRange!.from.month, selectedRange!.from.day);
    final to = DateTime(
        selectedRange!.to.year, selectedRange!.to.month, selectedRange!.to.day);

    // Before episode starts
    if (d.isBefore(from)) return _kColorBeforeEpisode;

    // After episode ends (includes the extended tail reaching later episodes)
    if (d.isAfter(to)) return _kColorAfterEpisode;

    // Within episode range: split at mid30Date
    final mid = DateTime(
        selectedRange!.mid.year, selectedRange!.mid.month, selectedRange!.mid.day);
    if (d.isBefore(mid)) return _kColorFirst30;
    return _kColorSecond30;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = _buildDays();
    final rows = days.length ~/ 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          // Weekday header
          Container(
            color: Colors.white,
            child: Row(
              children: _dow
                  .map((d) => Expanded(
                child: Container(
                  height: 28,
                  alignment: Alignment.center,
                  child: Text(
                    d,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888888),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ))
                  .toList(),
            ),
          ),
          // Grid
          Builder(builder: (ctx) {
            const cellH = 95.0;
            return Column(
              children: List.generate(rows, (row) {
                final rowDays =
                days.sublist(row * 7, row * 7 + 7);
                return SizedBox(
                  height: cellH,
                  child: Row(
                    children: List.generate(7, (col) {
                      final date = rowDays[col];
                      final inRange = _isInRange(date);
                      final key = _dateKey(date);
                      final isWeekend =
                          date.weekday ==
                              DateTime.saturday ||
                              date.weekday == DateTime.sunday;
                      final evts = inRange && !isWeekend
                          ? (events[key] ?? [])
                          : <CalEvent>[];
                      final isToday = date.year ==
                          today.year &&
                          date.month == today.month &&
                          date.day == today.day;
                      final isSel = selected != null &&
                          date.year == selected!.year &&
                          date.month == selected!.month &&
                          date.day == selected!.day;
                      final showMonth = inRange &&
                          date.day == 1 &&
                          !(date ==
                              DateTime(baseMonth.year,
                                  baseMonth.month, 1));
                      return Expanded(
                        child: _DayCell(
                          date: date,
                          inRange: inRange,
                          isToday: isToday,
                          isSelected: isSel,
                          showMonthLabel: showMonth,
                          events: evts,
                          zoneColor: _zoneColor(date),
                          isLastCol: col == 6,
                          isLastRow: row == rows - 1,
                          onTap: () => onDateTap(date),
                        ),
                      );
                    }),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Day Cell ─────────────────────────────────────────────────────────────────
class _DayCell extends StatelessWidget {
  final DateTime date;
  final bool inRange;
  final bool isToday;
  final bool isSelected;
  final bool showMonthLabel;
  final List<CalEvent> events;
  final Color zoneColor;
  final bool isLastCol;
  final bool isLastRow;
  final VoidCallback onTap;

  static const _mShort = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  const _DayCell({
    required this.date,
    required this.inRange,
    required this.isToday,
    required this.isSelected,
    required this.showMonthLabel,
    required this.events,
    required this.zoneColor,
    required this.isLastCol,
    required this.isLastRow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Out-of-displayed-month cells keep the neutral fallback; otherwise use the episode-range zone color.
    Color bg = inRange ? zoneColor : _kColorOutOfRange;
    if (isSelected) bg = const Color(0xFFBBDEFB);

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          border: Border(
            right: isLastCol
                ? BorderSide.none
                : const BorderSide(
                color: Colors.white, width: 0.5),
            bottom: isLastRow
                ? BorderSide.none
                : const BorderSide(
                color: Colors.white, width: 0.5),
          ),
        ),
        padding:
        const EdgeInsets.only(left: 6, top: 6, right: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                isToday
                    ? Container(
                  width: 26,
                  height: 26,
                  decoration:  BoxDecoration(
                      color:  ColorManager.blueprime,
                      shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(
                    '${date.day}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
                    : Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: inRange
                        ? const Color(0xFF222222)
                        : const Color(0xFFBBBBBB),
                  ),
                ),
                if (showMonthLabel) ...[
                  const SizedBox(width: 4),
                  Text(
                    _mShort[date.month],
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF222222),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            ...events.take(4).map((e) => _EvtLabel(e)),
          ],
        ),
      ),
    );
  }
}

// ─── Event Label ──────────────────────────────────────────────────────────────
class _EvtLabel extends StatelessWidget {
  final CalEvent e;
  const _EvtLabel(this.e);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              e.label,
              style: TextStyle(
                fontSize: 10,
                color: e.color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (e.hasCheck) ...[
            const SizedBox(width: 1),
            Icon(Icons.check, size: 10, color: e.color),
          ],
        ],
      ),
    );
  }
}

// ─── Daily Visit List (right panel) ──────────────────────────────────────────
class _DailyVisitList extends StatelessWidget {
  final Stream<List<PatientDailyVisitData>> stream;
  const _DailyVisitList({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PatientDailyVisitData>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Text(
              'Tap a date to view visits',
              style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
            ),
          );
        }
        if (snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No visits on this date!',
              style: AllNoDataAvailable.customTextStyle(context),
            ),
          );
        }
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView.separated(
            padding:
            const EdgeInsets.only(right: 5),
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, i) =>
                _VisitCard(visit: snapshot.data![i]),
          ),
        );
      },
    );
  }
}

// ─── Visit Card ───────────────────────────────────────────────────────────────
class _VisitCard extends StatelessWidget {
  final PatientDailyVisitData visit;
  const _VisitCard({required this.visit});

  @override
  Widget build(BuildContext context) {
    // parse discipline color
    Color disciplineColor = const Color(0xFF2E7D32);
    try {
      disciplineColor = Color(int.parse(
          visit.discipline.color.replaceFirst('#', '0xFF')));
    } catch (_) {}

    // initials from clinician name
    final parts = visit.clinician.name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : visit.clinician.name.substring(0, 1).toUpperCase();

    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom:
          BorderSide(color: Color(0xFFEEEEEE), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          visit.clinician.imgUrl != null
              ? CircleAvatar(
            radius: 22,
            backgroundColor: Colors.transparent,
            backgroundImage:
            NetworkImage(visit.clinician.imgUrl!),
            onBackgroundImageError: (_, __) {},
          )
              : CircleAvatar(
            radius: 22,
            backgroundColor: disciplineColor,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Name + icons
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  visit.clinician.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Image.asset("images/sm/contact_icon.png", height: 30, width: 30,)
              ],
            ),
          ),

          // Visit type
          Expanded(
            flex: 2,
            child: Text(
              visit.visitTypeName,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Discipline badge
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: disciplineColor,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              visit.discipline.abbreviation,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Time
          Expanded(
            flex: 3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time_rounded,
                    size: 11, color: ColorManager.blueprime),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    '${visit.timeFrom}-${visit.timeTo}',
                    style: TextStyle(
                      fontSize: 11,
                      color: ColorManager.blueprime,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status badge
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: visit.status.toLowerCase() == 'completed'
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFE65100),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: const Text(
              "A",
              style: TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}