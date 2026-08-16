import 'package:flutter/material.dart';
import '../../../../../../../app/resources/color.dart';
import '../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../app/resources/value_manager.dart';
import 'package:prohealth/presentation/screens/scheduler_model/widgets/constant_widgets/dropdown_constant_sm.dart';
import '../../../../../../../oasis_form_builder/model/patient_form_model.dart';
import '../../../../../../../oasis_form_builder/services/api/managers/form_builder_manager.dart';
import 'widgets/patient_form_tab_popp.dart';

class PatientFormsPage extends StatefulWidget {
  final int patientID;
  final int chartID;
  final int episodeID;

  const PatientFormsPage({
    super.key,
    required this.patientID,
    required this.chartID,
    required this.episodeID,
  });

  @override
  State<PatientFormsPage> createState() => _PatientFormsPageState();
}

class _PatientFormsPageState extends State<PatientFormsPage> {
  List<PatientForm> _filledForms = [];
  List<PatentDataEpisode> _episodeList = [];
  PatentDataEpisode? _selectedEpisode;
  bool _isFormsLoading = false;
  bool _isEpisodesLoading = true;
  bool _isUserSelection = false;

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
  }

  Future<void> _loadEpisodes() async {
    final episodes = await FormBuilderManager().getEpisodeDropdown(
      context,
      patientID: widget.patientID,
    );

    if (mounted) {
      final matched = episodes.where((e) => e.episodeId == widget.episodeID).toList();

      setState(() {
        _episodeList = episodes;
        // _selectedEpisode = matched.isNotEmpty ? matched.first : null;
        _isEpisodesLoading = false;
      });

      if (_selectedEpisode != null) {
        await _loadForms(
          chartID: 0,
          episodeID: 0,
          showLoader: false,
          patientId: 0,
        );
      }
    }
  }

  Future<void> _loadForms({
    required int chartID,
    required int episodeID,
    required int patientId,
    bool showLoader = true,
  }) async {
    if (showLoader) setState(() => _isFormsLoading = true);

    final result = await FormBuilderManager().getInitFormData(
      context,
      patientID: patientId,
      chartID: chartID,
      episodeID: episodeID,
    );

    if (mounted) {
      setState(() {
        _filledForms = (result['filled'] as List<PatientForm>?) ?? [];
        _isFormsLoading = false;
        _isUserSelection = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int itemsPerColumn = _filledForms.isNotEmpty
        ? (_filledForms.length / 3).ceil()
        : 0;
    final List<List<PatientForm>> columns = _filledForms.isNotEmpty
        ? List.generate(3, (colIndex) {
      final start = colIndex * itemsPerColumn;
      final end = (start + itemsPerColumn).clamp(0, _filledForms.length);
      return start < _filledForms.length
          ? _filledForms.sublist(start, end)
          : [];
    })
        : [];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: _isEpisodesLoading
                        ? CustomDropdownTextFieldsm(
                      height: 30,
                      headText: 'Select Episode',
                      items: ['Loading episodes...'],
                      value: null,
                      onChanged: null,
                    )
                        : CustomDropdownTextFieldsm(
                      height: 30,
                      headText: 'Select Episode',
                      items: _episodeList.map((e) => e.label).toList(),
                      value: _selectedEpisode?.label,
                      onChanged: (value) {
                        if (value == null) return;
                        final selected = _episodeList.firstWhere(
                              (e) => e.label == value,
                          orElse: () => _episodeList.first,
                        );
                        setState(() {
                          _selectedEpisode = selected;
                          _isUserSelection = true;
                        });
                        _loadForms(
                          chartID: selected.chartId,
                          episodeID: selected.episodeId,
                          showLoader: true,
                          patientId: selected.pt_id,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSize.s16),

            // Forms content area
            if (_selectedEpisode == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text('Please select an episode to view forms.'),
                ),
              )
            else if (_isFormsLoading && _isUserSelection)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_filledForms.isEmpty)
                const Center(child: Text('No filled forms found.'))
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(flex: 1, child: SizedBox()),
                    ...List<Widget>.from(
                      columns.expand((columnItems) => <Widget>[
                        const SizedBox(width: 40),
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: columnItems.map((form) {
                              final String title = form.formName ?? '';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppPadding.p16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: AppPadding.p10,
                                          top: AppPadding.p10,
                                        ),
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                            fontSize: FontSize.s13,
                                            fontWeight: FontWeight.w500,
                                            color: ColorManager.blueprime,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(height: 1, color: Colors.grey.shade300),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ]),
                    ),
                    const Expanded(flex: 1, child: SizedBox()),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}