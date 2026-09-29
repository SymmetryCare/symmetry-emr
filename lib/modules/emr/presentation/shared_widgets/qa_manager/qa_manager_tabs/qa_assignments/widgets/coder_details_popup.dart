import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/clinical_manager_manager/my_tasks_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/clinical_manager_data/my_tasks_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/clinical_manager/constant_widgets/dashboard_const.dart';

class CoderDetailsPopupQA extends StatefulWidget {
  final int coderId;
  const CoderDetailsPopupQA({super.key, required this.coderId});

  @override
  State<CoderDetailsPopupQA> createState() =>
      _CoderDetailsPopupQAState();
}

class _CoderDetailsPopupQAState extends State<CoderDetailsPopupQA> {
  EmployeeByIdData? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await getEmployeeById(context, widget.coderId);
    setState(() {
      _data = result;
      _isLoading = false;
    });
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso);
      return '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return '-';
    }
  }

  String _age(String? dob) {
    if (dob == null || dob.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dob);
      final age = DateTime.now().difference(dt).inDays ~/ 365;
      return age.toString();
    } catch (_) {
      return '-';
    }
  }

  String _hireDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      final years = diff.inDays ~/ 365;
      final months = (diff.inDays % 365) ~/ 30;
      final formatted =
          '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}/${dt.year}';
      return '$formatted (${years.toString().padLeft(2, '0')} Y ${months.toString().padLeft(2, '0')} M)';
    } catch (_) {
      return '-';
    }
  }

  String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0].toUpperCase() : '';
    final l = last.isNotEmpty ? last[0].toUpperCase() : '';
    return '$f$l';
  }

  static const double _kDesignWidth = 855;
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
      width: AppSize.s700,
      height: AppSize.s400,
      title: "Coder Details",
      body: [
        if (_isLoading)
          const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_data == null)
          const SizedBox(
            height: 300,
            child: Center(child: Text('Failed to load coder details')),
          )
        else
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top section ─────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar + initials badge

                        Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0E0E0),
                            shape: BoxShape.circle,
                          ),
                          child: _data!.imgurl.isNotEmpty
                              ? ClipOval(
                            child: Image.network(
                              _data!.imgurl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                  Icons.person,
                                  size: AppSize.s40,
                                  color: Colors.grey.shade500),
                            ),
                          )
                              : Icon(Icons.person,
                              size: AppSize.s40,
                              color: Colors.grey.shade500),
                        ),


                    const SizedBox(width: AppSize.s80),

                    // Name + Employment + Location
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_data!.firstName.toUpperCase()} ${_data!.lastName.toUpperCase()}',
                            style: TextStyle(
                              fontSize: FontSize.s14,
                              fontWeight: FontWeight.w700,
                              color: ColorManager.darkgrey,
                            ),
                          ),
                          const SizedBox(height: AppSize.s4),
                          Row(
                            children: [
                              Text(
                                'Employment Type',
                                style: TextStyle(
                                  fontSize: FontSize.s11,
                                  color: ColorManager.grey,
                                ),
                              ),
                              const SizedBox(width: AppSize.s8),
                              Text(
                                _data!.employment.isNotEmpty
                                    ? _data!.employment
                                    : '-',
                                style: TextStyle(
                                  fontSize: FontSize.s11,
                                  fontWeight: FontWeight.w600,
                                  color: ColorManager.darkgrey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSize.s4),
                          Text(
                            _data!.address.isNotEmpty ? _data!.address : '-',
                            style: TextStyle(
                              fontSize: FontSize.s11,
                              color: ColorManager.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Expanded(child: SizedBox()),

                    SvgPicture.asset(
                      "images/sm/contact_sv.svg",
                      height: AppSize.s40,
                      width: AppSize.s40,
                    ),

                    const SizedBox(width: AppSize.s100),
                  ],
                ),

                const SizedBox(height: AppSize.s16),

                // ── Detail grid ──────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DetailItem(
                            label: 'Age:',
                            value:
                            '${_formatDate(_data!.dateOfBirth)} (${_age(_data!.dateOfBirth)})',
                          ),
                          DetailItem(
                            label: 'Gender:',
                            value: _data!.gender.isNotEmpty
                                ? _data!.gender
                                : '-',
                          ),
                          DetailItem(
                            label: 'Social Security No.:',
                            value: _data!.ssnNbr.isNotEmpty
                                ? _data!.ssnNbr
                                : '-',
                          ),
                          DetailItem(
                            label: 'Phone Number:',
                            value: _data!.primaryPhoneNbr.isNotEmpty
                                ? _data!.primaryPhoneNbr
                                : '-',
                          ),
                          DetailItem(
                            label: 'Personal Email:',
                            value: _data!.personalEmail.isNotEmpty
                                ? _data!.personalEmail
                                : '-',
                            valueColor: ColorManager.blueprime,
                            isUnderline: true,
                          ),
                          DetailItem(
                            label: 'Service:',
                            value: _data!.service.isNotEmpty
                                ? _data!.service
                                : '-',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: AppSize.s30),

                    // Right column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DetailItem(
                            label: 'Speciality:',
                            value: _data!.expertise.isNotEmpty
                                ? _data!.expertise
                                : '-',
                          ),
                          DetailItem(
                            label: 'Service:',
                            value: _data!.service.isNotEmpty
                                ? _data!.service
                                : '-',
                          ),
                          DetailItem(
                            label: 'Reporting Office:',
                            value: _data!.regOfficId.isNotEmpty
                                ? _data!.regOfficId
                                : '-',
                          ),
                          DetailItem(
                            label: 'Summary:',
                            value: _data!.summary.isNotEmpty
                                ? _data!.summary
                                : '-',
                          ),
                          DetailItem(
                            label: 'Hire Date:',
                            value: _hireDate(_data!.dateofHire),
                          ),
                          DetailItem(
                            label: 'Rating:',
                            value: _data!.rating.isNotEmpty
                                ? _data!.rating
                                : '-',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}