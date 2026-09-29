import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';
class WaitingFtoFPopup extends StatelessWidget {
  const WaitingFtoFPopup({super.key});

  final List<Map<String, String>> _patients = const [
    {
      'name': 'Lucas Garcia',
      'mrn': 'MRN: 6596535454',
      'dob': '05/08/2001 | 24y',
      'socDate': '05/08/2025',
      'insurance': 'Medicare',
      'f2fWindow': 'Weakness',
      'primaryDx': 'Lorem Ipsum',
      'timelyFiling': '05/08/2025',
    },
    {
      'name': 'Daniel Johnson',
      'mrn': 'MRN: 6596535454',
      'dob': '05/08/2001 | 24y',
      'socDate': '05/08/2025',
      'insurance': 'Medicare',
      'f2fWindow': 'Vertigo',
      'primaryDx': 'Lorem Ipsum',
      'timelyFiling': '05/08/2025',
    },
    {
      'name': 'Richard Miller',
      'mrn': 'MRN: 6596535454',
      'dob': '05/08/2001 | 24y',
      'socDate': '05/08/2025',
      'insurance': 'Medicare',
      'f2fWindow': 'Dizziness',
      'primaryDx': 'Lorem Ipsum',
      'timelyFiling': '05/08/2025',
    },
    {
      'name': 'Joseph Davis',
      'mrn': 'MRN: 6596535454',
      'dob': '05/08/2001 | 24y',
      'socDate': '05/08/2025',
      'insurance': 'Medicare',
      'f2fWindow': 'Malaise',
      'primaryDx': 'Lorem Ipsum',
      'timelyFiling': '05/08/2025',
    },
    {
      'name': 'Lucas Garcia',
      'mrn': 'MRN: 6596535454',
      'dob': '05/08/2001 | 24y',
      'socDate': '05/08/2025',
      'insurance': 'Medicare',
      'f2fWindow': 'Vertigo',
      'primaryDx': 'Lorem Ipsum',
      'timelyFiling': '05/08/2025',
    },
    {
      'name': 'Lucas Garcia',
      'mrn': 'MRN: 6596535454',
      'dob': '05/08/2001 | 24y',
      'socDate': '05/08/2025',
      'insurance': 'Medicare',
      'f2fWindow': 'Vertigo',
      'primaryDx': 'Lorem Ipsum',
      'timelyFiling': '05/08/2025',
    },
    {
      'name': 'Lucas Garcia',
      'mrn': 'MRN: 6596535454',
      'dob': '05/08/2001 | 24y',
      'socDate': '05/08/2025',
      'insurance': 'Medicare',
      'f2fWindow': 'Vertigo',
      'primaryDx': 'Lorem Ipsum',
      'timelyFiling': '05/08/2025',
    },
  ];

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
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
    return DialogueTemplateCoder(
      title: 'Waiting for F2F',
      width: 1000,
      height: 800,
      body: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF8FC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const SizedBox(width: 52),
              _headerCell('Patient Name', flex: 3),
              _headerCell('SOC Date', flex: 2),
              _headerCell('Insurance', flex: 2),
              _headerCell('F2F Window', flex: 2),
              _headerCell('Primary Dx', flex: 2),
              _headerCell('Timely Filing deadline', flex: 2),
            ],
          ),
        ),
        const SizedBox(height: AppSize.s20,),
        // ✅ Fixed height container makes ListView scrollable without RenderFlex error
        Expanded(
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _patients.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              color: Color(0xFFEEEEEE),
            ),
            itemBuilder: (context, index) {
              final p = _patients[index];
              return Container(
                padding:  const EdgeInsets.only(top: AppPadding.p20,bottom: AppPadding.p10, left: AppPadding.p12,right: AppPadding.p12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5DEB3),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _getInitials(p['name']!),
                        style:  TextStyle(
                          fontSize: FontSize.s13,
                          fontWeight: FontWeight.w700,
                          color: ColorManager.granitegray,
                        ),
                      ),
                    ),

                    // Patient Name + MRN + DOB
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['name']!,
                            style:  TextStyle(
                              fontSize: FontSize.s13,
                              fontWeight: FontWeight.w600,
                              color: ColorManager.granitegray,
                            ),
                          ),
                          const SizedBox(height: AppSize.s5),
                          Text(
                            p['mrn']!,
                            style:  TextStyle(
                              fontSize: FontSize.s11,
                              fontWeight: FontWeight.w400,
                              color: ColorManager.granitegray,
                            ),
                          ),
                          const SizedBox(height: AppSize.s5),
                          Text(
                            p['dob']!,
                            style:  TextStyle(
                              fontSize: FontSize.s12,
                              fontWeight: FontWeight.w400,
                              color: ColorManager.granitegray,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _dataCell(p['socDate']!, flex: 2),
                    _dataCell(p['insurance']!, flex: 2),
                    _dataCell(p['f2fWindow']!, flex: 2),
                    _dataCell(p['primaryDx']!, flex: 2),
                    Expanded(
                      flex: 2,
                      child: Text(
                        p['timelyFiling']!,
                        textAlign: TextAlign.center,
                        style:  TextStyle(
                          fontSize: FontSize.s12,
                          fontWeight: FontWeight.w600,
                          color: ColorManager.granitegray,
                        ),
                      ),
                    )                  ],
                ),
              );
            },
          ),
        )

      ],
    );
  }

  Widget _headerCell(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style:  TextStyle(
          fontSize: FontSize.s13,
          fontWeight: FontWeight.w600,
          color: ColorManager.granitegray,
        ),
      ),
    );
  }

  Widget _dataCell(String value, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        style:  TextStyle(
          fontSize: FontSize.s12,
          fontWeight: FontWeight.w600,
          color: ColorManager.granitegray,
        ),
      ),
    );
  }
}