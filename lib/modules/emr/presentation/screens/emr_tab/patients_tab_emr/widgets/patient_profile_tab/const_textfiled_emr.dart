import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/text_form_field_const.dart';

/// ✅ EMR-only textfield — clone of SchedularTextField with ONE fix:
/// the label-row spacer is IconSize.I20 in BOTH branches (icon shown or not),
/// so every field lines up at the same Y whether or not it has the info icon.
/// Only use this in EMR screens — SchedularTextField stays untouched for
/// intake/referral/everything else.
class EmrSchedularTextField extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  final TextStyle? textStyle;
  final Icon? suffixIcon;
  final Color textColor;
  final FormFieldValidator<String>? validator;
  final double? width;
  final ValueChanged<String>? onChanged;
  bool? phoneField;
  final FocusNode? focusNode;
  final bool? enable;
  final bool showDatePicker;
  final Icon? icon;
  final Widget? prefixWidget;
  final VoidCallback? onChange;
  final bool? isIconVisible;
  final double? borderRadius;
  final bool? onlyAllowNumbers;
  final bool allowSSNBR;
  final VoidCallback? isIClicked;
  final bool? isPasswordField;
  bool? isIconClicked;
  VoidCallback? iconClickedPress;
  final bool? dateFormateMMDDYYYY;

  EmrSchedularTextField({
    Key? key,
    this.dateFormateMMDDYYYY = false,
    this.iconClickedPress,
    this.isIconClicked = false,
    this.isIClicked,
    this.textColor = const Color(0xff686464),
    this.textStyle,
    this.isIconVisible = true,
    this.phoneField = false,
    required this.labelText,
    this.initialValue,
    this.controller,
    this.suffixIcon,
    this.validator,
    this.width,
    this.onChanged,
    this.focusNode,
    this.icon,
    this.onChange,
    this.enable,
    this.prefixWidget,
    this.showDatePicker = false,
    this.hintText,
    this.borderRadius,
    this.onlyAllowNumbers = false,
    this.allowSSNBR = false,
    this.isPasswordField = false,
  }) : super(key: key);

  @override
  _EmrSchedularTextFieldState createState() => _EmrSchedularTextFieldState();
}

class _EmrSchedularTextFieldState extends State<EmrSchedularTextField> {
  late TextEditingController _controller;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _obscureText = widget.isPasswordField ?? false;
    _controller.addListener(() {
      if (widget.onChanged != null) {
        widget.onChanged!(_controller.text);
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2031),
    );
    if (pickedDate != null) {
      widget.controller!.text = widget.dateFormateMMDDYYYY == false
          ? DateFormat('yyyy-MM-dd').format(pickedDate)
          : DateFormat('MM/dd/yyyy').format(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SmIntakeProviderManager>(
      builder: (context, providerState, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: widget.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(widget.labelText,
                          style: SMTextfieldHeadings.customTextStyle(context)),
                    ),
                    widget.isIconVisible!
                    // ✅ FIX: was SizedBox(height:7) in SchedularTextField —
                    //    now matches the icon branch's IconSize.I20 exactly.
                        ? const SizedBox(height: IconSize.I20)
                        : InkWell(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: widget.isIClicked,
                      child: SvgPicture.asset(
                        'images/sm/sm_refferal/i_circle.svg',
                        height: IconSize.I20,
                        width: IconSize.I20,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 5),
              InkWell(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: widget.showDatePicker ? () => _selectDate(context) : null,
                child: AbsorbPointer(
                  absorbing: widget.showDatePicker,
                  child: Container(
                    width: widget.width,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFB1B1B1), width: 1),
                      borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
                    ),
                    child: TextFormField(
                      focusNode: widget.focusNode,
                      autofocus: false,
                      enabled: widget.enable == null ? true : false,
                      controller: widget.controller,
                      obscureText: _obscureText,
                      onChanged: widget.onChanged,
                      cursorHeight: 17,
                      cursorColor: Colors.black,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        suffixIcon: widget.showDatePicker
                            ? GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Icon(Icons.calendar_month_outlined,
                              color: ColorManager.blueprime, size: IconSize.I22),
                        )
                            : widget.isPasswordField == true
                            ? GestureDetector(
                          child: Icon(
                            _obscureText
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: ColorManager.blueprime,
                            size: IconSize.I20,
                          ),
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        )
                            : widget.isIconClicked == true
                            ? InkWell(onTap: widget.iconClickedPress, child: widget.icon)
                            : widget.icon,
                        prefix: widget.prefixWidget,
                        prefixIcon: widget.suffixIcon,
                        hintText: widget.hintText,
                        prefixStyle: DropdownItemStyle.customTextStyle(context),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(bottom: AppPadding.p20, left: AppPadding.p10),
                      ),
                      style: widget.textStyle ??
                          TableSubHeading.customTextStyleWithColor(context, widget.textColor),
                      onTap: widget.onChange,
                      validator: widget.validator,
                      inputFormatters: widget.allowSSNBR == true
                          ? [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                      ]
                          : widget.phoneField == true
                          ? [PhoneNumberInputFormatter()]
                          : widget.onlyAllowNumbers == true
                          ? [FilteringTextInputFormatter.digitsOnly]
                          : [],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ✅ EMR-only dropdown — clone of CustomDropdownTextFieldsm with ONE fix:
/// added the missing IconSize.I20 spacer next to the head text (the original
/// had nothing there, which made its label row shorter than
/// EmrSchedularTextField's). Only use this in EMR screens.
class EmrDropdownTextFieldConst extends StatefulWidget {
  final String? value;
  final List<String>? items;
  final List<DropdownMenuItem<String>>? dropDownMenuList;
  final String? hintText;
  final String headText;
  final void Function(String?)? onChanged;
  final double? width;
  final double? widthone;
  final double? height;
  final String? initialValue;
  final bool? isIconVisible;
  final double? borderRadius;

  const EmrDropdownTextFieldConst({
    Key? key,
    this.dropDownMenuList,
    required this.headText,
    this.value,
    this.items,
    this.onChanged,
    this.width,
    this.widthone,
    this.height,
    this.initialValue,
    this.hintText,
    this.isIconVisible = true,
    this.borderRadius,
  }) : super(key: key);

  @override
  _EmrDropdownTextFieldConstState createState() => _EmrDropdownTextFieldConstState();
}

class _EmrDropdownTextFieldConstState extends State<EmrDropdownTextFieldConst> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value ?? widget.initialValue;
  }

  void _showDropdownDialog() async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: widget.width ?? size.width,
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.items?.length ?? widget.dropDownMenuList?.length ?? 0,
                      itemBuilder: (context, index) {
                        final item = widget.items != null
                            ? widget.items![index]
                            : widget.dropDownMenuList![index].value;
                        return ListTile(
                          title: Text(item!, style: DocumentTypeDataStyle.customTextStyle(context)),
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedValue = result;
        widget.onChanged?.call(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SmIntakeProviderManager>(
      builder: (context, providerState, child) {
        // ✅ FIX: wrapped in the same Padding(vertical: 4) that
        //    EmrSchedularTextField uses. Without it, the dropdown's whole
        //    label+box column sat 4px higher than sibling textfields in the
        //    same row — this is the "dropdown looks upside" offset.
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: widget.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(widget.headText, style: SMTextfieldHeadings.customTextStyle(context)),
                    ),
                    const SizedBox(height: 20, width: 20),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: widget.width,
                height: widget.height ?? AppSize.s30,
                child: GestureDetector(
                  onTap: _showDropdownDialog,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 3, top: 4, left: AppPadding.p10, right: AppPadding.p7),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedValue ?? widget.hintText ?? 'Select',
                          style: TableSubHeading.customTextStyleWithColor(context, const Color(0xff686464)),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Icon(Icons.arrow_drop_down_sharp, color: ColorManager.blueprime),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}