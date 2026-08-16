import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/dialogue_template.dart';
import 'package:prohealth/presentation/screens/hr_module/manage/widgets/custom_icon_button_constant.dart';

import '../../../../../../../../app/resources/color.dart';
import '../../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../../app/resources/value_manager.dart';
import '../../../../../../em_module/widgets/button_constant.dart';

class EditAllergiesPopup extends StatefulWidget {
  const EditAllergiesPopup({super.key});

  @override
  State<EditAllergiesPopup> createState() => _EditAllergiesPopupState();
}

class _EditAllergiesPopupState extends State<EditAllergiesPopup> {
  final List<Map<String, dynamic>> _allergies = [
    {'name': 'Penicillin', 'sub': 'rash', 'checked': false},
    {'name': 'Latex', 'sub': 'rash', 'checked': true},
  ];

  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _reactionController = TextEditingController();

  @override
  void dispose() {
    _allergyController.dispose();
    _startDateController.dispose();
    _reactionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDateController.text =
        '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 80.0,horizontal: 200),
        child: DialogueTemplate(width: double.infinity, height:  double.infinity,
      title: "Edit Allergies",
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: IntrinsicHeight(
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left: Current Allergies ──────────────────────────────
              SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Allergies',
                      style: TextStyle(
                        fontSize: FontSize.s12,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.darkgrey,
                      ),
                    ),
                    const SizedBox(height: AppSize.s15),

                    // Allergy list
                    ..._allergies.asMap().entries.map((e) {
                      final index = e.key;
                      final item = e.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSize.s8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: AppSize.s18,
                              height: AppSize.s18,
                              child: Checkbox(
                                value: item['checked'],
                                onChanged: (val) => setState(
                                        () => _allergies[index]['checked'] = val),
                                activeColor: ColorManager.blueprime,
                                materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                side: BorderSide(
                                    color: ColorManager.mediumgrey, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(AppSize.s2),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSize.s6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: TextStyle(
                                      fontSize: FontSize.s12,
                                      fontWeight: FontWeight.w500,
                                      color: ColorManager.darkgrey,
                                    ),
                                  ),
                                  SizedBox(height: AppSize.s10,),
                                  Text(
                                    item['sub'],
                                    style: TextStyle(
                                      fontSize: FontSize.s11,
                                      color: ColorManager.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Delete icon (only for checked items)
                            if (item['checked'] == true)
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _allergies.removeAt(index)),
                                child: Icon(Icons.delete_outline,
                                    size: IconSize.I18, color: ColorManager.grey),
                              ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: AppSize.s16),

                    // Run Interactions button
                    CustomElevatedButton(
                      width: 120,
                      onPressed: (){},
                      text: "Run Interactions",
                      style: TextStyle(fontSize: FontSize.s12,fontWeight: FontWeight.w600,color: ColorManager.white),
                    ),
                  ],
                ),
              ),

              // ── Divider ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
                child: VerticalDivider(
                    width: 1, thickness: 1, color: Colors.grey.shade300),
              ),

              Expanded(flex: 1,child: Container()),
              // ── Right: Form fields ────────────────────────────────────
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Allergy field
                    _FormField(
                      label: 'Allergy*',
                      child: TextField(
                        controller: _allergyController,
                        style: TextStyle(
                            fontSize: FontSize.s12, color: ColorManager.darkgrey),
                        decoration: _inputDecoration(
                            'type allergy and select from list'),
                      ),
                    ),
                    const SizedBox(height: AppSize.s12),

                    // Start Date field
                    _FormField(
                      label: 'Start Date*',
                      child: TextField(
                        controller: _startDateController,
                        readOnly: true,
                        onTap: _pickDate,
                        style: TextStyle(
                            fontSize: FontSize.s12, color: ColorManager.darkgrey),
                        decoration: _inputDecoration('mm/dd/yyyy').copyWith(
                          suffixIcon: Icon(Icons.calendar_month_outlined,
                              size: AppSize.s16, color: ColorManager.blueprime),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSize.s12),

                    // Reaction field
                    _FormField(
                      label: 'Reaction*',
                      child: TextField(
                        controller: _reactionController,
                        style: TextStyle(
                            fontSize: FontSize.s12, color: ColorManager.darkgrey),
                        decoration: _inputDecoration('type text'),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(flex: 1,child: Container()),
            ],
          ),
          ),
        ),
      ],
      bottomButtons: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomButtonTransparent(
              text: "Cancel", onPressed: () => Navigator.pop(context)),
          const SizedBox(width: AppSize.s12),
          CustomElevatedButton(
            onPressed: () {},
            text: "Save",
          ),
          const SizedBox(width: AppSize.s12),
          CustomElevatedButton(
            width: 200,
            onPressed: () {},
            text: "Save & Add Additional",
          ),
          SizedBox(width: 100,),
        ],
      ),)
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
      TextStyle(fontSize: FontSize.s12, color: ColorManager.mediumgrey),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppPadding.p10, vertical: AppPadding.p4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.s6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.s6),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.s6),
        borderSide: BorderSide(color: ColorManager.blueprime, width: 1.5),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 90,
          height: 15,
          child: Text(
            label,
            style: TextStyle(
              fontSize: FontSize.s12,
              fontWeight: FontWeight.w500,
              color: ColorManager.darkgrey,
            ),
          ),
        ),
        const SizedBox(width: AppSize.s8),
        Expanded(child: child),
      ],
    );
  }
}