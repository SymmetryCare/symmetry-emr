import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/theme_manager.dart';

class SmDialPadConst extends StatelessWidget {
  final String dialNumber;
  final VoidCallback onTaped;
  const SmDialPadConst({super.key, required this.dialNumber, required this.onTaped});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onTaped,
      child: Container(
        decoration:BoxDecoration(borderRadius: BorderRadius.circular(5),color:const Color(0xFFE9E9E9)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 9),
            child: Text(dialNumber,style: CustomTextStylesCommon.commonStyle(
                color:const Color(0xFF686464),
                fontWeight: FontWeight.w700,fontSize: 22),),
          ),
        ),
      ),
    );
  }
}
