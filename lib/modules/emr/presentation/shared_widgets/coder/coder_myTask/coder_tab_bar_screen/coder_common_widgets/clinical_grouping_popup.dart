import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';

class ClinicalGroupingPopup extends StatelessWidget {
  const ClinicalGroupingPopup({super.key});

  final List<Map<String, String>> _clinicalGroups = const [
    {'id':'3','name': 'MS Rehab',                  'percent': '19.6%'},
    {'id':'1','name': 'Wounds',                    'percent': '11.0%'},
    {'id':'5','name': 'MFRA - Cardiac & Circulatory', 'percent': '11.0%'},
    {'id':'12','name': 'MFRA - Other',              'percent': '10.8%'},
    {'id':'2','name': 'Neu to / Stroke',           'percent': '10.6%'},
    {'id':'11','name': 'MFRA - Amputation',         'percent': '10%'},
    {'id':'6','name': 'MFRA - Respiratory',        'percent': '10%'},
    {'id':'7','name': 'MFRA - Infectious Disease', 'percent': '10%'},
    {'id':'8','name': 'MFRA - Skeletal Aftercare', 'percent': '3.7%'},
    {'id':'4','name': 'Extensive Burns',           'percent': '1.8%'},
    {'id':'9','name': 'Extensive MFRA',            'percent': '1.0%'},
    {'id':'10','name': 'Behavioral MFRA',           'percent': '1.0%'},
  ];
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
      width: 400,
      height: 500,
      title: 'Clinical Grouping',
      body: [

        // Scrollable List
        Expanded(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _clinicalGroups.length,
            itemBuilder: (context, index) {
              final item = _clinicalGroups[index];
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFF0F0F0)),
                  ),
                ),
                child: Row(
                  children: [
                    // Serial Number
                    SizedBox(
                      width: 24,
                      child: Text(
                        item['id']!,
                        style: TextStyle(
                          fontSize: FontSize.s12,
                          fontWeight: FontWeight.w600,
                          color: ColorManager.granitegray,
                        ),
                      ),
                    ),
                    // Group Name
                    Expanded(
                      flex: 8,
                      child: Text(
                        item['name']!,
                        style:  TextStyle(
                          fontSize: FontSize.s12,
                          color: ColorManager.granitegray,
                        ),
                      ),
                    ),
                    // Percentage
                    Expanded(
                      child: Text(
                        item['percent']!,
                        textAlign: TextAlign.start,
                        style:  TextStyle(
                          fontSize: FontSize.s12,
                          fontWeight: FontWeight.w600,
                          color: ColorManager.granitegray,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
