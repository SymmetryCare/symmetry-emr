import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../../app/resources/provider/hh_emr/visit_details_provider.dart';
import '../../../../../../app/services/api/managers/emr_module_manager/emr_dashboard_tab_manager/emr_announcement_tab_manager.dart';
import '../../../../../../app/services/token/token_manager.dart';
import '../../../../../../data/api_data/emr_module_data/emr_dash_data/emr_announcement_data.dart';

class TodaysVisitsMapScreen extends StatefulWidget {
  const TodaysVisitsMapScreen({super.key});

  @override
  State<TodaysVisitsMapScreen> createState() => _TodaysVisitsMapScreenState();
}

class _TodaysVisitsMapScreenState extends State<TodaysVisitsMapScreen> {
  GoogleMapController? _mapController;
  ClinicianVisitsMapData? _mapData;
  Set<Marker> _markers = {};
  CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(34.0522, -118.2437),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

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
      // Move camera to clinician location once map is ready
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(_initialPosition),
      );
    } catch (e) {
      print("Error loading map data $e");
    }
  }

  Future<Set<Marker>> _buildMarkers(ClinicianVisitsMapData data) async {
    final Set<Marker> markers = {};

    // ── Clinician base marker (blue) ──────────────────────────────
    markers.add(
      Marker(
        markerId: const MarkerId('clinician'),
        position: LatLng(data.clinician.latitude, data.clinician.longitude),
        infoWindow: InfoWindow(title: data.clinician.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // ── Visit numbered circle markers ─────────────────────────────
    for (final visit in data.visits) {
      final color = _statusColor(visit.visitStatus);
      final icon = await _buildNumberedMarker(visit.visitNumber, color);
      markers.add(
        Marker(
          markerId: MarkerId('visit_${visit.visitId}'),
          position: LatLng(visit.latitude, visit.longitude),
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

    // Shadow
    canvas.drawCircle(
      const Offset(size / 2 + 1, size / 2 + 2),
      size / 2 - 2,
      Paint()..color = Colors.black.withOpacity(0.25),
    );
    // Fill circle
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2 - 2,
      Paint()..color = color,
    );
    // White border
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2 - 2,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Number
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 15),

          // ── Title row ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 20),
            child: GestureDetector(
              onTap: () =>
                  context.read<EMRNavigationController>().closeMap(),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.black87, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Today's Visits",
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Legend row ─────────────────────────────────────────
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 42, vertical: 10),
            child: Row(
              children: [
                const Text(
                  "Today's Visits",
                  style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff59748A),
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 15),
                _legendDot(Colors.red, 'Not Started'),
                const SizedBox(width: 10),
                _legendDot(Colors.green, 'Visited'),
                const SizedBox(width: 10),
                _legendDot(Colors.orange, 'Visit In-progress'),
              ],
            ),
          ),

          // ── Map ────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding:
              const EdgeInsets.only(left: 42, right: 30, bottom: 2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GoogleMap(
                  onMapCreated: (ctrl) {
                    _mapController = ctrl;
                    // Animate to clinician location once map ready
                    if (_mapData != null) {
                      ctrl.animateCamera(
                        CameraUpdate.newCameraPosition(_initialPosition),
                      );
                    }
                  },
                  initialCameraPosition: _initialPosition,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                  liteModeEnabled: false,
                  markers: _markers,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }
}