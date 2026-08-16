import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/value_manager.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/button_constant.dart';
import 'package:prohealth/presentation/screens/em_module/widgets/dialogue_template.dart';
import '../../../../../../em_module/company_identity/widgets/ci_corporate_compliance_doc/widgets/corporate_compliance_constants.dart';
import '../../../../../../em_module/widgets/header_content_const.dart';
import 'add_alert_sub_popup.dart';

class AddAlertPopup extends StatelessWidget {
  const AddAlertPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: AppSize.s350,
      height: AppSize.s350,
      title: "Add Alert",
      body: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: HeaderContentConst(
            isAsterisk: false,
            heading: "Select Alert Type",
            content: CICCDropdown(
              borderRadius: 8,
              initialValue: "Select Alert Type",
              onChange: (val) {},
              items: ['Safety', 'Medication', 'Infection Control', 'Vitals', 'Social', 'Legal', 'Nutrition']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: AppSize.s10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: HeaderContentConst(
            isAsterisk: false,
            heading: "Add Alert",
            content: CICCDropdown(
              borderRadius: 8,
              initialValue: "Add Alert",
              onChange: (val) {},
              items: ['High', 'Medium', 'Low']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
          ),
        ),
      ],
      bottomButtons: CustomElevatedButton(
        onPressed: () => showDialog(context: context, builder: (_) => const AddAlertSubPopup()),
        text: "Submit",
      ),
    );
  }
}