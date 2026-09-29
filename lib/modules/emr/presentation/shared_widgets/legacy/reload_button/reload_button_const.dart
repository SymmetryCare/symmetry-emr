import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/color.dart';

class ReloadIconButton extends StatelessWidget {
  const ReloadIconButton({
    super.key,
    required this.onTap,
    this.message = "Reload",
  });

  final VoidCallback onTap;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            border: Border.all(color: ColorManager.greyShade300),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.refresh_rounded,
            size: 20,
            color: ColorManager.bluebottom,
          ),
        ),
      ),
    );
  }
}

















//Demo
//
// DEMO LOG IN :-
//
// xegara9143@herojp.com  Office admin,  Pass :-sujata@123
//
// pquzf12814@minitts.net RN Per dime,  Pass :-  shubham@123 per diem ,
//
// yblnb84568@minitts.net RN , Pass :- shubham@123,  salaried employee
//
// mqdip51784@minitts.net PT, Pass :-  shubham@123,  per diem
//
// fdsfs65764@minitts.net  PT,  Pass :-  shubham@123 salaried employee
//
// lisisi8244@5nek.com QA coordinator,  Pass :- shubham@123
//
// doxiyan914@5nek.com coder,  Pass :-  shubham@123
//
// fameni5366@aspensif.com    Clinical manager,   Pass :- sujata@123
//
// jasegag961@herojp.com  QA manager,  Pass :-  sujata@123
//
// hasedo5540@5nek.com    DME,  Pass :-   sujata@123