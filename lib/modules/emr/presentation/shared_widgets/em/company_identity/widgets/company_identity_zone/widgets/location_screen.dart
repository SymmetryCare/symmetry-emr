import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'dart:html' as html; // For browser back button

class MapScreen extends StatefulWidget {
  final LatLng initialLocation;
  final Function(LatLng) onLocationPicked;

  const MapScreen({required this.initialLocation, required this.onLocationPicked});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  late LatLng _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    html.window.onPopState.listen((event) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }});
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  ///old
  void _confirmSelection() {
    widget.onLocationPicked(_selectedLocation);
    print("Picked Location: $_selectedLocation");
    Navigator.of(context).pop(_selectedLocation);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              onTap: _onTap,
              initialCameraPosition: CameraPosition(
                target: _selectedLocation,
                zoom: 14.0,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('selectedLocation'),
                  position: _selectedLocation,
                ),
              },
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 30,
              children: [
                CustomElevatedButton(
                  width: AppSize.s120,
                  height: AppSize.s32,
                  text: "Cancel",
                  textColor: ColorManager.blueprime,
                  style: TextStyle(color:  ColorManager.blueprime),
                  color: ColorManager.white,
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),
                CustomElevatedButton(
                width: AppSize.s120,
                height: AppSize.s32,
                  text: "Confirm",
                  color: ColorManager.blueprime,
                  onPressed: _confirmSelection,
                ),
              ],
            )
          ),
        ],
      ),
    );
  }
}
