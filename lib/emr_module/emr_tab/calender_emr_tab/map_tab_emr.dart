import 'dart:async';
import 'dart:math' as Math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../app/resources/color.dart';
import '../../../../../app/resources/value_manager.dart';
import '../../../../../app/services/token/token_manager.dart';
import '../../../../widgets/widgets/custom_scrollbar.dart';
import '../../../../../data/api_data/emr_module_data/calender_map_data/calender_map_data.dart';
import '../../../../../data/api_data/emr_module_data/emr_dash_data/emr_announcement_data.dart';
import '../../../../../app/services/api/managers/emr_module_manager/emr_dashboard_tab_manager/emr_announcement_tab_manager.dart';
import '../emr_const/calender_popup_const.dart';
import 'edit_details_popup.dart';

class MapView extends StatefulWidget {
  final List<ClinicianCalendarVisitData> visits;
  const MapView({super.key, required this.visits});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final ScrollController _horizontalScrollController = ScrollController();

  // ── Date nav ──────────────────────────────────────────────────────────────
  bool _isMonth = false;
  DateTime _currentDate = DateTime.now();
  final GlobalKey _datePillKey = GlobalKey();

  // ── Map ───────────────────────────────────────────────────────────────────
  GoogleMapController? _mapController;
  ClinicianVisitsMapData? _mapData;
  Set<Marker> _markers = {};
  bool _loadingMap = false;

  static const _fallbackPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 12,
  );

  // ── Marker / legend colours by visitStatus ────────────────────────────────
  static const _colorNotStarted = Color(0xFFE53935); // red
  static const _colorInProgress = Color(0xFFFB8C00); // orange
  static const _colorVisited    = Color(0xFF43A047); // green

  Color _statusColor(String status) {
    switch (status) {
      case 'VISITED':     return _colorVisited;
      case 'IN_PROGRESS': return _colorInProgress;
      case 'NOT_STARTED':
      default:            return _colorNotStarted;
    }
  }

  // ── Card toggle ───────────────────────────────────────────────────────────
  List<bool> _showNotes = [];

  // ── Date helpers ──────────────────────────────────────────────────────────
  String _mName(int m) => const [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ][m];

  String get _dayLabel =>
      '${_currentDate.day} ${_mName(_currentDate.month)} ${_currentDate.year}';
  String get _monthLabel =>
      '${_mName(_currentDate.month)} ${_currentDate.year}';

  void _prev() {
    setState(() {
      _currentDate = _isMonth
          ? DateTime(_currentDate.year, _currentDate.month - 1, 1)
          : _currentDate.subtract(const Duration(days: 1));
    });
    _loadMapData();
  }

  void _next() {
    setState(() {
      _currentDate = _isMonth
          ? DateTime(_currentDate.year, _currentDate.month + 1, 1)
          : _currentDate.add(const Duration(days: 1));
    });
    _loadMapData();
  }

  Future<void> _pickDate() async {
    final picked = await CalendarPickerHelper.show(
      context: context,
      anchorKey: _datePillKey,
      selectedDate: _currentDate,
      horizontalOffset: -60,
    );
    if (picked != null) {
      setState(() => _currentDate = picked);
      _loadMapData();
    }
  }

  // ── Sidebar visits filtered by selected day ───────────────────────────────
  List<ClinicianCalendarVisitData> get _visitsForSelectedDay {
    return widget.visits.where((v) {
      if (v.visiteDateTimeFrom == null || v.visiteDateTimeFrom!.isEmpty)
        return false;
      try {
        final dt = DateTime.parse(v.visiteDateTimeFrom!).toLocal();
        return dt.year == _currentDate.year &&
            dt.month == _currentDate.month &&
            dt.day == _currentDate.day;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  // ── API ───────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    if (!mounted) return;
    setState(() => _loadingMap = true);
    try {
      final clinicianId = await TokenManager.getEmployeeId();
      final data = await getClinicianTodayMapData(context, clinicianId);
      if (data == null || !mounted) return;

      final markers = await _buildMarkers(data);

      setState(() {
        _mapData = data;
        _markers = markers;
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(data.clinician.latitude, data.clinician.longitude),
            zoom: 12,
          ),
        ),
      );
    } catch (e) {
      print('MapView _loadMapData error: $e');
    } finally {
      if (mounted) setState(() => _loadingMap = false);
    }
  }

  Future<Set<Marker>> _buildMarkers(ClinicianVisitsMapData data) async {
    final Set<Marker> markers = {};

    // Clinician — blue pin
    markers.add(
      Marker(
        markerId: const MarkerId('clinician'),
        position: LatLng(data.clinician.latitude, data.clinician.longitude),
        infoWindow: InfoWindow(title: data.clinician.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Visits — numbered circle coloured by visitStatus
    // null lat/lng already filtered out in the manager.
    // Visits sharing the same coordinates are fanned out in a small circle
    // so they don't stack on top of each other.
    final Map<String, int> _positionCount = {};

    for (final visit in data.visits) {
      final posKey = '${visit.latitude},${visit.longitude}';
      final index = _positionCount[posKey] ?? 0;
      _positionCount[posKey] = index + 1;

      // Offset duplicate markers ~30 m apart in a spiral
      const double offsetStep = 0.00025; // ~27 m per step
      final double angle = index * (2.4); // golden-angle spacing in radians
      final double lat = visit.latitude  + (index == 0 ? 0 : offsetStep * Math.sin(angle));
      final double lng = visit.longitude + (index == 0 ? 0 : offsetStep * Math.cos(angle));

      final icon = await _buildNumberedMarker(
          visit.visitNumber, _statusColor(visit.visitStatus));
      markers.add(
        Marker(
          markerId: MarkerId('visit_${visit.visitId}'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: visit.patientName,
            snippet: visit.address,
          ),
          icon: icon,
        ),
      );
    }
    return markers;
  }

  Future<BitmapDescriptor> _buildNumberedMarker(
      int number, Color color) async {
    const double size = 44;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Shadow
    canvas.drawCircle(
      const Offset(size / 2 + 1, size / 2 + 2),
      size / 2 - 2,
      Paint()..color = Colors.black.withOpacity(0.25),
    );
    // Fill
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 2,
      Paint()..color = color,
    );
    // White border ring
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 2,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    // Number
    final tp = TextPainter(
      text: TextSpan(
        text: '$number',
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset((size - tp.width) / 2, (size - tp.height) / 2));

    final img = await recorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  // ── Card helpers ──────────────────────────────────────────────────────────
  Color _accentFor(String? type) {
    switch (type) {
      case 'SOC':    return const Color(0xFF2E7D32);
      case 'RECERT': return const Color(0xFF1565C0);
      case 'PRN':    return const Color(0xFF6A1B9A);
      default:       return Colors.grey;
    }
  }

  Color _bgFor(String? type) {
    switch (type) {
      case 'SOC':    return const Color(0xFFE8F5E9);
      case 'RECERT': return const Color(0xFFE3F2FD);
      case 'PRN':    return const Color(0xFFF3E5F5);
      default:       return Colors.grey.shade100;
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty)
      return parts[0][0].toUpperCase();
    return '?';
  }

  String _fmtTime(String? iso) {
    if (iso == null || iso.isEmpty) return '--';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m${dt.hour < 12 ? 'AM' : 'PM'}';
    } catch (_) {
      return '--';
    }
  }

  void _showPatientPopup(BuildContext context, ClinicianCalendarVisitData v) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => EditDetailsDialog(visit: v),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final dayVisits = _visitsForSelectedDay;
    if (_showNotes.length != dayVisits.length) {
      _showNotes = List.filled(dayVisits.length, false);
    }

    final camInit = _mapData != null
        ? CameraPosition(
      target: LatLng(
          _mapData!.clinician.latitude, _mapData!.clinician.longitude),
      zoom: 12,
    )
        : _fallbackPosition;

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
              child: Column(
                children: [
        // ── Top bar ────────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 100),

                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        GestureDetector(
                          onTap: _prev,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 6),
                            child: Icon(Icons.chevron_left,
                                size: 20, color: ColorManager.bluebottom),
                          ),
                        ),
                        Container(
                            width: 1, height: 20, color: Colors.grey.shade300),
                        GestureDetector(
                          key: _datePillKey,
                          onTap: _pickDate,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: SizedBox(
                              width: 160,
                              child: Center(
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                          'images/hh_emr/calendar.png',
                                          width: 13,
                                          height: 13),
                                      const SizedBox(width: 6),
                                      Text(
                                          _isMonth ? _monthLabel : _dayLabel,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: ColorManager.bluebottom)),
                                    ]),
                              ),
                            ),
                          ),
                        ),
                        Container(
                            width: 1, height: 20, color: Colors.grey.shade300),
                        GestureDetector(
                          onTap: _next,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 6),
                            child: Icon(Icons.chevron_right,
                                size: 20, color: ColorManager.bluebottom),
                          ),
                        ),
                      ]),
                    ),

                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: Image.asset('images/hh_emr/optimise.png',
                          width: 14, height: 14),
                      label: const Text('Optimise Routes',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.bluebottom,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Expanded(flex: 2, child: SizedBox()),
          ],
        ),

        const SizedBox(height: 15),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Map (left) ────────────────────────────────────────────────
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.only(left: 60, right: 10),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: GoogleMap(
                                initialCameraPosition: camInit,
                                onMapCreated: (ctrl) {
                                  _mapController = ctrl;
                                  if (_mapData != null) {
                                    ctrl.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                            camInit));
                                  }
                                },
                                myLocationEnabled: false,
                                myLocationButtonEnabled: false,
                                zoomControlsEnabled: true,
                                mapToolbarEnabled: false,
                                markers: _markers,
                              ),
                            ),
                            if (_loadingMap)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.55),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ── Legend ────────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _legendDot(color: _colorVisited, label: 'Visited'),
                          const SizedBox(width: 14),
                          _legendDot(
                              color: _colorInProgress, label: 'Visit In-Progress'),
                          const SizedBox(width: 14),
                          _legendDot(color: _colorNotStarted, label: 'Not Started'),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),

              // ── Sidebar (right) ───────────────────────────────────────────
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: dayVisits.isEmpty
                      ? Center(
                      child: Text('No visits today',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400)))
                      : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: dayVisits.length,
                    itemBuilder: (_, i) {
                      final v = dayVisits[i];
                      final type = v.visitTypeName ?? '';
                      final accent = _accentFor(type);
                      final bg = _bgFor(type);
                      final name = v.patientName ?? '';
                      final showNote = _showNotes[i];
                      final timeRange =
                          '${_fmtTime(v.visiteDateTimeFrom)}–${_fmtTime(v.visitDateTimeTo)}';

                      return GestureDetector(
                        onTap: () => setState(
                                () => _showNotes[i] = !_showNotes[i]),
                        child: ConstrainedBox(
                          constraints:
                          const BoxConstraints(minHeight: 72),
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
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                children: [
                                  if (!showNote)
                                    Container(
                                      width: 18,
                                      decoration:
                                      BoxDecoration(color: bg),
                                      alignment: Alignment.center,
                                      child: RotatedBox(
                                          quarterTurns: 3,
                                          child: Text(type,
                                              style: TextStyle(
                                                  fontSize: 7,
                                                  fontWeight:
                                                  FontWeight.w800,
                                                  color: accent,
                                                  letterSpacing: 0.8))),
                                    ),
                                  Expanded(
                                    child: showNote
                                        ? Padding(
                                      padding: const EdgeInsets
                                          .symmetric(
                                          horizontal: 10,
                                          vertical: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                        mainAxisSize:
                                        MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              const Text('Note',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                      FontWeight
                                                          .w700,
                                                      color: Color(
                                                          0xFFBF360C))),
                                              Row(
                                                mainAxisSize:
                                                MainAxisSize
                                                    .min,
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .edit_outlined,
                                                      size: 14,
                                                      color: Colors
                                                          .grey
                                                          .shade500),
                                                  const SizedBox(
                                                      width: 8),
                                                  Icon(
                                                      Icons
                                                          .delete_outline,
                                                      size: 14,
                                                      color: Colors
                                                          .grey
                                                          .shade500),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text('No Note here',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey
                                                      .shade500,
                                                  fontStyle: FontStyle
                                                      .italic)),
                                        ],
                                      ),
                                    )
                                        : Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Center(
                                              child: Text(
                                                  'Visit #${i + 1}',
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      color: Colors
                                                          .grey
                                                          .shade500,
                                                      fontWeight:
                                                      FontWeight
                                                          .w500))),
                                        ),
                                        GestureDetector(
                                          onTap: () =>
                                              _showPatientPopup(
                                                  context, v),
                                          behavior: HitTestBehavior
                                              .opaque,
                                          child: Row(
                                            mainAxisSize:
                                            MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding:
                                                const EdgeInsets
                                                    .only(
                                                    left: 4,
                                                    right: 10,
                                                    top: 10,
                                                    bottom: 10),
                                                child: CircleAvatar(
                                                  radius: 16,
                                                  backgroundColor:
                                                  bg,
                                                  child: Text(
                                                      _initials(
                                                          name),
                                                      style: TextStyle(
                                                          fontSize:
                                                          10,
                                                          color:
                                                          accent,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold)),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets
                                                    .symmetric(
                                                    vertical:
                                                    10,
                                                    horizontal:
                                                    4),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                                  children: [
                                                    Text(name,
                                                        style: const TextStyle(
                                                            fontSize:
                                                            11,
                                                            fontWeight:
                                                            FontWeight
                                                                .w700,
                                                            color: Colors
                                                                .black87)),
                                                    const SizedBox(
                                                        height: 2),
                                                    Text(
                                                        v.primaryDiagnosis ??
                                                            '',
                                                        style: TextStyle(
                                                            fontSize:
                                                            10,
                                                            color: Colors
                                                                .grey
                                                                .shade500)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        Padding(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 8,
                                              vertical: 10),
                                          child: Text(timeRange,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: ColorManager
                                                      .bluebottom,
                                                  fontWeight:
                                                  FontWeight
                                                      .w500)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 6),
                                    child: Center(
                                        child: Icon(Icons.menu,
                                            size: 16,
                                            color:
                                            Colors.grey.shade400)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
              ],
            ),        // Column
            ),        // SizedBox
          ),          // Padding
        ),            // SingleChildScrollView
      );              // CustomScrollbar
    });               // LayoutBuilder
  }

  Widget _legendDot({required Color color, required String label}) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700)),
    ]);
  }
}