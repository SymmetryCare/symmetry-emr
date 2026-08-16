import 'package:flutter/material.dart';

import '../../../../../app/resources/establishment_resources/establish_theme_manager.dart';
import '../../../../../app/resources/value_manager.dart';
import '../../../../../data/api_data/emr_module_data/timesheet_tab_data/timesheet_data.dart';

class EmrDropdownConst extends StatefulWidget {
  final String? value;
  final List<String>? items;
  final List<DropdownMenuItem<String>>? dropDownMenuList;
  final String? hintText;
  final void Function(String?)? onChanged;
  final double? width;
  final double? widthone;
  final double? height;
  String? initialValue;

  EmrDropdownConst({
    Key? key,
    this.dropDownMenuList,
    this.value,
    this.items,
    this.onChanged,
    this.width,
    this.widthone,
    this.height,
    this.initialValue,
    this.hintText,
  }) : super(key: key);

  @override
  _EmrDropdownConstState createState() => _EmrDropdownConstState();
}

class _EmrDropdownConstState extends State<EmrDropdownConst> {
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
                      itemCount: widget.items?.length ??
                          widget.dropDownMenuList?.length ?? 0,
                      itemBuilder: (context, index) {
                        final item = widget.items != null
                            ? widget.items![index]
                            : widget.dropDownMenuList![index].value;
                        return ListTile(
                          title: Text(
                            item!,
                            style: DocumentTypeDataStyle.customTextStyle(context),
                          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: widget.height ?? AppSize.s31,
          child: GestureDetector(
            onTap: _showDropdownDialog,
            child: Container(
              padding: const EdgeInsets.only(bottom: 3, top: 5, left: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedValue ?? widget.hintText ?? 'Select',
                    style: DocumentTypeDataStyle.customTextStyle(context),
                  ),
                  const Icon(Icons.arrow_drop_down_sharp, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}





///prayroll
///


class PayrollPeriodDropdown extends StatefulWidget {
  final PayrollPeriodData? value;
  final List<PayrollPeriodData>? items;
  final String? hintText;
  final void Function(PayrollPeriodData?)? onChanged;
  final double? width;
  final double? height;

  const PayrollPeriodDropdown({
    Key? key,
    this.value,
    this.items,
    this.onChanged,
    this.width,
    this.height,
    this.hintText,
  }) : super(key: key);

  @override
  _PayrollPeriodDropdownState createState() => _PayrollPeriodDropdownState();
}

class _PayrollPeriodDropdownState extends State<PayrollPeriodDropdown> {
  PayrollPeriodData? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  void didUpdateWidget(PayrollPeriodDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      setState(() => _selectedValue = widget.value);
    }
  }

  /// e.g. "Payroll 1: 01/20/2026 – 01/31/2026" or
  ///      "Payroll 3: 01/07/2026 – 01/26/2026 (Current)"
  String _buildLabel(PayrollPeriodData period) {
    if (period.isCurrent == true) {
      // Strip any existing "(Current)" from the API label to avoid duplication
      final baseLabel = (period.label ?? '').replaceAll(RegExp(r'\s*\(Current\)', caseSensitive: false), '').trim();
      return '$baseLabel ${period.startDate} – ${period.endDate} (Current)';
    }
    return '${period.label}: ${period.startDate} – ${period.endDate}';
  }

  void _showDropdownDialog() async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final result = await showDialog<PayrollPeriodData>(
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
                child: SizedBox(
                  width: widget.width ?? size.width,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.items?.length ?? 0,
                        itemBuilder: (context, index) {
                          final period = widget.items![index];
                          final isSelected =
                              _selectedValue?.periodNumber == period.periodNumber;
                          return InkWell(
                            onTap: () => Navigator.of(context).pop(period),
                            child: Container(
                              color: isSelected
                                  ? Colors.blue.shade50
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Text(
                                _buildLabel(period),
                                style: DocumentTypeDataStyle.customTextStyle(context)
                                    .copyWith(
                                  color: isSelected
                                      ? Colors.blue.shade700
                                      : Colors.black87,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
    return SizedBox(
      width: widget.width ?? 250,
      height: widget.height ?? AppSize.s31,
      child: GestureDetector(
        onTap: _showDropdownDialog,
        child: Container(
          padding: const EdgeInsets.only(bottom: 3, top: 5, left: 12, right: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _selectedValue != null
                      ? _buildLabel(_selectedValue!)
                      : (widget.hintText ?? 'Select payroll period'),
                  style: DocumentTypeDataStyle.customTextStyle(context)
                      .copyWith(color: Colors.blue.shade700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.arrow_drop_down_sharp, color: Colors.blue.shade400),
            ],
          ),
        ),
      ),
    );
  }
}