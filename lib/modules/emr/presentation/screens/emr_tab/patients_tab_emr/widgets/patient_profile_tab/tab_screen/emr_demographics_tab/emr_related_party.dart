import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/related_parties_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/related_parties_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/schedular_textfield_const.dart';


class EmrRelatedParty extends StatefulWidget {
  final int patientId;
  final VoidCallback onIButtonPressed;

  const EmrRelatedParty({
    super.key,
    required this.patientId,
    required this.onIButtonPressed,
  });

  @override
  State<EmrRelatedParty> createState() => _EmrRelatedPartyState();
}

class _EmrRelatedPartyState extends State<EmrRelatedParty> {
  List<EmergencyContactData> emergencyContacts = [];
  bool emergencyLoading = true;

  List<PatientRepresentativeData> representatives = [];
  bool representativeLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
    _loadRepresentatives();
  }

  Future<void> _loadEmergencyContacts() async {
    try {
      final data = await getPatientEmergencyContact(
        context: context,
        ptId: widget.patientId,
      );
      setState(() {
        emergencyContacts = data;
        emergencyLoading = false;
      });
    } catch (e) {
      setState(() => emergencyLoading = false);
    }
  }

  Future<void> _loadRepresentatives() async {
    try {
      final data = await getPatientRepresentative(
        context: context,
        ptId: widget.patientId,
      );
      setState(() {
        representatives = data;
        representativeLoading = false;
      });
    } catch (e) {
      setState(() => representativeLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerUpdate = context.watch<SmIntakeProviderManager>(); // ✅ watch → reacts to sidebar toggle
    final bool sidebarOpen = providerUpdate.isLeftSidebarOpen;
    final int perRow = sidebarOpen ? 3 : 5; // ✅ related-party rows were 5-wide originally, drop to 3 when open
    const gap = SizedBox(width: AppSize.s35);
    const rowGap = SizedBox(height: AppSize.s16);

    // ✅ Removed Scaffold — this widget is nested inside a PageView/IndexedStack
    //    (EmrDemographicsTab). A nested Scaffold here clips/misaligns content
    //    against the outer module Scaffold. Use Container + Column instead.
    return Container(
      width: double.infinity,
      color: ColorManager.white,
      child: Column(
          children: [

            // ✅ Go Back — only while sidebar is open
            sidebarOpen
                ? Padding(
              padding: const EdgeInsets.only(top: 10, left: 20, bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onTap: () {
                    widget.onIButtonPressed();
                    providerUpdate.setLinkAndPageClear();
                  },
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back, size: IconSize.I16, color: ColorManager.mediumgrey),
                      const SizedBox(width: 5),
                      Text('Go Back',
                          style: TextStyle(fontWeight: FontWeight.w700, color: ColorManager.mediumgrey)),
                    ],
                  ),
                ),
              ),
            )
                : const SizedBox(height: AppSize.s16),

            // ── Emergency Contacts ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: BlueBGHeadConst(
                HeadText: "Emergency Contact",
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: emergencyLoading
                      ? Center(child: CircularProgressIndicator(color: ColorManager.blueprime))
                      : emergencyContacts.isEmpty
                      ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text('No Emergency Contact found!',
                          style: AllNoDataAvailable.customTextStyle(context)),
                    ),
                  )
                      : Column(
                    children: emergencyContacts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      return _EmergencyContactReadOnly(
                        data: data,
                        index: index,
                        perRow: perRow,
                        gap: gap,
                        rowGap: rowGap,
                        onIButtonPressed: widget.onIButtonPressed,
                        providerUpdate: providerUpdate,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSize.s40),

            // ── Patient Representatives ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: BlueBGHeadConst(
                HeadText: "Patient Representative",
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: representativeLoading
                      ? Center(child: CircularProgressIndicator(color: ColorManager.blueprime))
                      : representatives.isEmpty
                      ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text('No Representative found!',
                          style: AllNoDataAvailable.customTextStyle(context)),
                    ),
                  )
                      : Column(
                    children: representatives.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      return _RepresentativeReadOnly(
                        data: data,
                        index: index,
                        perRow: perRow,
                        gap: gap,
                        rowGap: rowGap,
                        onIButtonPressed: widget.onIButtonPressed,
                        providerUpdate: providerUpdate,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSize.s30),
          ],
        ),
    );
  }
}

// ✅ Shared reflow helper — chunks a flat field list into rows of `perRow`,
//    padding the last row so columns stay aligned.
Widget _reflowRelatedPartyRows({
  required List<Widget> fields,
  required int perRow,
  required SizedBox gap,
  required SizedBox rowGap,
}) {
  final rows = <Widget>[];
  for (int i = 0; i < fields.length; i += perRow) {
    final chunk = fields.sublist(
      i,
      (i + perRow > fields.length) ? fields.length : i + perRow,
    );
    final padded = List<Widget>.from(chunk);
    while (padded.length < perRow) {
      padded.add(const SizedBox());
    }

    final rowChildren = <Widget>[];
    for (int j = 0; j < padded.length; j++) {
      rowChildren.add(Expanded(flex: 1, child: padded[j]));
      if (j != padded.length - 1) rowChildren.add(gap);
    }

    rows.add(Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rowChildren,
    ));
    if (i + perRow < fields.length) rows.add(rowGap);
  }
  return Column(children: rows);
}

// ── Emergency Contact Read-Only Card ─────────────────────────────────────────

class _EmergencyContactReadOnly extends StatelessWidget {
  final EmergencyContactData data;
  final int index;
  final int perRow;
  final SizedBox gap;
  final SizedBox rowGap;
  final VoidCallback onIButtonPressed;
  final SmIntakeProviderManager providerUpdate;

  const _EmergencyContactReadOnly({
    required this.data,
    required this.index,
    required this.perRow,
    required this.gap,
    required this.rowGap,
    required this.onIButtonPressed,
    required this.providerUpdate,
  });

  void _openLink(String link, int pageNo) {
    if (link.isEmpty) return;
    onIButtonPressed();
    providerUpdate.setLinkAndPageNumber(
      selectLink: Uri.parse(link).pathSegments.last,
      pageNo: pageNo,
      isLinkeOpen: link,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[
      SchedularTextField(
        isIconVisible: (data.firstName.link ?? '').isEmpty,
        isIClicked: () => _openLink(data.firstName.link ?? '', data.firstName.pageNo ?? 0),
        controller: TextEditingController(text: data.firstName.value ?? ''),
        labelText: 'First Name*',
      ),
      SchedularTextField(
        isIconVisible: (data.lastName.link ?? '').isEmpty,
        isIClicked: () => _openLink(data.lastName.link ?? '', data.lastName.pageNo ?? 0),
        controller: TextEditingController(text: data.lastName.value ?? ''),
        labelText: 'Last Name*',
      ),
      SchedularTextField(
        controller: TextEditingController(text: data.relationship.relationshipName),
        labelText: 'Relationship',
      ),
      SchedularTextField(
        isIconVisible: data.street.streetLink.isEmpty,
        isIClicked: () => _openLink(data.street.streetLink, data.street.streetPgNo),
        controller: TextEditingController(text: data.street.street ?? ''),
        icon: Icon(Icons.location_on_outlined, color: ColorManager.blueprime, size: IconSize.I18),
        labelText: 'Street*',
      ),
      SchedularTextField(
        isIconVisible: data.suite.suiteLink.isEmpty,
        isIClicked: () => _openLink(data.suite.suiteLink, data.suite.suitePgNo),
        controller: TextEditingController(text: data.suite.suite ?? ''),
        labelText: 'Suite/Apt#',
      ),
      SchedularTextField(
        isIconVisible: data.city.cityLink.isEmpty,
        isIClicked: () => _openLink(data.city.cityLink, data.city.cityPgNo),
        controller: TextEditingController(text: data.city.city ?? ''),
        labelText: 'City*',
      ),
      SchedularTextField(
        isIconVisible: data.state.stateLink.isEmpty,
        isIClicked: () => _openLink(data.state.stateLink, data.state.statePgNo),
        controller: TextEditingController(text: data.state.state ?? ''),
        labelText: 'State*',
      ),
      SchedularTextField(
        isIconVisible: data.zipcode.zipcodeLink.isEmpty,
        isIClicked: () => _openLink(data.zipcode.zipcodeLink, data.zipcode.zipcodePgNo),
        controller: TextEditingController(text: data.zipcode.zipcode ?? ''),
        labelText: 'Zip Code*',
        allowSSNBR: true,
      ),
      SchedularTextField(
        isIconVisible: (data.phoneNumber.link ?? '').isEmpty,
        isIClicked: () => _openLink(data.phoneNumber.link ?? '', data.phoneNumber.pageNo ?? 0),
        controller: TextEditingController(text: data.phoneNumber.value ?? ''),
        labelText: 'Phone Number*',
        phoneField: true,
      ),
      SchedularTextField(
        isIconVisible: (data.email.link ?? '').isEmpty,
        isIClicked: () => _openLink(data.email.link ?? '', data.email.pageNo ?? 0),
        controller: TextEditingController(text: data.email.value ?? ''),
        labelText: 'Email',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) const Divider(),
        const SizedBox(height: AppSize.s16),
        _reflowRelatedPartyRows(fields: fields, perRow: perRow, gap: gap, rowGap: rowGap),
        const SizedBox(height: AppSize.s16),
      ],
    );
  }
}

// ── Representative Read-Only Card ─────────────────────────────────────────────

class _RepresentativeReadOnly extends StatelessWidget {
  final PatientRepresentativeData data;
  final int index;
  final int perRow;
  final SizedBox gap;
  final SizedBox rowGap;
  final VoidCallback onIButtonPressed;
  final SmIntakeProviderManager providerUpdate;

  const _RepresentativeReadOnly({
    required this.data,
    required this.index,
    required this.perRow,
    required this.gap,
    required this.rowGap,
    required this.onIButtonPressed,
    required this.providerUpdate,
  });

  void _openLink(String link, int pageNo) {
    if (link.isEmpty) return;
    onIButtonPressed();
    providerUpdate.setLinkAndPageNumber(
      selectLink: Uri.parse(link).pathSegments.last,
      pageNo: pageNo,
      isLinkeOpen: link,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[
      SchedularTextField(
        isIconVisible: (data.firstName.link ?? '').isEmpty,
        isIClicked: () => _openLink(data.firstName.link ?? '', data.firstName.pageNo ?? 0),
        controller: TextEditingController(text: data.firstName.value ?? ''),
        labelText: 'First Name*',
      ),
      SchedularTextField(
        isIconVisible: (data.lastName.link ?? '').isEmpty,
        isIClicked: () => _openLink(data.lastName.link ?? '', data.lastName.pageNo ?? 0),
        controller: TextEditingController(text: data.lastName.value ?? ''),
        labelText: 'Last Name*',
      ),
      SchedularTextField(
        controller: TextEditingController(text: data.relationship.relationshipName),
        labelText: 'Relationship',
      ),
      SchedularTextField(
        controller: TextEditingController(text: data.role.roleName ?? ''),
        labelText: 'Role*',
      ),
      SchedularTextField(
        controller: TextEditingController(text: data.type.typeName ?? ''),
        labelText: 'Type*',
      ),
      SchedularTextField(
        isIconVisible: data.street.streetLink.isEmpty,
        isIClicked: () => _openLink(data.street.streetLink, data.street.streetPgNo),
        controller: TextEditingController(text: data.street.street ?? ''),
        icon: Icon(Icons.location_on_outlined, color: ColorManager.blueprime, size: IconSize.I18),
        labelText: 'Street*',
      ),
      SchedularTextField(
        isIconVisible: data.suite.suiteLink.isEmpty,
        isIClicked: () => _openLink(data.suite.suiteLink, data.suite.suitePgNo),
        controller: TextEditingController(text: data.suite.suite ?? ''),
        labelText: 'Suite/Apt#',
      ),
      SchedularTextField(
        isIconVisible: data.city.cityLink.isEmpty,
        isIClicked: () => _openLink(data.city.cityLink, data.city.cityPgNo),
        controller: TextEditingController(text: data.city.city ?? ''),
        labelText: 'City*',
      ),
      SchedularTextField(
        isIconVisible: data.state.stateLink.isEmpty,
        isIClicked: () => _openLink(data.state.stateLink, data.state.statePgNo),
        controller: TextEditingController(text: data.state.state ?? ''),
        labelText: 'State*',
      ),
      SchedularTextField(
        isIconVisible: data.zipcode.zipcodeLink.isEmpty,
        isIClicked: () => _openLink(data.zipcode.zipcodeLink, data.zipcode.zipcodePgNo),
        controller: TextEditingController(text: data.zipcode.zipcode ?? ''),
        labelText: 'Zip Code*',
        allowSSNBR: true,
      ),
      SchedularTextField(
        isIconVisible: (data.phoneNumber.link ?? '').isEmpty,
        isIClicked: () => _openLink(data.phoneNumber.link ?? '', data.phoneNumber.pageNo ?? 0),
        controller: TextEditingController(text: data.phoneNumber.value ?? ''),
        labelText: 'Phone Number*',
        phoneField: true,
      ),
      SchedularTextField(
        isIconVisible: (data.email.link ?? '').isEmpty,
        isIClicked: () => _openLink(data.email.link ?? '', data.email.pageNo ?? 0),
        controller: TextEditingController(text: data.email.value ?? ''),
        labelText: 'Email',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) const Divider(),
        const SizedBox(height: AppSize.s16),
        _reflowRelatedPartyRows(fields: fields, perRow: perRow, gap: gap, rowGap: rowGap),
        const SizedBox(height: AppSize.s16),
      ],
    );
  }
}