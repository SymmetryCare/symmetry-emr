import 'package:flutter/material.dart';
import '../../../../../../../../../app/resources/color.dart';
import '../../../../../../../../../app/resources/value_manager.dart';
import '../../../../../../../../../app/services/api/managers/sm_module_manager/intake/related_parties_manager.dart';
import '../../../../../../../../../data/api_data/sm_data/sm_intake_data/intake_demographics/related_parties_data.dart';
import '../../../../../../../scheduler_model/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import '../../../../../../../scheduler_model/textfield_dropdown_constant/schedular_textfield_const.dart';


class EmrRelatedParty extends StatefulWidget {
  final int patientId;

  const EmrRelatedParty({super.key, required this.patientId});

  @override
  State<EmrRelatedParty> createState() => _EmrRelatedPartyState();
}

class _EmrRelatedPartyState extends State<EmrRelatedParty> {
  // ── Emergency Contact state ───────────────────────────────────────────────
  List<EmergencyContactData> emergencyContacts = [];
  bool emergencyLoading = true;

  // ── Representative state ──────────────────────────────────────────────────
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
    return Scaffold(
      backgroundColor: ColorManager.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Emergency Contacts ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
              child: BlueBGHeadConst(
                HeadText: "Emergency Contact",
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: emergencyLoading
                      ? Center(child: CircularProgressIndicator(color: ColorManager.blueprime))
                      : emergencyContacts.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('No Emergency Contact found')),
                  )
                      : Column(
                    children: emergencyContacts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      return _EmergencyContactReadOnly(
                        data: data,
                        index: index,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSize.s40),

            // ── Patient Representatives ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
              child: BlueBGHeadConst(
                HeadText: "Patient Representative",
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: representativeLoading
                      ? Center(child: CircularProgressIndicator(color: ColorManager.blueprime))
                      : representatives.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('No Representative found')),
                  )
                      : Column(
                    children: representatives.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      return _RepresentativeReadOnly(
                        data: data,
                        index: index,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSize.s30),
          ],
        ),
      ),
    );
  }
}

// ── Emergency Contact Read-Only Card ─────────────────────────────────────────

class _EmergencyContactReadOnly extends StatelessWidget {
  final EmergencyContactData data;
  final int index;

  const _EmergencyContactReadOnly({required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) const Divider(),
        const SizedBox(height: AppSize.s16),

        // Row 1 — First / Last / Relationship
        Row(
          children: [
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.firstName.value ?? ''),
              labelText: 'First Name*',
            )),
            const SizedBox(width: AppSize.s35),
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.lastName.value ?? ''),
              labelText: 'Last Name*',
            )),
            const SizedBox(width: AppSize.s35),
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.relationship.relationshipName),
              labelText: 'Relationship',
            )),
            const SizedBox(width: AppSize.s35),
            const Flexible(child: SizedBox(width: 0)),
            const SizedBox(width: AppSize.s35),
            const Flexible(child: SizedBox(width: 0)),
          ],
        ),
        const SizedBox(height: AppSize.s16),

        // Row 2 — Street / Suite / City / State / Zip
        Row(
          children: [
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.street.street ?? ''),
              icon: Icon(Icons.location_on_outlined, color: ColorManager.blueprime, size: IconSize.I18),
              labelText: 'Street*',
            )),
            const SizedBox(width: AppSize.s35),
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.suite.suite ?? ''),
              labelText: 'Suite/Apt#',
            )),
            const SizedBox(width: AppSize.s35),
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.city.city ?? ''),
              labelText: 'City*',
            )),
            const SizedBox(width: AppSize.s35),
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.state.state ?? ''),
              labelText: 'State*',
            )),
            const SizedBox(width: AppSize.s35),
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.zipcode.zipcode ?? ''),
              labelText: 'Zip Code*',
              allowSSNBR: true,
            )),
          ],
        ),
        const SizedBox(height: AppSize.s16),

        // Row 3 — Phone / Email
        Row(
          children: [
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.phoneNumber.value ?? ''),
              labelText: 'Phone Number*',
              phoneField: true,
            )),
            const SizedBox(width: AppSize.s35),
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.email.value ?? ''),
              labelText: 'Email',
            )),
            const SizedBox(width: AppSize.s35),
            const Flexible(child: SizedBox(width: 0)),
            const SizedBox(width: AppSize.s35),
            const Flexible(child: SizedBox(width: 0)),
            const SizedBox(width: AppSize.s35),
            const Flexible(child: SizedBox(width: 0)),
          ],
        ),
        const SizedBox(height: AppSize.s16),
      ],
    );
  }
}

// ── Representative Read-Only Card ─────────────────────────────────────────────

class _RepresentativeReadOnly extends StatelessWidget {
  final PatientRepresentativeData data;
  final int index;

  const _RepresentativeReadOnly({required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) const Divider(),
        const SizedBox(height: AppSize.s16),

        // Row 1 — First / Last / Relationship / Role / Type
        Row(
          children: [
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.firstName.value ?? ''),
              labelText: 'First Name*',
            )),
            const SizedBox(width: AppSize.s35),
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.lastName.value ?? ''),
              labelText: 'Last Name*',
            )),
            const SizedBox(width: AppSize.s35),
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.relationship.relationshipName),
              labelText: 'Relationship',
            )),
            const SizedBox(width: AppSize.s35),
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.role.roleName ?? ''),
              labelText: 'Role*',
            )),
            const SizedBox(width: AppSize.s35),
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.type.typeName ?? ''),
              labelText: 'Type*',
            )),
          ],
        ),
        const SizedBox(height: AppSize.s16),

        // Row 2 — Street / Suite / City / State / Zip
        Row(
          children: [
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.street.street ?? ''),
              icon: Icon(Icons.location_on_outlined, color: ColorManager.blueprime, size: IconSize.I18),
              labelText: 'Street*',
            )),
            const SizedBox(width: AppSize.s35),
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.suite.suite ?? ''),
              labelText: 'Suite/Apt#',
            )),
            const SizedBox(width: AppSize.s35),
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.city.city ?? ''),
              labelText: 'City*',
            )),
            const SizedBox(width: AppSize.s35),
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.state.state ?? ''),
              labelText: 'State*',
            )),
            const SizedBox(width: AppSize.s35),
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.zipcode.zipcode ?? ''),
              labelText: 'Zip Code*',
              allowSSNBR: true,
            )),
          ],
        ),
        const SizedBox(height: AppSize.s16),

        // Row 3 — Phone / Email
        Row(
          children: [
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.phoneNumber.value ?? ''),
              labelText: 'Phone Number*',
              phoneField: true,
            )),
            const SizedBox(width: AppSize.s35),
            Flexible(child: SchedularTextField(
              controller: TextEditingController(text: data.email.value ?? ''),
              labelText: 'Email',
            )),
            const SizedBox(width: AppSize.s35),
            const Flexible(child: SizedBox(width: 0)),
            const SizedBox(width: AppSize.s35),
            const Flexible(child: SizedBox(width: 0)),
            const SizedBox(width: AppSize.s35),
            const Flexible(child: SizedBox(width: 0)),
          ],
        ),
        const SizedBox(height: AppSize.s16),
      ],
    );
  }
}
