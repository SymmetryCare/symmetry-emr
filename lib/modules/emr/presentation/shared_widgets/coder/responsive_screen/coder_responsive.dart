import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:symmetry_emr/app/resources/screen_route_name.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/coder/coder_dashboard/coder_desktop_screen.dart';

/// Entry point for the Coder role, mirroring [ResponsiveScreenQA] one
/// directory over: below the desktop breakpoint there is no coder-specific
/// tablet layout in this codebase (there never was one in the monolith
/// either), so narrow widths fall back to the same "rotate your device" SVG
/// every other role screen shows rather than rendering a desktop layout too
/// cramped to use.
///
/// Unlike QA, nothing here reaches for a GetX controller -- CoderDesktopScreen
/// and its tab bar manage their own selection through CoderProvider, already
/// registered in main.dart's MultiProvider.
class ResponsiveScreenCoder extends StatelessWidget {
  static String routeName = RouteStrings.coderDesktop;

  const ResponsiveScreenCoder({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return Padding(
            padding: MediaQuery.of(context).size.width > 1920
                ? EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 8)
                : EdgeInsets.zero,
            child: const CoderDesktopScreen(),
          );
        }
        return Material(
          color: Colors.white,
          child: Center(
            child: SvgPicture.asset(
              'images/tablet.svg',
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}
