import 'package:flutter/material.dart';

import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';

class EmrTextField extends StatelessWidget {
  final TextEditingController controller;
  final String?    hintText;
  final double?    height;
  final Widget?    suffixIcon;

  const EmrTextField({
    Key? key,
    required this.controller,
    this.hintText,
    this.height,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 35,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        cursorColor: Colors.black45,
        controller: controller,
        style: DocumentTypeDataStyle.customTextStyle(context),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          fillColor: Colors.white,
          hintText: hintText,
          hintStyle: DocumentTypeDataStyle.customTextStyle(context),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}