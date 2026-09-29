import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/providers/hh_emr/visit_details_provider.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dash_manager/insurance_filter_api.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/qa_coordinator_manager/qa_coader_filter_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/qa_coordinator_data/qa_coader_filter_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_left_widget_components/map_side_column_widgets.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/todays_visit_column_widget.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_right_widget_components/order_supply_column_widgets.dart';

class EMRDashboardScreen extends StatefulWidget {
  const EMRDashboardScreen({super.key});

  @override
  State<EMRDashboardScreen> createState() => _EMRDashboardScreenState();
}

class _EMRDashboardScreenState extends State<EMRDashboardScreen> {
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filterProvider = context.watch<FilterDrawerProvider>();

    return Stack(
      children: [

        // ── Main content ──────────────────────────────────────────────
        Container(
          color: ColorManager.white,
          child: LayoutBuilder(builder: (context, constraints) {
            const double minContentWidth = 1200;
            final double contentWidth = constraints.maxWidth > minContentWidth
                ? constraints.maxWidth
                : minContentWidth;
            return CustomScrollbar(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppPadding.p10),
                  child: SizedBox(
                    width: contentWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(flex: 2, child: DashboardMapColumnComponents()),
                          const Expanded(flex: 4, child: DashboardTodaysVisitMidleColumnWidgets()),
                          Expanded(flex: 2, child: DashboardOrderSupplyColumnComponents()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),

        // ── Barrier — close on outside tap ────────────────────────────
        if (filterProvider.isFilterOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => context.read<FilterDrawerProvider>().closeFilter(),
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),

        // ── Filter panel ──────────────────────────────────────────────
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          right: filterProvider.isFilterOpen ? 0 : -320,
          top: 0,
          bottom: 0,
          width: 300,
          child: EMRFilterDrawer(
            onClose: () => context.read<FilterDrawerProvider>().closeFilter(),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  FILTER DRAWER
// ════════════════════════════════════════════════════════════════════════════

class EMRFilterDrawer extends StatefulWidget {
  final VoidCallback onClose;
  const EMRFilterDrawer({super.key, required this.onClose});

  @override
  State<EMRFilterDrawer> createState() => _EMRFilterDrawerState();
}

class _EMRFilterDrawerState extends State<EMRFilterDrawer> {

  List<FormData>                      _allForms           = <FormData>[];
  List<FormData>                      _filteredForms      = <FormData>[];
  bool                                _formsLoading       = false;

  List<DistinctInsuranceProviderData> _allInsurances      = <DistinctInsuranceProviderData>[];
  List<DistinctInsuranceProviderData> _filteredInsurances = <DistinctInsuranceProviderData>[];
  bool                                _insurancesLoading  = false;

  List<int>    _selectedFormIds    = [];
  List<String> _selectedFormNames  = [];
  List<String> _selectedInsurances = [];

  final TextEditingController _formSearchCtrl      = TextEditingController();
  final TextEditingController _insuranceSearchCtrl = TextEditingController();

  final Map<String, bool> _expanded = {
    'Form Name': false,
    'Insurance': false,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadForms();
      _loadInsurances();
    });
  }

  @override
  void dispose() {
    _formSearchCtrl.dispose();
    _insuranceSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadForms() async {
    setState(() => _formsLoading = true);
    try {
      final result = await getFormList(context);
      if (mounted) setState(() {
        _allForms      = List<FormData>.from(result);
        _filteredForms = List<FormData>.from(result);
        _formsLoading  = false;
      });
    } catch (_) {
      if (mounted) setState(() => _formsLoading = false);
    }
  }

  Future<void> _loadInsurances() async {
    setState(() => _insurancesLoading = true);
    try {
      final result = await getDistinctInsuranceProviders(context);
      if (mounted) setState(() {
        _allInsurances      = List<DistinctInsuranceProviderData>.from(result);
        _filteredInsurances = List<DistinctInsuranceProviderData>.from(result);
        _insurancesLoading  = false;
      });
    } catch (_) {
      if (mounted) setState(() => _insurancesLoading = false);
    }
  }

  void _onFormSearch(String val) => setState(() {
    _filteredForms = val.isEmpty
        ? List<FormData>.from(_allForms)
        : _allForms
        .where((f) => f.formName.toLowerCase().contains(val.toLowerCase()))
        .toList();
  });

  void _onInsuranceSearch(String val) => setState(() {
    _filteredInsurances = val.isEmpty
        ? List<DistinctInsuranceProviderData>.from(_allInsurances)
        : _allInsurances
        .where((i) => i.providerName.toLowerCase().contains(val.toLowerCase()))
        .toList();
  });

  bool _allFormsSelected() =>
      _allForms.isNotEmpty &&
          _allForms.every((f) => _selectedFormIds.contains(f.formId));

  void _toggleAllForms(bool? val) {
    setState(() {
      _selectedFormIds   = val == true ? _allForms.map((f) => f.formId).toList()   : [];
      _selectedFormNames = val == true ? _allForms.map((f) => f.formName).toList() : [];
    });
  }

  void _clearAll() {
    setState(() {
      _selectedFormIds    = [];
      _selectedFormNames  = [];
      _selectedInsurances = [];
      _formSearchCtrl.clear();
      _insuranceSearchCtrl.clear();
      _filteredForms      = List<FormData>.from(_allForms);
      _filteredInsurances = List<DistinctInsuranceProviderData>.from(_allInsurances);
      for (var key in _expanded.keys) _expanded[key] = false;
    });
    context.read<FilterDrawerProvider>().clearFilters();
  }

  void _onSave() {
    context.read<FilterDrawerProvider>().applyFilters(
      formNames:  Set.from(_selectedFormNames),
      insurances: Set.from(_selectedInsurances),
    );
    context.read<FilterDrawerProvider>().saveFilters();
    widget.onClose();
  }

  Widget _buildSectionContent(String section) {
    switch (section) {

      case 'Form Name':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _searchField(_formSearchCtrl, 'Search form', _onFormSearch),
              const SizedBox(height: AppSize.s8),
              if (_formsLoading)
                const Center(child: CircularProgressIndicator(strokeWidth: 2))
              else ...[
                _selectAllRow(_allFormsSelected(), _toggleAllForms),
                const SizedBox(height: AppSize.s4),
                _scrollableList(
                  child: Column(
                    children: _filteredForms.map((form) {
                      final isSelected = _selectedFormIds.contains(form.formId);
                      return _checkRow(form.formName, isSelected, () {
                        setState(() {
                          final ids   = List<int>.from(_selectedFormIds);
                          final names = List<String>.from(_selectedFormNames);
                          if (isSelected) {
                            ids.remove(form.formId);
                            names.remove(form.formName);
                          } else {
                            ids.add(form.formId);
                            names.add(form.formName);
                          }
                          _selectedFormIds   = ids;
                          _selectedFormNames = names;
                        });
                      });
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: AppSize.s8),
            ],
          ),
        );


      case 'Insurance':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _searchField(_insuranceSearchCtrl, 'Search insurance', _onInsuranceSearch),
              const SizedBox(height: AppSize.s8),
              if (_insurancesLoading)
                const Center(child: CircularProgressIndicator(strokeWidth: 2))
              else if (_filteredInsurances.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
                  child: Text('No insurances found!',
                      style: AllNoDataAvailable.customTextStyle(context),
                ),)
              else
                _scrollableList(
                  child: Column(
                    children: _filteredInsurances
                        .map((DistinctInsuranceProviderData ins) {
                      final isSelected =
                      _selectedInsurances.contains(ins.providerName);
                      return _checkRow(ins.providerName, isSelected, () {
                        setState(() {
                          final list = List<String>.from(_selectedInsurances);
                          isSelected
                              ? list.remove(ins.providerName)
                              : list.add(ins.providerName);
                          _selectedInsurances = list;
                        });
                      });
                    }).toList(),
                  ),
                ),
              const SizedBox(height: AppSize.s8),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _searchField(
      TextEditingController ctrl,
      String hint,
      void Function(String) onChanged,
      ) {
    return TextField(
      controller: ctrl,
      style: TextStyle(fontSize: FontSize.s12, color: ColorManager.darkgrey),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText:  hint,
        hintStyle: TextStyle(fontSize: FontSize.s12, color: ColorManager.mediumgrey),
        prefixIcon: Icon(Icons.search,
            size: AppSize.s16, color: ColorManager.mediumgrey),
        contentPadding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSize.s6),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSize.s6),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSize.s6),
            borderSide: BorderSide(color: ColorManager.blueprime, width: 1.5)),
      ),
    );
  }

  Widget _selectAllRow(bool selected, void Function(bool?) onToggle) {
    return InkWell(
      onTap: () => onToggle(!selected),
      child: Row(
        children: [
          SizedBox(
            width: AppSize.s18, height: AppSize.s18,
            child: Checkbox(
              value:     selected,
              onChanged: onToggle,
              activeColor: ColorManager.blueprime,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              side: BorderSide(color: ColorManager.blueprime, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSize.s2)),
            ),
          ),
          const SizedBox(width: AppSize.s8),
          Text('Select all',
              style: TextStyle(
                  fontSize:   FontSize.s12,
                  color:      ColorManager.blueprime,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _checkRow(String label, bool checked, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPadding.p6),
      child: InkWell(
        onTap: onToggle,
        child: Row(
          children: [
            SizedBox(
              width: AppSize.s18, height: AppSize.s18,
              child: Checkbox(
                value:     checked,
                onChanged: (_) => onToggle(),
                activeColor: ColorManager.blueprime,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSize.s2)),
              ),
            ),
            const SizedBox(width: AppSize.s8),
            Flexible(
              child: Text(label,
                  style: TextStyle(
                      fontSize: FontSize.s12, color: ColorManager.darkgrey),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scrollableList({required Widget child}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Material(
        elevation: 8,
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.p16, vertical: AppPadding.p12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: widget.onClose,
                      child: Row(
                        children: [
                          Icon(Icons.menu_open,
                              size: AppSize.s18,
                              color: ColorManager.blueprime),
                          const SizedBox(width: AppSize.s8),
                          Text('Filters',
                              style: TextStyle(
                                  fontSize:   FontSize.s14,
                                  fontWeight: FontWeight.w600,
                                  color:      ColorManager.blueprime)),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: _clearAll,
                      child: Text('CLEAR ALL',
                          style: TextStyle(
                              fontSize:   FontSize.s11,
                              fontWeight: FontWeight.w600,
                              color:      ColorManager.blueprime)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

              // ── Body ─────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: ['Form Name', 'Insurance'].map((section) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => setState(() =>
                            _expanded[section] =
                            !(_expanded[section] ?? false)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left:   AppPadding.p16,
                                  right:  AppPadding.p13,
                                  top:    AppPadding.p12,
                                  bottom: AppPadding.p12),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(section,
                                      style: TextStyle(
                                          fontSize:   FontSize.s13,
                                          fontWeight: FontWeight.w600,
                                          color:      ColorManager.darkgrey)),
                                  Icon(
                                    (_expanded[section] ?? false)
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size:  AppSize.s20,
                                    color: ColorManager.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_expanded[section] ?? false)
                            _buildSectionContent(section),
                          const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFEEEEEE)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),

              // ── Save button — pinned at bottom ────────────────────────
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.only(bottom: 15, top: 10, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: _onSave,
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontSize:        FontSize.s13,
                          fontWeight:      FontWeight.w600,
                          color:           ColorManager.blueprime,
                          decoration:      TextDecoration.underline,
                          decorationColor: ColorManager.blueprime,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}