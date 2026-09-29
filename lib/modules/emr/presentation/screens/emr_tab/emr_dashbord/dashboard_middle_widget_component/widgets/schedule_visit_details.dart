import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/assitant_review_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/discharge_visit.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/miss_visit_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/recert_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/reschedule_visit_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/view_start_visit.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:math';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/providers/hh_emr/visit_details_provider.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dash_manager/patient_visit_list_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dashboard_tab_manager/schedule_visit_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/patientVisit_list_emr_model.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/schedule_visit_data.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/widgets/popup/pending_forms_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/clinical_manager/constant_widgets/dashboard_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/calender_emr_tab/emr_calender_screen.dart';

class ScheduleVisitDetails extends StatefulWidget {
  final int visitId;
  const ScheduleVisitDetails({super.key, required this.visitId});

  @override
  State<ScheduleVisitDetails> createState() => _ScheduleVisitDetailsState();
}

class _ScheduleVisitDetailsState extends State<ScheduleVisitDetails> {
  int _selectedTab = 0;

  GoogleMapController? _todaysMapController;
  VisitDetailsData? _visitData;
  bool _isLoading = true;

  // ── Map state ────────────────────────────────────────────────────────────
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

  final String _remainingFrequency = '1w3 effective 12/04/2024';

  @override
  void initState() {
    super.initState();
    _loadVisitData();
  }

  // ── Show Start Visit ──────────────────────────────────────────────────────
  void _showStartVisit(int visitId) {
    // FIX: compute the future once per call instead of inline inside the
    // dialog's builder, which re-fires the API call on every rebuild of
    // the dialog.
    final Future<VisitPrefillByIdModel> visitPrefillFuture =
    getVisitDataUsingVisitId(context: context, visitId: visitId);
    showDialog<bool>(
      context: context,
      builder: (_) => FutureBuilder<VisitPrefillByIdModel>(
        future: visitPrefillFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: ColorManager.blueprime),
            );
          }
          if (!snapshot.hasData || snapshot.hasError) {
            return Center(
              child: Text('Failed to load visit data',
                  style: TextStyle(color: Colors.grey.shade500)),
            );
          }
          return  snapshot.data!.pendingAssistantFormIds.isNotEmpty ?
          PendingReviewFormPopup(
            visitId: snapshot.data!.visitId,
            patientId:snapshot.data!.ptId,
            visitData: snapshot.data!,
            isLastEpisode: snapshot.data!.isSecoundLastEpisodeVisit ?? false,):
          snapshot.data!.episodeTriggerType == "CALENDAR"?
          snapshot.data!.remainingVisitsCount > 2 ?
          RecertFormDialog(
            visitId:  snapshot.data!.visitId,
            visitData:  snapshot.data!,):
          DischargeVisitTypePopup(
            visitData: snapshot.data!,
            onNevigate: () {
              showDialog(context: context,
                  builder: (_) =>
                      ViewStartVisit(
                        visitData: snapshot.data!,
                        onRefresh: (){},
                      ));
            },):
          snapshot.data!.isSecoundLastEpisodeVisit == true
              || snapshot.data!.episodeTriggerType == "POSITION"?
          DischargeVisitTypePopup(
            visitData: snapshot.data!,
            onNevigate: () {
              showDialog(context: context,
                  builder: (_) =>
                      ViewStartVisit(
                        visitData: snapshot.data!,
                        onRefresh: (){},
                      ));
            },):
          ViewStartVisit(
            visitData: snapshot.data!,
            onRefresh: () {},
          );
        },
      ),
    );
  }

  Future<void> _loadVisitData() async {
    final data = await getVisitDetails(context, widget.visitId);
    if (mounted) {
      setState(() {
        _visitData = data;
        print('Visit data loaded: ${_visitData?.patient.name}');
        _isLoading = false;
        _mapRouteLoading = true;
      });
      await _loadMapRoute();
    }
  }

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

  Future<void> _buildMapRoute() async {
    if (_patientLatLng == null) return;

    final firstClinician = _visitData?.clinicians.isNotEmpty == true
        ? _visitData!.clinicians.first
        : null;

    final patientMarker = Marker(
      markerId: const MarkerId('patient'),
      position: _patientLatLng!,
      infoWindow: InfoWindow(
        title: _visitData?.patient.name ?? 'Patient',
        snippet: _visitData?.patient.address ?? '',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    Set<Marker> markers = {patientMarker};
    Set<Polyline> polylines = {};

    if (_employeeLatLng != null) {
      final routePoints =
      await _getRoutePolyline(_employeeLatLng!, _patientLatLng!);
      markers.add(Marker(
        markerId: const MarkerId('employee'),
        position: _employeeLatLng!,
        infoWindow: InfoWindow(
          title: firstClinician?.name ?? 'Clinician',
          snippet: firstClinician?.phone ?? '',
        ),
        icon:
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
      if (routePoints.isNotEmpty) {
        polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          points: routePoints,
          color: ColorManager.blueprime,
          width: 4,
        ));
      }
    }

    if (mounted) {
      setState(() {
        _markers = markers;
        _polylines = polylines;
        _mapRouteLoading = false;
      });
    }

    if (_mapReady && _todaysMapController != null) {
      _fitMapToBounds();
    }
  }

  void _fitMapToBounds() {
    if (_patientLatLng == null) return;
    if (_employeeLatLng == null) {
      _todaysMapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_patientLatLng!, 14),
      );
      return;
    }
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

  Future<void> _loadMapRoute() async {
    final patientAddress = _visitData?.patient.address ?? '';
    _patientLatLng = await _geocodeAddress(patientAddress);
    _employeeLatLng = null;
    await _buildMapRoute();
  }

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
  VisitPatientData? get _patient => _visitData?.patient;
  VisitInfoData? get _visit => _visitData?.visit;
  VisitEpisodeData? get _episode => _visitData?.episode;

  String get _formattedDateFrom {
    final raw = _visit?.visitDateFrom ?? '';
    if (raw.isEmpty) return '--';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
        ? 12
        : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  String get _formattedTimeRange {
    final from = DateTime.tryParse(_visit?.visitDateFrom ?? '');
    final to = DateTime.tryParse(_visit?.visitDateTo ?? '');
    if (from == null || to == null) return '--';
    return '${_formatTime(from)}-${_formatTime(to)}';
  }

  String get _dob {
    final raw = _patient?.dateOfBirth ?? '';
    if (raw.isEmpty) return '--';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return '--';
    final age = _patient?.age ?? (DateTime.now().year - dt.year);
    return 'DOB: ${dt.year}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} · ${age}y';
  }

  String get _chapterEpisode {
    if (_episode == null) return '--';
    final from = DateTime.tryParse(_episode!.episodeFrom ?? '');
    final to = DateTime.tryParse(_episode!.episodeTo ?? '');
    final fromStr = from != null
        ? '${from.month.toString().padLeft(2, '0')}/${from.day.toString().padLeft(2, '0')}/${from.year}'
        : '--';
    final toStr = to != null
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
    if (_visit?.onWay == true) return ColorManager.blueprime;
    if (_visit?.isRescheduled == true) return Colors.orange;
    return Colors.grey;
  }

  // ── Lock actions once visit is completed ──────────────────────────────────
  // Drives the disabled state of Start Visit / Reschedule / Miss Visit below
  // the map — once a visit is completed, none of those actions apply anymore.
  bool get _isVisitCompleted => _visit?.isCompleted == true;

  String get _firstClinicianTypeLabel {
    final c = _visitData?.clinicians.isNotEmpty == true
        ? _visitData!.clinicians.first
        : null;
    return c?.employeeTypeAbbreviation.isNotEmpty == true
        ? c!.employeeTypeAbbreviation
        : 'Therapist';
  }

  Color _hexToColor(String hex) {
    try {
      final cleaned = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleaned', radix: 16));
    } catch (_) {
      return Colors.blueGrey;
    }
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

          // ── Top Bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
            child: Row(children: [
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () => context
                    .read<EMRNavigationController>()
                    .closeScheduleVisit(),
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
                // ── LEFT PANEL ───────────────────────────────────────────
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

                                  // col 1 — Avatar + Name/Diagnosis/MRN/DOB
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          ClipOval(
                                            child: (_patient?.imageUrl ?? '')
                                                .isNotEmpty
                                                ? Image.network(
                                              _patient!.imageUrl,
                                              height: 56,
                                              width: 56,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (_, __, ___) =>
                                                  CircleAvatar(
                                                    radius: 28,
                                                    backgroundColor:
                                                    Colors.transparent,
                                                    child: Image.asset(
                                                        'images/profilepic.png'),
                                                  ),
                                            )
                                                : CircleAvatar(
                                              radius: 28,
                                              backgroundColor:
                                              Colors.transparent,
                                              child: Image.asset(
                                                  'images/profilepic.png'),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      _patient?.name
                                                          .isNotEmpty ==
                                                          true
                                                          ? _patient!.name
                                                          : '--',
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                          FontWeight.w700)),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                      _patient?.diagnosisName ??
                                                          '--',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors
                                                              .grey.shade600)),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                      'MRN# ${(_patient?.mrn ?? 0) > 0 ? _patient!.mrn : '--'}',
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors
                                                              .grey.shade500)),
                                                  const SizedBox(height: 1),
                                                  Text(_dob,
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors
                                                              .grey.shade500)),
                                                ]),
                                          ),
                                        ]),
                                  ),

                                  // col 2 — Visit type badge + status badge
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
                                          Text('Phone Number:',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey.shade500)),
                                          const SizedBox(height: 3),
                                          Text(
                                              (_patient?.phone ?? '').isNotEmpty
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

                            // ── Address / Zone / Charge / Episode / InZone / Chat ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.location_on,
                                            size: 13,
                                            color: ColorManager.blueprime),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                              (_patient?.address ?? '')
                                                  .isNotEmpty
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
                                if ((_patient?.zoneName ?? '').isNotEmpty)
                                  Text(
                                    _patient!.zoneName!,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600),
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  '\$${_visit?.visitCharge.toStringAsFixed(2) ?? '--'}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: ColorManager.blueprime,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _chapterEpisode,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: ColorManager.blueprime,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                    _visit?.inZone == true
                                        ? 'In Zone'
                                        : 'Out of Zone',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: _visit?.inZone == true
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                        fontWeight: FontWeight.w600)),
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
                                  _visitData?.clinicians.length ?? 1, (i) {
                                final active = _selectedTab == i;
                                final label =
                                _visitData?.clinicians.isNotEmpty == true
                                    ? _visitData!.clinicians[i]
                                    .employeeTypeAbbreviation
                                    : 'PT';
                                return InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
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
                                                ? ColorManager.blueprime
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
                                              ? ColorManager.blueprime
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
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black87),
                                children: [
                                  const TextSpan(
                                    text: 'Remaining Frequency: ',
                                    style:
                                    TextStyle(fontWeight: FontWeight.w600),
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

                            // ── Today's Visit block ───────────────────────
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: _VisitBlock(
                                        title: "Today's Visit",
                                        noteLabel:
                                        '$_firstClinicianTypeLabel Visit Note',
                                        date: _formattedDateFrom,
                                        time: _formattedTimeRange,
                                        badge: _visitStatusBadge.isNotEmpty
                                            ? _visitStatusBadge
                                            : null,
                                        badgeColor: _visitStatusColor,
                                      )),
                                ]),

                            const SizedBox(height: 16),

                            // ── Clinicians (all) ──────────────────────────
                            const Text("Clinician's :",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
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
                                Text('No clinician assigned!',
                                    style:AllNoDataAvailable.customTextStyle(context)),
                              const Spacer(),
                            ]),

                            const SizedBox(height: 16),
                            Divider(color: Colors.grey.shade200, height: 1),
                            const SizedBox(height: 12),
                          ]),
                    ),
                  ),
                ),

                // ── RIGHT PANEL ──────────────────────────────────────────
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
                                    _mapReady = true;
                                    if (_patientLatLng != null) {
                                      Future.delayed(
                                        const Duration(milliseconds: 300),
                                        _fitMapToBounds,
                                      );
                                    }
                                  },
                                  initialCameraPosition:
                                  _patientLatLng != null
                                      ? CameraPosition(
                                      target: _patientLatLng!,
                                      zoom: 12)
                                      : _initialPosition,
                                  myLocationEnabled: false,
                                  myLocationButtonEnabled: false,
                                  zoomControlsEnabled: false,
                                  mapToolbarEnabled: false,
                                  liteModeEnabled: false,
                                  markers: _markers,
                                  polylines: _polylines,
                                ),

                                // ── Legend ────────────────────────────
                                if (!_mapRouteLoading && _markers.isNotEmpty)
                                  Positioned(
                                    bottom: 10,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color:
                                        Colors.white.withOpacity(0.92),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withOpacity(0.1),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(children: [
                                            const Icon(Icons.location_pin,
                                                size: 14,
                                                color: Colors.red),
                                            const SizedBox(width: 4),
                                            Text(
                                              _patient?.name ?? 'Patient',
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight:
                                                  FontWeight.w600),
                                            ),
                                          ]),
                                          const SizedBox(height: 2),
                                          Text(
                                            _patient?.address ?? '',
                                            style: TextStyle(
                                                fontSize: 9,
                                                color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                // ── Open in Google Maps ───────────────
                                if (!_mapRouteLoading &&
                                    _patientLatLng != null)
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: _openInGoogleMaps,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                          BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.12),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.network(
                                              'https://maps.google.com/mapfiles/ms/icons/blue-dot.png',
                                              width: 16,
                                              height: 16,
                                              errorBuilder: (_, __, ___) =>
                                                  Icon(Icons.map,
                                                      size: 16,
                                                      color: ColorManager.blueprime),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Open in Google Maps',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: ColorManager.blueprime),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                // ── Loading overlay ───────────────────
                                if (_mapRouteLoading)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: ColorManager.blueprime,
                                          ),
                                          const SizedBox(height: 8),
                                          const Text('Loading route...',
                                              style:
                                              TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ),

                                // ── No location fallback ──────────────
                                if (!_mapRouteLoading &&
                                    _patientLatLng == null)
                                  Container(
                                    color: Colors.grey.shade100,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.location_off_outlined,
                                              size: 32,
                                              color: Colors.grey.shade400),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Location unavailable',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade500),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Action buttons ────────────────────────────
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // ── Start Visit ─────────────────────────
                              // Disabled once the visit is Completed.
                              InkWell(
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: _isVisitCompleted
                                    ? null
                                    : () => _showStartVisit(
                                    _visitData!.visit.visitId),
                                child: _actionItem(
                                  Icons.play_arrow,
                                  "Start Visit",
                                  ColorManager.blueprime,
                                  disabled: _isVisitCompleted,
                                ),
                              ),

                              // ── Reschedule ───────────────────────────
                              // Disabled once the visit is Completed.
                              InkWell(
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: _isVisitCompleted
                                    ? null
                                    : () => showDialog(
                                  context: context,
                                  builder: (_) => RescheduleVisitTodaysVisit(
                                      visitId: _visitData!.visit.visitId),
                                ),
                                child: _actionItem(
                                  Icons.calendar_today_outlined,
                                  "Reschedule",
                                  ColorManager.blueprime,
                                  disabled: _isVisitCompleted,
                                ),
                              ),

                              // ── Miss Visit ───────────────────────────
                              // Disabled once the visit is Completed.
                              InkWell(
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: _isVisitCompleted
                                    ? null
                                    : () => showDialog(
                                  context: context,
                                  builder: (_) => MissVisitTodaysVisit(
                                    visitId: _visitData!.visit.visitId,
                                    ptId: _visitData!.patient.ptId, ),
                                ),
                                child: _actionItem(
                                  Icons.cancel_outlined,
                                  "Miss Visit",
                                  Colors.red,
                                  disabled: _isVisitCompleted,
                                ),
                              ),
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

  // ── Action item icon+label pair ────────────────────────────────────────────
  // `disabled` greys out the icon and label; used to visually lock actions
  // once the visit is Completed (see _isVisitCompleted).
  Widget _actionItem(IconData icon, String label, Color color, {bool disabled = false}) {
    final displayColor = disabled ? Colors.grey.shade400 : color;
    return Column(
      children: [
        Icon(icon, size: 18, color: displayColor),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: displayColor)),
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
      dateTimeText = parts.join('  |  ');
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
                      ? ColorManager.blueprime
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
        Image.asset('images/emr_clinician/patient_chat.png'),
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