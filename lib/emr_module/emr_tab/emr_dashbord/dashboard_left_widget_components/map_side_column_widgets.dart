import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../../../app/resources/color.dart';
import '../../../../../../app/resources/provider/hh_emr/visit_details_provider.dart';
import '../../../../../../app/services/api/managers/emr_module_manager/emr_dashboard_tab_manager/emr_announcement_tab_manager.dart';
import '../../../../../../app/services/token/token_manager.dart';
import '../../../../../../data/api_data/emr_module_data/emr_dash_data/emr_announcement_data.dart';

class DashboardMapColumnComponents extends StatefulWidget {
  const DashboardMapColumnComponents({super.key});

  @override
  State<DashboardMapColumnComponents> createState() =>
      _DashboardMapColumnComponentsState();
}

class _DashboardMapColumnComponentsState
    extends State<DashboardMapColumnComponents> {
  GoogleMapController? _todaysMapController;
  List<ClinicianAlertDataDashboard> _alerts = [];
  bool _alertsLoading = true;
  ClinicianVisitsMapData? _mapData;
  Set<Marker> _markers = {};
  CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(34.0522, -118.2437),
    zoom: 12,
  );

  // ── Auto-scroll ─────────────────────────────────────────────────────────────
  final ScrollController _alertsScrollController = ScrollController();
  Timer? _alertsScrollTimer;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
    _loadMapData();
  }

  @override
  void dispose() {
    _alertsScrollTimer?.cancel();
    _alertsScrollController.dispose();
    _todaysMapController?.dispose();
    super.dispose();
  }

  // ── Auto-scroll logic ───────────────────────────────────────────────────────

  void _startAutoScroll() {
    _alertsScrollTimer?.cancel();
    if (_alerts.isEmpty) return;

    const double scrollStep = 0.5;
    const Duration tickInterval = Duration(milliseconds: 16);

    _alertsScrollTimer = Timer.periodic(tickInterval, (_) {
      if (!_alertsScrollController.hasClients) return;

      final max = _alertsScrollController.position.maxScrollExtent;
      final current = _alertsScrollController.offset;

      if (current >= max) {
        _alertsScrollController.jumpTo(0);
      } else {
        _alertsScrollController.jumpTo(current + scrollStep);
      }
    });
  }

  // ── Load alerts ─────────────────────────────────────────────────────────────

  Future<void> _loadAlerts() async {
    try {
      final clinicianId = await TokenManager.getEmployeeId();
      final data = await getClinicianAlerts(context, clinicianId);
      if (mounted) {
        setState(() {
          _alerts = data;
          _alertsLoading = false;
        });
        // Start auto-scroll after list renders
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _startAutoScroll());
      }
    } catch (e) {
      print("Error loading alerts $e");
      if (mounted) setState(() => _alertsLoading = false);
    }
  }

  // ── Load map data ───────────────────────────────────────────────────────────

  Future<void> _loadMapData() async {
    try {
      final clinicianId = await TokenManager.getEmployeeId();
      final data = await getClinicianTodayMapData(context, clinicianId);
      if (data == null || !mounted) return;
      final markers = await _buildMarkers(data);
      setState(() {
        _mapData = data;
        _markers = markers;
        _initialPosition = CameraPosition(
          target: LatLng(data.clinician.latitude, data.clinician.longitude),
          zoom: 12,
        );
      });
    } catch (e) {
      print("Error loading map data $e");
    }
  }

  // ── Markers ─────────────────────────────────────────────────────────────────

  Future<Set<Marker>> _buildMarkers(ClinicianVisitsMapData data) async {
    final Set<Marker> markers = {};

    markers.add(
      Marker(
        markerId: const MarkerId('clinician'),
        position: LatLng(data.clinician.latitude, data.clinician.longitude),
        infoWindow: InfoWindow(title: data.clinician.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue),
      ),
    );

    for (final visit in data.visits) {
      final color = _statusColor(visit.visitStatus);
      final icon = await _buildNumberedMarker(visit.visitNumber, color);
      markers.add(
        Marker(
          markerId: MarkerId('visit_${visit.visitId}'),
          position: LatLng(visit.latitude, visit.longitude),
          infoWindow: InfoWindow(title: visit.patientName),
          icon: icon,
        ),
      );
    }
    return markers;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'VISITED':
        return Colors.green;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'NOT_STARTED':
      default:
        return Colors.red;
    }
  }

  Future<BitmapDescriptor> _buildNumberedMarker(
      int number, Color color) async {
    const double size = 44;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = color;
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25);

    canvas.drawCircle(
        const Offset(size / 2 + 1, size / 2 + 2), size / 2 - 2, shadowPaint);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 2, paint);
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2 - 2,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: '$number',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas,
        Offset((size - tp.width) / 2, (size - tp.height) / 2));

    final img = await recorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final bytes =
    await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Announcements header ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorManager.blueprime.withAlpha(30),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border(
              bottom:
              BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: const Text(
            'Announcements',
            textAlign: TextAlign.center,
            style:
            TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),

        // ── Announcement body ────────────────────────────────────────────────
        SizedBox(
          height: 140,
          child: _alertsLoading
              ? Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ColorManager.blueprime,
              ),
            ),
          )
              : _alerts.isEmpty
              ? const Padding(
            padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Text(
              'No announcements',
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  height: 1.5),
            ),
          )
              : ScrollConfiguration(
            behavior: ScrollConfiguration.of(context)
                .copyWith(scrollbars: false),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Pause on user drag, resume on release
                if (notification
                is ScrollStartNotification &&
                    notification.dragDetails != null) {
                  _alertsScrollTimer?.cancel();
                }
                if (notification is ScrollEndNotification &&
                    notification.dragDetails != null) {
                  _startAutoScroll();
                }
                return false;
              },
              child: ListView.separated(
                controller: _alertsScrollController,
                padding:
                const EdgeInsets.fromLTRB(10, 8, 10, 8),
                itemCount: _alerts.length,
                separatorBuilder: (_, __) => Divider(
                  color: Colors.grey.shade200,
                  height: 12,
                  thickness: 1,
                ),
                itemBuilder: (context, index) {
                  final alert = _alerts[index];
                  return Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.alertHeading,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                      Text(
                        alert.alertBody,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),

        // ── "Today's Visits" + legend row ───────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Row(
            children: [
              const Text(
                "Today's Visits",
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 11),
              ),
              const Spacer(),
              _legendDot(Colors.red, 'Not Started'),
              const SizedBox(width: 6),
              _legendDot(Colors.green, 'Visited'),
              const SizedBox(width: 6),
              _legendDot(Colors.orange, 'Visit In-progress'),
            ],
          ),
        ),

        // ── Map ──────────────────────────────────────────────────────────────
        Expanded(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: GoogleMap(
                    onMapCreated: (ctrl) =>
                    _todaysMapController = ctrl,
                    initialCameraPosition: _initialPosition,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    liteModeEnabled: true,
                    markers: _markers,
                  ),
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => context
                      .read<EMRNavigationController>()
                      .openMap(),
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration:
          BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(label,
            style:
            const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}