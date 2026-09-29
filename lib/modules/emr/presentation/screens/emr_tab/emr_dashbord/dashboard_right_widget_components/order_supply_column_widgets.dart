import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_right_widget_components/widgets/widgets/add_reminder_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_right_widget_components/widgets/widgets/widgets/edit_checkbox_list_popup.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dash_manager/emr_dashboard_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/reminder_model.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/calender_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/constants/dropdown_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_right_widget_components/widgets/order_supply_popup.dart';

class DashboardOrderSupplyColumnComponents extends StatefulWidget {
  @override
  State<DashboardOrderSupplyColumnComponents> createState() =>
      _DashboardOrderSupplyColumnComponentsState();
}

class _DashboardOrderSupplyColumnComponentsState
    extends State<DashboardOrderSupplyColumnComponents> {

  final GlobalKey _datePillKey = GlobalKey();
  DateTime _selectedDate = DateTime.now();
  String _selectedPriority = 'All';

  List<RemiderListData> _todos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  // ── API Call ────────────────────────────────────────────────────────────────
  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    try {
      final priority = _selectedPriority == 'All' ? 'all' : _selectedPriority;
      final date = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final ReminderData result = await getReminderToDoList(
        context: context,
        priority: priority,
        date: date,
      );
      if (mounted) setState(() => _todos = result.data ?? []);
    } catch (e) {
      debugPrint("Load reminders error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Card Decoration ─────────────────────────────────────────────────────────
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () => showDialog(
            context: context,
            barrierColor: Colors.black.withOpacity(0.2),
            builder: (_) => const OrderSuppliesDialog(),
          ),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: ColorManager.blueprime,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Order Supplies',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorManager.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
        Expanded(child: _buildToDoListCard(context)),
      ],
    );
  }

  // ── To Do List Card ─────────────────────────────────────────────────────────
  Widget _buildToDoListCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 10, 5, 8),
            child: Row(
              children: [
                Text(
                  'To Do List',
                  style: SearchDropdownConst.customTextStyle(context),
                ),
                const Spacer(),
                InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => AddReminderPopup(),
                    );
                    _loadReminders();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: ColorManager.blueprime,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Add reminder',
                        style: TextStyle(
                          color: ColorManager.blueprime,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Filter Row ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p5),
            child: Row(
              children: [
                CustomDropdown(
                  items: const ['All', 'High', 'Medium', 'Low'],
                  initialValue: _selectedPriority,
                  onChanged: (val) {
                    if (val != null && val != _selectedPriority) {
                      setState(() => _selectedPriority = val);
                      _loadReminders();
                    }
                  },
                ),
                const Spacer(),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  key: _datePillKey,
                  onTap: () async {
                    final picked = await CalendarPickerHelper.show(
                      context: context,
                      anchorKey: _datePillKey,
                      selectedDate: _selectedDate,
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                      _loadReminders();
                    }
                  },
                  child: _filterBox(
                    CalendarPickerHelper.fmt(_selectedDate),
                    trailingIcon: Icons.calendar_today_outlined,
                    iconSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Divider(height: 1,
                color: Colors.grey.shade200),
          ),

          // ── Todo List ────────────────────────────────────
          Expanded(
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: ColorManager.blueprime,
                strokeWidth: 2,
              ),
            )
                : _todos.isEmpty
                ? Center(
              child: Text(
                'No reminders found!',
                style: AllNoDataAvailable.customTextStyle(context)
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 5, vertical: 6),
              itemCount: _todos.length,
              itemBuilder: (_, i) => TodoCard(
                item: _todos[i],
                onDeleted: _loadReminders,
                onEdited: _loadReminders,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Box ──────────────────────────────────────────────────────────────
  Widget _filterBox(String label,
      {IconData? trailingIcon, double iconSize = 22}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, color: ColorManager.mediumgrey)),
          if (trailingIcon != null) ...[
            const SizedBox(width: 20),
            Icon(trailingIcon, size: iconSize, color: ColorManager.mediumgrey),
          ],
        ],
      ),
    );
  }
}

// ── _TodoCard ─────────────────────────────────────────────────────────────────
class TodoCard extends StatefulWidget {
  final RemiderListData item;
  final VoidCallback onDeleted;
  final VoidCallback onEdited;

  const TodoCard({
    required this.item,
    required this.onDeleted,
    required this.onEdited,
  });

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  late bool _isChecked;

  // Priority → color mapping
  Color get _priorityColor {
    switch (widget.item.priority.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return ColorManager.blueiconColor;
    }
  }

  @override
  void initState() {
    super.initState();
    _isChecked = widget.item.isCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Colored Left Bar ─────────────────────────────
          Container(
            width: 4,
            height: 58,
            decoration: BoxDecoration(
              color: _priorityColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
          ),

          // ── Checkbox ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: ColorManager.blueprime.withOpacity(0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Transform.scale(
                scale: 0.78,
                child: Checkbox(
                  splashRadius: 0,
                  value: _isChecked,
                  onChanged: (val) async{
                    final result = await patchToDoReminder(
                      context: context,
                      reminderId: widget.item.reminderId,
                      title: widget.item.title.trim(),
                      date: widget.item.date,
                      startTime: widget.item.startTime,
                      endTime: widget.item.endTime,
                      priority: widget.item.priority,
                      isCompleted: widget.item.isCompleted  == true ? false : true,
                    );
                    if(result.statusCode == 200 || result.statusCode == 201){
                      setState(() => _isChecked = val ?? false);
                    }else{
                      setState(() => false);
                    }
                  },
                  activeColor: ColorManager.blueprime,
                  checkColor: Colors.white,
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return ColorManager.blueprime;
                    }
                    return Colors.transparent;
                  }),
                  side: BorderSide(color: ColorManager.blueprime, width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ),

          // ── Text Content ──────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: _isChecked ? Colors.grey : Colors.black87,
                      decoration:
                      _isChecked ? TextDecoration.lineThrough : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.item.clinicianName,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.item.date.replaceAll('-', '/')} | ${widget.item.startTime} - ${widget.item.endTime}',
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // ── Action Icons ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isChecked ? const Offstage() :InkWell(
                  onTap: () async {
                    // FIX: compute the future once per tap instead of
                    // inline inside the dialog's builder, which re-fires
                    // the API call on every rebuild of the dialog.
                    final Future<ReminderDataPrefill> reminderPrefillFuture =
                        getReminderToDoPreFill(
                            context: context,
                            reminderId: widget.item.reminderId);
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return FutureBuilder<ReminderDataPrefill>(
                            future: reminderPrefillFuture,
                            builder: (context,snapshot){
                                if(snapshot.connectionState == ConnectionState.waiting){
                                  return Center(child: CircularProgressIndicator(
                                      color: ColorManager.blueprime));
                                }
                                if(snapshot.hasError){
                                  return const Center(child: Text("Error loading data"));
                                }
                                return EditCheckboxListPopupRightWidget(preFillData: snapshot.data!,);
                            });

                      },
                    );
                    widget.onEdited();
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                  ),
                ),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        content: SizedBox(
                          height: 150,
                          width: 250,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    onPressed: () => Navigator.pop(context),
                                    icon: Icon(Icons.close,
                                        color: ColorManager.mediumgrey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Are you sure want to delete this\ntask?",
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomButtonTransparent(
                                    text: "Cancel",
                                    onPressed: () => Navigator.pop(context),
                                    height: 28,
                                  ),
                                  const SizedBox(width: 10),
                                  CustomButton(
                                    height: 28,
                                    width: 100,
                                    onPressed: () async{
                                      try{
                                        var response = await deleteToDoReminder(
                                          context: context,
                                          reminderId:widget.item.reminderId,
                                        );
                                        if(response.statusCode == 200 || response.statusCode == 201){
                                          Navigator.pop(context);
                                          widget.onDeleted();
                                        }
                                      }finally{

                                      }

                                    },
                                    text: "Yes",
                                    borderRadius: 12,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}