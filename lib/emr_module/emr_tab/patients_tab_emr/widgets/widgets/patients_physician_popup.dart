import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/popup_const_emr.dart';

import '../../../../../../../app/resources/color.dart';
import '../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../app/resources/value_manager.dart';
import '../../../../../../../app/services/api/managers/emr_module_manager/emr_patient_manager/patient_physician_manager.dart';
import '../../../../../../../data/api_data/emr_module_data/patient_tab_data/patient_physician_model.dart';

class PatientsPhysicianPopup extends StatelessWidget {
  final int ptId;
   PatientsPhysicianPopup({super.key, required this.ptId});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive horizontal padding:
    // - Mobile  (<600px wide):  5% each side
    // - Tablet  (600–900px):   10% each side
    // - Desktop (>900px):      clamp to max 300px or 20% each side
    final double horizontalPadding = screenWidth < 600
        ? screenWidth * 0.05
        : screenWidth < 900
        ? screenWidth * 0.10
        : (screenWidth * 0.20).clamp(0, 300);

    // Responsive vertical padding
    final double verticalPadding = screenHeight < 600
        ? screenHeight * 0.05
        : screenHeight < 900
        ? screenHeight * 0.10
        : (screenHeight * 0.15).clamp(0, 130);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: DialogueTemplateNoButtons(
        width: double.infinity,
        height: double.infinity,
        title: "Physicians",
        body: [
          FutureBuilder<List<PatientPhysicianModel>>(
            future: getEmrPatientPhysicians(
              context: context,
              patientId: ptId, // pass your patientId here
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSize.s150),
                  child:  Center(child: CircularProgressIndicator(
                    color: ColorManager.blueprime,
                  )),
                );
              }

              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No physicians found"));
              }

              final physicians = snapshot.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: physicians.map((p) => _PhysicianRow(
                  name: '${p.firstName.phyFirstName} ${p.lastName.phyLastName}',
                  phone: p.contact.phyContact,
                  address: '${p.street.phyStreet}, ${p.city.phyCity}, ${p.state.phyState} ${p.zipcode.phyZipCode}',
                  imageUrl: '',
                )).toList(),
              );
            },
          ),
        ],
      )
    );
  }
}

class _PhysicianRow extends StatelessWidget {
  final String name;
  final String phone;
  final String address;
  final String imageUrl;

  const _PhysicianRow({
    required this.name,
    required this.phone,
    required this.address,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 480;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
      child: isNarrow
          ? _buildNarrowLayout(context)
          : _buildWideLayout(context),
    );
  }

  /// Wide layout (tablets & desktops): avatar | name+phone | address in one row
  Widget _buildWideLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatar(),
        const SizedBox(width: AppSize.s12),
        Expanded(
          child: _buildNamePhone(),
        ),
        const SizedBox(width: AppSize.s8),
        _buildAddress(),
      ],
    );
  }

  /// Narrow layout (phones): avatar + name+phone stacked, address below
  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatar(),
            const SizedBox(width: AppSize.s12),
            Expanded(child: _buildNamePhone()),
          ],
        ),
        const SizedBox(height: AppSize.s4),
        Padding(
          padding: const EdgeInsets.only(left: AppSize.s12),
          child: _buildAddress(),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: AppSize.s24,
      backgroundColor: ColorManager.lightGrey,
      backgroundImage:
      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
      child: imageUrl.isEmpty
          ? Icon(Icons.person, size: AppSize.s24, color: ColorManager.grey)
          : null,
    );
  }

  Widget _buildNamePhone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: FontSize.s13,
            fontWeight: FontWeight.w600,
            color: ColorManager.darkgrey,
          ),
        ),
        const SizedBox(height: AppSize.s4),
        Row(
          children: [
            Icon(Icons.phone,
                size: AppSize.s12, color: ColorManager.blueprime),
            const SizedBox(width: AppSize.s4),
            Flexible(
              child: Text(
                phone,
                style: TextStyle(
                  fontSize: FontSize.s11,
                  color: ColorManager.blueprime,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddress() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on_outlined,
            size: AppSize.s14, color: ColorManager.blueprime),
        const SizedBox(width: AppSize.s4),
        Flexible(
          child: Text(
            address,
            style: TextStyle(
              fontSize: FontSize.s11,
              color: ColorManager.grey,
            ),
          ),
        ),
      ],
    );
  }
}