import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/font_manager.dart';
import '../../../../../../../app/resources/color.dart';

// ── Field Label ───────────────────────────────────────────────────────────────

Widget fieldLabel(String label, {bool required = true}) {
  return RichText(
    text: TextSpan(
      text: label,
      style: TextStyle(
          fontSize: FontSize.s12, fontWeight: FontWeight.w500, color: ColorManager.textgrey),
      children: [
        if (required)
          const TextSpan(text: '*', style: TextStyle(color: Colors.red)),
      ],
    ),
  );
}

// ── Input Field ───────────────────────────────────────────────────────────────

Widget inputField({
  required TextEditingController controller,
  required String hint,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
  ValueChanged<String>? onChanged,
}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    onChanged: onChanged,
    style: const TextStyle(fontSize: FontSize.s12),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: FontSize.s12, color: ColorManager.greyShade400),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: ColorManager.bluebottom, width: 1.5),
      ),
    ),
  );
}

// ── Dropdown Field ────────────────────────────────────────────────────────────

Widget dropdownField({
  required String? value,
  required String hint,
  required List<String> items,
  required ValueChanged<String?> onChanged,
}) {
  return DropdownButtonFormField<String>(
    value: value,
    hint: Text(hint,
        style: TextStyle(fontSize: FontSize.s12, color: Colors.grey.shade400)),
    icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade500, size: 22),
    style: const TextStyle(fontSize: FontSize.s12, color: Colors.black87),
    dropdownColor: Colors.white,
    borderRadius: BorderRadius.circular(5),
    decoration: InputDecoration(
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: ColorManager.bluebottom, width: 1.5),
      ),
    ),
    items: items
        .map((c) => DropdownMenuItem(
        value: c, child: Text(c, style: const TextStyle(fontSize: FontSize.s12))))
        .toList(),
    onChanged: onChanged,
  );
}

// ── Custom Inline Dropdown (with radio options) ───────────────────────────────

class CustomRadioDropdown extends StatefulWidget {
  final String? value;
  final String hint;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const CustomRadioDropdown({
    super.key,
    required this.value,
    required this.hint,
    required this.options,
    required this.onChanged,
  });

  @override
  State<CustomRadioDropdown> createState() => _CustomRadioDropdownState();
}

class _CustomRadioDropdownState extends State<CustomRadioDropdown> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Trigger box
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: _open
                  ? const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              )
                  : BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.value ?? widget.hint,
                    style: TextStyle(
                        fontSize: 12,
                        color: widget.value != null
                            ? Colors.black87
                            : Colors.grey.shade400),
                  ),
                ),
                Icon(
                  _open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.grey.shade500,
                  size: 22,
                ),
              ],
            ),
          ),
        ),

        // Options panel
        if (_open)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.options.map((opt) {
                final isSelected = widget.value == opt;
                return GestureDetector(
                  onTap: () {
                    setState(() => _open = false);
                    widget.onChanged(opt);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(color: Colors.grey.shade100)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            opt,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? ColorManager.bluebottom
                                  : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        // Custom radio indicator
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? ColorManager.bluebottom
                                  : Colors.grey.shade400,
                              width: 1.8,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorManager.bluebottom,
                              ),
                            ),
                          )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

// ── Quantity Stepper ──────────────────────────────────────────────────────────

class QuantityStepper extends StatelessWidget {
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final double height;
  final double buttonWidth;

  const QuantityStepper({
    super.key,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    this.height = 40,
    this.buttonWidth = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Minus
          GestureDetector(
            onTap: onDecrement,
            child: Container(
              width: buttonWidth,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border:
                Border(right: BorderSide(color: Colors.grey.shade300)),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child:
              const Icon(Icons.remove, size: 16, color: Colors.black54),
            ),
          ),
          // Count
          Expanded(
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          // Plus
          GestureDetector(
            onTap: onIncrement,
            child: Container(
              width: buttonWidth,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border:
                Border(left: BorderSide(color: Colors.grey.shade300)),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: const Icon(Icons.add, size: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

///
///

class MultiSelectDropdown extends StatefulWidget {
  final List<String> options;
  final List<String> selected;
  final String hint;
  final ValueChanged<List<String>> onChanged;
  /// Max height of the overlay list before it scrolls
  final double maxOverlayHeight;

  const MultiSelectDropdown({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.hint = 'Select',
    this.maxOverlayHeight = 200,
  });

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _open = false;
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selected);
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  // ── Overlay helpers ───────────────────────────────────────────────────────

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleDropdown() {
    if (_open) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final ctx = _triggerKey.currentContext;
    if (ctx == null) return;

    final box = ctx.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;

    _overlayEntry = OverlayEntry(
      builder: (_) => _DropdownOverlay(
        offset: offset,
        triggerWidth: size.width,
        triggerHeight: size.height,
        maxHeight: widget.maxOverlayHeight,
        options: widget.options,
        selected: _selected,
        onToggle: (opt) {
          _toggle(opt);
          // Rebuild overlay to reflect checkbox state
          _overlayEntry?.markNeedsBuild();
        },
        onClose: _closeDropdown,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _open = true);
  }

  void _closeDropdown() {
    _removeOverlay();
    if (mounted) setState(() => _open = false);
  }

  // ── Selection logic ───────────────────────────────────────────────────────

  void _toggle(String item) {
    setState(() {
      if (item == 'All') {
        if (_selected.contains('All')) {
          _selected.clear();
        } else {
          _selected = ['All', ...widget.options.where((o) => o != 'All')];
        }
      } else {
        if (_selected.contains(item)) {
          _selected.remove(item);
          _selected.remove('All');
        } else {
          _selected.add(item);
          final nonAll = widget.options.where((o) => o != 'All').toList();
          if (nonAll.every(_selected.contains)) _selected.add('All');
        }
      }
    });
    widget.onChanged(List.from(_selected));
  }

  String get _displayText {
    if (_selected.isEmpty) return widget.hint;
    if (_selected.contains('All')) return 'All';
    return _selected.join(', ');
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Trigger ──────────────────────────────────────
        GestureDetector(
          key: _triggerKey,
          onTap: _toggleDropdown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selected.isEmpty ? widget.hint : 'Select',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                Icon(
                  _open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.grey.shade500,
                  size: 22,
                ),
              ],
            ),
          ),
        ),

        // ── Selected Chips ────────────────────────────────
        if (_selected.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _selected
                  .where((s) => s != 'All' || _selected.length == 1)
                  .map((s) => _buildChip(s))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: FontSize.s12, color: Colors.black87),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _toggle(label),
            child: Icon(Icons.close, size: FontSize.s12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// ── Overlay content widget ────────────────────────────────────────────────────

class _DropdownOverlay extends StatelessWidget {
  final Offset offset;
  final double triggerWidth;
  final double triggerHeight;
  final double maxHeight;
  final List<String> options;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onClose;

  const _DropdownOverlay({
    required this.offset,
    required this.triggerWidth,
    required this.triggerHeight,
    required this.maxHeight,
    required this.options,
    required this.selected,
    required this.onToggle,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Barrier — closes dropdown when tapping outside
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onClose,
            child: const SizedBox.expand(),
          ),
        ),

        // Dropdown panel
        Positioned(
          left: offset.dx,
          top: offset.dy + triggerHeight,
          width: triggerWidth,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(maxHeight: maxHeight),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: options.map((opt) {
                  final isChecked = selected.contains(opt);
                  return GestureDetector(
                    onTap: () => onToggle(opt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              opt,
                              style: const TextStyle(
                                  fontSize: FontSize.s12, color: Colors.black87),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: isChecked,
                              onChanged: (_) => onToggle(opt),
                              activeColor: ColorManager.bluebottom,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              side: BorderSide(
                                  color: Colors.grey.shade400, width: 1),
                              materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

///stepper

class StepperWidgetWithHead extends StatelessWidget {
  const StepperWidgetWithHead({
    super.key,
    required this.title,
    required this.stepLabels,
    required this.currentStep,
    required this.onStepTapped,
    required this.onClose,
  });

  final String title;
  final List<String> stepLabels;
  final int currentStep;
  final ValueChanged<int> onStepTapped;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Header ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),

        // ── Step Indicator ───────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 30),
          child: Row(
            children: List.generate(stepLabels.length, (i) {
              final stepNum = i + 1;
              final isActive = stepNum == currentStep;
              final isDone = stepNum < currentStep;
              final isFirst = i == 0;
              final isLast = i == stepLabels.length - 1;

              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        // Left connector
                        Expanded(
                          child: Container(
                            height: 1.5,
                            color: isFirst
                                ? Colors.transparent
                                : isDone
                                ? Colors.green
                                : isActive
                                ? ColorManager.bluebottom
                                : Colors.grey.shade300,
                          ),
                        ),

                        // Circle — tappable in both directions
                        GestureDetector(
                          onTap: () => onStepTapped(stepNum),
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone
                                  ? Colors.green
                                  : isActive
                                  ? ColorManager.bluebottom
                                  : Colors.grey.shade200,
                            ),
                            child: Center(
                              child: isDone
                                  ? const Icon(Icons.check,
                                  size: 14, color: Colors.white)
                                  : Text(
                                '$stepNum',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isActive
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Right connector
                        Expanded(
                          child: Container(
                            height: 1.5,
                            color: isLast
                                ? Colors.transparent
                                : currentStep > stepNum + 1
                                ? Colors.green
                                : currentStep > stepNum
                                ? ColorManager.bluebottom
                                : Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),

                    // Label
                    const SizedBox(height: 6),
                    Text(
                      stepLabels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: FontSize.s10,
                        color: ColorManager.mediumgrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
// class StepperWidgetWithHead extends StatelessWidget {
//   const StepperWidgetWithHead({
//     super.key,
//     required this.title,
//     required this.stepLabels,
//     required this.currentStep,
//     required this.onStepTapped,
//     required this.onClose,
//   });
//
//   final String title;
//   final List<String> stepLabels;
//   final int currentStep;
//   final ValueChanged<int> onStepTapped;
//   final VoidCallback onClose;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // ── Header ──────────────────────────────────────
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//           child: Row(
//             children: [
//               GestureDetector(
//                 onTap: onClose,
//                 child: const Icon(Icons.close, size: 18),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 title,
//                 style: const TextStyle(
//                     fontWeight: FontWeight.bold, fontSize: 15),
//               ),
//             ],
//           ),
//         ),
//
//         Divider(height: 1, color: Colors.grey.shade200),
//
//         // ── Step Indicator ───────────────────────────────
//         Padding(
//           padding: const EdgeInsets.only(top: 20, bottom: 30),
//           child: Row(
//             children: List.generate(stepLabels.length, (i) {
//               final stepNum = i + 1;
//               final isActive = stepNum == currentStep;
//               final isDone = stepNum < currentStep;
//               final isFirst = i == 0;
//               final isLast = i == stepLabels.length - 1;
//
//               return Expanded(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       children: [
//                         // Left connector
//                         Expanded(
//                           child: Container(
//                             height: 1.5,
//                             color: isFirst
//                                 ? Colors.transparent
//                                 : isDone
//                                 ? Colors.green
//                                 : isActive
//                                 ? ColorManager.bluebottom
//                                 : Colors.grey.shade300,
//                           ),
//                         ),
//
//                         // Circle
//                         GestureDetector(
//                           onTap: () {
//                             // Only allow tapping back to visited steps
//                             if (stepNum <= currentStep) {
//                               onStepTapped(stepNum);
//                             }
//                           },
//                           child: Container(
//                             width: 25,
//                             height: 25,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: isDone
//                                   ? Colors.green
//                                   : isActive
//                                   ? ColorManager.bluebottom
//                                   : Colors.grey.shade200,
//                             ),
//                             child: Center(
//                               child: isDone
//                                   ? const Icon(Icons.check,
//                                   size: 14, color: Colors.white)
//                                   : Text(
//                                 '$stepNum',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                   color: isActive
//                                       ? Colors.white
//                                       : Colors.grey,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//
//                         // Right connector
//                         Expanded(
//                           child: Container(
//                             height: 1.5,
//                             color: isLast
//                                 ? Colors.transparent
//                                 : currentStep > stepNum + 1
//                                 ? Colors.green
//                                 : currentStep > stepNum
//                                 ? ColorManager.bluebottom
//                                 : Colors.grey.shade300,
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     // Label
//                     const SizedBox(height: 6),
//                     Text(
//                       stepLabels[i],
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: FontSize.s10,
//                         color: ColorManager.mediumgrey,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//           ),
//         ),
//       ],
//     );
//   }
// }


void showCalendarPicker({
  required BuildContext context,
  required DateTime initialDate,
  required ValueChanged<DateTime> onDateSelected,
}) {
  final RenderBox box = context.findRenderObject() as RenderBox;
  final Offset offset = box.localToGlobal(Offset.zero);
  final Size size = box.size;

  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    builder: (_) => Stack(
      children: [
        Positioned(
          left: offset.dx,
          top: offset.dy + size.height + 4,
          child: Material(
            color: Colors.transparent,
            child: _CustomCalendar(
              initialDate: initialDate,
              onDateSelected: (date) {
                Navigator.pop(context);
                onDateSelected(date);
              },
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Calendar Widget ───────────────────────────────────────────────────────────

class _CustomCalendar extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  const _CustomCalendar({
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<_CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<_CustomCalendar> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  static const List<String> _weekDays = [
    'Fr', 'Sa', 'Su', 'Mo', 'Tu', 'We', 'Th'
  ];

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(
        widget.initialDate.year, widget.initialDate.month);
    _selectedDate = widget.initialDate;
  }

  void _prevMonth() => setState(() => _focusedMonth =
      DateTime(_focusedMonth.year, _focusedMonth.month - 1));

  void _nextMonth() => setState(() => _focusedMonth =
      DateTime(_focusedMonth.year, _focusedMonth.month + 1));

  List<DateTime?> _buildCalendarDays() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);

    // weekday: Mon=1 ... Sun=7, our grid starts Friday(5)
    // offset so Friday = column 0
    int startOffset = (firstDay.weekday - 5 + 7) % 7;

    final List<DateTime?> days = List.filled(startOffset, null);
    for (int d = 1; d <= lastDay.day; d++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, d));
    }
    // pad to complete last row
    while (days.length % 7 != 0) {
      days.add(null);
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final days = _buildCalendarDays();
    final monthName = _monthName(_focusedMonth.month);

    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Month / Year navigation ──────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _prevMonth,
                child: const Icon(Icons.chevron_left,
                    size: 18, color: Colors.black54),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$monthName  ',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: '${_focusedMonth.year}_',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _nextMonth,
                child: const Icon(Icons.chevron_right,
                    size: 18, color: Colors.black54),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Weekday headers ──────────────────────────
          Row(
            children: _weekDays.map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 4),

          // ── Days grid ────────────────────────────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 2,
              crossAxisSpacing: 0,
              childAspectRatio: 1,
            ),
            itemBuilder: (_, index) {
              final day = days[index];
              if (day == null) return const SizedBox.shrink();

              final isSelected = day.year == _selectedDate.year &&
                  day.month == _selectedDate.month &&
                  day.day == _selectedDate.day;

              final isToday = day.year == DateTime.now().year &&
                  day.month == DateTime.now().month &&
                  day.day == DateTime.now().day;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDate = day);
                  widget.onDateSelected(day);
                },
                child: Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ColorManager.bluebottom
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : isToday
                            ? ColorManager.bluebottom
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ];
    return names[month - 1];
  }
}