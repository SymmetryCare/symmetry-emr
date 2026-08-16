import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/color.dart';
import 'package:prohealth/app/services/token/token_manager.dart';

import '../../../../../../../app/services/api/managers/emr_module_manager/emr_patient_manager/patient_schedule_manager.dart';
import '../../../../../../../data/api_data/emr_module_data/patient_tab_data/patient_schedule_data.dart';

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
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected
                                      ? Colors.blue.shade700
                                      : const Color(0xFF444444),
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
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
    return SizedBox(
      width: widget.width ?? 260,
      height: widget.height ?? 28,
      child: GestureDetector(
        onTap: _showDropdownDialog,
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
                  _selectedValue?.label ?? 'Select Episode',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF444444)),
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

const _kRowTints = [
  Color(0xFFEDF7ED),
  Color(0xFFFCECEC),
  Color(0xFFFFFBE6),
];

// ─── CalEvent model ───────────────────────────────────────────────────────────
class CalEvent {
  final String label;
  final Color color;
  final bool hasCheck;
  CalEvent(this.label, this.color, {this.hasCheck = false});
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

  // ── Schedule data ───────────────────────────────────────────────────────────
  PatientScheduleData? _scheduleData;
  LupaData? _lupaData;

  // ── Daily visit list (right panel) ─────────────────────────────────────────
  final _dailyStream =
  StreamController<List<PatientDailyVisitData>>();
  DateTime? _selected;

  // ── Calendar events map ─────────────────────────────────────────────────────
  Map<String, List<CalEvent>> _events = {};

  bool _loadingEpisodes = true;
  bool _loadingSchedule = false;

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
        _loadScheduleAndLupa(_selectedEpisode!);
      }
    });
  }

  // ── Load schedule + lupa when episode changes ───────────────────────────────
  Future<void> _loadScheduleAndLupa(
      EpisodeChartDropdownData episode) async {
    setState(() {
      _loadingSchedule = true;
      _scheduleData = null;
      _lupaData = null;
      _events = {};
      _selected = null;
    });

    final results = await Future.wait([
      getPatientSchedule(context, widget.ptId, episode.ptEpisodeId),
      getLupa(context, widget.ptId, episode.ptEpisodeId),
    ]);

    final schedule = results[0] as PatientScheduleData?;
    final lupa = results[1] as LupaData?;

    setState(() {
      _scheduleData = schedule;
      _lupaData = lupa;
      _loadingSchedule = false;
      if (schedule != null) {
        _events = _buildEventsFromSchedule(schedule);
      }
    });

    // clear daily panel
    _dailyStream.add([]);
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
        .insert(0, CalEvent('Episode Starts', const Color(0xFF1565C0)));

    // 2nd 30 day start marker
    final mid = schedule.episode.mid30DayDate;
    final midKey = mid.substring(0, 10);
    result.putIfAbsent(midKey, () => []);
    result[midKey]!
        .insert(0, CalEvent('Start of 2nd 30 days', const Color(0xFF1565C0)));

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

  // ── Base month from episode ──────────────────────────────────────────────────
  DateTime get _baseMonth {
    if (_scheduleData != null) {
      final from = _scheduleData!.episode.episodeFrom;
      final dt = DateTime.parse(from);
      return DateTime(dt.year, dt.month);
    }
    return DateTime(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ColoredBox(
        color: Colors.white,
        child: _loadingEpisodes
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
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
                            setState(
                                    () => _selectedEpisode = ep);
                            _loadScheduleAndLupa(ep);
                          },
                        ),
                        Expanded(
                          child: _loadingSchedule
                              ? const Center(
                              child:
                              CircularProgressIndicator())
                              : _TwoMonthGrid(
                            baseMonth: _baseMonth,
                            events: _events,
                            selected: _selected,
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
                    TextSpan(
                      text: '1st 30',
                      style: const TextStyle(
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
                    TextSpan(
                      text: '2nd 30',
                      style: const TextStyle(
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
    return '$mm/$dd/${d.year}';
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

// ─── Two-Month Grid ───────────────────────────────────────────────────────────
class _TwoMonthGrid extends StatelessWidget {
  final DateTime baseMonth;
  final Map<String, List<CalEvent>> events;
  final DateTime? selected;
  final ValueChanged<DateTime> onDateTap;

  static const _dow = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  ];

  const _TwoMonthGrid({
    required this.baseMonth,
    required this.events,
    required this.selected,
    required this.onDateTap,
  });

  List<DateTime> _buildDays() {
    final m1Start =
    DateTime(baseMonth.year, baseMonth.month, 1);
    final m2End =
    DateTime(baseMonth.year, baseMonth.month + 2, 0);
    final gridStart =
    m1Start.subtract(Duration(days: m1Start.weekday % 7));
    final daysToSat = (6 - m2End.weekday % 7) % 7;
    final gridEnd = m2End.add(Duration(days: daysToSat));
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
    final m2End =
    DateTime(baseMonth.year, baseMonth.month + 2, 0);
    return !d.isBefore(m1) && !d.isAfter(m2End);
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
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context)
                  .copyWith(scrollbars: false),
              child: SingleChildScrollView(
                child: Builder(builder: (ctx) {
                  const cellH = 110.0;
                  return Column(
                    children: List.generate(rows, (row) {
                      final rowDays =
                      days.sublist(row * 7, row * 7 + 7);
                      final rowTint =
                      _kRowTints[row % _kRowTints.length];
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
                                rowTint: rowTint,
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
              ),
            ),
          ),
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
  final Color rowTint;
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
    required this.rowTint,
    required this.isLastCol,
    required this.isLastRow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = inRange ? rowTint : const Color(0xFFF9F9F9);
    if (isSelected) bg = const Color(0xFFBBDEFB);

    return GestureDetector(
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
                  decoration: const BoxDecoration(
                      color: Color(0xFF1565C0),
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
          return const Center(
            child: Text(
              'No visits on this date',
              style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
            ),
          );
        }
        return ListView.separated(
          padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (_, i) =>
              _VisitCard(visit: snapshot.data![i]),
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
            radius: 19,
            backgroundImage:
            NetworkImage(visit.clinician.imgUrl!),
            onBackgroundImageError: (_, __) {},
          )
              : CircleAvatar(
            radius: 19,
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
                const SizedBox(height: 3),
                Image.asset("images/sm/contact_icon.png", height: 40, width: 40,)
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Visit type
          Expanded(
            flex: 2,
            child: Text(
              visit.visitTypeName,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
                    size: 11, color: ColorManager.bluebottom),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    '${visit.timeFrom}-${visit.timeTo}',
                    style: TextStyle(
                      fontSize: 10,
                      color: ColorManager.bluebottom,
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
            child: Text(
              "A",
              style: const TextStyle(
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