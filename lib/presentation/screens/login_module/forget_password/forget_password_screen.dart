import 'package:flutter/material.dart';
import 'package:symmetry_emr/presentation/screens/login_module/forget_password/widgets/forget_password_mobile.dart';
import 'package:symmetry_emr/presentation/screens/login_module/forget_password/widgets/forget_password_tablet.dart';
import 'package:symmetry_emr/presentation/screens/login_module/forget_password/widgets/forget_password_web.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/responsive_screen.dart';


class ForgetPassword extends StatelessWidget {
  static const String routeName = "/forgetPassword";
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScreen(
        mobile: const ForgetPasswordMobile(),
        web: const ForgetPasswordWeb(),
        tablet: const ForgetPasswordTablet());
  }
}
