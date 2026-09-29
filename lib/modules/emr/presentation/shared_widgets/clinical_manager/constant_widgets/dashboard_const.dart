import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/emr_theme_const.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

class ConstClinicalCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  final Color bgColor;
  final Color titleColor;
  final VoidCallback onTap;

  const ConstClinicalCard({
    super.key,
    required this.title,
    required this.count,
    required this.color,
    required this.bgColor,
    required this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 100,
        child: GestureDetector(
          onTap: onTap,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: 6,
                decoration: BoxDecoration(
                  border:  Border(
                    top: BorderSide(
                      color: color,
                      width: 2,
                    ),
                  ),
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10)),
                ),
                child: Container(
                  height: 70,
                  width: constraints.maxWidth == double.infinity
                      ? double.infinity
                      : constraints.maxWidth,
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 16, bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                        width: 3,
                      ),
                      left: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      right: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            count,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal:12,vertical: 14),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: SvgPicture.asset("images/clinical/clinical_dashboard_icon.svg",color: color,),
                          ),

                    ],
                  ),
                ),
              );
            },
          ),
        ),
    );
  }
}



class CustomDropdownNoBorders extends StatefulWidget {
  final List<String> items;
  final String initialValue;
  final ValueChanged<String>? onChanged;

  const CustomDropdownNoBorders({
    super.key,
    required this.items,
    this.initialValue = '',
    this.onChanged,
  });

  @override
  State<CustomDropdownNoBorders> createState() => _CustomDropdownNoBordersState();
}

class _CustomDropdownNoBordersState extends State<CustomDropdownNoBorders> {
  late String selected;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  OverlayEntry? _barrierEntry;

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
  }

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
  }

  void _closeDropdown() {
    _barrierEntry?.remove();
    _barrierEntry = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _openDropdown();
    } else {
      _closeDropdown();
    }
  }

  void _openDropdown() {
    final overlayState = Overlay.of(context);

    _barrierEntry = OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeDropdown,
        child: Container(color: Colors.transparent),
      ),
    );

    _overlayEntry = _createOverlay();

    overlayState.insert(_barrierEntry!);
    overlayState.insert(_overlayEntry!);
  }

  OverlayEntry _createOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 4,
        width: size.width,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.items.map((e) {
              final isSelected = e == selected;
              return InkWell(
                splashColor:    Colors.transparent,
                hoverColor:     Colors.transparent,
                focusColor:     Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  setState(() => selected = e);
                  widget.onChanged?.call(e);
                  _closeDropdown();
                },
                child: Container(
                  width: size.width,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
                  ),
                  child: Text(
                    e,
                    style: EMRListViewHead.customTextStyle(context),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        splashColor:    Colors.transparent,
        hoverColor:     Colors.transparent,
        focusColor:     Colors.transparent,
        onTap: _toggleDropdown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected,
              style: EMRListViewHead.customTextStyle(context),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade700),
          ],
        ),
      ),
    );
  }
}


class DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isUnderline;

  const DetailItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.isUnderline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPadding.p20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: FontSize.s11,
                fontWeight: FontWeight.w600,
                color: ColorManager.darkgrey,
              ),
            ),
          ),
          const SizedBox(width: AppSize.s20),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: FontSize.s11,
                color: valueColor ?? ColorManager.grey,
                decoration: isUnderline ? TextDecoration.underline : TextDecoration.none,
                decorationColor: valueColor ?? ColorManager.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ClinicalAvatarWithBadge extends StatelessWidget {
  final String name;
  final String badgeText;
  final double radius;
  final Color badgeColor;
  final String circleImage;

  const ClinicalAvatarWithBadge({
    super.key,
    required this.name,
    required this.badgeText,
    this.radius = AppSize.s20,
    this.badgeColor = Colors.blueGrey,
    required this.circleImage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: circleImage.isNotEmpty
                ? Image.network(
              circleImage,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                "images/profilepic.png",
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            )
                : Image.asset(
              "images/profilepic.png",
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: -3,
          right: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(AppSize.s4),
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: Text(
              badgeText,
              style: const TextStyle(
                fontSize: FontSize.s7,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String label;
  final bool isExpanded;
  final VoidCallback onTap;

  const SectionHeader({
    required this.label,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p16, vertical: AppPadding.p12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: FontSize.s13,
                fontWeight: FontWeight.w600,
                color: ColorManager.darkgrey,
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: AppSize.s20,
              color: ColorManager.grey,
            ),
          ],
        ),
      ),
    );
  }
}
