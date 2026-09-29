import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/intake/inirial_contact_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_intake_data/intake_initial_contact_data/initial_contact_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/constant_widgets/const_checckboxtile.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/textfield_dropdown_constant/schedular_textfield_const.dart';

class EmrInitialContactTab extends StatefulWidget {
  final int patientId;
  const EmrInitialContactTab({super.key, required this.patientId});

  @override
  State<EmrInitialContactTab> createState() => _EmrInitialContactTabState();
}

class _EmrInitialContactTabState extends State<EmrInitialContactTab> {
  // ── Cached future — prevents refetch/rebuild loop on every build ──
  late Future<List<PatientInitialContactData>> _initialContactFuture;

  @override
  void initState() {
    super.initState();
    _initialContactFuture = getInitialContactWithPtid(
      context: context,
      ptId: widget.patientId,
    );
  }

  Widget _buildIntroCallRow(String question, String answer,
      {bool isLink = false, String? subLabel}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: CustomTextStylesCommon.commonStyle(
              fontSize: FontSize.s11,
              fontWeight: FontWeight.w400,
              color: ColorManager.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: CustomTextStylesCommon.commonStyle(
              fontSize: FontSize.s12,
              fontWeight: FontWeight.w500,
              color: isLink ? ColorManager.blueprime : ColorManager.black,
            ),
          ),
          if (subLabel != null) ...[
            const SizedBox(height: 8),
            Text(
              subLabel,
              style: CustomTextStylesCommon.commonStyle(
                fontSize: FontSize.s11,
                fontWeight: FontWeight.w600,
                color: ColorManager.blueprime,
              ),
            ),
          ],
          const Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final diagnosisProvider =
    // Provider.of<DiagnosisProvider>(context, listen: false);

    bool isDementia = false;
    bool isCatheterCare = false;
    bool isWoundCare = false;
    bool isZenMed = false;
    bool isOrthoPatient = false;
    bool isPtInr = false;
    bool _isLoading = false;

    TextEditingController patientDcDateController = TextEditingController();

    return Consumer<SmIntakeProviderManager>(
      builder: (context, providerState, child) {
        return FutureBuilder(
            future: _initialContactFuture,
            builder: (context, snapshot) {
              // ── Loading ──────────────────────────────────────────────
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 100),
                  child: Center(
                    child: CircularProgressIndicator(
                        color: ColorManager.blueprime),
                  ),
                );
              }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  // Review hint
                  Padding(
                    padding: const EdgeInsets.only(
                        top: AppSize.s25, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Review and confirm the data pulled is correct ',
                          style: SMItalicTextConst.customTextStyle(context),
                        ),
                      ],
                    ),
                  ),

                    // ── Call Details ──────────────────────────────────
                    BlueBGHeadConst(
                      HeadText: 'Call Details',
                      body: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.isEmpty
                                ? 1
                                : snapshot.data!.length,
                            itemBuilder: (context, index) {
                              isDementia = snapshot.data!.isEmpty
                                  ? false
                                  : snapshot.data![index].introCallComplete;
                              isCatheterCare = snapshot.data!.isEmpty
                                  ? false
                                  : snapshot.data![index].demographicsConfirmed;
                              isWoundCare = snapshot.data!.isEmpty
                                  ? false
                                  : snapshot.data![index].patientIsHome;
                              isZenMed = snapshot.data!.isEmpty
                                  ? false
                                  : snapshot.data![index].consentsNeeded;
                              isOrthoPatient = snapshot.data!.isEmpty
                                  ? false
                                  : snapshot.data![index].representativePresentSoc;
                              isPtInr = snapshot.data!.isEmpty
                                  ? false
                                  : snapshot.data![index].sendConsentsForSign;

                              patientDcDateController = TextEditingController(
                                text: snapshot.data!.isEmpty ||
                                    snapshot.data![index].potentialDcDate ==
                                        '0000-00-00T00:00:00.000Z'
                                    ? ''
                                    : snapshot.data![index].potentialDcDate,
                              );

                              return Container(
                                padding: const EdgeInsets.only(top: 60),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        // ── Contact button column ────────
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 30.0),
                                                child: ElevatedButton(
                                                  onPressed: () {},
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                    ColorManager.blueprime,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(24),
                                                    ),
                                                    padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 10.0,
                                                    ),
                                                  ),

                                                  child: Text(
                                                    'Edit Intro Call Details',
                                                    style:BlueButtonTextConst.customTextStyle(context)
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // ── Intro Call + Demographics ────
                                        StatefulBuilder(
                                          builder: (context, setLocal) {
                                            return Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  CheckboxTile(
                                                    title: 'Intro Call Complete',
                                                    initialValue: isDementia,
                                                    onChanged: (value) {
                                                      setLocal(() =>
                                                      isDementia = value);
                                                    },
                                                  ),
                                                  CheckboxTile(
                                                    title: providerState.isContactTrue
                                                        ? 'Demographics\nConfirmed'
                                                        : 'Demographics Confirmed',
                                                    initialValue: isCatheterCare,
                                                    onChanged: (value) {
                                                      setLocal(() =>
                                                      isCatheterCare = value);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),

                                        // ── Patient is home + DC Date ────
                                        StatefulBuilder(
                                          builder: (context, setLocal) {
                                            return Expanded(
                                              flex: 2,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    CheckboxTile(
                                                      title: 'Patient is home',
                                                      initialValue: isWoundCare,
                                                      onChanged: (value) {
                                                        setLocal(() =>
                                                        isWoundCare = value);
                                                      },
                                                    ),
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0, top: 5),
                                                      child: SchedularTextField(
                                                        width: 215,
                                                        isIconVisible: true,
                                                        dateFormateMMDDYYYY: true,
                                                        controller:
                                                        patientDcDateController,
                                                        labelText:
                                                        'Potential DC Date',
                                                        showDatePicker: true,
                                                        enable: false,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),

                                        // ── Consents + Rep + Send ────────
                                        StatefulBuilder(
                                          builder: (context, setLocal) {
                                            return Expanded(
                                              flex: providerState.isContactTrue
                                                  ? 3
                                                  : 2,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    CheckboxTile(
                                                      title: 'Consents Needed',
                                                      initialValue: isZenMed,
                                                      onChanged: (value) {
                                                        setLocal(() =>
                                                        isZenMed = value);
                                                      },
                                                    ),
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                          left: 40),
                                                      child: ExpCheckboxTile(
                                                        title: providerState
                                                            .isContactTrue
                                                            ? 'Patient representative will be\npresent at SOC'
                                                            : 'Patient representative will be present at SOC',
                                                        initialValue: isOrthoPatient,
                                                        onChanged: (value) {
                                                          setLocal(() =>
                                                          isOrthoPatient = value);
                                                        },
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                          left: 40),
                                                      child: SizedBox(
                                                        width: 300,
                                                        child: ExpCheckboxTile(
                                                          icon: Image.asset(
                                                            'images/sm/sm_refferal/telegram.png',
                                                            height: 18,
                                                            width: 18,
                                                          ),
                                                          title:
                                                          'Send consents for signature',
                                                          initialValue: isPtInr,
                                                          isInfoIconVisible: true,
                                                          onChanged: (value) {
                                                            setLocal(() =>
                                                            isPtInr = value);
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 25, bottom: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Send via Docusign 1/25/2025 3:50pm by Henry, Rebecca',
                                            style: SMItalicTextConst.customTextStyle(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 10),
                        const Divider(),

                        // ── Intro Call Details Section ─────────────
                        // Commented out per request — full block preserved below.
                        /*
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: ColorManager.grey.withOpacity(0.5),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 15),

                                  // Section header
                                  Center(
                                    child: Text(
                                      'Intro Call Details',
                                      style: CustomTextStylesCommon.commonStyle(
                                        fontSize: FontSize.s14,
                                        fontWeight: FontWeight.w600,
                                        color: ColorManager.blueprime,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 25),

                                  _buildIntroCallRow(
                                    'Document who you are speaking with:',
                                    'Chris',
                                  ),
                                  _buildIntroCallRow(
                                    'Explain what home health is and what we provide:',
                                    '"Home health is home-based healthcare services that will be provided to you in the comfort of your home environment. Do you have any questions about this?"',
                                    subLabel: 'Explained',
                                  ),
                                  _buildIntroCallRow(
                                    'Are you currently being seen by another HH agency/going to an outpatient clinic/being seen by other nurses for care?',
                                    'Explained',
                                  ),
                                  _buildIntroCallRow(
                                    'We have received orders for:',
                                    'Nursing, Physical Therapy, Occupational Therapy, Home Health Aide',
                                    subLabel: 'Confirmed',
                                  ),
                                  _buildIntroCallRow(
                                    'Do you have someone coming to your home to help with wound care, medication management, showering, ADLs, or walking?',
                                    'No',
                                  ),
                                  _buildIntroCallRow(
                                    'Do you require assistance from another person to leave the home?',
                                    'Yes',
                                  ),
                                  _buildIntroCallRow(
                                    'Do you use a walker, cane or wheelchair?',
                                    'Yes, walker',
                                  ),
                                  _buildIntroCallRow(
                                    'Is it difficult for you to leave the home?',
                                    'Yes',
                                  ),
                                  _buildIntroCallRow(
                                    'Who should be the primary contact for scheduling and patient care?',
                                    'See Demographics',
                                    isLink: true,
                                  ),
                                  _buildIntroCallRow(
                                    'Who is your emergency contact?',
                                    'See Demographics',
                                    isLink: true,
                                  ),

                                  // ── New fields from screenshot ─────
                                  _buildIntroCallRow(
                                    'What is the best number or email to text or send a survey link to?',
                                    'See Demographics',
                                    isLink: true,
                                  ),
                                  _buildIntroCallRow(
                                    'Are you home and ready for us to start services?',
                                    'Yes',
                                  ),
                                  _buildIntroCallRow(
                                    'Can you sign your own consent forms?',
                                    'No',
                                  ),
                                  _buildIntroCallRow(
                                    'If the patient can not sign consent, who will be signing?',
                                    'See Demographics',
                                    isLink: true,
                                  ),
                                  _buildIntroCallRow(
                                    'Will this person be present during the SOC?',
                                    'No',
                                  ),
                                  _buildIntroCallRow(
                                    'If no, can we email them to you? (enter email above)',
                                    'See Demographics',
                                    isLink: true,
                                  ),
                                  _buildIntroCallRow(
                                    'What address are we coming out to provide care to?',
                                    'See Demographics',
                                    isLink: true,
                                  ),
                                  _buildIntroCallRow(
                                    'Who provides your transportation to your doctor\'s appointments?',
                                    'Chris, spouse',
                                  ),
                                  _buildIntroCallRow(
                                    'Can you please confirm your primary doctor/ surgeon/ specialist?',
                                    '',
                                  ),
                                  _buildIntroCallRow(
                                    'Do or any one you have been in contact with in the last 14 days have COVID or signs or symptoms of COVID? (fever >100.4, Difficulty breathing or Shortness of breath, cough, persistent pain or pressure in the chest, chills, Muscle pain/body aches, Sore throat, New loss of taste or smell, fatigue, Congestion or runny nose, Diarrhea, or Nausea and Vomiting.)',
                                    'No',
                                  ),
                                  _buildIntroCallRow(
                                    'Do you have any pets?',
                                    'No',
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Completed 1/25/2025 3:45pm by Henry, Rebecca',
                                          style: SMItalicTextConst.customTextStyle(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          */
                      ],
                    ),
                  ),

                  const SizedBox(height: 200),
                  // ── Save / Skip buttons ───────────────────────────
                  const SizedBox(height: AppSize.s30),
                ],
              ),
            );
          },
        );
      },
    );
  }
}