import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
// removed in extraction: import 'package:prohealth/app/app.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_dashboard/widget/Qa_productive_graph.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_dashboard/widget/const_info_card.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_dashboard/widget/const_qa_card.dart';
// removed in extraction: import 'package:prohealth/presentation/screens/qa_coordinator_module/qa_dashboard/widget/const_toDo_list_card.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_dashboard/widget/rating_dialog.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/resources/qa_coordinator_resource/const_string_qa.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dash_manager/emr_dashboard_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/qa_coordinator_manager/qa_dashboard.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/reminder_model.dart';
import 'package:symmetry_emr/modules/emr/data/models/qa_coordinator_data/dashboard/dashboard_graph_model.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/calender_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/constants/dropdown_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_right_widget_components/order_supply_column_widgets.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_right_widget_components/widgets/widgets/add_reminder_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/coder/coder_myTask/coder_tab_bar_screen/coder_common_widgets/clinical_grouping_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/coder/coder_myTask/coder_tab_bar_screen/coder_common_widgets/pdx_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/coder/coder_myTask/coder_tab_bar_screen/coder_common_widgets/waring_f2f_poup.dart';

class CoderDashboardScreen extends StatefulWidget {
  final Function(int) onTap;
  const CoderDashboardScreen({super.key, required this.onTap});

  @override
  State<CoderDashboardScreen> createState() => _CoderDashboardScreenState();
}

class _CoderDashboardScreenState extends State<CoderDashboardScreen> {
  final ScrollController _horizontalScrollController = ScrollController();
  QaDashboardGraphModel? _dashboardData;
  List<RemiderListData> _todos = [];
  bool _isReminderLoading = false;
  bool _isLoading = true;
  final GlobalKey _datePillKey = GlobalKey();
  DateTime _selectedDate = DateTime.now();
  String _selectedPriority = 'All';


  @override
  void initState() {
    super.initState();
    _fetchData();
    _loadReminders();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }


  Future<void> _loadReminders() async {
    setState(() => _isReminderLoading = true);
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
      if (mounted) setState(() => _isReminderLoading = false);
    }
  }

  Future<void> _fetchData() async {
    final result = await getDashboardGraphData(context: context);
    if (mounted) {
      setState(() {
        _dashboardData = result;
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const double minContentWidth = 1200;
      final double contentWidth = constraints.maxWidth > minContentWidth
          ? constraints.maxWidth
          : minContentWidth;
      return CustomScrollbar(
        controller: _horizontalScrollController,
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppPadding.p10),
            child: SizedBox(
              width: contentWidth,
              child:  Padding(
                padding: const EdgeInsets.only(left: AppSizeConst.A40,right: AppSizeConst.A40),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        color: Colors.white,
                        child:  ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: AppPadding.p5,right: AppPadding.p5,
                                      bottom: AppPadding.p20,top: AppPadding.p20),
                                  child: Container(
                                    height: AppSize.s120,
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFF1EEF7).withAlpha(99),
                                        borderRadius:
                                        BorderRadius.circular(AppSize.s10)),
                                    child: Center(
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.only(right: AppPadding.p40,left: AppPadding.p60),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              spacing: 5,
                                              children: [
                                                Text(ConstStringQa.dashboardTitle,
                                                  style: TextStyle(
                                                      letterSpacing: 0.5,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 22,
                                                      color: ColorManager.granitegray),),
                                                const SizedBox(height: AppSize.s12,),
                                                Text(ConstStringQa.dashboardSubTitle,
                                                    style:  TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 12,
                                                        letterSpacing: 0.5,
                                                        color: ColorManager.granitegray)),
                                              ],
                                            ),
                                            Expanded(child: Container()),
                                            Expanded(
                                              flex: 2,
                                              child: Stack(
                                                clipBehavior: Clip.none,
                                                alignment: Alignment.center,
                                                children: [
                                                  Positioned(
                                                    top: -5,
                                                    bottom: -10,
                                                    child: SvgPicture.asset(
                                                      "images/qa_coordinator/qa_dash.svg",
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSize.s10,),
                                /// ── Stats Cards Row ──
                                Padding(
                                  padding: const  EdgeInsets.symmetric(horizontal: AppPadding.p5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: const Color(0xFF2EA3D4).withAlpha(9),
                                        borderRadius:
                                        BorderRadius.circular(AppSize.s10)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: AppPadding.p20, vertical: AppPadding.p10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Align(
                                            alignment: Alignment.centerRight,
                                            child: CustomDropdown(
                                              items: ['Sacramento 1', 'Sacramento 2'],
                                              initialValue: 'Sacramento',
                                            ),
                                          ),
                                          const SizedBox(height: AppSize.s10,),
                                          Container(
                                            width: double.infinity,
                                            child: Wrap(
                                              spacing: 10,   // horizontal gap between cards
                                              runSpacing: 8, // vertical gap if cards wrap to next line
                                              children: [
                                                ConstCoderCard(
                                                  title: 'Pending Tasks',
                                                  count: _isLoading ? '-' : '${_dashboardData?.summary.pendingTasks ?? 0}',
                                                  color: const Color(0xFFB4DB4C),
                                                  onTap: () => widget.onTap(0),
                                                ),
                                                ConstCoderCard(
                                                  title: 'Overdue Tasks',
                                                  count: '-',
                                                  color: const Color(0xFFA81818),
                                                  onTap: (){},
                                                ),
                                                ConstCoderCard(
                                                  title: 'Waiting for\nAcceptable PDx',
                                                  count: '-',
                                                  color: const Color(0xFF95B2E5),
                                                  onTap: (){
                                                    showDialog(context: context, builder: (BuildContext context){
                                                      return AcceptedPdxPopup();
                                                    });
                                                  },
                                                ),
                                                ConstCoderCard(
                                                  title: "Waiting for F2F",
                                                  count: '-',
                                                  color: const Color(0xFFAD4DE8),
                                                  onTap: (){
                                                    showDialog(context: context, builder: (BuildContext context){
                                                      return const WaitingFtoFPopup();
                                                    });
                                                  },
                                                ),
                                                ConstCoderInfoCard(
                                                  title: 'Clinical Grouping',
                                                  subTitle: 'MS Rehab',
                                                  color: const Color(0xFFF2AB19),
                                                  onTap: () {
                                                    showDialog(context: context, builder: (BuildContext context){
                                                      return const ClinicalGroupingPopup();
                                                    });
                                                  },
                                                ),
                                                ConstCoderInfoCardWithPercent(
                                                  title: 'Comorbidity Adjustment',
                                                  color: const Color(0xFFEE61CF),
                                                  onTap: () {  },
                                                  leftPercentage: '-',
                                                  leftString: 'Low (-)',
                                                  rightPercentage: '-',
                                                  rightString: 'High (-)',),
                                              ],
                                            ),
                                          ),


                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                /// ── Graph Row ──
                                const SizedBox(height: AppSize.s10,),
                                if (_dashboardData != null)
                                  QaProductivityGraph(dashboardData: _dashboardData!,),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSize.s10,),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(AppPadding.p0, AppPadding.p20, AppPadding.p0, AppPadding.p10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'To Do List',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: FontSize.s14, color: ColorManager.ToDoColor),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
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
                                      Text('Add reminder',
                                        style: TextStyle(
                                          color: ColorManager.blueprime,
                                          fontSize: FontSize.s12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
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
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            focusColor: Colors.transparent,
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
                          const SizedBox(height: AppSize.s10),
                          Divider(height: 1, color: Colors.grey.shade200),
                          const SizedBox(height: AppSize.s5),
                          Expanded(
                            child: _isReminderLoading
                                ?  Center(child: CircularProgressIndicator(color: ColorManager.blueprime,))
                                : _todos.isEmpty
                                ?  Center(child: Text('No reminders found!',style:  AllNoDataAvailable.customTextStyle(context),))
                                : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: AppPadding.p6),
                              itemCount: _todos.length,
                              itemBuilder: (_, i) => TodoCard(
                                item: _todos[i],
                                onDeleted: () {
                                  setState(() => _todos.removeAt(i));
                                },
                                onEdited: () {
                                  _loadReminders(); // refresh after edit
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),  ),
          ),
        ),
      );
    });
  }
  Widget _filterBox(String label,
      {IconData? trailingIcon, double iconSize = 22}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10, vertical: AppPadding.p7),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(fontSize: FontSize.s11, color: ColorManager.mediumgrey)),
          if (trailingIcon != null) ...[
            const SizedBox(width: AppSize.s20),
            Icon(trailingIcon, size: iconSize, color: ColorManager.mediumgrey),
          ],
        ],
      ),
    );
  }
}