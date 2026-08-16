import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../app/constants/app_config.dart';
import '../../../../../app/resources/color.dart';
import '../../../../../app/resources/provider/hh_emr/visit_details_provider.dart';
import '../../../../../app/resources/value_manager.dart';
import '../../../../../app/services/api/managers/emr_module_manager/calender_map_tab_manager/calender_details_manager.dart';
import '../../../../../data/api_data/emr_module_data/calender_map_data/caledner_details_data.dart';
import '../../../clinical_manager/constant_widgets/dashboard_const.dart';
import '../calender_emr_tab/emr_calender_screen.dart';

class VisitDetailsScreen extends StatefulWidget {
  final int visitId;
  const VisitDetailsScreen({super.key, required this.visitId});

  @override
  State<VisitDetailsScreen> createState() => _VisitDetailsScreenState();
}

class _VisitDetailsScreenState extends State<VisitDetailsScreen> {
  int _selectedTab = 0;

  GoogleMapController? _todaysMapController;
  PatientVisitCalenderDetailsData? _visitData;
  bool _isLoading = true;

  // ── Map state ─────────────────────────────────────────────────────────────
  LatLng? _employeeLatLng;
  LatLng? _patientLatLng;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _mapReady = false;
  bool _mapRouteLoading = false;

  static const _initialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 12,
  );

  // ── Hardcoded placeholder values (until API returns these fields) ──────────
  final String _remainingFrequency = '--';

  @override
  void initState() {
    super.initState();
    _loadVisitData();
  }

  @override
  void dispose() {
    _todaysMapController?.dispose();
    super.dispose();
  }

  Color _hexToColor(String hex) {
    try {
      final cleaned = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleaned', radix: 16));
    } catch (_) {
      return Colors.blueGrey;
    }
  }

  // ── Load visit data then trigger map ──────────────────────────────────────
  Future<void> _loadVisitData() async {
    final data = await getPatientVisitCalenderDetails(context, widget.visitId);
    if (mounted) {
      setState(() {
        _visitData = data;
        _isLoading = false;
        _mapRouteLoading = true;
      });
      await _loadMapRoute();
    }
  }

  // ── Geocode address string → LatLng ───────────────────────────────────────
  Future<LatLng?> _geocodeAddress(String address) async {
    if (address.isEmpty) return null;
    final encoded = Uri.encodeComponent(address);
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
          '?address=$encoded&key=${AppConfig.googleApiKey}',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['status'] == 'OK') {
          final loc = body['results'][0]['geometry']['location'];
          return LatLng(
            (loc['lat'] as num).toDouble(),
            (loc['lng'] as num).toDouble(),
          );
        }
      }
    } catch (e) {
      print('Geocode error: $e');
    }
    return null;
  }

  // ── Fetch driving route polyline via Directions API ───────────────────────
  Future<List<LatLng>> _getRoutePolyline(LatLng origin, LatLng dest) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${origin.latitude},${origin.longitude}'
          '&destination=${dest.latitude},${dest.longitude}'
          '&mode=driving'
          '&key=${AppConfig.googleApiKey}',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['status'] == 'OK') {
          final encoded =
          body['routes'][0]['overview_polyline']['points'] as String;
          return _decodePolyline(encoded);
        }
      }
    } catch (e) {
      print('Directions error: $e');
    }
    return [];
  }

  // ── Decode Google encoded polyline ────────────────────────────────────────
  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0, lng = 0;
    while (index < encoded.length) {
      int shift = 0, result = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  // ── Build markers + polyline on map ───────────────────────────────────────
  Future<void> _buildMapRoute() async {
    if (_employeeLatLng == null || _patientLatLng == null) return;

    final routePoints =
    await _getRoutePolyline(_employeeLatLng!, _patientLatLng!);

    // Use first clinician for marker label if available
    final firstClinician =
    (_visitData?.clinicians.isNotEmpty == true) ? _visitData!.clinicians.first : null;

    final employeeMarker = Marker(
      markerId: const MarkerId('employee'),
      position: _employeeLatLng!,
      infoWindow: InfoWindow(
        title: firstClinician?.name ?? 'Clinician',
        snippet: firstClinician?.phone ?? '',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    final patientMarker = Marker(
      markerId: const MarkerId('patient'),
      position: _patientLatLng!,
      infoWindow: InfoWindow(
        title: _patient?.name.isNotEmpty == true ? _patient!.name : 'Patient',
        snippet: _patient?.address ?? '',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: routePoints,
      color: Colors.blue.shade600,
      width: 4,
    );

    if (mounted) {
      setState(() {
        _markers = {employeeMarker, patientMarker};
        _polylines = {polyline};
        _mapRouteLoading = false;
      });
    }

    if (_mapReady && _todaysMapController != null) {
      _fitMapToBounds();
    }
  }

  // ── Fit camera to show both markers ───────────────────────────────────────
  void _fitMapToBounds() {
    if (_employeeLatLng == null || _patientLatLng == null) return;
    final southWest = LatLng(
      min(_employeeLatLng!.latitude, _patientLatLng!.latitude),
      min(_employeeLatLng!.longitude, _patientLatLng!.longitude),
    );
    final northEast = LatLng(
      max(_employeeLatLng!.latitude, _patientLatLng!.latitude),
      max(_employeeLatLng!.longitude, _patientLatLng!.longitude),
    );
    _todaysMapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southWest, northeast: northEast),
        80,
      ),
    );
  }

  // ── Geocode patient address only (clinician address no longer in response) ─
  Future<void> _loadMapRoute() async {
    final patientAddress = _visitData?.patient.address ?? '';
    _patientLatLng = await _geocodeAddress(patientAddress);

    // Use first clinician phone as fallback — no address field in new model
    // If you later get clinician address from another endpoint, geocode it here
    _employeeLatLng = null;

    await _buildMapRoute();
  }

  // ── Open destination in Google Maps ───────────────────────────────────────
  Future<void> _openInGoogleMaps() async {
    if (_patientLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location data not available yet.')),
      );
      return;
    }
    final destination =
        '${_patientLatLng!.latitude},${_patientLatLng!.longitude}';
    final webUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
          '&destination=$destination'
          '&travelmode=driving',
    );
    try {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Could not open Google Maps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps.')),
        );
      }
    }
  }

  // ── Derived helpers ───────────────────────────────────────────────────────

  PatientCalenderDetailsData? get _patient => _visitData?.patient;
  VisitCalenderDetailsData? get _visit => _visitData?.visit;
  EpisodeCalenderDetailsData? get _episode => _visitData?.episode;

  String get _initials {
    final parts = (_patient?.name ?? '').trim().split(' ');
    final first = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }

  String get _formattedDateFrom {
    if (_visit == null || _visit!.visitDateFrom.isEmpty) return '--';
    final dt = DateTime.tryParse(_visit!.visitDateFrom);
    if (dt == null) return _visit!.visitDateFrom;
    return '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  String get _formattedTimeRange {
    if (_visit == null) return '--';
    final from = DateTime.tryParse(_visit!.visitDateFrom);
    final to = DateTime.tryParse(_visit!.visitDateTo);
    if (from == null || to == null) return '--';
    return '${_formatTime(from)}-${_formatTime(to)}';
  }

  String get _dayLabel {
    if (_visit == null || _visit!.visitDateFrom.isEmpty) return '';
    final dt = DateTime.tryParse(_visit!.visitDateFrom);
    if (dt == null) return '';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dt.weekday - 1];
  }

  String get _dob {
    final dob = _patient?.dateOfBirth ?? '';
    if (dob.isEmpty) return '--';
    final dt = DateTime.tryParse(dob);
    if (dt == null) return '--';
    return 'DOB: ${dt.month.toString().padLeft(2, '0')}/'
        '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.year} · ${_patient?.age ?? '--'}y';
  }

  String get _chapterEpisode {
    if (_episode == null) return '--';
    final from = DateTime.tryParse(_episode!.episodeFrom);
    final to = DateTime.tryParse(_episode!.episodeTo);
    String fromStr = from != null
        ? '${from.month.toString().padLeft(2, '0')}/${from.day.toString().padLeft(2, '0')}/${from.year}'
        : '--';
    String toStr = to != null
        ? '${to.month.toString().padLeft(2, '0')}/${to.day.toString().padLeft(2, '0')}/${to.year}'
        : '--';
    return 'Ch ${_episode!.chartNumber} Ep ${_episode!.episodeNumber}: $fromStr - $toStr';
  }

  String get _visitStatusBadge {
    if (_visit?.isCompleted == true) return 'Completed';
    if (_visit?.isMissed == true) return 'Missed';
    if (_visit?.onWay == true) return 'On Way';
    if (_visit?.isRescheduled == true) return 'Rescheduled';
    return '';
  }

  Color get _visitStatusColor {
    if (_visit?.isCompleted == true) return Colors.green;
    if (_visit?.isMissed == true) return Colors.red;
    if (_visit?.onWay == true) return Colors.blue;
    if (_visit?.isRescheduled == true) return Colors.orange;
    return Colors.grey;
  }

  // First clinician's type label for tab + visit block
  String get _employeeTypeLabel {
    final c = _visitData?.clinicians.isNotEmpty == true
        ? _visitData!.clinicians.first
        : null;
    return c?.employeeTypeAbbreviation.isNotEmpty == true
        ? c!.employeeTypeAbbreviation
        : 'Therapist';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [
          const Divider(thickness: 1),

          // ── Top Bar ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
            child: Row(children: [
              GestureDetector(
                onTap: () =>
                    context.read<EMRNavigationController>().closeVisit(),
                child: const Icon(Icons.arrow_back_outlined,
                    size: 16, color: Colors.black87),
              ),
              const SizedBox(width: 8),
              const Text('Visit Details',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
            ]),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── LEFT PANEL ─────────────────────────────────────────────
                Expanded(
                  flex: 6,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(left: 40, right: 20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // ── Patient Info Row ──────────────────────────
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [

                                  // col 1 — Avatar + Name / Diagnosis / MRN / DOB
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
// REPLACE with:
                                          ClipOval(
                                            child: (_patient?.imageUrl ?? '').isNotEmpty
                                                ? Image.network(
                                              _patient!.imageUrl,
                                              height: 44,
                                              width: 44,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => CircleAvatar(
                                                radius: 22,
                                                backgroundColor: Colors.transparent,
                                                child: Image.asset('images/profilepic.png'),
                                              ),
                                            )
                                                : CircleAvatar(
                                              radius: 22,
                                              backgroundColor: Colors.transparent,
                                              child: Image.asset('images/profilepic.png'),
                                            ),
                                          ),
                                          SizedBox(width: AppSize.s10),
                                          Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      _patient?.name.isNotEmpty == true
                                                          ? _patient!.name
                                                          : '--',
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                          FontWeight.w700)),
                                                  const SizedBox(
                                                      height: AppSize.s5),
                                                  Text(
                                                      _patient?.diagnosisName
                                                          .isNotEmpty ==
                                                          true
                                                          ? _patient!.diagnosisName
                                                          : '--',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors
                                                              .grey.shade600)),
                                                  const SizedBox(
                                                      height: AppSize.s8),
                                                  Text(
                                                      'MRN# ${_patient?.MRN ?? '--'}',
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors
                                                              .grey.shade500)),
                                                  const SizedBox(
                                                      height: AppSize.s8),
                                                  Text(_dob,
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors
                                                              .grey.shade500)),
                                                ]),
                                          ),
                                        ]),
                                  ),

                                  // col 2 — Clinician type badges (all clinicians)
                                  Expanded(
                                    flex: 3,
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: _visitData?.clinicians
                                          .where((c) =>
                                      c.employeeTypeAbbreviation.isNotEmpty)
                                          .map((c) => _Badge(
                                        type: c.employeeTypeAbbreviation,
                                        bgColor: _hexToColor(
                                            c.employeeTypeColor),
                                      ))
                                          .toList() ??
                                          [],
                                    ),
                                  ),
                                  // col 3 — Phone Number
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text('Phone Number :',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey.shade500)),
                                          const SizedBox(height: 3),
                                          Text(
                                              _patient?.phone.isNotEmpty ==
                                                  true
                                                  ? _patient!.phone
                                                  : '--',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600)),
                                        ]),
                                  ),

                                  // col 4 — Date + Time
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(_formattedDateFrom,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade600)),
                                          const SizedBox(height: 2),
                                          Text(_formattedTimeRange,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600)),
                                        ]),
                                  ),
                                ]),

                            const SizedBox(height: 20),

                            // ── Address / Zip / $Charge / ChEp / InZone / Chat ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Address
                                Flexible(
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.location_on,
                                            size: 13,
                                            color: ColorManager.bluebottom),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                              _patient?.address.isNotEmpty ==
                                                  true
                                                  ? _patient!.address
                                                  : 'No address on file',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade600)),
                                        ),
                                      ]),
                                ),
                                const SizedBox(width: 8),
                                // Zone
                                if (_patient?.zoneName != null)
                                  Text('Zone: ${_patient!.zoneName}',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600)),
                                const SizedBox(width: 8),
                                // ── Visit Charge ──────────────────────────
                                Text(
                                  '\$${_visit?.visitCharge.toStringAsFixed(2) ?? '--'}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue.shade600,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                // ── Chapter / Episode ─────────────────────
                                Text(
                                  _chapterEpisode,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue.shade600,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 8),
                                // In Zone
                                Text(
                                    _visit?.inZone == true
                                        ? 'In Zone'
                                        : 'Out of Zone',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: _visit?.inZone == true
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {},
                                  child: Image.asset(
                                    'images/emr_clinician/patient_chat.png',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),
                            Divider(color: Colors.grey.shade200, height: 1),

                            // ── Discipline Tabs (one per clinician) ───────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                  _visitData?.clinicians.length ?? 1,
                                      (i) {
                                    final c = _visitData?.clinicians.isNotEmpty == true
                                        ? _visitData!.clinicians[i]
                                        : null;
                                    final active = _selectedTab == i;
                                    final label = c?.employeeTypeAbbreviation.isNotEmpty == true
                                        ? c!.employeeTypeAbbreviation
                                        : 'PT';
                                    return GestureDetector(
                                      onTap: () =>
                                          setState(() => _selectedTab = i),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 28, vertical: 10),
                                        decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                color: active
                                                    ? Colors.blue.shade700
                                                    : Colors.transparent,
                                                width: 2,
                                              )),
                                        ),
                                        child: Text(label,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: active
                                                  ? FontWeight.w700
                                                  : FontWeight.normal,
                                              color: active
                                                  ? Colors.blue.shade700
                                                  : Colors.grey.shade500,
                                            )),
                                      ),
                                    );
                                  }),
                            ),

                            const SizedBox(height: 10),

                            // ── Remaining Frequency ───────────────────────
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 11, color: Colors.black87),
                                children: [
                                  const TextSpan(
                                    text: 'Remaining Frequency: ',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  TextSpan(
                                    text: _remainingFrequency,
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            // ── Today / Last / Next Visit ─────────────────
                            Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: _VisitBlock(
                                        title: "Today's Visit",
                                        noteLabel:
                                        '$_employeeTypeLabel Visit Note',
                                        date: _formattedDateFrom,
                                        time: _formattedTimeRange,
                                        dayLabel: _dayLabel,
                                        badge: _visitStatusBadge.isNotEmpty
                                            ? _visitStatusBadge
                                            : null,
                                        badgeColor: _visitStatusColor,
                                      )),
                                  Expanded(
                                      child: _VisitBlock(
                                        title: 'Last Visit',
                                        noteLabel:
                                        '$_employeeTypeLabel Visit Note',
                                        date: '--',
                                        time: '--',
                                        badge: 'Completed',
                                        badgeColor: Colors.green,
                                      )),
                                  Expanded(
                                      child: _VisitBlock(
                                        title: 'Next Visit',
                                        noteLabel:
                                        '$_employeeTypeLabel Visit Note',
                                        date: '--',
                                        time: '--',
                                        badge: null,
                                        badgeColor: Colors.grey,
                                      )),
                                ]),

                            const SizedBox(height: 16),

                            // ── Clinician's ───────────────────────────────
                            const Text("Clinician's :",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 10),

                            Row(children: [
                              if (_visitData?.clinicians.isNotEmpty == true)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _visitData!.clinicians
                                      .map((c) => ClinicianCard(
                                    name: c.name,
                                    initials: c.name.isNotEmpty
                                        ? c.name[0].toUpperCase()
                                        : '--',
                                    imgUrl: c.imageUrl,
                                    abbreviation:
                                    c.employeeTypeAbbreviation,
                                    badgeColor: _hexToColor(
                                        c.employeeTypeColor),
                                  ))
                                      .toList(),
                                )
                              else
                                Text('No clinician assigned',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500)),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border:
                                    Border.all(color: Colors.blue.shade300),
                                  ),
                                  child: Text('Request for Clinician',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue.shade600,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ),
                            ]),

                            const SizedBox(height: 16),
                            Divider(color: Colors.grey.shade200, height: 1),
                            const SizedBox(height: 12),

                            // ── Alerts ────────────────────────────────────
                            Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Alerts',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700)),
                                  ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.add,
                                        size: 14, color: Colors.white),
                                    label: const Text('Add Alert',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ColorManager.bluebottom,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12)),
                                      iconAlignment: IconAlignment.end,
                                    ),
                                  ),
                                ]),

                            const SizedBox(height: 20),

                            _AlertBlock(
                              title: 'Visit Alert :',
                              body: _visitData?.alerts.visitAlerts.isNotEmpty == true
                                  ? _visitData!.alerts.visitAlerts.join(', ')
                                  : 'No visit alert available.',
                            ),
                            const SizedBox(height: 15),
                            _AlertBlock(
                              title: 'Patient Alert :',
                              body: _visitData?.alerts.patientAlerts.isNotEmpty == true
                                  ? _visitData!.alerts.patientAlerts.join(', ')
                                  : 'No patient alert available.',
                            ),

                            const SizedBox(height: 32),
                            Divider(color: Colors.grey.shade200, height: 1),
                          ]),
                    ),
                  ),
                ),

                // ── RIGHT PANEL ────────────────────────────────────────────
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.only(right: 40, left: 10),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 300,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              children: [
                                GoogleMap(
                                  onMapCreated: (ctrl) {
                                    _todaysMapController = ctrl;
                                    setState(() => _mapReady = true);
                                    if (!_mapRouteLoading) _fitMapToBounds();
                                  },
                                  initialCameraPosition: _initialPosition,
                                  myLocationEnabled: false,
                                  myLocationButtonEnabled: false,
                                  zoomControlsEnabled: false,
                                  mapToolbarEnabled: false,
                                  liteModeEnabled: true,
                                  markers: _markers,
                                  polylines: _polylines,
                                ),
                                if (_mapRouteLoading)
                                  Positioned.fill(
                                    child: Container(
                                      color: Colors.white.withOpacity(0.6),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: _openInGoogleMaps,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                            Colors.black.withOpacity(0.15),
                                            blurRadius: 4,
                                          )
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.open_in_new,
                                              size: 11,
                                              color: Colors.blue.shade600),
                                          const SizedBox(width: 4),
                                          Text('Open in Maps',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.blue.shade600,
                                                  fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _actionItem(Icons.play_arrow_outlined,
                                  "Start Visit", Colors.blue),
                              _actionItem(Icons.event_available_outlined,
                                  "Reschedule", Colors.blue),
                              _actionItem(Icons.block_flipped, "Miss Visit",
                                  Colors.red),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _actionItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: color)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String type;
  final Color bgColor;

  const _Badge({required this.type, required this.bgColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
        color: bgColor, borderRadius: BorderRadius.circular(4)),
    child: Text(type,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.white)),
  );
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4)),
    child: Text(label,
        style: TextStyle(
            fontSize: 8, fontWeight: FontWeight.w800, color: color)),
  );
}

class _VisitBlock extends StatelessWidget {
  final String title, noteLabel, date, time;
  final String? badge;
  final Color badgeColor;
  final String? dayLabel;

  const _VisitBlock({
    required this.title,
    required this.noteLabel,
    required this.date,
    required this.time,
    this.badge,
    required this.badgeColor,
    this.dayLabel,
  });

  @override
  Widget build(BuildContext context) {
    String dateTimeText = '--';
    if (date != '--' || time != '--') {
      final parts = <String>[];
      if (dayLabel != null && dayLabel!.isNotEmpty) parts.add(dayLabel!);
      if (date != '--') parts.add(date);
      dateTimeText = parts.join(' | ');
      if (time != '--') dateTimeText += '  $time';
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Row(children: [
        Flexible(
            child: Text(noteLabel,
                style: TextStyle(
                  fontSize: 11,
                  color: badge != null
                      ? Colors.blue.shade500
                      : Colors.grey.shade600,
                ))),
        if (badge != null && badge!.isNotEmpty) ...[
          const SizedBox(width: 10),
          Text(badge!,
              style: TextStyle(
                  fontSize: 9,
                  color: badgeColor,
                  fontWeight: FontWeight.w600)),
        ],
      ]),
      const SizedBox(height: 4),
      Text(
        dateTimeText,
        style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500),
      ),
    ]);
  }
}

class ClinicianCard extends StatelessWidget {
  final String name, initials, imgUrl, abbreviation;
  final Color badgeColor;

  const ClinicianCard({
    required this.name,
    required this.initials,
    required this.imgUrl,
    this.badgeColor = Colors.blueGrey,
    required this.abbreviation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        ClinicalAvatarWithBadge(
          name: name,
          badgeText: abbreviation,
          badgeColor: badgeColor,
          circleImage: imgUrl,
        ),
        const SizedBox(width: 8),
        Text(name,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, height: 1.4)),
        const SizedBox(width: 10),
        Image.asset(
          'images/emr_clinician/patient_chat.png',
        ),
      ]),
    );
  }
}

class _AlertBlock extends StatelessWidget {
  final String title, body;
  const _AlertBlock({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text(body, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
    ]);
  }
}


