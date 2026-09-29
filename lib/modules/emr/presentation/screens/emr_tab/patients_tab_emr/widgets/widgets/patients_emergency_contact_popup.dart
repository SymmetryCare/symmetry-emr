import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/related_parties_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_demographics/related_parties_data.dart';

class PatientsEmergencyContactPopup extends StatefulWidget {
  final int ptId;
  const PatientsEmergencyContactPopup({super.key, required this.ptId});

  @override
  State<PatientsEmergencyContactPopup> createState() =>
      _PatientsEmergencyContactPopupState();
}

class _PatientsEmergencyContactPopupState
    extends State<PatientsEmergencyContactPopup> {
  static const double _kDesignWidth = 855;

  // ── Cached future — prevents refetch/rebuild loop on every build ──
  late Future<List<EmergencyContactData>> _emergencyContactFuture;

  @override
  void initState() {
    super.initState();
    _emergencyContactFuture = getPatientEmergencyContact(
      context: context,
      ptId: widget.ptId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kDesignWidth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70.0, vertical: 60),
      child: DialogueTemplateNoButtons(
        width: double.infinity,
        height: double.infinity,
        title: "Emergency Contacts",
        body: [
          // ✅ Single FutureBuilder wrapping both sections
          FutureBuilder<List<EmergencyContactData>>(
            future: _emergencyContactFuture,
            builder: (context, snapshot) {
              // ✅ Single loader for entire body
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSize.s150),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text("Failed to load contacts"));
              }

              final contacts = snapshot.data!;

              // Index 0 -> Emergency Contact, Index 1 -> Primary Caregiver
              final emergencyContact = contacts.isNotEmpty ? contacts[0] : null;
              final primaryCaregiver = contacts.length > 1 ? contacts[1] : null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),

                  // ✅ Emergency Contact — contacts[0]
                  BlueBGHeadConst(
                    HeadText: "Emergency Contact",
                    body: emergencyContact == null
                        ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "No emergency contact found!",
                          style: AllNoDataAvailable.customTextStyle(context),
                        ),
                      ),
                    )
                        : Column(
                      children: [
                        const SizedBox(height: AppSize.s18),
                        Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: _ContactDetailGrid(
                            firstName: emergencyContact.firstName.value,
                            lastName: emergencyContact.lastName.value,
                            relationship:
                            emergencyContact.relationship.relationshipName,
                            street: emergencyContact.street.street,
                            suiteApt: emergencyContact.suite.suite,
                            city: emergencyContact.city.city,
                            state: emergencyContact.state.state,
                            zipCode: emergencyContact.zipcode.zipcode,
                            phoneNumber: emergencyContact.phoneNumber.value,
                            email: emergencyContact.email.value,
                          ),
                        ),
                        const SizedBox(height: AppSize.s18),
                        const Divider(height: 1, thickness: 1),
                        const SizedBox(height: AppSize.s12),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSize.s15),

                  // ✅ Primary Caregiver — contacts[1]
                  BlueBGHeadConst(
                    HeadText: "Primary Caregiver",
                    body: primaryCaregiver == null
                        ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "No primary caregiver found!",
                          style: AllNoDataAvailable.customTextStyle(context),
                        ),
                      ),
                    )
                        : Column(
                      children: [
                        const SizedBox(height: AppSize.s18),
                        Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: _ContactDetailGrid(
                            firstName: primaryCaregiver.firstName.value,
                            lastName: primaryCaregiver.lastName.value,
                            relationship:
                            primaryCaregiver.relationship.relationshipName,
                            street: primaryCaregiver.street.street,
                            suiteApt: primaryCaregiver.suite.suite,
                            city: primaryCaregiver.city.city,
                            state: primaryCaregiver.state.state,
                            zipCode: primaryCaregiver.zipcode.zipcode,
                            phoneNumber: primaryCaregiver.phoneNumber.value,
                            email: primaryCaregiver.email.value,
                          ),
                        ),
                        const SizedBox(height: AppSize.s18),
                        const Divider(height: 1, thickness: 1),
                        const SizedBox(height: AppSize.s12),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ContactDetailGrid extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String relationship;
  final String street;
  final String suiteApt;
  final String city;
  final String state;
  final String zipCode;
  final String phoneNumber;
  final String email;

  const _ContactDetailGrid({
    required this.firstName,
    required this.lastName,
    required this.relationship,
    required this.street,
    required this.suiteApt,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.phoneNumber,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _Pair('First Name:', firstName),
            const SizedBox(width: AppSize.s20),
            _Pair('Last Name:', lastName),
            const SizedBox(width: AppSize.s20),
            _Pair('Relationship:', relationship),
            const SizedBox(width: AppSize.s20),
            _Pair('Street:', street),
          ],
        ),
        const SizedBox(height: AppSize.s15),
        Row(
          children: [
            _Pair('Suite/Apt:', suiteApt),
            const SizedBox(width: AppSize.s20),
            _Pair('City:', city),
            const SizedBox(width: AppSize.s20),
            _Pair('State:', state),
            const SizedBox(width: AppSize.s20),
            _Pair('Zip Code:', zipCode),
          ],
        ),
        const SizedBox(height: AppSize.s15),
        Row(
          children: [
            _Pair('Phone Number:', phoneNumber),
            const SizedBox(width: AppSize.s20),
            _Pair('Email:', email),
            const SizedBox(width: AppSize.s20),
            const Expanded(child: SizedBox()),
            const SizedBox(width: AppSize.s20),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }
}

class _Pair extends StatelessWidget {
  final String label;
  final String value;
  const _Pair(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: FontSize.s11,
                fontWeight: FontWeight.w600,
                color: ColorManager.darkgrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: FontSize.s11,
                color: ColorManager.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}