import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/hr_module_manager/profile_mnager.dart';
import 'package:symmetry_emr/modules/emr/data/models/hr_module_data/employee_profile/search_profile_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/chatbotContainer.dart';

class CoderClinicalInfoPopup extends StatefulWidget {
  final VoidCallback onTap;
  final int employeeId;
  final String abbreviation; // ✅ NEW — passed in from the calling row (widget.item!.clinician.abbreviation)
  const CoderClinicalInfoPopup({
    super.key,
    required this.onTap,
    required this.employeeId,
    required this.abbreviation, // ✅ NEW
  });

  @override
  State<CoderClinicalInfoPopup> createState() => _CoderClinicalInfoPopupState();
}

class _CoderClinicalInfoPopupState extends State<CoderClinicalInfoPopup> {
  SearchByEmployeeIdProfileData? _data;
  bool _isLoading = true;
  bool _hasError = false;
  var hexColor;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final result = await getSearchByEmployeeIdProfileByText(
        context,
        widget.employeeId,
      );
      if (mounted) {
        setState(() {
          _data = result;
          hexColor = _data?.color.replaceAll("#", "");
          _isLoading = false;
          _hasError = result == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// "05-03-1997 [27]"
  String _formatDobWithAge(String? isoDate) {
    if (isoDate == null || isoDate == '--' || isoDate.isEmpty) return '--';
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return isoDate;
    final age = DateTime.now().year - dt.year;
    final fmt = DateFormat('MM-dd-yyyy');
    return '${fmt.format(dt)} [$age]';
  }

  /// "09/02/2016 [08 Y 11 M]"
  String _formatHireDateWithTenure(String? isoDate) {
    if (isoDate == null || isoDate == '--' || isoDate.isEmpty) return '--';
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return isoDate;
    final now = DateTime.now();
    int years = now.year - dt.year;
    int months = now.month - dt.month;
    if (months < 0) {
      years--;
      months += 12;
    }
    final fmt = DateFormat('MM/dd/yyyy');
    return '${fmt.format(dt)} [${years.toString().padLeft(2, '0')} Y ${months.toString().padLeft(2, '0')} M]';
  }

  String get _fullName {
    if (_data == null) return '--';
    return '${_data!.firstName} ${_data!.lastName}'.trim().toUpperCase();
  }

  String get _initials {
    if (_data == null) return '?';
    final f = _data!.firstName.isNotEmpty ? _data!.firstName[0] : '';
    final l = _data!.lastName.isNotEmpty ? _data!.lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  // ✅ CHANGED — always use the abbreviation passed in from the row,
  // never data.position. Falls back to computed initials only if
  // widget.abbreviation is empty.
  String get _resolvedAbbreviation {
    if (widget.abbreviation.isNotEmpty) {
      return widget.abbreviation;
    }
    return _initials;
  }

  // ── Email launcher ────────────────────────────────────────────────────────
  Future<void> _launchEmail(String email) async {
    if (email.isEmpty || email == '--') return;
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    try {
      final launched = await launchUrl(emailUri);
      if (!launched) {
        print("Could not launch email client for $email");
      }
    } catch (e) {
      print("Error $e");
    }
  }
  static const double _kDesignWidth = 855;
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kDesignWidth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
    return DialogueTemplateNoButtons(
      width: 670,
      height: 340,
      title: 'Clinician Details',
      body: [
        if (_isLoading)
          SizedBox(
            height: 260,
            child: Center(child: CircularProgressIndicator(color: ColorManager.blueprime,)),
          )
        else if (_hasError || _data == null)
          SizedBox(
            height: 260,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 32, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  const Text('Failed to load clinician details',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _hasError = false;
                      });
                      _loadData();
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else
          _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    final data = _data!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // ── Top section: Avatar | Info | Chat Icon ──────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Avatar with abbreviation/type badge
            Stack(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: data.imgurl.isNotEmpty &&
                      data.imgurl != '--'
                      ? NetworkImage(data.imgurl)
                      : null,
                  child: data.imgurl.isEmpty || data.imgurl == '--'
                      ? Text(
                    _initials,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(int.parse("0xFF$hexColor")),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      _resolvedAbbreviation, // ✅ uses widget.abbreviation (never data.position)
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()),

            // Name + Employment + Location
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fullName,
                    style: TextStyle(
                      fontSize: FontSize.s14,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.granitegray,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _inlineField('Employment Type', data.employment),
                  const SizedBox(height: 4),
                  Text(
                    data.city.isNotEmpty && data.city != '--'
                        ? data.city
                        : data.finalAddress.isNotEmpty &&
                        data.finalAddress != '--'
                        ? data.finalAddress
                        : '--',
                    style: TextStyle(
                      fontSize: FontSize.s12,
                      color: ColorManager.granitegray,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Chat icon
            SizedBox(
              width: 44,
              height: 44,
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    barrierColor: Colors.black.withOpacity(0.3),
                    builder: (BuildContext context) {
                      return Align(
                        alignment: Alignment.center,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            height: 500,
                            width: 550,
                            child: ChatBotContainer(
                              onClose: () => Navigator.of(context).pop(),
                              receiverEmpId: data.employeeId!,
                              receiverName: _fullName,
                              receiverImageUrl: data.imgurl != '--'
                                  ? data.imgurl
                                  : '',
                              receiverAbbreviation: _resolvedAbbreviation, // ✅ uses widget.abbreviation (never data.position)
                              receiverColor: data.color.isNotEmpty
                                  ? data.color
                                  : '#FFA500',
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: SvgPicture.asset('images/sm/contact_sv.svg'),
              ),
            ),
            const Expanded(flex: 2, child: SizedBox()),
          ],
        ),

        const SizedBox(height: 16),

        // ── Detail grid ───────────────────────────────────────────────────
        _detailRow(
          'Age:',
          _formatDobWithAge(data.dateOfBirth),
          'Speciality:',
          data.expertise.isNotEmpty && data.expertise != '--'
              ? data.expertise
              : '--',
        ),
        const SizedBox(height: 12),
        _detailRow(
          'Gender:',
          data.gender,
          'Service:',
          data.service,
        ),
        const SizedBox(height: 12),
        _detailRow(
          'Social Security No.:',
          data.SSNNbr.isNotEmpty && data.SSNNbr != '--'
              ? '*** ** ****'
              : '--',
          'Reporting Office:',
          data.regOfficId,
        ),
        const SizedBox(height: 12),
        _detailRow(
          'Phone Number:',
          data.primaryPhoneNbr,
          'Summary:',
          data.summary,
        ),
        const SizedBox(height: 12),
        _detailRow(
          'Personal Email:',
          data.personalEmail,
          'Hire Date:',
          _formatHireDateWithTenure(data.dateofHire),
        ),
        const SizedBox(height: 12),
        _detailRow(
          'Work Email:',
          data.workEmail,
          'Race:',
          data.race,
        ),
      ],
    );
  }

  // ── Inline field ──────────────────────────────────────────────────────────
  Widget _inlineField(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label  ',
            style: const TextStyle(
              fontSize: FontSize.s12,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: value.isNotEmpty && value != '--' ? value : '--',
            style: TextStyle(
              fontSize: FontSize.s12,
              color: ColorManager.granitegray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Two-column detail row ─────────────────────────────────────────────────
  Widget _detailRow(
      String leftLabel,
      String leftValue,
      String rightLabel,
      String rightValue,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _detailCell(leftLabel, leftValue)),
        Expanded(child: _detailCell(rightLabel, rightValue)),
      ],
    );
  }

  Widget _detailCell(String label, String value) {
    if (label.isEmpty) return const SizedBox.shrink();
    final isEmail = value.contains('@');
    final hasValue = value.isNotEmpty && value != '--';

    final Widget valueText = Text(
      hasValue ? value : '--',
      style: TextStyle(
        fontSize: FontSize.s12,
        color: isEmail ? ColorManager.blueprime : ColorManager.grey,
        fontWeight: FontWeight.w400,
        decoration:
        isEmail && hasValue ? TextDecoration.underline : TextDecoration.none,
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: FontSize.s12,
              color: ColorManager.granitegray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: isEmail && hasValue
              ? MouseRegion(
            cursor: SystemMouseCursors.click,
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: () => _launchEmail(value),
              child: valueText,
            ),
          )
              : valueText,
        ),
      ],
    );
  }
}