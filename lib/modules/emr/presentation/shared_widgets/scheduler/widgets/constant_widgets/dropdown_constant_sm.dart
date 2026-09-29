import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

class CustomDropdownTextFieldsm extends StatefulWidget {
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

  const CustomDropdownTextFieldsm({
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
    this.hintText, this.isIconVisible = true, this.borderRadius,
  }) : super(key: key);

  @override
  _CustomDropdownTextFieldsmState createState() =>
      _CustomDropdownTextFieldsmState();
}

class _CustomDropdownTextFieldsmState extends State<CustomDropdownTextFieldsm> {
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
                  constraints: const BoxConstraints(
                    maxHeight: 250, // Restrict height for scroll
                  ),
                  child: SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.items?.length ?? widget.dropDownMenuList?.length ?? 0,
                      itemBuilder: (context, index) {
                        final item = widget.items != null
                            ? widget.items![index]
                            : widget.dropDownMenuList![index].value;
                        return ListTile(
                          title: Text(
                            item!,
                            style: DocumentTypeDataStyle.customTextStyle(context),
                          ),
                          onTap: () {
                            Navigator.of(context).pop(item);
                          },
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
      builder: (context,providerState,child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: widget.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                        widget.headText,
                        style:SMTextfieldHeadings.customTextStyle(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              width: widget.width ?? null,
              height:widget.height ?? AppSize.s30,
              child: GestureDetector(
                onTap: _showDropdownDialog,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 3, top: 4, left: AppPadding.p10,right: AppPadding.p7),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedValue ?? widget.hintText ?? 'Select',
                        style: TableSubHeading.customTextStyleWithColor(context,const Color(0xff686464)),// TableSubHeading.customTextStyle(context),//DocumentTypeDataStyle.customTextStyle(context),
                      ),
                      Icon(Icons.arrow_drop_down_sharp, color: ColorManager.blueprime,),
                    ],
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


///referal
class SmDropdownConst extends StatefulWidget {
  final String? value;
  final List<String>? items;
  final List<DropdownMenuItem<String>>? dropDownMenuList;
  final String? hintText;
  final String headText;
  final void Function(String?)? onChanged;
  final double? width;
  final double? height;
  final FontWeight? fontwight;
  final double? fontsize;
  final String? initialValue;
  final bool? isAstric;
  final IconData? icon;
  final Color? iconColor;

  const SmDropdownConst({
    Key? key,
    this.isAstric = true,
    this.dropDownMenuList,
    required this.headText,
    this.value,
    this.items,
    this.onChanged,
    this.width,
    this.height,
    this.initialValue,
    this.hintText, this.fontsize,
    this.icon, this.iconColor, this.fontwight,
  }) : super(key: key);

  @override
  _SmDropdownConstState createState() =>
      _SmDropdownConstState();
}

class _SmDropdownConstState extends State<SmDropdownConst> {
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
                  constraints: const BoxConstraints(
                    maxHeight: 250, // Restrict height for scroll
                  ),
                  child: SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.items?.length ?? widget.dropDownMenuList?.length ?? 0,
                      itemBuilder: (context, index) {
                        final item = widget.items != null
                            ? widget.items![index]
                            : widget.dropDownMenuList![index].value;
                        return ListTile(
                          title: Text(
                            item!,
                            style: DocumentTypeDataStyle.customTextStyle(context),
                          ),
                          onTap: () {
                            Navigator.of(context).pop(item);
                          },
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.isAstric!?Padding(
          padding: const EdgeInsets.only(left: 5.0, bottom: 2),
          child: RichText(
            text: TextSpan(
              text: widget.isAstric!?widget.headText:"", // Main text
              style: AllPopupHeadings.customTextStyle(context), // Main style
              children: [
                widget.isAstric!? TextSpan(
                  text: ' *', // Asterisk
                  style: AllPopupHeadings.customTextStyle(context).copyWith(
                    color: ColorManager.red, // Asterisk color
                  ),
                ):const TextSpan(
                  text: ' ', // Asterisk
                )
              ],
            ),
          ),
        )
            :const Offstage(),
        SizedBox(
          width: widget.isAstric!?AppSize.s250:widget.width,
          height: AppSize.s40,
          child: GestureDetector(
            onTap: _showDropdownDialog,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Container(
                padding: const EdgeInsets.only(bottom: 3, top: 5, left: 4),
                decoration:widget.isAstric!? BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 1), // Applies to all sides
                  borderRadius: BorderRadius.circular(10),
                )
                    :BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 1), // Applies to all sides
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0,vertical: 3),
                        child: Text(
                            _selectedValue ?? widget.hintText ?? 'Select',
                            style: TextStyle(
                              fontWeight:widget.fontwight ?? FontWeight.w600,
                              fontSize: widget.fontsize ?? FontSize.s13,
                              color: ColorManager.mediumgrey,
                              decoration: TextDecoration.none,
                            ) //DocumentTypeDataStyle.customTextStyle(context),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(widget.icon ?? Icons.arrow_drop_down_sharp, color: widget.iconColor ?? ColorManager.mediumgrey,size: IconSize.I22,),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


///filter by
class FilterBy extends StatefulWidget {
  final List<Widget> body;
  final String? value;
  final List<String>? items;
  final List<DropdownMenuItem<String>>? dropDownMenuList;
  final String? hintText;
 final String? headText;
  final void Function(String?)? onChanged;
  final double? width;
  final double? widthone;
  final double? height;
  final String? initialValue;
  final bool? isIconVisible;
  final double? borderRadius;
  const FilterBy ({
    Key? key,
    this.dropDownMenuList,
     this.headText,
    this.value,
    this.items,
    this.onChanged,
    this.width,
    this.widthone,
    this.height,
    this.initialValue,
    this.hintText, this.isIconVisible = true, this.borderRadius,required this.body,
  }): super(key:key);

  @override
  State<FilterBy> createState() => _FilterByState();
}

class _FilterByState extends State<FilterBy> {


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
                color: ColorManager.white,
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                  child: Container(
                    width: 400,
                   height: 300,
                    child:  ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                      child: SingleChildScrollView(
                      child: Column(
                        children: widget.body,
                      ),
                      )
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );


  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      width: 150,

      child: GestureDetector(
        onTap: _showDropdownDialog,
        child: Container(
          padding: const EdgeInsets.only(bottom: 3, top: 5, left: 4),
          decoration:
          BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1), // Applies to all sides
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0,vertical: 3),
                  child: Text(
                      'Filter by',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize:FontSize.s13,
                        color: ColorManager.mediumgrey,
                        decoration: TextDecoration.none,
                      ) //DocumentTypeDataStyle.customTextStyle(context),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon( Icons.arrow_drop_down_sharp, color:  ColorManager.mediumgrey,size: IconSize.I22,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


///small item box dropdown

class CustomDropdownSmallBoxSm extends StatefulWidget {
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

  const CustomDropdownSmallBoxSm({
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
    this.hintText, this.isIconVisible = true, this.borderRadius,
  }) : super(key: key);

  @override
  _CustomDropdownSmallBoxSmState createState() =>
      _CustomDropdownSmallBoxSmState();
}

class _CustomDropdownSmallBoxSmState extends State<CustomDropdownSmallBoxSm> {
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
                  constraints: const BoxConstraints(
                    maxHeight: 150, // Restrict height for scroll
                  ),
                  child: SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.items?.length ?? widget.dropDownMenuList?.length ?? 0,
                      itemBuilder: (context, index) {
                        final item = widget.items != null
                            ? widget.items![index]
                            : widget.dropDownMenuList![index].value;
                        return ListTile(
                          title: Text(
                            item!,
                            style: DocumentTypeDataStyle.customTextStyle(context),
                          ),
                          onTap: () {
                            Navigator.of(context).pop(item);
                          },
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
        builder: (context,providerState,child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: widget.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        widget.headText,
                        style:SMTextfieldHeadings.customTextStyle(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                width: widget.width ?? null,
                height:widget.height ?? AppSize.s30,
                child: GestureDetector(
                  onTap: _showDropdownDialog,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 3, top: 4, left: AppPadding.p10,right: AppPadding.p7),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedValue ?? widget.hintText ?? 'Select',
                          style: TableSubHeading.customTextStyleWithColor(context,const Color(0xff686464)),// TableSubHeading.customTextStyle(context),//DocumentTypeDataStyle.customTextStyle(context),
                        ),
                        Icon(Icons.arrow_drop_down_sharp, color: ColorManager.blueprime,),
                      ],
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



class CustomDropdownTextFieldsmintake extends StatefulWidget {
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

  const CustomDropdownTextFieldsmintake({
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
    this.hintText, this.isIconVisible = true, this.borderRadius,
  }) : super(key: key);

  @override
  _CustomDropdownTextFieldsmintakeState createState() => _CustomDropdownTextFieldsmintakeState();
}

class _CustomDropdownTextFieldsmintakeState extends State<CustomDropdownTextFieldsmintake> {
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

    // ✅ Flip above if not enough space below
    final double screenHeight = MediaQuery.of(context).size.height;
    const double menuHeight = 48.0 * 4;
    final double topBelow = offset.dy + size.height;
    final double topAbove = offset.dy - menuHeight;
    final double top = (topBelow + menuHeight > screenHeight) ? topAbove : topBelow;

    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: top,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: widget.width ?? size.width,
                  constraints: const BoxConstraints(
                    maxHeight: 48.0 * 4, // ✅ 4 items then scrolls
                  ),
                  child: ListView.builder( // ✅ no SingleChildScrollView
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: widget.items?.length ??
                        widget.dropDownMenuList?.length ?? 0,
                    itemBuilder: (context, index) {
                      final item = widget.items != null
                          ? widget.items![index]
                          : widget.dropDownMenuList![index].value;
                      return SizedBox(
                        height: 48, // ✅ fixed item height
                        child: ListTile(
                          title: Text(
                            item!,
                            style: DocumentTypeDataStyle.customTextStyle(context),
                          ),
                          onTap: () => Navigator.of(context).pop(item),
                        ),
                      );
                    },
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
        builder: (context,providerState,child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: widget.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        widget.headText,
                        style:SMTextfieldHeadings.customTextStyle(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                width: widget.width ?? null,
                height:widget.height ?? AppSize.s30,
                child: GestureDetector(
                  onTap: _showDropdownDialog,
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 3, top: 4, left: AppPadding.p10,right: AppPadding.p7),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedValue ?? widget.hintText ?? 'Select',
                          style: TableSubHeading.customTextStyleWithColor(context,const Color(0xff686464)),// TableSubHeading.customTextStyle(context),//DocumentTypeDataStyle.customTextStyle(context),
                        ),
                        Icon(Icons.arrow_drop_down_sharp, color: ColorManager.blueprime,),
                      ],
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
