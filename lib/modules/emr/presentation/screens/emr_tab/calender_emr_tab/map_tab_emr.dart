import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:math' as Math;
import 'dart:ui' as ui;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/calender_map_data/calender_map_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/emr_announcement_data.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dashboard_tab_manager/emr_announcement_tab_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/calender_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/calender_emr_tab/edit_details_popup.dart';

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
  // FIX: strip time-of-day so _currentDate is always a clean midnight-anchored
  // date. DateTime.now() otherwise carries the current hour/min/sec, which
  // isn't wrong by itself, but keeping it normalized avoids any accidental
  // time-of-day leaking into date comparisons elsewhere.
  // This also defines the DEFAULT selected date as "today" on first load.
  DateTime _currentDate = DateUtils.dateOnly(DateTime.now());
  final GlobalKey _datePillKey = GlobalKey();

  // ── Map ───────────────────────────────────────────────────────────────────
  GoogleMapController? _mapController;
  ClinicianVisitsMapData? _mapData;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _loadingMap = false;
  bool _optimising = false;

  // ✅ FIX: GoogleMap (and the embedded directions iframe) on Flutter Web is
  // a native DOM platform view — it sits OUTSIDE Flutter's own widget/hit-test
  // tree. A `showDialog` barrier only blocks Flutter-side hit-testing, so
  // wheel/scroll/click events over the map area still reach that DOM element
  // underneath the dialog. That's why opening the "Edit Details" popup over
  // the map let scroll events zoom the map in/out instead of hitting the
  // dropdown inside the dialog. This flag is flipped true right before any
  // dialog is shown on top of the map, and back to false once it closes —
  // it's used below to both IgnorePointer the map/iframe AND disable the
  // GoogleMap's own gesture flags (belt-and-suspenders, since some renderers
  // still let native wheel events through even under IgnorePointer).
  bool _mapInteractionLocked = false;

  // Tracks the visitId of the nearest stop that "Optimise Routes" is
  // currently routing to, so its marker can be drawn highlighted on the map.
  // Cleared whenever map data reloads (new date selected, etc.) so a stale
  // highlight never survives past its own route.
  int? _routeDestinationVisitId;

  // google_maps_flutter_web doesn't reliably repaint polylines added AFTER
  // the map is first built (markers update fine, polylines don't) — so we
  // force a full GoogleMap remount whenever the route changes by bumping
  // this and keying the widget to it. onMapCreated re-fires harmlessly and
  // re-centers on the same clinician position, so nothing else is lost.
  int _routeVersion = 0;

  // Only true once the person taps "Optimise Routes" — before that we show
  // the native map with the custom highlighted/numbered visit pins; after,
  // we switch to Google's embedded Directions view for the real road route
  // (see _buildEmbeddedDirections() for why that switch is necessary).
  bool _showEmbeddedRoute = false;

  // True while the embedded Directions <iframe> is loading its content —
  // there's a real gap between the widget swapping in and Google's page
  // actually rendering, which otherwise looks like a blank/white flash.
  bool _embedLoading = false;

  // ✅ FIX: direct reference to the currently active embedded-directions
  // iframe DOM element. IgnorePointer (Flutter-side) does NOT reliably
  // disable pointer events on this iframe once "Optimise Routes" swaps the
  // native GoogleMap for the embedded Directions view — same root cause as
  // the GoogleMap note above (platform views sit outside Flutter's
  // hit-test tree), but here there's no gesture-flag equivalent to fall
  // back on since it's a bare iframe (GoogleMap has
  // zoomGesturesEnabled/scrollGesturesEnabled/etc., iframe has nothing).
  // That's why the Edit Details popup worked fine over the native map
  // (gesture flags kicked in) but not after Optimise Routes swapped in the
  // iframe (nothing to disable it). We toggle CSS pointer-events on this
  // DOM node directly whenever a dialog opens/closes over the map — see
  // _showPatientPopup().
  html.IFrameElement? _activeRouteIframe;

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

  // Formats _currentDate as YYYY-MM-DD for the API call — the backend
  // expects a plain date string, not a DateTime object.
  String get _selectedDateStr =>
      '${_currentDate.year.toString().padLeft(4, '0')}-'
          '${_currentDate.month.toString().padLeft(2, '0')}-'
          '${_currentDate.day.toString().padLeft(2, '0')}';

  void _prev() {
    setState(() {
      // FIX: wrap the result in DateUtils.dateOnly so we never accumulate
      // stray time-of-day components across repeated prev/next taps.
      _currentDate = DateUtils.dateOnly(_isMonth
          ? DateTime(_currentDate.year, _currentDate.month - 1, 1)
          : _currentDate.subtract(const Duration(days: 1)));
    });
    _loadMapData();
  }

  void _next() {
    setState(() {
      // FIX: same normalization as _prev — keep _currentDate midnight-anchored.
      _currentDate = DateUtils.dateOnly(_isMonth
          ? DateTime(_currentDate.year, _currentDate.month + 1, 1)
          : _currentDate.add(const Duration(days: 1)));
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
      // FIX: normalize the picked date too — the picker may hand back a
      // DateTime with a non-zero time-of-day depending on its implementation.
      setState(() => _currentDate = DateUtils.dateOnly(picked));
      _loadMapData();
    }
  }

  // ── Sidebar visits filtered by selected day ───────────────────────────────
  // FIX: was comparing dt.year/month/day against _currentDate manually.
  // That's logically the same idea as DateUtils.isSameDay, but doing it by
  // hand made it easy for a stray time-of-day component (e.g. on
  // _currentDate, or on `dt` right at a UTC->local day-boundary shift from
  // `.toLocal()`) to silently break the match — which is what produced
  // "still showing previous date's data" when picking a new date. Using
  // DateUtils.isSameDay (and keeping _currentDate normalized to midnight
  // everywhere it's set — see _prev/_next/_pickDate/initState) removes that
  // whole class of mismatch.
  List<ClinicianCalendarVisitData> get _visitsForSelectedDay {
    return widget.visits.where((v) {
      if (v.visiteDateTimeFrom == null || v.visiteDateTimeFrom!.isEmpty)
        return false;
      try {
        final dt = DateTime.parse(v.visiteDateTimeFrom!).toLocal();
        return DateUtils.isSameDay(dt, _currentDate);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  // ── API ───────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // _currentDate defaults to today (see field init above), so this first
    // call loads today's map data automatically.
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    if (!mounted) return;
    setState(() => _loadingMap = true);
    try {
      final clinicianId = await TokenManager.getEmployeeId();

      // FIX: previously this always called getClinicianTodayMapData with no
      // date, so the MAP (markers + route) stayed pinned to "today" no matter
      // what date was selected via _prev/_next/_pickDate — even though the
      // sidebar visit list (_visitsForSelectedDay) was already filtering by
      // _currentDate correctly. Passing _currentDate here makes the map data
      // follow the selected date too, while still defaulting to today because
      // _currentDate itself is initialized to today's date.
      //
      // NOTE: this assumes getClinicianTodayMapData accepts a `selectedDate`
      // parameter as a YYYY-MM-DD string. If the underlying manager/API
      // doesn't support that yet, it needs a small update to accept and
      // forward the string to the backend endpoint (e.g. as a query param
      // like `?date=yyyy-MM-dd`).
      final data = await getClinicianTodayMapData(
        context,
        clinicianId,
        _selectedDateStr,
      );
      if (data == null || !mounted) return;

      // DEBUG — verify the clinician's real coordinates and how far each
      // visit actually is. This is the first thing to check when a visit
      // that "looks close" on screen doesn't get routed to — the map's
      // Mercator projection at low zoom can make far-apart points look
      // close, and dummy/test data sometimes has 0,0 or malformed coords.
      print('=== MapView DEBUG: _loadMapData ===');
      print('--- RAW API VALUES ---');
      print('Clinician "${data.clinician.name}" — '
          'RAW latitude=${data.clinician.latitude} (${data.clinician.latitude.runtimeType}), '
          'RAW longitude=${data.clinician.longitude} (${data.clinician.longitude.runtimeType})');
      for (final v in data.visits) {
        // Prints exactly what the API sent for THIS visit, so you can see
        // whether it actually returned real coordinates, a real address,
        // both, or neither (e.g. address present but lat/lng still 0,0 —
        // or the reverse). This tells you which field to trust per-record,
        // rather than assuming the whole dataset behaves the same way.
        print('Visit #${v.visitNumber} "${v.patientName}" (visitId: ${v.visitId}):');
        print('    RAW address  = "${v.address}"  (empty: ${v.address.trim().isEmpty})');
        print('    RAW latitude = ${v.latitude}  (zero: ${v.latitude == 0})');
        print('    RAW longitude= ${v.longitude}  (zero: ${v.longitude == 0})');
      }
      print('--- END RAW API VALUES ---');
      if (data.clinician.latitude == 0 && data.clinician.longitude == 0) {
        print('WARNING: clinician coordinates are 0,0 — this is almost certainly bad/missing data from the API.');
      }
      for (final v in data.visits) {
        final d = _distanceKm(
          data.clinician.latitude,
          data.clinician.longitude,
          v.latitude,
          v.longitude,
        );
        print('  Visit #${v.visitNumber} "${v.patientName}" (visitId: ${v.visitId}): '
            'lat=${v.latitude}, lng=${v.longitude}, address="${v.address}" — ${d.toStringAsFixed(2)} km away');
      }
      print('=== end DEBUG ===');

      final markers = await _buildMarkers(data);

      setState(() {
        _mapData = data;
        _markers = markers;
        _polylines = {};
        _showEmbeddedRoute = false; // back to native map + highlighted pins on every reload
        _embedLoading = false;
        _routeDestinationVisitId = null; // clear stale nearest-stop highlight on reload
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
                data.clinician.latitude, data.clinician.longitude),
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

  // ── Distance helper (haversine, km) ────────────────────────────────────────
  double _degToRad(double deg) => deg * (Math.pi / 180);

  double _distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadiusKm = 6371;
    final dLat = _degToRad(lat2 - lat1);
    final dLng = _degToRad(lng2 - lng1);
    final a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(_degToRad(lat1)) *
            Math.cos(_degToRad(lat2)) *
            Math.sin(dLng / 2) *
            Math.sin(dLng / 2);
    final c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  // ── Road route between stops ──────────────────────────────────────────────
  // NOTE: Google's Directions REST endpoint (maps.googleapis.com/.../directions)
  // does not send CORS headers, so a direct browser `http.get()` call to it
  // gets blocked on Flutter Web — that's why the route wasn't drawing at all,
  // straight or otherwise. Google's own JS Maps SDK works around this
  // internally, but a raw HTTP call from Dart can't.
  //
  // For now this uses OSRM's public routing server, which IS CORS-enabled
  // and needs no API key, so it works directly from the browser. It uses
  // the same polyline encoding Google does, so `_decodePolyline` below is
  // unchanged.
  //
  // ⚠ For production, swap this to hit your own NestJS backend (e.g. a
  // `/maps/directions` endpoint that calls Google's Directions API
  // server-side, where CORS doesn't apply) via `Api(context).get()`,
  // instead of calling a third-party public server directly.
  Future<List<LatLng>> _getRoadRoute(List<LatLng> points) async {
    if (points.length < 2) return [];
    final coords =
    points.map((p) => '${p.longitude},${p.latitude}').join(';');
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/$coords'
          '?overview=full&geometries=polyline',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['code'] == 'Ok' &&
            (body['routes'] as List).isNotEmpty) {
          final encoded = body['routes'][0]['geometry'] as String;
          return _decodePolyline(encoded);
        } else {
          print('OSRM route status: ${body['code']}');
        }
      }
    } catch (e) {
      print('Route fetch error: $e');
    }
    return [];
  }

  // ── Decode Google's encoded polyline format ───────────────────────────────
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

  // Finds the single closest visit to the clinician's current location.
  // Replaces the old "sort every visit nearest-first" approach — we only
  // ever route to ONE stop (the nearest), not a multi-stop chain.
  VisitMapData _nearestVisit(ClinicianVisitsMapData data) {
    final clinicianLat = data.clinician.latitude;
    final clinicianLng = data.clinician.longitude;
    final nearest = data.visits.reduce((a, b) {
      final da = _distanceKm(clinicianLat, clinicianLng, a.latitude, a.longitude);
      final db = _distanceKm(clinicianLat, clinicianLng, b.latitude, b.longitude);
      return da <= db ? a : b;
    });
    // DEBUG — confirms which visit the haversine calculation actually picked,
    // and from which clinician coordinate it was measured. If this doesn't
    // match what "looks" nearest on screen, the map zoom/projection is
    // misleading you visually — trust this printed distance instead.
    final d = _distanceKm(clinicianLat, clinicianLng, nearest.latitude, nearest.longitude);
    print('_nearestVisit: clinician(lat=$clinicianLat, lng=$clinicianLng) -> '
        'nearest = Visit #${nearest.visitNumber} "${nearest.patientName}" '
        '(visitId: ${nearest.visitId}) at ${d.toStringAsFixed(2)} km');
    return nearest;
  }

  // FIX: was preferring the stored `address` string over lat/lng. That broke
  // routing whenever test/dummy data had a vague or malformed address (e.g.
  // "123 Main St" with no city/state, or a garbled plus-code string) —
  // Google's Directions API can't confidently resolve an ambiguous address
  // to one specific real-world point, so it silently fails to draw a route
  // (shows "More options" / a blank world map instead) rather than erroring.
  //
  // Coordinates are unambiguous, so they're now the primary source; the
  // address string is only used as a last-resort fallback if lat/lng are
  // missing/zero.
  String _routeLocationFor(VisitMapData v) {
    final hasValidCoords = v.latitude != 0 && v.longitude != 0;
    final result = hasValidCoords
        ? '${v.latitude},${v.longitude}'
        : (v.address.trim().isNotEmpty ? v.address : '${v.latitude},${v.longitude}');

    // DEBUG — shows exactly what the API gave for this visit (raw address
    // string vs raw lat/lng) and which one is actually being sent to
    // Google as the destination.
    print('_routeLocationFor: visitId=${v.visitId} "${v.patientName}" — '
        'API gave address="${v.address}", lat=${v.latitude}, lng=${v.longitude} '
        '-> using "$result" (${hasValidCoords ? "COORDINATES" : "ADDRESS fallback"})');

    return result;
  }

  // ── Fallback: open the route to the nearest visit directly in Google Maps
  // (new tab) — a guaranteed-to-work alternative to the in-app polyline,
  // since Google Maps' own web app always renders the road route correctly
  // regardless of google_maps_flutter_web's inline rendering quirks.
  Future<void> _openInGoogleMaps() async {
    if (_mapData == null || _mapData!.visits.isEmpty) return;
    final data = _mapData!;
    final nearestVisit = _nearestVisit(data);

    final origin = '${data.clinician.latitude},${data.clinician.longitude}';
    final destination = _routeLocationFor(nearestVisit);

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
          '&origin=$origin'
          '&destination=$destination'
          '&travelmode=driving',
    );

    // DEBUG — this is the exact URL Google Maps will open. If the route
    // shows "More options" / a blank world map instead of a real route,
    // paste this URL directly into a browser tab to see Google's own
    // error for it — that will confirm whether origin or destination is
    // the ambiguous/bad value.
    print('_openInGoogleMaps: opening $uri');

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Could not open Google Maps: $e');
    }
  }

  // ── Optimise Routes: find the SINGLE nearest visit from the clinician's
  // current location (from the API) and draw the actual driving route
  // (not a straight line) from the clinician to that one stop only. This
  // does NOT touch each visit's `visitNumber` — the numbered pins stay
  // exactly as originally assigned. The nearest visit's marker is also
  // redrawn highlighted so it's obvious which stop is being routed to.
  Future<void> _optimiseRoutes() async {
    if (_mapData == null || _mapData!.visits.isEmpty) return;
    setState(() => _optimising = true);
    try {
      final data = _mapData!;
      final clinicianLatLng =
      LatLng(data.clinician.latitude, data.clinician.longitude);

      print('_optimiseRoutes: clinician at (${clinicianLatLng.latitude}, ${clinicianLatLng.longitude})');

      // FIX: fail loudly instead of silently drawing nothing — if the
      // clinician's coordinates are 0,0 (missing/bad API data), any route
      // built from them will be meaningless (likely pointing at the Gulf
      // of Guinea, the "null island" lat/lng default), so stop here rather
      // than showing a confusing blank/incorrect route.
      if (clinicianLatLng.latitude == 0 && clinicianLatLng.longitude == 0) {
        print('_optimiseRoutes ABORTED: clinician coordinates are 0,0 — bad/missing data from API.');
        return;
      }

      // Single nearest visit only — no multi-stop chain.
      final nearestVisit = _nearestVisit(data);
      final nearestLatLng =
      LatLng(nearestVisit.latitude, nearestVisit.longitude);

      print('_optimiseRoutes: routing to visitId=${nearestVisit.visitId} at (${nearestLatLng.latitude}, ${nearestLatLng.longitude})');

      // Real driving route: clinician → nearest visit only.
      var routePoints =
      await _getRoadRoute([clinicianLatLng, nearestLatLng]);

      print('_optimiseRoutes: OSRM returned ${routePoints.length} route points');

      // Fallback to a straight line only if the routing call fails/returns
      // nothing (e.g. no connectivity), so the route never just disappears.
      if (routePoints.isEmpty) {
        print('Road route unavailable — using straight-line fallback.');
        routePoints = [clinicianLatLng, nearestLatLng];
      } else {
        print('Road route loaded: ${routePoints.length} points.');
      }

      // Rebuild markers so the nearest-visit pin is visually highlighted
      // (bigger pin + gold ring — see _buildNumberedMarker).
      final highlightedMarkers = await _buildMarkers(
        data,
        highlightVisitId: nearestVisit.visitId,
      );

      if (!mounted) return;
      setState(() {
        _markers = highlightedMarkers;
        _routeDestinationVisitId = nearestVisit.visitId;
        _polylines = {
          Polyline(
            polylineId: const PolylineId('optimised_route'),
            points: routePoints,
            color: const Color(0xFFE53935),
            width: 6,
            visible: true,
            zIndex: 1,
            geodesic: false,
          ),
        };
        _routeVersion++;
        // Switch to the embedded Directions view now — this is the one
        // guaranteed-to-render road route (see _buildEmbeddedDirections()).
        _showEmbeddedRoute = true;
        _embedLoading = true; // cleared once the iframe's onLoad fires below
      });

      // Camera intentionally left as-is here — keep the canonical
      // clinician-centered position set in _loadMapData(), no re-animate.

      final d = _distanceKm(clinicianLatLng.latitude, clinicianLatLng.longitude,
          nearestVisit.latitude, nearestVisit.longitude);
      print(
          'Optimised route → nearest visit: ${nearestVisit.patientName} '
              '(visitId: ${nearestVisit.visitId}, marker #${nearestVisit.visitNumber}) '
              '— ${d.toStringAsFixed(2)} km');
    } finally {
      if (mounted) setState(() => _optimising = false);
    }
  }

  static final Set<String> _registeredRouteViews = {};

  Widget? _buildEmbeddedDirections() {
    if (!_showEmbeddedRoute) return null;
    if (_mapData == null || _mapData!.visits.isEmpty) return null;
    final data = _mapData!;
    final nearestVisit = _nearestVisit(data);

    final origin = '${data.clinician.latitude},${data.clinician.longitude}';
    final destination = _routeLocationFor(nearestVisit);

    final viewId = 'route_embed_$_routeVersion';

    if (!_registeredRouteViews.contains(viewId)) {
      final src = Uri(
        scheme: 'https',
        host: 'www.google.com',
        path: '/maps/embed/v1/directions',
        queryParameters: {
          'key': AppConfig.googleApiKey,
          'origin': origin,
          'destination': destination,
          'mode': 'driving',
        },
      ).toString();

      // DEBUG — the exact embedded-directions URL loaded into the iframe.
      // Paste this into a browser tab (minus needing the iframe) to see
      // whether Google itself renders a route for these exact origin/
      // destination values, independent of anything in this Flutter code.
      print('_buildEmbeddedDirections: iframe src = $src');

      final iframe = html.IFrameElement()
        ..src = src
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
      // ✅ FIX: initialize pointer-events from the current lock state so
      // a freshly (re)registered iframe respects whatever lock state is
      // already active (e.g. rebuilt while a dialog happens to be open).
        ..style.pointerEvents = _mapInteractionLocked ? 'none' : 'auto';

      // Clear the loading overlay only once the iframe's content has
      // actually rendered — this is what removes the blank/white flash.
      iframe.onLoad.listen((_) {
        if (mounted) setState(() => _embedLoading = false);
      });

      ui_web.platformViewRegistry
          .registerViewFactory(viewId, (int _) => iframe);
      _registeredRouteViews.add(viewId);

      // ✅ FIX: keep a direct reference to this iframe DOM node so
      // _showPatientPopup() can toggle its pointer-events directly.
      // IgnorePointer (Flutter-side) does not reliably block pointer
      // events reaching this platform view — see field doc above.
      _activeRouteIframe = iframe;
    }

    return HtmlElementView(viewType: viewId);
  }

  // Builds all markers for the map. Pass `highlightVisitId` (the nearest
  // visit's visitId) to draw that one marker bigger with a gold ring, so
  // it's obvious which stop "Optimise Routes" is targeting.
  Future<Set<Marker>> _buildMarkers(
      ClinicianVisitsMapData data, {
        int? highlightVisitId,
      }) async {
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

      final bool isHighlighted =
          highlightVisitId != null && visit.visitId == highlightVisitId;

      final icon = await _buildNumberedMarker(
        visit.visitNumber,
        _statusColor(visit.visitStatus),
        isHighlighted: isHighlighted,
      );

      markers.add(
        Marker(
          markerId: MarkerId('visit_${visit.visitId}'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: isHighlighted
                ? '${visit.patientName} (Nearest stop)'
                : visit.patientName,
            snippet: visit.address,
          ),
          icon: icon,
        ),
      );
    }
    return markers;
  }

  // Draws a numbered circular marker. When `isHighlighted` is true (the
  // nearest-visit destination for "Optimise Routes"), the marker is drawn
  // larger with an outer gold ring so it stands out from the rest.
  Future<BitmapDescriptor> _buildNumberedMarker(
      int number,
      Color color, {
        bool isHighlighted = false,
      }) async {
    final double size = isHighlighted ? 56 : 44;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    if (isHighlighted) {
      // Outer gold halo ring — marks this as the "Optimise Routes" destination.
      canvas.drawCircle(
        Offset(size / 2, size / 2),
        size / 2 - 1,
        Paint()
          ..color = const Color(0xFFFFC107)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }

    // Shadow
    canvas.drawCircle(
      Offset(size / 2 + 1, size / 2 + 2),
      size / 2 - (isHighlighted ? 8 : 2),
      Paint()..color = Colors.black.withOpacity(0.25),
    );
    // Fill
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2 - (isHighlighted ? 8 : 2),
      Paint()..color = color,
    );
    // White border ring
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2 - (isHighlighted ? 8 : 2),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    // Number
    final tp = TextPainter(
      text: TextSpan(
        text: '$number',
        style: TextStyle(
          color: Colors.white,
          fontSize: isHighlighted ? 20 : 18,
          fontWeight: FontWeight.bold,
        ),
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
      return '$h:$m ${dt.hour < 12 ? 'AM' : 'PM'}';
    } catch (_) {
      return '--';
    }
  }

  // ✅ FIX: this is the actual fix for the "map zooms in/out instead of the
  // dropdown opening" bug — and now also covers the "map / embedded route
  // stays interactive underneath the Edit Details popup after Optimise
  // Routes was tapped" bug. GoogleMap / HtmlElementView are native DOM
  // platform views on Flutter Web, sitting outside Flutter's own hit-test
  // tree — a `showDialog` barrier can't block scroll/click events from
  // reaching them. So we explicitly lock the map (see _mapInteractionLocked
  // + its usage in build() below) right before the dialog opens, and
  // unlock it once the dialog is closed/popped, regardless of how it closes.
  //
  // For the native GoogleMap branch, IgnorePointer + the gesture-enabled
  // flags (zoomGesturesEnabled etc., driven by _mapInteractionLocked) are
  // enough. But once "Optimise Routes" has swapped in the embedded
  // Directions <iframe>, there are no equivalent gesture flags to disable —
  // it's a bare iframe — so IgnorePointer alone does NOT stop it from
  // eating scroll/click events on Chrome. We fix that by also setting the
  // iframe's own CSS pointer-events directly via _activeRouteIframe.
  void _showPatientPopup(BuildContext context, ClinicianCalendarVisitData v) {
    setState(() => _mapInteractionLocked = true);
    _activeRouteIframe?.style.pointerEvents = 'none';

    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => EditDetailsDialog(visit: v),
    ).then((_) {
      if (mounted) setState(() => _mapInteractionLocked = false);
      _activeRouteIframe?.style.pointerEvents = 'auto';
    });
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

    final embeddedDirections = _buildEmbeddedDirections();

    // FIX: only show the "Optimise Routes" button when the API actually
    // returned map data with at least one visit — with no visits there is
    // nothing to route/optimise, and tapping it would just no-op (see
    // _optimiseRoutes()'s own early-return guard above) while still taking
    // up space and looking actionable in the top bar.
    final bool _hasRoutableVisits =
        _mapData != null && _mapData!.visits.isNotEmpty;

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
                          padding: const EdgeInsets.only(left: AppSizeConst.A40, right: 20,bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
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
                                          size: 20, color: ColorManager.blueprime),
                                    ),
                                  ),
                                  Container(
                                      width: 1, height: 20, color: Colors.grey.shade300),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
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
                                                Icon(
                                                  Icons.calendar_month_sharp,
                                                  size: 15,
                                                  color: ColorManager.blueprime,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                    _isMonth ? _monthLabel : _dayLabel,
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w500,
                                                        color: ColorManager.blueprime)),
                                              ]),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                      width: 1, height: 20, color: Colors.grey.shade300),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: _next,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 6),
                                      child: Icon(Icons.chevron_right,
                                          size: 20, color:ColorManager.blueprime),
                                    ),
                                  ),
                                ]),
                              ),

                              // FIX: hide the "Optimise Routes" button entirely
                              // when there's no map data yet or the API returned
                              // zero visits — nothing to optimise, so don't show
                              // an actionable-looking button that would just no-op.
                              if (_hasRoutableVisits)
                                ElevatedButton.icon(
                                  onPressed: _optimising ? null : _optimiseRoutes,
                                  icon: _optimising
                                      ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                      : Image.asset('images/hh_emr/optimise.png',
                                      width: 14, height: 14),
                                  label: const Text('Optimise Routes',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorManager.blueprime,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSize.s20,),
                      const Expanded(flex: 2, child: SizedBox()),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizeConst.A40,),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Map (left) ────────────────────────────────────────────────
                          Expanded(
                            flex: 6,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      // Native map with the custom highlighted/numbered
                                      // pins by default; swaps to the embedded real
                                      // route (embeddedDirections) only after
                                      // "Optimise Routes" is tapped — see
                                      // _buildEmbeddedDirections() for why.
                                      //
                                      // ✅ FIX: both branches are wrapped in
                                      // IgnorePointer(ignoring: _mapInteractionLocked)
                                      // so that while the Edit Details dialog (or any
                                      // future dialog) is open above the map, no
                                      // scroll/click event reaches the underlying DOM
                                      // platform view — that's what was causing the
                                      // map to zoom in/out instead of the dialog's
                                      // dropdown responding. NOTE: for the embedded
                                      // iframe branch this IgnorePointer is now backed
                                      // up by a direct CSS pointer-events toggle on
                                      // the iframe itself (see _activeRouteIframe /
                                      // _showPatientPopup) since IgnorePointer alone
                                      // doesn't reliably block a bare iframe platform
                                      // view.
                                      if (embeddedDirections != null)
                                        IgnorePointer(
                                          ignoring: _mapInteractionLocked,
                                          child: embeddedDirections,
                                        )
                                      else
                                        IgnorePointer(
                                          ignoring: _mapInteractionLocked,
                                          child: GoogleMap(
                                            key: ValueKey('gmap_route_$_routeVersion'),
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
                                            zoomControlsEnabled: !_mapInteractionLocked,
                                            zoomGesturesEnabled: !_mapInteractionLocked,
                                            scrollGesturesEnabled: !_mapInteractionLocked,
                                            rotateGesturesEnabled: !_mapInteractionLocked,
                                            tiltGesturesEnabled: !_mapInteractionLocked,
                                            mapToolbarEnabled: false,
                                            markers: _markers,
                                            polylines: _polylines,
                                          ),
                                        ),
                                      if (_loadingMap || _embedLoading)
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
                                      if (_hasRoutableVisits)
                                        Positioned(
                                          bottom: 12,
                                          left: 12,
                                          child: InkWell(
                                            splashColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: _openInGoogleMaps,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 14, vertical: 10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.2),
                                                    blurRadius: 6,
                                                  )
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.open_in_new,
                                                      size: 16,
                                                      color: Colors.blue.shade600),
                                                  const SizedBox(width: 6),
                                                  Text('Open in Maps',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.blue.shade600,
                                                          fontWeight: FontWeight.w600)),
                                                ],
                                              ),
                                            ),
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
                          const SizedBox(width: AppSize.s20,),
                          // ── Sidebar (right) ───────────────────────────────────────────
                          Expanded(
                            flex: 2,
                            ///if any spacing issue arise horizontal add here
                            child: dayVisits.isEmpty
                                ? Center(
                                child: Text('No visits today!',
                                    style: AllNoDataAvailable.customTextStyle(context)))
                                : ScrollConfiguration(
                              behavior: const ScrollBehavior().copyWith(scrollbars: false),
                              child: ListView.builder(
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

                                  return InkWell(
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () => setState(
                                            () => _showNotes[i] = !_showNotes[i]),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(minHeight: 72),
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
                                              // Left colored tab
                                              Container(
                                                width: 18,
                                                decoration: BoxDecoration(color: bg),
                                                alignment: Alignment.center,
                                                child: RotatedBox(
                                                  quarterTurns: 3,
                                                  child: Text(
                                                    type,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 7,
                                                        fontWeight: FontWeight.w800,
                                                        color: accent,
                                                        letterSpacing: 0.8),
                                                  ),
                                                ),
                                              ),

                                              Expanded(
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    // "Visit #x" — fixed width so it doesn't get squeezed
                                                    SizedBox(
                                                      width: 48,
                                                      child: Center(
                                                        child: Text(
                                                          'Visit #${i + 1}',
                                                          textAlign: TextAlign.center,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors.grey.shade500,
                                                              fontWeight: FontWeight.w500),
                                                        ),
                                                      ),
                                                    ),


                                                    Expanded(
                                                      child: InkWell(
                                                        splashColor: Colors.transparent,
                                                        hoverColor: Colors.transparent,
                                                        highlightColor: Colors.transparent,
                                                        onTap: () => _showPatientPopup(context, v),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(
                                                                  horizontal: 4, vertical: 10),
                                                              child: CircleAvatar(
                                                                radius: 16,
                                                                backgroundColor: bg,
                                                                child: Text(
                                                                  _initials(name),
                                                                  style: TextStyle(
                                                                      fontSize: 11,
                                                                      color: accent,
                                                                      fontWeight: FontWeight.bold),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Text(
                                                                    name,
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: const TextStyle(
                                                                        fontSize: 12,
                                                                        fontWeight: FontWeight.w700,
                                                                        color: Colors.black87),
                                                                  ),
                                                                  const SizedBox(height: 2),
                                                                  Text(
                                                                    v.primaryDiagnosis ?? '',
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: TextStyle(
                                                                        fontSize: 10,
                                                                        color: Colors.grey.shade500),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),

                                                    // Time/date — always shown in full, never truncated.
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 8, vertical: 10),
                                                      child: Center(
                                                        child: Text(
                                                          timeRange,
                                                          textAlign: TextAlign.right,
                                                          softWrap: false,
                                                          overflow: TextOverflow.visible,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: ColorManager.blueprime,
                                                              fontWeight: FontWeight.w500),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Padding(
                                                padding: const EdgeInsets.only(right: 6),
                                                child: Center(
                                                  child: Icon(Icons.menu, size: 16, color: Colors.grey.shade400),
                                                ),
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