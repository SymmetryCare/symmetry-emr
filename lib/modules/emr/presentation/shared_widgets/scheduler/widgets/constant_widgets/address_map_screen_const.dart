import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'dart:convert';
import 'dart:html' as html;

import 'package:symmetry_emr/app/constants/app_config.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/google_aotopromt_api_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/schedular_textfield_const.dart';

class AddressMapScreenConst extends StatefulWidget {
  final LatLng initialLocation;
  final Function(LatLng) onLocationPicked;

  const AddressMapScreenConst({required this.initialLocation, required this.onLocationPicked});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<AddressMapScreenConst> {
  late GoogleMapController _mapController;
  late LatLng _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;

    html.window.onPopState.listen((event) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  Future<Map<String, String?>> _getAddressFromLatLng(LatLng position) async {
    final apiKey = AppConfig.googleApiKey;
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final address = result['formatted_address'];

          String? city;
          String? state;

          for (var component in result['address_components']) {
            final types = component['types'] as List<dynamic>;

            if (types.contains('locality')) {
              city = component['long_name'];
            }

            if (types.contains('administrative_area_level_1')) {
              state = component['long_name'];
            }
          }

          return {
            'address': address,
            'city': city,
            'state': state,
          };
        }
      }
    } catch (e) {
      debugPrint('Geocoding failed: $e');
    }

    return {
      'address': null,
      'city': null,
      'state': null,
    };
  }

  void _confirmSelection() async {
    final data = await _getAddressFromLatLng(_selectedLocation);

    debugPrint("Picked Location: $_selectedLocation");
    debugPrint("Full Address: ${data['address']}");
    debugPrint("City: ${data['city']}");
    debugPrint("State: ${data['state']}");

    print('"Full Address: ${data['address']}"');
    print('"City: ${data['city']}"');
    print('"State: ${data['state']}"');

    Navigator.of(context).pop({
      'location': _selectedLocation,
      'address': data['address'],
      'city': data['city'],
      'state': data['state'],
    });
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
            child: PointerInterceptor(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 30,
                children: [
                  CustomElevatedButton(
                    width: AppSize.s120,
                    height: AppSize.s32,
                    text: "Cancel",
                    textColor: ColorManager.white,
                    style: TextStyle(color:  ColorManager.white),
                    color: ColorManager.blueprime,
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
              ),
            ),
          ),
        ],
      ),
    );

  }
}


/// Address suggetion screen
class AddressSMIntakeInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onSuggestionSelected;
  final Function(String) onChanged;
  final VoidCallback iconClickedPress;
  final bool isIconVisible;
  final VoidCallback isIClicked;// Callback to notify parent

  const AddressSMIntakeInput({required this.controller, this.onSuggestionSelected, required this.onChanged, required this.iconClickedPress, required this.isIconVisible, required this.isIClicked});

  @override
  _AddressSMIntakeInputState createState() => _AddressSMIntakeInputState();
}

class _AddressSMIntakeInputState extends State<AddressSMIntakeInput> {
  List<String> _suggestions = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onCountyNameChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onCountyNameChanged);
    _removeOverlay();
    super.dispose();
  }

  void _onCountyNameChanged() async {
    final query = widget.controller.text;
    if (query.isEmpty) {
      _suggestions.clear();
      _removeOverlay();
      return;
    }

    final suggestions = await fetchSuggestions(query);
    setState(() {
      _suggestions = suggestions.isNotEmpty && suggestions[0] != query ? suggestions : [];
    });
    print('Suggestion ${_suggestions}');
    _showOverlay();
  }

  void _showOverlay() {
    _removeOverlay();

    if (_suggestions.isEmpty) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
          children:[
            GestureDetector(
              onTap: _removeOverlay,
              child: Container(
                color: Colors.transparent, // Make this transparent so it's invisible
              ),
            ),Positioned(
              left: position.dx,
              top: position.dy + renderBox.size.height,
              width: AppSize.s354,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: _suggestions.length > 5 ? 80.0 : double.infinity,
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            _suggestions[index],
                            style: TableSubHeading.customTextStyle(context),
                          ),
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            widget.controller.text = _suggestions[index];
                            _suggestions.clear();
                            _removeOverlay();

                            // Call the callback with the selected suggestion
                            if (widget.onSuggestionSelected != null) {
                              widget.onSuggestionSelected!(_suggestions[index]);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ]),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return   Column(
      children: [
        SchedularTextField(
            isIconClicked: true,
            iconClickedPress:widget.iconClickedPress,
            isIconVisible: widget.isIconVisible,
            onChanged: widget.onChanged,
            isIClicked: widget
                .isIClicked,
            controller:widget.controller,
            icon: Icon(
              Icons
                  .location_on_outlined,
              color: ColorManager
                  .blueprime,
              size: IconSize.I18,
            ),
            labelText: 'Street*')
      ],
    );
  }
}
