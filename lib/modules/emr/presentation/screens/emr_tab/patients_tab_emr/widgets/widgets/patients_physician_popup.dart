import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_patient_manager/patient_physician_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/patient_tab_data/patient_physician_model.dart';

class PatientsPhysicianPopup extends StatefulWidget {
  final int ptId;
   const PatientsPhysicianPopup({super.key, required this.ptId});

  @override
  State<PatientsPhysicianPopup> createState() => _PatientsPhysicianPopupState();
}

class _PatientsPhysicianPopupState extends State<PatientsPhysicianPopup> {
  static const double _kDesignWidth = 855;

  // ── Cached future — prevents refetch/rebuild loop on every build ──
  late Future<List<PatientPhysicianModel>> _physiciansFuture;

  @override
  void initState() {
    super.initState();
    _physiciansFuture = getEmrPatientPhysicians(
      context: context,
      patientId: widget.ptId,
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
    return DialogueTemplateNoButtons(
        width: 500,
        height: 350,
        title: "Physicians",
        body: [
          FutureBuilder<List<PatientPhysicianModel>>(
            future: _physiciansFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSize.s150),
                  child:  Center(child: CircularProgressIndicator(
                    color: ColorManager.blueprime,
                  )),
                );
              }

              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox(
                  height: AppSize.s200,
                  child: Center(child: Text("No physicians found!",
                  style: AllNoDataAvailable.customTextStyle(context))),
                );
              }
              final physicians = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: physicians.map((p) => _PhysicianRow(
                  name: '${p.firstName.phyFirstName} ${p.lastName.phyLastName}',
                  phone: p.contact.phyContact,
                  address: '${p.street.phyStreet}, ${p.city.phyCity}, ${p.state.phyState} ${p.zipcode.phyZipCode}',
                  imageUrl: p.profileUrl.phyUrl,
                )).toList(),
              );
            },
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
      child: _buildWideLayout(context),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatar(),
        const SizedBox(width: AppSize.s12),
        Expanded(
          flex: 2,
          child: _buildNamePhone(),
        ),
        const SizedBox(width: AppSize.s8),
        Expanded(
          flex: 3,
          child: _buildAddress(),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: AppSize.s24,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  'images/profilepic.png',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                'images/profilepic.png',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
      ),
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