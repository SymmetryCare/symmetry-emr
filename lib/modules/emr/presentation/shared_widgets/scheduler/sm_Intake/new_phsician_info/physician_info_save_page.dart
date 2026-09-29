import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/intake_physician_info_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/sm_physician_info/physician_info.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';

class SavePagePhysicianInfo extends StatefulWidget {
  final VoidCallback onEdit;
  final int physicianId;

  const SavePagePhysicianInfo({Key? key, required this.onEdit, required this.physicianId}) : super(key: key);

  @override
  State<SavePagePhysicianInfo> createState() => _SavePagePhysicianInfoState();
}

class _SavePagePhysicianInfoState extends State<SavePagePhysicianInfo> {
  late bool isSaved;

  String? name;
  String? street;
  String? suite;
  String? city;
  String? state;
  String? zipCode;
  String? phone;
  String? fax;
  String? email;
  String? npi;
  String? upi;
  String? protocol;
  String? notes;
  String? verificationDetails;
  String? pecosStatus;

  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _prefillPhysicianData();
  }
  bool _isOverlayVisible = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  OverlayEntry _createOverlayEntry(BuildContext context, Offset position, String text) {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          left: position.dx,
          top: position.dy,
          child: Material(
            elevation: 8.0,
            child: Container(
              width: 150,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                  text,
                  style: ThemeManagerDarkFont.customTextStyle(context)
              ),
            ),
          ),
        );
      },
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length > maxLength) {
      return text.substring(0, maxLength) + '...'; // Add "..." if the text exceeds 10 characters
    }
    return text;
  }
  void showOverlay(BuildContext context, Offset position, String text) {
    if (_isOverlayVisible) return;

    _overlayEntry = _createOverlayEntry(context, position, text);
    Overlay.of(context)?.insert(_overlayEntry!);
    _isOverlayVisible = true;
  }

  // Remove overlay
  void removeOverlay() {
    if (_overlayEntry != null && _isOverlayVisible) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOverlayVisible = false;
    }
  }
  Future<void> _prefillPhysicianData() async {
    final provider = Provider.of<DiagnosisProvider>(context, listen: false);

    try {
      List<PhysicianInfoPrefillData> prefilledData = await getPhysicianInfoById(
        context: context,
        patientId: provider.patientId,
        physicianId: widget.physicianId
      );

      if (prefilledData.isNotEmpty) {
        final data = prefilledData.first;

        setState(() {
          name = '${data.firstName.phyFirstName} ${data.lastName.phyLastName}, ${data.suffix?.phySuffix ?? ""}';
          street = data.street.phyStreet ?? '';
          suite = data.suite.phySuite ?? '';
          city = data.city.phyCity ?? '';
          state = data.state.phyState ?? '';
          zipCode = data.zipcode.phyZipCode ?? '';
          phone = data.contact.phyContact ?? '';
          fax = data.fax.phyFax ?? '';
          email = data.email.phyEmail ?? '';
          npi = data.phyNPI.phyNPI.toString();
          upi = data.upi.phyUPI ?? '';
          protocol = data.protocols.phyProtocols ?? '';
          notes = data.notes.phyNotes ?? '';
          verificationDetails = data.verificationDetails.phyVerificationDetails ?? '';
          pecosStatus = data.phyPicoStatus.toString()  ?? 'UNKNOWN';
        });
      }
    } catch (e) {
      print('Failed to load prefilled data: $e');
    } finally {
      setState(() {
        _isLoading = false; // ✅ Done loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double spacing  =  MediaQuery.of(context).size.width * 0.05;
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Padding(
      padding:  const EdgeInsets.symmetric(horizontal: AppPadding.p35,vertical: AppPadding.p10),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 120,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFF008000),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Verified",
                          style: CustomTextStylesCommon.commonStyle(
                            fontSize: FontSize.s12,
                            fontWeight: FontWeight.w700,
                            color: ColorManager.white,
                          )),
                      Image.asset(
                        "images/sm/white_tik.png",
                        height: 20,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// First Column Group
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 15,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text('Name :', style: ThemeManagerDark.customTextStyle(context))),
                          Expanded(
                              flex: 2,
                              child: Text(name ?? '', style: ThemeManagerDarkFont.customTextStyle(context))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text('Street :', style: ThemeManagerDark.customTextStyle(context))),
                          Expanded(
                              flex: 2,
                              child: Text(street ?? '', style: ThemeManagerDarkFont.customTextStyle(context))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text('Suite/Apt# :', style: ThemeManagerDark.customTextStyle(context))),
                          Expanded(
                              flex: 2,
                              child: Text(suite ?? '', style: ThemeManagerDarkFont.customTextStyle(context))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text('City :', style: ThemeManagerDark.customTextStyle(context))),
                          Expanded(
                              flex: 2,
                              child: Text(city ?? '', style: ThemeManagerDarkFont.customTextStyle(context))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text('State :', style: ThemeManagerDark.customTextStyle(context))),
                          Expanded(
                              flex: 2,
                              child: Text(state ?? '', style: ThemeManagerDarkFont.customTextStyle(context))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text('Zip Code :', style: ThemeManagerDark.customTextStyle(context))),
                          Expanded(
                              flex: 2,
                              child: Text(zipCode ?? '', style: ThemeManagerDarkFont.customTextStyle(context))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text('Phone Number :', style: ThemeManagerDark.customTextStyle(context))),
                          Expanded(
                              flex: 2,
                              child: Text(phone ?? '', style: ThemeManagerDarkFont.customTextStyle(context))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text('Fax Number :', style: ThemeManagerDark.customTextStyle(context))),
                          Expanded(
                              flex: 2,
                              child: Text(fax ?? '', style: ThemeManagerDarkFont.customTextStyle(context))),
                        ],
                      ),
                    ],
                  ),
                ),

                 SizedBox(width: spacing),
                /// Second Column Group
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 15,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text('NPI Number :', style: ThemeManagerDark.customTextStyle(context))),
                          Expanded(
                              flex: 2,
                              child: Text(npi ?? '', style: ThemeManagerDarkFont.customTextStyle(context))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text('UPI Number :', style: ThemeManagerDark.customTextStyle(context))),
                          Expanded(
                              flex: 2,
                              child: Text(upi ?? '', style: ThemeManagerDarkFont.customTextStyle(context))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text('Email :', style: ThemeManagerDark.customTextStyle(context))),
                          Expanded(
                              flex: 2,
                              child: Text(email ?? '', style: ThemeManagerDarkFont.customTextStyle(context))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text('Protocols :', style: ThemeManagerDark.customTextStyle(context))),
                          Expanded(
                              flex: 2,
                              child: Text(protocol ?? '', style: ThemeManagerDarkFont.customTextStyle(context))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text('Notes :', style: ThemeManagerDark.customTextStyle(context))),
                          Expanded(
                              flex: 2,
                              child: Text(notes ?? '', style: ThemeManagerDarkFont.customTextStyle(context))),
                        ],
                      ),
                    ],
                  ),
                ),

                 SizedBox(width: spacing),

                /// Third Column Group (PECOS Status)
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 15,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text('PECOS Status :', style: ThemeManagerDark.customTextStyle(context))),
                          Expanded(
                            flex: 2,
                            child: Text(
                                pecosStatus ?? 'UNKNOWN',           //"ENROLLED",
                                style: CustomTextStylesCommon.commonStyle(
                                  fontSize: FontSize.s12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xff04BF00),
                                )),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text('Verification Details :', style: ThemeManagerDark.customTextStyle(context))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text(verificationDetails ?? '', style: ThemeManagerDarkFont.customTextStyle(context))), ],
                      ),
                    ],
                  ),
                ),
                 SizedBox(width: spacing),

                /// Fourth Column (Edit Button)
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: widget.onEdit,
                        icon: Icon(
                          Icons.edit_outlined,
                          color: ColorManager.blueprime,
                          size: IconSize.I22,
                        ),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
