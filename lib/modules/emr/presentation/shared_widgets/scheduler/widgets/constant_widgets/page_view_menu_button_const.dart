import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
typedef void OnManuButtonTapCallBack(int index);

class PageViewMenuButtonConst extends StatefulWidget {
  PageViewMenuButtonConst({
    super.key,
    required this.onTap,
    required this.index,
    this.icon,
    required this.grpIndex,
    required this.heading,
    this.enabled = true,
   this.isSaved = false,
  });

  final OnManuButtonTapCallBack onTap;
  final int index;
  final IconData? icon;
  final int grpIndex;
  final String heading;
  final bool enabled;
  bool isSaved;

  @override
  State<PageViewMenuButtonConst> createState() => _PageViewMenuButtonConstState();
}

class _PageViewMenuButtonConstState extends State<PageViewMenuButtonConst> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SmIntakeProviderManager>(
      builder: (context,providerState,child) {
        return GestureDetector(
          onTap: widget.enabled ? () => widget.onTap(widget.index) : null,  // Only trigger onTap if enabled
          child: Opacity(
            opacity: widget.enabled ? 1.0 : 0.5,  // Dim the button if disabled
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centered
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Centered
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                     // SizedBox(width: 12,),
                      Text(
                        widget.heading,
                        style: TextStyle(
                          fontSize: providerState.isContactTrue && providerState.isLeftSidebarOpen == false ? FontSize.s13:FontSize.s14,
                          fontWeight: FontWeight.w700,
                          color: widget.grpIndex == widget.index
                              ? ColorManager.blueprime
                              : const Color(0xff686464),
                        ),
                      ),
                      const SizedBox(width: 8,),
                      widget.isSaved
                          ? Container(
                        height: 15,
                        width: 15,
                        child: Image.asset(
                          'images/sm/tick.png',
                          fit: BoxFit.contain,
                        ),
                      )
                          : const Offstage(),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centered
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: AppSize.s5,
                      width:providerState.isContactTrue ?AppSize.s120  :AppSize.s130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13.0),
                        color: widget.grpIndex == widget.index
                            ? ColorManager.blueprime
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

typedef OnClickableTap = Function();
typedef OnClickableHover = Function(bool val);

class MenuClickableWidget extends StatelessWidget {
  const MenuClickableWidget(
      {super.key,
        required this.onTap,
        required this.child,
        required this.onHover});
  final OnClickableTap onTap;
  final OnClickableHover onHover;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          onTap();
        },
        onHover: (value) {
          onHover(value);
        },
        focusColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: child);
  }
}
