import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> items;
  final String initialValue;
  final ValueChanged<String>? onChanged;

  const CustomDropdown({
    super.key,
    required this.items,
    this.initialValue = 'All',
    this.onChanged,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
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

    // Barrier inserted FIRST (below the dropdown)
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
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.items.map((e) {
              final isSelected = e == selected;
              return InkWell(
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.white,
                onTap: () {
                  setState(() => selected = e);
                  widget.onChanged?.call(e);
                  _closeDropdown();
                },
                child: Container(
                  width: size.width,
                  padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10, vertical: AppPadding.p12),
                  decoration: BoxDecoration(
                    color: isSelected ? ColorManager.SMFBlue: ColorManager.white,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    e,
                    style: TextStyle(
                      fontSize: FontSize.s12,
                      color: isSelected ? ColorManager.blueprime : ColorManager.mediumgrey,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
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
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: _toggleDropdown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p12, vertical: AppPadding.p4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selected,
                style: DocumentTypeDataStyle.customTextStyle(context),
              ),
              const SizedBox(width: AppSize.s10,),
              Icon(Icons.arrow_drop_down,
                  size: 20, color: ColorManager.mediumgrey),
            ],
          ),
        ),
      ),
    );
  }
}








class CustomDropdownhint extends StatefulWidget {
  final List<String> items;
  final String? initialValue;
  final String? hint;
  final ValueChanged<String>? onChanged;

  const CustomDropdownhint({
    super.key,
    required this.items,
    this.initialValue,
    this.hint,
    this.onChanged,
  });

  @override
  State<CustomDropdownhint> createState() => _CustomDropdownhintState();
}

class _CustomDropdownhintState extends State<CustomDropdownhint> {
  String? selected;
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.items.map((e) {
              final isSelected = e == selected;
              return InkWell(
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.white,
                onTap: () {
                  setState(() => selected = e);
                  widget.onChanged?.call(e);
                  _closeDropdown();
                },
                child: Container(
                  width: size.width,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    e,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.blue : Colors.grey.shade800,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
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
    final displayText = selected ?? widget.hint ?? '';

    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: _toggleDropdown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayText,
                style: TextStyle(
                  fontSize: 12,
                  color:  Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade700),
            ],
          ),
        ),
      ),
    );
  }
}