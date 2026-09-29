import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/dialogue_template.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';

class PatientsDataSummaryPopup extends StatelessWidget {
  const PatientsDataSummaryPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
        width: AppSize.s450, height: AppSize.s450,
        body: const [
          Padding(
            padding: EdgeInsets.only(left: 15.0),
            child: Text(
              'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.\nLorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.\nLorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.',
              softWrap: true,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ], bottomButtons: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomButtonTransparent(text: 'Cancle', onPressed: (){}),
      ],
    ), title: "AI Summary");
  }
}
