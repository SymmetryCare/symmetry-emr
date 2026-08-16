import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/popup_const_emr.dart';
import 'package:prohealth/presentation/screens/scheduler_model/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';

import '../../../../../../../app/resources/color.dart';
import '../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../app/resources/value_manager.dart';
import '../../../../../../../app/services/api/managers/sm_module_manager/intake/related_parties_manager.dart';
import '../../../../../../../data/api_data/sm_data/sm_intake_data/intake_demographics/related_parties_data.dart';

class PatientsEmergencyContactPopup extends StatelessWidget {
  final int ptId;
  const PatientsEmergencyContactPopup({super.key, required this.ptId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70.0, vertical: 60),
      child: DialogueTemplateNoButtons(
        width: double.infinity,
        height: double.infinity,
        title: "Emergency Contacts",
        body: [
          // ✅ Single FutureBuilder wrapping both sections
          FutureBuilder<List<EmergencyContactData>>(
            future: getPatientEmergencyContact(
              context: context,
              ptId: ptId,
            ),
            builder: (context, snapshot) {

              // ✅ Single loader for entire body
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSize.s150),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text("Failed to load contacts"));
              }

              final contacts = snapshot.data!;
              final emergencyContact = contacts.isNotEmpty ? contacts[0] : null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),

                  // ✅ Emergency Contact — API data
                  BlueBGHeadConst(
                    HeadText: "Emergency Contact",
                    body: contacts.isEmpty
                        ? const Center(child: Text("No emergency contact found"))
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return Column(
                          children: [
                            const SizedBox(height: AppSize.s18),
                            Padding(
                              padding: const EdgeInsets.only(left: 25.0),
                              child: _ContactDetailGrid(
                                firstName: contact.firstName.value,
                                lastName: contact.lastName.value,
                                relationship: contact.relationship.relationshipName,
                                street: contact.street.street,
                                suiteApt: contact.suite.suite,
                                city: contact.city.city,
                                state: contact.state.state,
                                zipCode: contact.zipcode.zipcode,
                                phoneNumber: contact.phoneNumber.value,
                                email: contact.email.value,
                              ),
                            ),
                            const SizedBox(height: AppSize.s18),
                            const Divider(height: 1, thickness: 1),
                            const SizedBox(height: AppSize.s12),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: AppSize.s15),

                  // ✅ Primary Caregiver — static data
                  BlueBGHeadConst(
                    HeadText: "Primary Caregiver",
                    body: Column(
                      children: [
                        const SizedBox(height: AppSize.s18),
                        Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: _ContactDetailGrid(
                            firstName: 'Chris',
                            lastName: 'Thompson',
                            relationship: 'Spouse',
                            street: '298, Farewell Ave',
                            suiteApt: '305',
                            city: 'Pleasanton',
                            state: 'CA',
                            zipCode: '98271',
                            phoneNumber: '408-256-5872',
                            email: '3bt@gmail.com',
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
        // Row 1: First Name | Last Name | Relationship | Street
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
        // Row 2: Suite/Apt | City | State | Zip Code
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
        // Row 3: Phone Number | Email | empty | empty
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