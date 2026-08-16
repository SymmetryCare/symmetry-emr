import 'package:flutter/material.dart';
import 'package:prohealth/app/services/api/managers/sm_module_manager/intake/intake_physician_info_manager.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../../app/resources/color.dart';
import '../../../../../../../../../app/resources/common_resources/common_theme_const.dart';
import '../../../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../../../app/resources/theme_manager.dart';
import '../../../../../../../../../app/resources/value_manager.dart';
import '../../../../../../../../../data/api_data/sm_data/sm_intake_data/sm_physician_info/physician_dropdown_data.dart';
import '../../../../../../../../../data/api_data/sm_data/sm_intake_data/sm_physician_info/physician_info.dart';
import '../../../../../../em_module/manage_hr/manage_employee_documents/widgets/radio_button_tile_const.dart';
import '../../../../../../scheduler_model/sm_Intake/widgets/intake_orders/intake_orders_screen.dart';
import '../../../../../../scheduler_model/sm_Intake/widgets/intake_update_schedular/information_update.dart';
import '../../../../../../scheduler_model/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import '../../../../../../scheduler_model/textfield_dropdown_constant/schedular_textfield_const.dart';
import '../../../../../../scheduler_model/widgets/constant_widgets/dropdown_constant_sm.dart';

class EmrPhysicianInfoTab extends StatefulWidget {
  final int patientId;
  const EmrPhysicianInfoTab({super.key, required this.patientId});

  @override
  State<EmrPhysicianInfoTab> createState() => _EmrPhysicianInfoTabState();
}

class _EmrPhysicianInfoTabState extends State<EmrPhysicianInfoTab> {

  // ── Controllers ───────────────────────────────────────────────────────────
  final TextEditingController physicianIdController  = TextEditingController();
  final TextEditingController nameController         = TextEditingController();
  final TextEditingController lastController         = TextEditingController();
  final TextEditingController suffixController       = TextEditingController();
  final TextEditingController streetController       = TextEditingController();
  final TextEditingController suitapiController      = TextEditingController();
  final TextEditingController cityController         = TextEditingController();
  final TextEditingController stateController        = TextEditingController();
  final TextEditingController zipcodeController      = TextEditingController();
  final TextEditingController phonenumberController  = TextEditingController();
  final TextEditingController faxnumController       = TextEditingController();
  final TextEditingController emailController        = TextEditingController();
  final TextEditingController npiController          = TextEditingController();
  final TextEditingController upiController          = TextEditingController();
  final TextEditingController protocalController     = TextEditingController();
  final TextEditingController noteController         = TextEditingController();
  final TextEditingController pecosController        = TextEditingController();
  final TextEditingController pecosStatus            = TextEditingController();
  final TextEditingController verificationController = TextEditingController();
  final TextEditingController trakingController      = TextEditingController();

  // ── State ─────────────────────────────────────────────────────────────────
  String? statustype;
  int     physicianSelectedId = 0;
  String  selectedPhyName     = 'Select';

  Future<List<PhysicianInfoPrefillData>>? _physicianFuture;

  // ── Shared gaps ───────────────────────────────────────────────────────────
  static const _gap    = SizedBox(width: AppSize.s35);
  static const _rowGap = SizedBox(height: AppSize.s16);

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final providerTabSave = Provider.of<InformationUpdateProvider>(context, listen: false);
      // Get physicianId from provider — set by setPatientStatusFromModel
      physicianSelectedId = providerTabSave.physicianId;
      _refreshPhysicianFuture(
        patientId:   widget.patientId,
        physicianId: physicianSelectedId,
      );
    });
  }

  void _refreshPhysicianFuture({int? patientId, int? physicianId}) {
    setState(() {
      _physicianFuture = getPhysicianInfoById(
        context:     context,
        patientId:   patientId   ?? widget.patientId,
        physicianId: physicianId ?? physicianSelectedId,
      );
    });
  }

  void clearControllers() {
    physicianIdController.clear();
    nameController.clear();
    lastController.clear();
    suffixController.clear();
    streetController.clear();
    suitapiController.clear();
    cityController.clear();
    stateController.clear();
    zipcodeController.clear();
    phonenumberController.clear();
    faxnumController.clear();
    emailController.clear();
    npiController.clear();
    upiController.clear();
    protocalController.clear();
    noteController.clear();
    verificationController.clear();
    trakingController.clear();
    pecosController.clear();
    pecosStatus.clear();
    statustype = null;
  }

  void _populateControllers(PhysicianInfoPrefillData d) {
    physicianIdController.text = '${d.firstName.phyFirstName} ${d.lastName.phyLastName}';
    if (nameController.text.isEmpty)         nameController.text         = d.firstName.phyFirstName;
    if (lastController.text.isEmpty)         lastController.text         = d.lastName.phyLastName;
    if (suffixController.text.isEmpty)       suffixController.text       = d.suffix.phySuffix ?? '';
    if (streetController.text.isEmpty)       streetController.text       = d.street.phyStreet ?? '';
    if (suitapiController.text.isEmpty)      suitapiController.text      = d.suite.phySuite ?? '';
    if (cityController.text.isEmpty)         cityController.text         = d.city.phyCity ?? '';
    if (stateController.text.isEmpty)        stateController.text        = d.state.phyState ?? '';
    if (zipcodeController.text.isEmpty)      zipcodeController.text      = d.zipcode.phyZipCode ?? '';
    if (phonenumberController.text.isEmpty)  phonenumberController.text  = d.contact.phyContact;
    if (faxnumController.text.isEmpty)       faxnumController.text       = d.fax.phyFax ?? '';
    if (emailController.text.isEmpty)        emailController.text        = d.email.phyEmail;
    if (npiController.text.isEmpty)          npiController.text          = d.phyNPI.phyNPI.toString();
    if (upiController.text.isEmpty)          upiController.text          = d.upi.phyUPI ?? '';
    if (protocalController.text.isEmpty)     protocalController.text     = d.protocols.phyProtocols ?? '';
    if (noteController.text.isEmpty)         noteController.text         = d.notes.phyNotes ?? '';
    if (verificationController.text.isEmpty) verificationController.text = d.verificationDetails.phyVerificationDetails ?? '';
    if (trakingController.text.isEmpty)      trakingController.text      = d.trackingNotes.phyTrackingNotes ?? '';
    if (pecosController.text.isEmpty)        pecosController.text        = d.picoNo.phyPicoNo;
    if (pecosStatus.text.isEmpty)            pecosStatus.text            = d.phyPicoStatus.toString();
    statustype = d.phyVerified == true ? 'Yes' : 'No';
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<InformationUpdateProvider>(
      builder: (context, providerTabSave, _) {
        // Re-sync whenever provider's physicianId changes
        if (physicianSelectedId != providerTabSave.physicianId) {
          physicianSelectedId = providerTabSave.physicianId;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _refreshPhysicianFuture(
              patientId:   widget.patientId,
              physicianId: providerTabSave.physicianId,
            );
          });
        }
        return _buildMainContent(widget.patientId);
      },
    );
  }

  Widget _buildMainContent(int currentPatientId) {
    if (_physicianFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return FutureBuilder<List<PhysicianInfoPrefillData>>(
      future: _physicianFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: ColorManager.blueprime));
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong!'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Text('No physician data available.',
                  style: AllNoDataAvailable.customTextStyle(context)),
            ),
          );
        }
        _populateControllers(snapshot.data![0]);
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Column(children: [_buildPhysicianForm()]),
          ),
        );
      },
    );
  }

  // ── Physician Form ────────────────────────────────────────────────────────
  Widget _buildPhysicianForm() {
    return BlueBGHeadConst(
      HeadText: 'Certifying F2F Physician Or Allowed Practitioner',
      body: Column(
        children: [
          const SizedBox(height: AppSize.s10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _rowGap,

                // ── Row 1 — Select DB | First Name | Last Name | Suffix | (empty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(child: _buildPhysicianDropdown()),
                    _gap,
                    Flexible(child: SchedularTextField(isIconVisible: true, controller: nameController, labelText: 'First Name*', enable: false)),
                    _gap,
                    Flexible(child: SchedularTextField(isIconVisible: true, controller: lastController, labelText: 'Last Name*', enable: false)),
                    _gap,
                    Flexible(child: SchedularTextField(isIconVisible: true, controller: suffixController, labelText: 'Suffix', enable: false)),
                    _gap,
                    const Flexible(child: SizedBox()),
                  ],
                ),
                _rowGap,

                // ── Row 2 — Street | Suite/Apt | City | State | Zip Code
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(child: SchedularTextField(isIconVisible: true, controller: streetController, labelText: 'Street*', enable: false)),
                    _gap,
                    Flexible(child: SchedularTextField(isIconVisible: true, controller: suitapiController, labelText: 'Suite/Apt#', enable: false)),
                    _gap,
                    Flexible(child: SchedularTextField(isIconVisible: true, controller: cityController, labelText: 'City*', enable: false)),
                    _gap,
                    Flexible(child: SchedularTextField(isIconVisible: true, controller: stateController, labelText: 'State*', enable: false)),
                    _gap,
                    Flexible(child: SchedularTextField(isIconVisible: true, controller: zipcodeController, labelText: 'Zip Code*', enable: false)),
                  ],
                ),
                _rowGap,

                // ── Row 3 — Phone | Fax | Email | Contact Icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(child: SchedularTextField(isIconVisible: true, controller: phonenumberController, labelText: 'Phone Number*', enable: false)),
                    _gap,
                    Flexible(child: SchedularTextField(isIconVisible: true, controller: faxnumController, labelText: 'Fax Number', enable: false)),
                    _gap,
                    Flexible(child: SchedularTextField(isIconVisible: true, controller: emailController, labelText: 'Email', enable: false)),
                    _gap,
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 18),
                          Icon(Icons.contact_page_outlined, color: ColorManager.blueprime, size: 32),
                          Text('Contact', style: TextStyle(color: ColorManager.blueprime, fontSize: FontSize.s12)),
                        ],
                      ),
                    ),
                  ],
                ),
                _rowGap,

                // ── Row 4 — NPI | UPI | Protocols | Notes
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(child: SchedularTextField(isIconVisible: true, controller: npiController, labelText: 'NPI Number', enable: false)),
                    _gap,
                    Flexible(child: SchedularTextField(isIconVisible: true, controller: upiController, labelText: 'UPI Number', enable: false)),
                    _gap,
                    Flexible(child: SchedularTextField(isIconVisible: true, controller: protocalController, labelText: 'Protocols', enable: false)),
                    _gap,
                    Flexible(child: SchedularTextField(isIconVisible: true, controller: noteController, labelText: 'Notes', enable: false)),
                  ],
                ),
                _rowGap,

                _buildPecosSection(),
                _rowGap,
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Divider(),
          ),
        ],
      ),
    );
  }

  // ── Physician DB Dropdown ─────────────────────────────────────────────────
  Widget _buildPhysicianDropdown() {
    return FutureBuilder<List<PhysicianDropDownData>>(
      future: getPhysicianDropDown(context: context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SchedularTextField(
            isIconVisible: false,
            controller: TextEditingController(text: selectedPhyName),
            labelText: 'Select from Database',
            enable: false,
          );
        }
        if (!snapshot.hasData) return const Offstage();
        return CustomDropdownTextFieldsm(
          initialValue: selectedPhyName,
          headText: 'Select from Database',
          dropDownMenuList: snapshot.data!
              .map((i) => DropdownMenuItem<String>(
            value: i.physicianName,
            child: Text(i.physicianName!),
          ))
              .toList(),
          onChanged: (newValue) {
            for (final a in snapshot.data!) {
              if (a.physicianName == newValue) {
                setState(() {
                  selectedPhyName     = a.physicianName!;
                  physicianSelectedId = a.id;
                  clearControllers();
                });
                _refreshPhysicianFuture(
                  patientId:   widget.patientId,
                  physicianId: physicianSelectedId,
                );
                break;
              }
            }
          },
        );
      },
    );
  }

  // ── PECOS Section ─────────────────────────────────────────────────────────
  Widget _buildPecosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Check PECOS Eligibility Status',
          style: CustomTextStylesCommon.commonStyle(
            fontSize:   FontSize.s14,
            fontWeight: FontWeight.w700,
            color:      ColorManager.bluebottom,
          ),
        ),
        _rowGap,

        // Sub-row A — Physician Verified | PECOS Status
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Physician Verified',
                      style: SMTextfieldHeadings.customTextStyle(context)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(child: CustomRadioListTileSMp(title: 'No',  value: 'No',  groupValue: statustype, onChanged: (_) {})),
                      Expanded(child: CustomRadioListTileSMp(title: 'Yes', value: 'Yes', groupValue: statustype, onChanged: (_) {})),
                    ],
                  ),
                ],
              ),
            ),
            _gap,
            SizedBox(
              width: 250,
              child: SchedularTextField(
                isIconVisible: false,
                controller: pecosStatus,
                labelText:  'PECOS Status',
                enable:     false,
                textStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize:   FontSize.s12,
                  color:      ColorManager.greenDark,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
        _rowGap,

        // Sub-row B — Verification Details | Tracking Notes
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(child: SchedularTextField(isIconVisible: true, controller: verificationController, labelText: 'Verification Details', enable: false)),
            _gap,
            Flexible(child: SchedularTextField(isIconVisible: true, controller: trakingController, labelText: 'Tracking Notes', enable: false)),
          ],
        ),
      ],
    );
  }
}