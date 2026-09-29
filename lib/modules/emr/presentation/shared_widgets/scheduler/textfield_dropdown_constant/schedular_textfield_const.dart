import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:intl/intl.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/text_form_field_const.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';


class SchedularTextField extends StatefulWidget {
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
  final bool isDOB;

   SchedularTextField({
    Key? key,
     this.dateFormateMMDDYYYY = false,
     this.isDOB = false,
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
    this.suffixIcon, this.validator, this.width,
    this.onChanged,
     this.focusNode,
     this.icon,
     this.onChange,
     this.enable,
     this.prefixWidget,
     this.showDatePicker = false, this.hintText,this.borderRadius,
     this.onlyAllowNumbers = false,
     this.allowSSNBR = false,
     this.isPasswordField = false,
  }) : super(key: key);

  @override
  _SchedularTextFieldState createState() => _SchedularTextFieldState();
}

class _SchedularTextFieldState extends State<SchedularTextField> {
  late TextEditingController _controller;
  bool _obscureText = false;
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _obscureText = widget.isPasswordField ?? false;
    // If onChanged is provided, listen to controller changes
    _controller.addListener(() {
      if (widget.onChanged != null) {
        widget.onChanged!(_controller.text); // Trigger the onChanged callback
      }
    });
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(1900),
      lastDate: widget.isDOB ? today : DateTime(2031),
    );
    if (pickedDate != null) {
      widget.controller!.text = widget.dateFormateMMDDYYYY == false ? DateFormat('yyyy-MM-dd').format(pickedDate) : DateFormat('MM/dd/yyyy').format(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      Consumer<SmIntakeProviderManager>(
        builder: (context,providerState,child) {
          return Padding(
            padding:  const EdgeInsets.symmetric(vertical: 4),
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
                            style:SMTextfieldHeadings.customTextStyle(context),
                        ),
                      ),
                      widget.isIconVisible!? const SizedBox(height:7) :
                      InkWell(
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
                const SizedBox(
                  height: 5,
                ),
                InkWell(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap:widget.showDatePicker ? ()=> _selectDate(context):null,
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
                          child: Icon(Icons.calendar_month_outlined,color: ColorManager.blueprime,size: IconSize.I22,),
                        )
                            : widget.isPasswordField == true
                            ? GestureDetector(
                          child: Icon(
                            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: ColorManager.blueprime,
                            size: IconSize.I20,
                          ),
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        )
                            : widget.isIconClicked == true ? InkWell(
                          onTap: widget.iconClickedPress,
                          child: widget.icon,
                        ) :widget.icon,
                        prefix: widget.prefixWidget,
                        prefixIcon: widget.suffixIcon,
                        hintText: widget.hintText,
                        prefixStyle: DropdownItemStyle.customTextStyle(context),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(bottom:AppPadding.p20, left: AppPadding.p10),
                      ),
                      style: widget.textStyle ?? TableSubHeading.customTextStyleWithColor(context,widget.textColor),
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
        }
      );
  }
}



class SchedularTextFieldcheckbox extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
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
  // ✅ New checkbox-related props
  final bool initialCheckboxValue;
  final ValueChanged<bool?>? onCheckboxChanged;


  SchedularTextFieldcheckbox({
    Key? key,
    this.phoneField = false,
    required this.labelText,
    this.textColor = const Color(0xff686464),
    this.initialValue,
    this.controller,
    this.suffixIcon, this.validator, this.width,
    this.onChanged,
    this.focusNode,
    this.icon,
    this.onChange,
    this.enable,
    this.prefixWidget,
    this.showDatePicker = false, this.hintText,
    ///
    this.initialCheckboxValue = false,
    this.onCheckboxChanged,
  }) : super(key: key);

  @override
  _SchedularTextFieldcheckboxState createState() => _SchedularTextFieldcheckboxState();
}

class _SchedularTextFieldcheckboxState extends State<SchedularTextFieldcheckbox> {
  late TextEditingController _controller;
  bool? _checkboxValue;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _checkboxValue = widget.initialCheckboxValue;

    // If onChanged is provided, listen to controller changes
    _controller.addListener(() {
      if (widget.onChanged != null) {
        widget.onChanged!(_controller.text); // Trigger the onChanged callback
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
      widget.controller!.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      Consumer<SmIntakeProviderManager>(
        builder: (context,providerState,child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    splashRadius: 0,
                    value: _checkboxValue,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _checkboxValue = newValue;
                      });
                      if (widget.onCheckboxChanged != null) {
                        widget.onCheckboxChanged!(newValue);
                      }
                    },
                  ),
                  const SizedBox(width: 2,),
                  Flexible(
                    child: Text(
                        widget.labelText,
                        style: providerState.isContactTrue ? SMTextfieldResponsiveHeadings.customTextStyle(context) : SMTextfieldHeadings.customTextStyle(context)
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2,),
              Padding(
                padding: const EdgeInsets.only(left: 33),
                child: InkWell(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap:widget.showDatePicker ? _checkboxValue == false ?(){}:()=> _selectDate(context):null,
                  child: IgnorePointer(
                    ignoring: _checkboxValue == false,
                    child: AbsorbPointer(
                      absorbing: widget.showDatePicker,
                      child: Container(
                        width: widget.width,
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFB1B1B1), width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                          focusNode: widget.focusNode,
                          autofocus: true,
                          enabled: widget.enable ?? false,
                          controller: widget.controller,
                          cursorHeight: 17,
                          cursorColor: Colors.black,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            suffixIcon: widget.showDatePicker
                                ? _checkboxValue == false ?GestureDetector(
                              onTap: (){},
                              child: Icon(Icons.calendar_month_outlined,color: ColorManager.grey,size: IconSize.I22,),
                            ) :GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Icon(Icons.calendar_month_outlined,color: ColorManager.blueprime,size: IconSize.I22,),
                            )
                                : widget.icon,
                            prefix: widget.prefixWidget,
                            prefixIcon: widget.suffixIcon,
                            hintText: widget.hintText,
                            hintStyle:TableSubHeading.customTextStyleWithColor(context,widget.textColor),

                            prefixStyle:TableSubHeading.customTextStyleWithColor(context,widget.textColor),// AllHRTableData.customTextStyle(context),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(bottom: 12, top: 2, left: AppPadding.p15),
                          ),
                          style:TableSubHeading.customTextStyleWithColor(context,widget.textColor),// TableSubHeading.customTextStyle(context),
                          onTap: widget.onChange,
                          validator: widget.validator,
                          inputFormatters: widget.phoneField! ? [
                            PhoneNumberInputFormatter()
                          ]: [],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      );
  }
}

class SchedularTextFieldno extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  final Icon? suffixIcon;
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


  SchedularTextFieldno({
    Key? key,
    this.phoneField = false,
    required this.labelText,
    this.initialValue,
    this.controller,
    this.suffixIcon, this.validator, this.width,
    this.onChanged,
    this.focusNode,
    this.icon,
    this.onChange,
    this.enable,
    this.prefixWidget,
    this.showDatePicker = false, this.hintText,
  }) : super(key: key);

  @override
  _SchedularTextFieldnoState createState() => _SchedularTextFieldnoState();
}

class _SchedularTextFieldnoState extends State<SchedularTextFieldno> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);

    // If onChanged is provided, listen to controller changes
    _controller.addListener(() {
      if (widget.onChanged != null) {
        widget.onChanged!(_controller.text); // Trigger the onChanged callback
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
      widget.controller!.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      Padding(
        padding:  const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                    widget.labelText,
                    style: SMTextfieldHeadings.customTextStyle(context)
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            InkWell(
              onTap:widget.showDatePicker ? ()=> _selectDate(context):null,
              child: AbsorbPointer(
                absorbing: widget.showDatePicker,
                child: Container(
                  width: widget.width,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFB1B1B1), width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    focusNode: widget.focusNode,
                    autofocus: true,
                    enabled: widget.enable == null ? true : false,
                    controller: widget.controller,
                    cursorHeight: 17,
                    cursorColor: Colors.black,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      suffixIcon: widget.showDatePicker
                          ? GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Icon(Icons.calendar_month_outlined,color: ColorManager.blueprime,size: 18,),
                      )
                          : widget.icon,
                      prefix: widget.prefixWidget,
                      prefixIcon: widget.suffixIcon,
                      hintText: widget.hintText,
                      prefixStyle: AllHRTableData.customTextStyle(context),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(bottom:20, left: AppPadding.p15),
                    ),
                    style: TableSubHeading.customTextStyle(context),
                    onTap: widget.onChange,
                    validator: widget.validator,
                    inputFormatters: widget.phoneField! ? [
                      PhoneNumberInputFormatter()
                    ]: [],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }
}
