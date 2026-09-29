import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/communication_model/communication_string.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/communication_manger/broadcast_manager/broadcast_file.dart';
import 'package:symmetry_emr/modules/emr/data/models/communication_data/broadcast_data/broadcast.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/dialogue_template.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/toste_notify_const.dart';

class SendBroadcastPopup extends StatefulWidget {
  final VoidCallback onRefresh;
  const SendBroadcastPopup({super.key, required this.onRefresh});

  @override
  State<SendBroadcastPopup> createState() => _SendBroadcastPopupState();
}

class _SendBroadcastPopupState extends State<SendBroadcastPopup> {
  TextEditingController descriptionController = TextEditingController();
  TextEditingController chipController = TextEditingController();

  BroadCastChipsData? data;
  List<String> _chips = [];
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool searchSelect = false;
  List<String> _searchResults = [];

  // ✅ Tracks the selected employee from dropdown (name + id)
  String? _selectedEmployeeName;
  int? _selectedEmployeeId;

  List<String> employeeIdList = [];
  bool isLoading = false;

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _removeOverlay,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            width: 550,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: true,
              offset: const Offset(0.0, 40),
              child: Material(
                elevation: 4.0,
                child: chipController.text.isEmpty
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Text(
                      'No User Found!',
                      style: AllNoDataAvailable.customTextStyle(context),
                    ),
                  ),
                )
                    : ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 100),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ..._searchResults.map((result) => ListTile(
                          title: Text(
                            result,
                            style: TextStyle(
                              fontSize: FontSize.s14,
                              fontWeight: FontWeight.w400,
                              color: ColorManager.mediumgrey,
                            ),
                          ),
                          onTap: () {
                            // ✅ On dropdown tap: just store the selection,
                            //    fill the text field, close overlay.
                            //    Do NOT add to chip yet — wait for Add button.
                            for (var e in data!.data) {
                              if (result == e.employeeName) {
                                setState(() {
                                  _selectedEmployeeName = e.employeeName;
                                  _selectedEmployeeId = e.employeeId;
                                  chipController.text = e.employeeName;
                                });
                                break;
                              }
                            }
                            _removeOverlay();
                          },
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void _search(String query) async {
    // ✅ If user manually edits the field, clear the stored selection
    setState(() {
      _selectedEmployeeName = null;
      _selectedEmployeeId = null;
    });

    if (query.isEmpty) {
      _searchResults = [];
      _removeOverlay();
      return;
    }

    if (!searchSelect) {
      data = await getAllBroadcastChips(context: context, searchText: query);
      _searchResults = data!.data.map((e) => e.employeeName).toList();
    } else {
      _searchResults = data!.data.map((e) => e.employeeName).toList();
    }
    _showOverlay();
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  // ✅ Called when Add button is pressed
  void _addChip(void Function(void Function()) setState) {
    // Must have a valid dropdown selection
    if (_selectedEmployeeName == null || _selectedEmployeeId == null) {
      showTopRightToast(context,
          message: "Please select a clinician from the list!",
          isSuccess: false);
      return;
    }

    final name = _selectedEmployeeName!;
    final id = _selectedEmployeeId!;

    if (_chips.contains(name)) {
      showTopRightToast(context,
          message: "Clinician already added!", isSuccess: false);
      chipController.clear();
      _selectedEmployeeName = null;
      _selectedEmployeeId = null;
      return;
    }

    if (_chips.length >= 4) {
      showTopRightToast(context,
          message: "Maximum 4 clinicians allowed!", isSuccess: false);
      return;
    }

    setState(() {
      _chips.add(name);
      employeeIdList.add(id.toString()); // ✅ ID synced with chip
      chipController.clear();
      _selectedEmployeeName = null;
      _selectedEmployeeId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplate(
      width: AppSize.s700,
      height: AppSize.s400,
      color: ColorManager.orangeBright,
      body: [
        StatefulBuilder(
          builder: (BuildContext context,
              void Function(void Function()) setState) {
            return Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: AppPadding.p12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScrollbarTheme(
                    data: ScrollbarThemeData(
                      thumbVisibility: MaterialStateProperty.all(false),
                      trackVisibility: MaterialStateProperty.all(false),
                      thickness: MaterialStateProperty.all(0),
                    ),
                    child: SizedBox(
                      width: double.maxFinite,
                      height: AppSize.s100,
                      child: TextField(
                        controller: descriptionController,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(
                            fontSize: FontSize.s12,
                            fontWeight: FontWeight.w400,
                            color: ColorManager.mediumgrey),
                        maxLines: 50,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: ColorManager.white,
                          hintText: CommunicationString.descBroadcast,
                          hintStyle: TextStyle(
                              fontSize: FontSize.s12,
                              fontWeight: FontWeight.w400,
                              color: ColorManager.mediumgrey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: ColorManager.greyShade200, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: ColorManager.greyShade200, width: 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppPadding.p13,
                              vertical: AppPadding.p13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSize.s20),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: AppSize.s36,
                          child: CompositedTransformTarget(
                            link: _layerLink,
                            child: TextField(
                              controller: chipController,
                              style: TextStyle(
                                  fontSize: FontSize.s12,
                                  fontWeight: FontWeight.w400,
                                  color: ColorManager.mediumgrey),
                              onChanged: (value) {
                                _search(value);
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: CommunicationString.sendto,
                                hintStyle: TextStyle(
                                    fontSize: FontSize.s12,
                                    fontWeight: FontWeight.w400,
                                    color: ColorManager.mediumgrey),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade200,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade200,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: AppPadding.p13,
                                    vertical: AppPadding.p8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSize.s10),
                      SizedBox(
                        height: 35,
                        width: 80,
                        child: OutlinedButton(
                          // ✅ Add button now uses _addChip()
                          onPressed: () => _addChip(setState),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: ColorManager.orangeBright, width: 1),
                            shape: const StadiumBorder(),
                            foregroundColor: const Color(0xFFFFA366),
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            elevation: 4,
                          ),
                          child: Text(
                            CommunicationString.add,
                            style: TextStyle(
                              fontSize: FontSize.s12,
                              fontWeight: FontWeight.w500,
                              color: ColorManager.orangeBright,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSize.s10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _chips
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final chip = entry.value;
                      return Chip(
                        label: Text(
                          chip,
                          style: CustomTextStylesCommon.commonStyle(
                            fontSize: FontSize.s12,
                            fontWeight: FontWeight.w400,
                            color: ColorManager.grey,
                          ),
                        ),
                        backgroundColor:
                        const Color(0xFFE67514).withValues(alpha: 0.04),
                        deleteIcon: Icon(Icons.close,
                            size: IconSize.I14,
                            color: ColorManager.grey),
                        onDeleted: () {
                          setState(() {
                            // ✅ Remove both chip and ID at the same index
                            if (index < employeeIdList.length) {
                              employeeIdList.removeAt(index);
                            }
                            _chips.removeAt(index);
                          });
                        },
                      );
                    })
                        .toList(),
                  ),
                ],
              ),
            );
          },
        )
      ],
      bottomButtons: CustomElevatedButtonCM(
        width: 120,
        elevation: 4,
        height: 40,
        borderRadius: 10,
        isSelectShow: true,
        isLoading: isLoading == true,
        style: const TextStyle(
            color: Colors.white,
            fontSize: FontSize.s12,
            fontWeight: FontWeight.w700),
        onPressed: () async {
          if (_chips.isEmpty) {
            showTopRightToast(context,
                message: "Please select clinician!",
                isSuccess: false);
            return;
          }
          setState(() {
            isLoading = true;
          });
          try {
            final userId = await TokenManager.getuserId();
            var response = await postBrodcaseData(
                context: context,
                userId: userId,
                clinicialId: employeeIdList
                    .where((e) => e.isNotEmpty)
                    .map((e) => int.tryParse(e) ?? 0)
                    .toList(),
                aleartHeading: '',
                aleartBody: descriptionController.text);
            if (response.statusCode == 200 ||
                response.statusCode == 201) {
              Navigator.pop(context);
              showTopRightToast(context,
                  message: "Send Successful!", isSuccess: true);
              chipController.clear();
              _chips.clear();
              employeeIdList.clear();
            } else {
              Navigator.pop(context);
              showTopRightToast(context,
                  message: "Something went wrong!", isSuccess: false);
            }
          } finally {
            setState(() {
              isLoading = false;
            });
            widget.onRefresh();
          }
        },
        text: CommunicationString.sendBroadcast,
        color: ColorManager.orangeBright,
      ),
      title: CommunicationString.sendBroadcast,
    );
  }
}




