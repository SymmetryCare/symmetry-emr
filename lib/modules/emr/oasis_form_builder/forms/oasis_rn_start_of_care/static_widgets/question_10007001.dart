
import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/provider/question_wapper_provider.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/modules/emr/oasis_form_builder/widgets/reusable_widgets/wrapper_checkbox.dart';

class Question10007001 extends StatelessWidget {
  const Question10007001({super.key, required this.queWrapper});
  final QuestionWrapper queWrapper;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QuestionWrapper>.value(
      value: queWrapper,
      child: Consumer<QuestionWrapper>(builder: (context, que, ch) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...queWrapper.question.options!.map((option) {
              return
                QuestionCheckbox(
                  questionWrapper: que,
                  optionIndex: option.index,
                  isEnabled: option.index == 0
                      ? true
                      : !(queWrapper.question.options?[0].selected ?? false),
                );

                /*DynamicCheckboxElement(
                label: option.label,
                value: option.value,
                selected: option.selected,
                onTap: (bool value, index) {
                  queWrapper.toggleOption(index);
                },
                index: option.index,
                hint: option.hint,
                popupCode: option.popupCode,
                enabled: option.index == 0
                    ? true
                    : !(queWrapper.question.options?[0].selected ?? false),
                onPopupValueChange: (popupValue) {
                  queWrapper.updateTextFieldValue(option.index, popupValue);
                },
              );*/
            }),
          ],
        );
      }),
    );
  }
}
