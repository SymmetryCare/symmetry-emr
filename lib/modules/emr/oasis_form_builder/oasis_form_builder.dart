import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/constants/app_text_style.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/constants/enums.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/constants/responsive.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/provider/sub_question_wrapper_provider.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/services/api/managers/form_builder_manager.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/provider/form_builder_provider.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/provider/question_wapper_provider.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/services/api/managers/patient_form_manager.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/side_drawer/side_drawer_item.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/side_drawer/side_drawer_provider.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/ui_components/overlays/local_notification_manager.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/ui_components/question_comment_panel.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/widgets/dynamic/model/question_data_model.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/widgets/dynamic/presentation/dynamic_question.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/widgets/static/presentation/static_question_box.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dash_manager/patient_visit_list_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/sucess_failed_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/discharge_visit.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_middle_widget_component/widgets/widgets/todays_visit_popups/view_start_visit.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/forms/oasis_rn_start_of_care/static_screens/wound_screen.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/forms/oasis_st_start_of_care/static_screens/static_functional_assessment.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/model/patient_form_model.dart';

class OasisFormBuilder extends StatefulWidget {
  final int subFormId;
  final int formId;
  final int patientFormID;
  String formTitle;
  String templateName;
  String userRole;
  String formStatus;
  String lastFormFillByAssist;
  int visitId;
  final ValueChanged<int>? onOrderAdded;
  final ValueChanged<int>? onFormChange;

  OasisFormBuilder({
    super.key,
    required this.subFormId,
    required this.formId,
    this.patientFormID = -1,
    this.visitId = 0,
    this.formTitle = "",
    this.templateName = "",
    this.userRole = "",
    this.formStatus = "",
    this.onOrderAdded,
    this.onFormChange,
    this.lastFormFillByAssist = "Clinitian",
  });


  @override
  State<OasisFormBuilder> createState() => _OasisFormBuilderState();
}

class _OasisFormBuilderState extends State<OasisFormBuilder> {
  int columns = 2;

  List<Widget> wideWidgets = [];

  List<Widget> comprehensiveQtn = [];

  List<Widget> nonComprehensiveQtn = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<SideDrawerItem> sideDrawerItems = [];

  int initialDrawerIndex = 0;

  int? _selectedQuestionId;
  String? _selectedQuestionTitle;

  Future<int>? _formFuture;
  List<Map<String, dynamic>> _pendingComments = [];
  Map<int, List<Map<String, dynamic>>> _preloadedCommentsByQuestion = {};
  Map<String, dynamic> _commentUsers = {};
  int _commentReloadToken = 0;

  void _reloadForm() {
    if (!mounted) return;
    setState(() {
      _formFuture = null;
      _pendingComments = [];
      _preloadedCommentsByQuestion = {};
      _commentUsers = {};
      _commentReloadToken++;
    });
  }

  @override
  void didUpdateWidget(covariant OasisFormBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subFormId != widget.subFormId ||
        oldWidget.patientFormID != widget.patientFormID ||
        oldWidget.formId != widget.formId) {
      _formFuture = null;
      _selectedQuestionId = null;
      _selectedQuestionTitle = null;
      _pendingComments = [];
      _preloadedCommentsByQuestion = {};
      _commentUsers = {};
    }
  }

  List<Map<String, dynamic>> _buildQuestionsWithComments(
      List<Map<String, dynamic>> questions) {
    final pendingByQuestion = <int, List<Map<String, dynamic>>>{};
    for (final c in _pendingComments) {
      final qId = c['question_id'] as int;
      final entry = Map<String, dynamic>.from(c)..remove('question_id');
      pendingByQuestion.putIfAbsent(qId, () => []).add(entry);
    }
    return questions.map((q) {
      final copy = Map<String, dynamic>.from(q);
      final qId = q['question_type_id'] as int?;
      if (qId == null) return copy;
      final existing = _preloadedCommentsByQuestion[qId] ?? [];
      final newComments = pendingByQuestion[qId] ?? [];
      if (existing.isNotEmpty || newComments.isNotEmpty) {
        copy['comments'] = [...existing, ...newComments];
      }
      return copy;
    }).toList();
  }

  Widget _wrapWithCommentTab(
    Widget questionWidget,
    QuestionDataModel question,
    VoidCallback onCommentTap,
  ) {
    final isSimpleText = question.answerType == AnswerType.info ||
        question.answerType == AnswerType.actionButton ||
        question.drawBox == false;

    if (isSimpleText) return questionWidget;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onCommentTap,
      child: questionWidget,
    );
  }

  void _resolvePreloadedComment(int questionId, int listIndex) {
    final comments = _preloadedCommentsByQuestion[questionId];
    if (comments == null || listIndex >= comments.length) return;
    setState(() {
      comments[listIndex] = Map<String, dynamic>.from(comments[listIndex])
        ..['resolution_status'] = true;
    });
  }

  void _deletePreloadedComment(int questionId, int listIndex) {
    final comments = _preloadedCommentsByQuestion[questionId];
    if (comments == null || listIndex >= comments.length) return;
    setState(() {
      comments.removeAt(listIndex);
    });
  }

  Color? _unresolvedColor(QuestionDataModel question) {
    final hasUnresolved = question.preloadedComments
        .any((c) => c['resolution_status'] == false);
    return hasUnresolved ? Colors.red.withValues(alpha: 0.08) : null;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    _formFuture ??= widget.patientFormID == -1
        ? getForm2(context, formID: widget.formId, subFormID: widget.subFormId)
        : getForm(context, patientFormID: widget.patientFormID, subFormId: widget.subFormId);
    return Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder(
          future: _formFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Center(
                  child: Text(
                'Loading Questions...',
                style: FormBuilderTextStyle.normal10style,
              ));
            }
            if (snap.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.userRole == "DME" || widget.userRole == "Clinical Manager" ?
                      const Offstage() :
                widget.userRole == "QA" ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 20,
                    children: [
                      InkWell(
                        onTap: () async {
                          final outerContext = context;
                          final formProvider = Provider.of<FormBuilderProvider>(
                              outerContext, listen: false);
                          await showDialog(
                            context: outerContext,
                            builder: (context) =>
                                StatefulBuilder(
                                  builder: (BuildContext context, void Function(void Function()) setState) {
                                    return
                                      DeletePopup(
                                        btnText: "Confirm",
                                        text: "Are you sure you want to send this form for correction?",
                                          title: "Confirmation",
                                          onCancel: () {
                                            Navigator.pop(context);
                                          },
                                          onDelete: () async {
                                            // Save form data before sending for correction
                                            await uploadAllImages(outerContext,
                                                formProvider.uploadTypeQuestions,
                                                deletedImageUrls: formProvider
                                                    .consumeDeletedImageUrlsQueue());
                                            if (!outerContext.mounted) return;
                                            await FormBuilderManager().savePatientForm(
                                              outerContext,
                                              patientFormID: widget.patientFormID,
                                              formData: {
                                                "subFormDataId": widget.subFormId,
                                                "data": {
                                                  "questions": _buildQuestionsWithComments(
                                                      formProvider.toJson()),
                                                }
                                              },
                                            );
                                            if (!context.mounted) return;
                                            final response = await FormBuilderManager().patchPatientForm(
                                                context,
                                                patientFormID: widget.patientFormID,
                                                formData: 'SENT_FOR_CORRECTION'
                                            );
                                            if (response.statusCode == 200 || response.statusCode == 201) {
                                              Navigator.pop(context, true);
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return const AddSuccessPopup(
                                                    message: 'Form Status Updated Successfully.',
                                                  );
                                                },
                                              );
                                              // Future.delayed(const Duration(milliseconds: 600));
                                              // Navigator.pop(context);
                                              // pass true so parent can refresh
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return const AddErrorPopup(
                                                    message: 'Something went wrong!',
                                                  );
                                                },
                                              );
                                            }
                                          }
                                      );
                                  },
                                ),
                          );

                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: ColorManager.blueprime,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(20))),
                          padding: EdgeInsets.symmetric(
                              horizontal: Responsive.isMobile(context)
                                  ? 40
                                  : 30,
                              vertical: Responsive.isMobile(context)
                                  ? 15
                                  : 10),
                          child: Text(
                            "Send For Correction",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      // const SizedBox(
                      //   width: 20,
                      // ),
                      InkWell(
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (context) =>
                                StatefulBuilder(
                                  builder: (BuildContext context, void Function(void Function()) setState) {
                                    return
                                      DeletePopup(
                                         text: "Are you sure you want to approve this form?",
                                          title: "Approve",
                                          btnText: "Approve",
                                          onCancel: () {
                                            Navigator.pop(context);
                                          },
                                          onDelete: () async {
                                            final response = await FormBuilderManager().patchPatientForm(
                                                context,
                                                patientFormID: widget.patientFormID,
                                                formData: 'QA_APPROVED'
                                            );
                                            if (response.statusCode == 200 || response.statusCode == 201) {
                                              Navigator.pop(context, true);
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return const AddSuccessPopup(
                                                    message: 'Form Approved Successfully.',
                                                  );
                                                },
                                              );
                                              // pass true so parent can refresh
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return const AddErrorPopup(
                                                    message: 'Something went wrong!',
                                                  );
                                                },
                                              );
                                            }
                                          }
                                      );
                                  },
                                ),
                          );

                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: ColorManager.blueprime,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(20))),
                          padding: EdgeInsets.symmetric(
                              horizontal: Responsive.isMobile(context)
                                  ? 40
                                  : 30,
                              vertical: Responsive.isMobile(context)
                                  ? 15
                                  : 10),
                          child: Text(
                            "Approve",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ) : widget.userRole == "Coder" ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 20,
                    children: [
                      InkWell(
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (context) => const EMRUnderDevelopmentPopup(),
                          );
                        },

                        // onTap: () async {
                        //   await showDialog(
                        //     context: context,
                        //     builder: (context) =>
                        //         StatefulBuilder(
                        //           builder: (BuildContext context, void Function(void Function()) setState) {
                        //             return
                        //               ConfirmOasisFormPopup(
                        //                   text: "You're about to mark this form as F2F Needed.\nDo you want to continue?",
                        //                   title: "F2F Needed",
                        //                   btnText: "Mark & Close",
                        //                   onCancel: () {
                        //                     Navigator.pop(context);
                        //                   },
                        //                   onDelete: () async {
                        //                     final response = await FormBuilderManager().patchPatientForm(
                        //                         context,
                        //                         patientFormID: widget.patientFormID,
                        //                         formData: 'F2F_NEEDED',
                        //                         isFaceToFace: true
                        //                     );
                        //                     if (response.statusCode == 200 || response.statusCode == 201) {
                        //                       Navigator.pop(context, true);
                        //                       showDialog(
                        //                         context: context,
                        //                         builder: (BuildContext context) {
                        //                           return const AddSuccessPopup(
                        //                             message: 'F2f Added Successfully.',
                        //                           );
                        //                         },
                        //                       );
                        //                       // pass true so parent can refresh
                        //                     } else {
                        //                       showDialog(
                        //                         context: context,
                        //                         builder: (BuildContext context) {
                        //                           return const AddErrorPopup(
                        //                             message: 'Something went wrong!',
                        //                           );
                        //                         },
                        //                       );
                        //                     }
                        //                   },
                        //                 btnText2: "Mark & Stay",
                        //                 onClickBtn2: () async{
                        //                   final response = await FormBuilderManager().patchPatientForm(
                        //                       context,
                        //                       patientFormID: widget.patientFormID,
                        //                       formData: 'F2F_NEEDED',
                        //                     isFaceToFace: true
                        //                   );
                        //                   if (response.statusCode == 200 || response.statusCode == 201) {
                        //                     Navigator.pop(context, true);
                        //                     showDialog(
                        //                       context: context,
                        //                       builder: (BuildContext context) {
                        //                         return const AddSuccessPopup(
                        //                           message: 'F2F Added Successfully.',
                        //                         );
                        //                       },
                        //                     );
                        //                     // pass true so parent can refresh
                        //                   } else {
                        //                     showDialog(
                        //                       context: context,
                        //                       builder: (BuildContext context) {
                        //                         return const AddErrorPopup(
                        //                           message: 'Something went wrong!',
                        //                         );
                        //                       },
                        //                     );
                        //                   }
                        //                 },
                        //               );
                        //           },
                        //         ),
                        //   );
                        // },
                        child: Container(
                          decoration: BoxDecoration(
                              color: ColorManager.blueprime,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(20))),
                          padding: EdgeInsets.symmetric(
                              horizontal: Responsive.isMobile(context)
                                  ? 40
                                  : 30,
                              vertical: Responsive.isMobile(context)
                                  ? 15
                                  : 10),
                          child: Text(
                            "F2F Needed",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
//TODO  this feature is coming soon
                      // InkWell(
                      //   onTap: () async {
                      //     await showDialog(
                      //       context: context,
                      //       builder: (context) =>
                      //           StatefulBuilder(
                      //             builder: (BuildContext context, void Function(void Function()) setState) {
                      //               return
                      //                 DeletePopup(
                      //                     btnText: "Confirm",
                      //                     text: "Are you sure you want to send this form for correction?",
                      //                     title: "Confirmation",
                      //                     onCancel: () {
                      //                       Navigator.pop(context);
                      //                     },
                      //                     onDelete: () async {
                      //                       final response = await FormBuilderManager().patchPatientForm(
                      //                           context,
                      //                           patientFormID: widget.patientFormID,
                      //                           formData: 'CODER_SENT_FOR_CORRECTION'
                      //                       );
                      //                       if (response.statusCode == 200 || response.statusCode == 201) {
                      //                         Navigator.pop(context, true);
                      //                         showDialog(
                      //                           context: context,
                      //                           builder: (BuildContext context) {
                      //                             return const AddSuccessPopup(
                      //                               message: 'Form Status Updated Successfully.',
                      //                             );
                      //                           },
                      //                         );
                      //                         Future.delayed(const Duration(milliseconds: 600));
                      //                         Navigator.pop(context);
                      //                         // pass true so parent can refresh
                      //                       } else {
                      //                         showDialog(
                      //                           context: context,
                      //                           builder: (BuildContext context) {
                      //                             return const AddErrorPopup(
                      //                               message: 'Something went wrong!',
                      //                             );
                      //                           },
                      //                         );
                      //                       }
                      //                     }
                      //                 );
                      //             },
                      //           ),
                      //     );
                      //   },
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //         color: ColorManager.blueprime,
                      //         borderRadius: const BorderRadius.all(
                      //             Radius.circular(20))),
                      //     padding: EdgeInsets.symmetric(
                      //         horizontal: Responsive.isMobile(context)
                      //             ? 40
                      //             : 30,
                      //         vertical: Responsive.isMobile(context)
                      //             ? 15
                      //             : 10),
                      //     child: Text(
                      //       "Send For Correction",
                      //       style: Theme.of(context)
                      //           .textTheme
                      //           .bodyMedium!
                      //           .copyWith(
                      //           color: Colors.white,
                      //           fontWeight: FontWeight.bold),
                      //     ),
                      //   ),
                      // ),
                      InkWell(
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (context) =>
                                StatefulBuilder(
                                  builder: (BuildContext context, void Function(void Function()) setState) {
                                    return
                                      DeletePopup(
                                          text: "Are you sure you want to approve this form?",
                                          title: "Approve",
                                          btnText: "Approve",
                                          onCancel: () {
                                            Navigator.pop(context);
                                          },
                                          onDelete: () async {
                                            final response = await FormBuilderManager().patchPatientForm(
                                                context,
                                                patientFormID: widget.patientFormID,
                                                formData: 'COMPLETED'
                                            );
                                            if (response.statusCode == 200 || response.statusCode == 201) {
                                              Navigator.pop(context, true);
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return const AddSuccessPopup(
                                                    message: 'Form Approved Successfully.',
                                                  );
                                                },
                                              );
                                              // pass true so parent can refresh
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return const AddErrorPopup(
                                                    message: 'Something went wrong!',
                                                  );
                                                },
                                              );
                                            }
                                          }
                                      );
                                  },
                                ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: ColorManager.blueprime,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(20))),
                          padding: EdgeInsets.symmetric(
                              horizontal: Responsive.isMobile(context)
                                  ? 40
                                  : 30,
                              vertical: Responsive.isMobile(context)
                                  ? 15
                                  : 10),
                          child: Text(
                            "Approve",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                    ],
                  ),
                ):Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                    child: Row(
                       mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 20,
                      children: [
                        ///add order button do not delete
                        // InkWell(
                        //   onTap: () async {
                        //     await showDialog(
                        //       context: context,
                        //       builder: (context) =>
                        //           StatefulBuilder(
                        //             builder: (BuildContext context, void Function(void Function()) setState) {
                        //               return
                        //                 DeletePopup(
                        //                     text: "Are you sure you want to Add Physician order?",
                        //                     title: "Add Physician order",
                        //                     btnText: "Confirm",
                        //                     onCancel: () {
                        //                       Navigator.pop(context);
                        //                     },
                        //                     onDelete: () async {
                        //                      var responseAddOrder = await FormBuilderManager().patchAssignPhysicianOrderForm(
                        //                           context,
                        //                           patientFormID: widget.patientFormID,
                        //                       );
                        //                      if(responseAddOrder.success == true){
                        //                        final result = await getPatientFormByPatientID(
                        //                          context,
                        //                          patientFormId: widget.patientFormID,
                        //                        );
                        //                        // Reload this form's questions
                        //                        _reloadForm();
                        //
                        //                        // Notify parent (OasisFormMapper) to rebuild sidebar
                        //                        widget.onOrderAdded?.call(widget.patientFormID);
                        //                        Navigator.pop(context);
                        //                      }
                        //                     }
                        //                 );
                        //             },
                        //           ),
                        //     );
                        //   },
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //         color: ColorManager.blueprime,
                        //         borderRadius: const BorderRadius.all(
                        //             Radius.circular(20))),
                        //     padding: EdgeInsets.symmetric(
                        //         horizontal: Responsive.isMobile(context)
                        //             ? 40
                        //             : 30,
                        //         vertical: Responsive.isMobile(context)
                        //             ? 15
                        //             : 10),
                        //     child: Text(
                        //       "Add Order",
                        //       style: Theme.of(context)
                        //           .textTheme
                        //           .bodyMedium!
                        //           .copyWith(
                        //           color: Colors.white,
                        //           fontWeight: FontWeight.bold),
                        //     ),
                        //   ),
                        // ),
                        InkWell(
                          onTap: () async {
                            final outerContext = context;
                            final formProvider = Provider.of<FormBuilderProvider>(
                                outerContext, listen: false);
                            await showDialog(
                              context: outerContext,
                              builder: (context) =>
                                  StatefulBuilder(
                                    builder: (BuildContext context, void Function(void Function()) setState) {
                                      return
                                        DeletePopup(
                                            text: widget.lastFormFillByAssist == "assistant"?
                                            "Are you sure you want to approve this form?":
                                            "Are you sure you want to submit this form?",
                                            title: widget.lastFormFillByAssist == "assistant"?
                                            "Review Form":
                                            "Submit Form",
                                            btnText: widget.lastFormFillByAssist == "assistant" ?
                                            "Review":
                                            "Submit",
                                            onCancel: () {
                                              Navigator.pop(context);
                                            },
                                            onDelete: () async {
                                              // Save form data before submitting
                                              // ─── Main submit logic ───────────────────────────────────────────────────────

                                              await uploadAllImages(
                                                outerContext,
                                                formProvider.uploadTypeQuestions,
                                                deletedImageUrls: formProvider.consumeDeletedImageUrlsQueue(),
                                              );

                                              if (!outerContext.mounted) return;

                                              await FormBuilderManager().savePatientForm(
                                                outerContext,
                                                patientFormID: widget.patientFormID,
                                                formData: {
                                                  "subFormDataId": widget.subFormId,
                                                  "data": {
                                                    "questions": _buildQuestionsWithComments(formProvider.toJson()),
                                                  }
                                                },
                                              );

                                              if (!outerContext.mounted) return;

                                              final bool isAssistantReview = widget.lastFormFillByAssist == "assistant";

                                              final response = isAssistantReview
                                                  ? await FormBuilderManager().patchIsAssistantFormReview(
                                                context: context,
                                                visitId: widget.visitId,
                                                patientFormId: widget.patientFormID,
                                              )
                                                  : await FormBuilderManager().patchPatientForm(
                                                context,
                                                patientFormID: widget.patientFormID,
                                                formData: widget.formStatus == "needs_correction"
                                                    ? "CORRECTED"
                                                    : "SUBMITTED_BY_CLINICIAN",
                                              );

                                              if (!context.mounted) return;

                                              if (response.statusCode == 200 || response.statusCode == 201) {
                                                // Close the current form screen
                                                Navigator.pop(context, true);

                                                if (!context.mounted) return;

                                                if (isAssistantReview) {
                                                  // ── Assistant review: just show success ──
                                                  showDialog(
                                                    context: context,
                                                    builder: (dialogContext) => FormChangePopup(
                                                      title: 'Supervisory Note',
                                                      text: 'Do you want to fill out the Supervisory Note for this visit?',
                                                      btnText: "Yes",
                                                      onCancel: () {
                                                        // User dismissed — dialog closes on its own
                                                      },
                                                      onDelete: () {
                                                        // Close the follow-up dialog

                                                        Navigator.pop(dialogContext); // ← close only the dialog, NOT the form screen

                                                        // Trigger reload and navigate to next form
                                                        _reloadForm();
                                                        widget.onFormChange?.call(response.supervisoryNoteFormID!);

                                                        if (!context.mounted) return;

                                                        // Show success after navigation
                                                        showDialog(
                                                          context: context,
                                                          builder: (ctx) => const AddSuccessPopup(
                                                            message: 'Form Submitted Successfully.',
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  );
                                                  // showDialog(
                                                  //   context: context,
                                                  //   builder: (ctx) => AddSuccessPopup(
                                                  //     message: 'Form Approved Successfully',
                                                  //   ),
                                                  // );
                                                } else {
                                                  // ── Clinician submission ──
                                                  final bool hasNextForm =
                                                      response.nextPatientFormId != null && response.nextPatientFormId != 0;
                                                  if (!hasNextForm) {
                                                    // No follow-up form — just show success
                                                    showDialog(
                                                      context: context,
                                                      builder: (ctx) => const AddSuccessPopup(
                                                        message: 'Form Submitted Successfully.',
                                                      ),
                                                    );
                                                  } else {
                                                    // Determine follow-up dialog content based on form ID
                                                    final bool isReassessmentForm =
                                                        response.nextFormName == "Reassessment" ||
                                                        response.nextFormName == "Follow Up";
                                                    if(isReassessmentForm){
                                                      showDialog(
                                                        context: context,
                                                        builder: (dialogContext) => FormChangePopup(
                                                          title: response.nextFormName == "Reassessment"
                                                              ? 'Reassessment'
                                                              : 'Discipline Follow-Up Visit Note',
                                                          text: response.nextFormName == "Reassessment"
                                                              ? 'Would you like to complete the Reassessment Form?'
                                                              : 'Do you want to fill out the Discipline Follow-Up Visit Note (PT/OT/ST) for this visit?',
                                                          btnText: "Yes",
                                                          onCancel: () {
                                                            // User dismissed — dialog closes on its own
                                                          },
                                                          onDelete: () {
                                                            // Close the follow-up dialog
                                                            Navigator.pop(dialogContext); // ← close only the dialog, NOT the form screen

                                                            // Trigger reload and navigate to next form
                                                            _reloadForm();
                                                            widget.onFormChange?.call(response.nextPatientFormId!);

                                                            if (!context.mounted) return;

                                                            // Show success after navigation
                                                            showDialog(
                                                              context: context,
                                                              builder: (ctx) => const AddSuccessPopup(
                                                                message: 'Form Submitted Successfully.',
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    }
                                                    // else {
                                                    //   final visitData = await getVisitDataUsingVisitId(
                                                    //     context: context,
                                                    //     visitId: visit.visitId,
                                                    //   );
                                                    //
                                                    //   if (visitData.isLastEpisode == true) {
                                                    //     if (!mounted) return;
                                                    //     showDialog(
                                                    //       context: context,
                                                    //       builder: (_) => DischargeVisitTypePopup(
                                                    //         visitData: visitData,
                                                    //         onNevigate: () {
                                                    //           showDialog(
                                                    //             context: context,
                                                    //             builder: (_) => ViewStartVisit(
                                                    //               visitData: visitData,
                                                    //               onRefresh: () {},
                                                    //             ),
                                                    //           );
                                                    //         },
                                                    //       ),
                                                    //     );
                                                    //   } else {
                                                    //     // Trigger reload and navigate to next form
                                                    //     _reloadForm();
                                                    //     widget.onFormChange?.call(response.nextPatientFormId!);
                                                    //   }
                                                    // }
                                                  }
                                                }
                                              } else {
                                                // ── Error response ──
                                                showDialog(
                                                  context: context,
                                                  builder: (ctx) => const AddErrorPopup(
                                                    message: 'Something went wrong!',
                                                  ),
                                                );
                                              }
                                            }
                                        );
                                    },
                                  ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: ColorManager.blueprime,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            padding: EdgeInsets.symmetric(
                                horizontal: Responsive.isMobile(context)
                                    ? 40
                                    : 30,
                                vertical: Responsive.isMobile(context)
                                    ? 15
                                    : 10),
                            child: Text(
                              widget.lastFormFillByAssist == "assistant" ?
                              "Review":
                              "Submit",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        // const SizedBox(
                        //   width: 20,
                        // ),
                        InkWell(
                          onTap: () async {
                            await showDialog(
                              context: context,
                              builder: (context) =>
                                  StatefulBuilder(
                                    builder: (BuildContext context, void Function(void Function()) setState) {
                                      return
                                        DeletePopup(
                                            text: "Are you sure you want to restart this visit?\nAll data will be lost",
                                            title: "Restart Visit",
                                            btnText: "Restart",
                                            onCancel: () {
                                              Navigator.pop(context);
                                            },
                                            onDelete: () async {
                                              final response = await FormBuilderManager().patchPatientFormRestart(
                                                  context,
                                                  widget.patientFormID,
                                              );
                                              if (response.statusCode == 200 || response.statusCode == 201) {
                                                Navigator.pop(context);
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return const AddSuccessPopup(
                                                      message: 'Restart visit Successfully.',
                                                    );
                                                  },
                                                );
                                                // Reload this form's questions
                                                _reloadForm();

                                                // Notify parent (OasisFormMapper) to rebuild sidebar
                                                widget.onOrderAdded?.call(widget.patientFormID);
                                                // pass true so parent can refresh
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return const AddErrorPopup(
                                                      message: 'Something went wrong!',
                                                    );
                                                  },
                                                );
                                              }
                                            }
                                        );
                                    },
                                  ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: ColorManager.blueprime,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            padding: EdgeInsets.symmetric(
                                horizontal: Responsive.isMobile(context)
                                    ? 40
                                    : 30,
                                vertical: Responsive.isMobile(context)
                                    ? 15
                                    : 10),
                            child: Text(
                              "Restart",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                  Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10.h,
                          children: [
                            Text(
                              widget.templateName,
                              style: FormBuilderTextStyle.bold14style.copyWith(
                                  fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              widget.formTitle,
                              style: FormBuilderTextStyle.bold14style
                                  .copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                      ),

                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ListView(
                            children: [
                              ...wideWidgets,
                        Responsive(
                          tablet: Column(
                            children: [
                              ...comprehensiveQtn,
                              ...nonComprehensiveQtn,
                            ],
                          ),
                          desktop: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              comprehensiveQtn.isNotEmpty
                                  ? Expanded(
                                      child: Column(
                                        children: comprehensiveQtn,
                                      ),
                                    )
                                  : const SizedBox(
                                      width: 1,
                                    ),
                              nonComprehensiveQtn.isNotEmpty
                                  ? Expanded(
                                      child: Column(
                                      children: nonComprehensiveQtn,
                                    ))
                                  : const SizedBox(
                                      width: 1,
                                    ),
                            ],
                          ),
                        ),
                              widget.userRole == "DME" || widget.userRole == "Clinical Manager" ?
                              const Offstage() :
                              Container(
                          height: 200,
                          width: double.maxFinite,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: ColorManager.white,
                                      border: Border.all(
                                          color: ColorManager.blueprime,
                                          width: 1),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20))),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Responsive.isMobile(context)
                                          ? 40
                                          : 70,
                                      vertical: Responsive.isMobile(context)
                                          ? 15
                                          : 10),
                                  child: Text(
                                    "Cancel",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: ColorManager.blueprime,
                                            fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 50,
                              ),
                              InkWell(
                                onTap: () async {
                                  final formProvider =
                                      Provider.of<FormBuilderProvider>(context,
                                          listen: false);

                                  // Validate frequency selection for evaluation forms
                                  const freqQuestionIds = {310564008, 320581009, 330594009, 300547007, 100313008, 110348008, 120383008, 130416008, 470773008, 480808008, 490843008, 500876008};
                                  bool freqInvalid = false;
                                  outer:
                                  for (final wrapper in formProvider.wrapperQuestions) {
                                    if (freqQuestionIds.contains(wrapper.question.id)) {
                                      for (final sub in wrapper.subQuestionWrappers) {
                                        final val = sub.subQuestion.options.isNotEmpty
                                            ? sub.subQuestion.options.first.value
                                            : '';
                                        final dates = val.split(',').where((s) => s.trim().isNotEmpty).toList();
                                        if (dates.isNotEmpty && dates.length < 2) {
                                          freqInvalid = true;
                                          break outer;
                                        }
                                      }
                                    }
                                  }
                                  if (freqInvalid) {
                                    await showDialog(
                                      context: context,
                                      builder: (ctx) => const AddErrorPopup(
                                        message: 'Please select more than one visit in date calendar',
                                      ),
                                    );
                                    return;
                                  }

                                  final overlay = OverlayEntry(
                                      builder: (BuildContext context) {
                                    return Positioned.fill(
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Container(),
                                      ),
                                    );
                                  });
                                  Overlay.of(context).insert(overlay);

                                  // For Uploading Signatures If Any
                                  await uploadAllImages(context,
                                      formProvider.uploadTypeQuestions,
                                      deletedImageUrls: formProvider
                                          .consumeDeletedImageUrlsQueue());
                                  await FormBuilderManager().savePatientForm(
                                    context,
                                    patientFormID: widget.patientFormID,
                                    formData: {
                                      "subFormDataId": widget.subFormId,
                                      "data": {
                                        "questions": _buildQuestionsWithComments(formProvider.toJson()),
                                      }
                                    },
                                  ).then((result) {
                                    if (result) {
                                      // formProvider.uploadTypeQuestions.forEach(
                                      //     (questionWrapper) =>
                                      //         questionWrapper.forceNotify());
                                      LocalNotificationManager
                                          .showSuccessNotification(
                                              context, 'Saved!',
                                              subtitle:
                                                  'Form has been saved successfully!');
                                      // FIX: only reload this subform's data
                                      // when a comment was part of this save
                                      // — a normal answer-only save keeps
                                      // working exactly as before.
                                      if (_pendingComments.isNotEmpty) {
                                        _reloadForm();
                                      }
                                    } else {
                                      LocalNotificationManager
                                          .showErrorNotification(
                                              context, 'Not Saved!',
                                              subtitle:
                                                  'Form has not been saved. Please try again!');
                                    }
                                  });
                                  overlay.remove();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: ColorManager.blueprime,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20))),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Responsive.isMobile(context)
                                          ? 40
                                          : 70,
                                      vertical: Responsive.isMobile(context)
                                          ? 15
                                          : 10),
                                  child: Text(
                                    "Save",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            ],
                          ),
                        ),
                        if (_selectedQuestionId != null)
                          Padding(
                            padding: const EdgeInsets.only(right:15),
                            child: QuestionCommentPanel(
                              key: ValueKey(_selectedQuestionId),
                              patientFormId: widget.patientFormID,
                              questionId: _selectedQuestionId!,
                              questionTitle: _selectedQuestionTitle ?? '',
                              initialComments: _preloadedCommentsByQuestion[_selectedQuestionId] ?? [],
                              commentUsers: _commentUsers,
                              reloadToken: _commentReloadToken,
                              onCommentResolved: _resolvePreloadedComment,
                              onCommentDeleted: _deletePreloadedComment,
                              onClose: () => setState(() {
                                _selectedQuestionId = null;
                                _selectedQuestionTitle = null;
                              }),
                              onCommentAdded: (qId, comment, index) async{
                                final usrId = await TokenManager.getuserId();
                                setState(() {
                                  _pendingComments.add({
                                    'question_id': qId,
                                    'comment': comment,
                                    "created_at": DateTime.now().toIso8601String(),
                                    "modified_at": DateTime.now().toIso8601String(),
                                    "user_id":usrId,
                                    "resolution_status":false,
                                    "index":index,
                                  });
                                  print('Pending Comments: $_pendingComments');
                                });
                                if (!context.mounted) return;
                                final formProvider = Provider.of<FormBuilderProvider>(
                                    context, listen: false);
                                await uploadAllImages(context,
                                    formProvider.uploadTypeQuestions,
                                    deletedImageUrls: formProvider
                                        .consumeDeletedImageUrlsQueue());
                                if (!context.mounted) return;
                                await FormBuilderManager().savePatientForm(
                                  context,
                                  patientFormID: widget.patientFormID,
                                  formData: {
                                    "subFormDataId": widget.subFormId,
                                    "data": {
                                      "questions": _buildQuestionsWithComments(
                                          formProvider.toJson()),
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }

            if (snap.hasError) {
              return Center(child: Text("Error : ${snap.error}"));
            } else {
              return const Center(child: Text("Error"));
            }
          }),
    );

  }

  SideDrawerItem _buildSidebarItem(PatientForm form, PatientSubForm subForm) {
    //Return Static Screens Here With Their Case. [Case is Subform ID]
    switch (subForm.subFormID) {
      case 19:
      case 164:
      case 300:
      case 539:
      case 701:
      case 760:
      case 892:
      case 998:
        return SideDrawerItem(
          itemTitle: subForm.subFormName,
          widget: WoundScreen(
            subFormId: subForm.subFormID,
            formId: form.formID,
            patientFormID: subForm.patientFormID,
            formTitle: subForm.subFormName,
            templateName: form.formName,
          ),
          commentCount: subForm.commentCount
        );
      case 129:
      case 271:
      case 407:
      case 591:
      case 659:
      case 867:
      case 972:
      case 1082:
        return SideDrawerItem(
          itemTitle: subForm.subFormName,
          widget: StaticFunctionalAssessment(
            subFormId: subForm.subFormID,
            formId: form.formID,
            patientFormID: subForm.patientFormID,
            formTitle: subForm.subFormName,
            templateName: form.formName,
          ),
          commentCount: subForm.commentCount
        );
      default:
        return SideDrawerItem(
          itemTitle: subForm.subFormName,
          widget: OasisFormBuilder(
            subFormId: subForm.subFormID,
            formId: form.formID,
            patientFormID: subForm.patientFormID,
            formTitle: subForm.subFormName,
            templateName: form.formName,
            userRole: widget.userRole,
          ),
          commentCount: subForm.commentCount
        );
    }
  }

  Future<int> getForm(
    BuildContext context, {
    required int patientFormID,
        required int subFormId
  }) async
  {
    final result = await FormBuilderManager()
        .getPatientFormByPatientFormID(context, patientFormId: patientFormID, subFormId: subFormId);
    final List<QuestionDataModel> response = (result['questions'] as List).cast<QuestionDataModel>();
    _commentUsers = (result['commentUsers'] as Map<String, dynamic>?) ?? {};
    final formProvider =
        Provider.of<FormBuilderProvider>(context, listen: false);
    formProvider.clear();
    comprehensiveQtn.clear();
    nonComprehensiveQtn.clear();
    wideWidgets.clear();
    formProvider.wrapperQuestions =
        response.map((q) => QuestionWrapper(question: q)).toList();

    _preloadedCommentsByQuestion = {
      for (final w in formProvider.wrapperQuestions)
        if (w.question.preloadedComments.isNotEmpty)
          w.question.id: w.question.preloadedComments,
    };

    for (var wrapper in formProvider.wrapperQuestions) {
      try {
        void onQuestionTap() {
          if (mounted) {
            setState(() {
              _selectedQuestionId = wrapper.question.id;
              _selectedQuestionTitle = wrapper.question.title ?? wrapper.question.code ?? '';
            });
          }
        }

        if (wrapper.question.dynamicType!) {
          if (wrapper.question.questionType == QuestionType.comprehensive) {
            comprehensiveQtn.add(_wrapWithCommentTab(
              DynamicQuestion(questionWrapper: wrapper, highlightColor: _unresolvedColor(wrapper.question)),
              wrapper.question,
              onQuestionTap,
            ));
          } else if (wrapper.question.questionType == QuestionType.both) {
            wideWidgets.add(_wrapWithCommentTab(
              DynamicQuestion(questionWrapper: wrapper, highlightColor: _unresolvedColor(wrapper.question)),
              wrapper.question,
              onQuestionTap,
            ));
          } else {
            nonComprehensiveQtn.add(_wrapWithCommentTab(
              DynamicQuestion(questionWrapper: wrapper, highlightColor: _unresolvedColor(wrapper.question)),
              wrapper.question,
              onQuestionTap,
            ));
          }
        } else {
          if (wrapper.question.questionType == QuestionType.comprehensive) {
            comprehensiveQtn.add(_wrapWithCommentTab(
              StaticQuestionBox(
                questionWrapper: wrapper,
                templetName: widget.templateName,
                highlightColor: _unresolvedColor(wrapper.question),
              ),
              wrapper.question,
              onQuestionTap,
            ));
          } else if (wrapper.question.questionType == QuestionType.both) {
            wideWidgets.add(_wrapWithCommentTab(
              StaticQuestionBox(
                templetName: widget.templateName,
                questionWrapper: wrapper,
                highlightColor: _unresolvedColor(wrapper.question),
              ),
              wrapper.question,
              onQuestionTap,
            ));
          } else {
            nonComprehensiveQtn.add(_wrapWithCommentTab(
              StaticQuestionBox(
                templetName: widget.templateName,
                questionWrapper: wrapper,
                highlightColor: _unresolvedColor(wrapper.question),
              ),
              wrapper.question,
              onQuestionTap,
            ));
          }
        }

        //Initializing text editing controllers when there is text field or text area
        if (wrapper.question.answerType == AnswerType.textArea ||
            wrapper.question.answerType == AnswerType.textBox) {
          for (int i = 0; i < wrapper.question.options!.length; i++) {
            wrapper.question.options![i].textEditingController =
                TextEditingController(
                    text: wrapper.question.options![i].value);
          }
        }
        //To get list of upload widgets so that we can handle image upload and delete functionality
        if (wrapper.question.answerType == AnswerType.upload ||
            wrapper.question.subQuestions.any(
              (element) => element.type == AnswerType.upload,
            )) {
          formProvider.addUploadTypeWrapper(wrapper);
        }
        formProvider.addQuestion(wrapper.question);
      } catch (e) {
        print("In conversion error");
        print(e);
      }
    }
    return 1;
  }

  Future<int> getForm2(BuildContext context,
      {required int formID, required int subFormID}) async {
    // List<ChartQuestionDataModel> response = await FormBuilderManager()
    //     .getPatientFormByID(context, patientId: patientId);
    List<QuestionDataModel> response =
        await FormBuilderManager().getDummyDataPatientFormByID(
      context,
      patientId: subFormID,
      formId: formID,
    );

    columns = await FormBuilderManager()
        .getColumns(patientId: subFormID, formId: formID);
    widget.formTitle = await FormBuilderManager()
        .getFormTitle(patientId: subFormID, formId: formID);
    widget.templateName = await FormBuilderManager()
        .getFormTemplateName(patientId: subFormID, formId: formID);
    final formProvider =
        Provider.of<FormBuilderProvider>(context, listen: false);
    formProvider.clear();
    comprehensiveQtn.clear();
    nonComprehensiveQtn.clear();
    wideWidgets.clear();
    formProvider.wrapperQuestions =
        response.map((q) => QuestionWrapper(question: q)).toList();

    _preloadedCommentsByQuestion = {
      for (final w in formProvider.wrapperQuestions)
        if (w.question.preloadedComments.isNotEmpty)
          w.question.id: w.question.preloadedComments,
    };

    for (var wrapper in formProvider.wrapperQuestions) {
      try {
        void onQuestionTap() {
          if (mounted) {
            setState(() {
              _selectedQuestionId = wrapper.question.id;
              _selectedQuestionTitle = wrapper.question.title ?? wrapper.question.code ?? '';
            });
          }
        }

        if (wrapper.question.dynamicType!) {
          if (wrapper.question.questionType == QuestionType.comprehensive) {
            comprehensiveQtn.add(_wrapWithCommentTab(
              DynamicQuestion(questionWrapper: wrapper, highlightColor: _unresolvedColor(wrapper.question)),
              wrapper.question,
              onQuestionTap,
            ));
          } else if (wrapper.question.questionType == QuestionType.both) {
            wideWidgets.add(_wrapWithCommentTab(
              DynamicQuestion(questionWrapper: wrapper, highlightColor: _unresolvedColor(wrapper.question)),
              wrapper.question,
              onQuestionTap,
            ));
          } else {
            nonComprehensiveQtn.add(_wrapWithCommentTab(
              DynamicQuestion(questionWrapper: wrapper, highlightColor: _unresolvedColor(wrapper.question)),
              wrapper.question,
              onQuestionTap,
            ));
          }
        } else {
          if (wrapper.question.questionType == QuestionType.comprehensive) {
            comprehensiveQtn.add(_wrapWithCommentTab(
              StaticQuestionBox(
                templetName: widget.templateName,
                questionWrapper: wrapper,
                highlightColor: _unresolvedColor(wrapper.question),
              ),
              wrapper.question,
              onQuestionTap,
            ));
          } else if (wrapper.question.questionType == QuestionType.both) {
            wideWidgets.add(_wrapWithCommentTab(
              StaticQuestionBox(
                templetName: widget.templateName,
                questionWrapper: wrapper,
                highlightColor: _unresolvedColor(wrapper.question),
              ),
              wrapper.question,
              onQuestionTap,
            ));
          } else {
            nonComprehensiveQtn.add(_wrapWithCommentTab(
              StaticQuestionBox(
                templetName: widget.templateName,
                questionWrapper: wrapper,
                highlightColor: _unresolvedColor(wrapper.question),
              ),
              wrapper.question,
              onQuestionTap,
            ));
          }
        }

        //Initializing text editing controllers when there is text field or text area
        if (wrapper.question.answerType == AnswerType.textArea ||
            wrapper.question.answerType == AnswerType.textBox) {
          for (int i = 0; i < wrapper.question.options!.length; i++) {
            wrapper.question.options![i].textEditingController =
                TextEditingController(
                    text: wrapper.question.options![i].value);
          }
        }
        formProvider.addQuestion(wrapper.question);
      } catch (e) {
        print("In conversion error");
        print(e);
      }
    }
    return 1;
  }
}

Future<void> uploadAllImages(BuildContext context, List<QuestionWrapper> questions,
    {List<String> deletedImageUrls = const []}) async {
  for (var qWrapper in questions) {
    // Upload images in main question options
    await _uploadOptions(context, qWrapper.question.options);

    // Upload images inside all sub-questions (recursively)
    await Future.wait(
      qWrapper.subQuestionWrappers.map(
        (subQWrapper) => _uploadSubQuestion(context, subQWrapper),
      ),
    );
  }

  final formBuilderManager = FormBuilderManager();
  for (final url in deletedImageUrls) {
    if (url.trim().isEmpty) continue;
    await formBuilderManager.deleteFiles(context, url: url);
  }
}

Future<void> _uploadSubQuestion(
    BuildContext context, SubQuestionWrapper subQWrapper) async {
  // Upload this sub-question's options
  await _uploadOptions(context, subQWrapper.subQuestion.options);
}

Future<void> _uploadOptions(
    BuildContext context, List<dynamic>? options) async {
  if (options == null) return;
  final formBuilderManager = FormBuilderManager();
  for (var option in options) {
    if (option.image != null) {
      final formData = FormData.fromMap({
        'file': MultipartFile(
          option.image!.openRead(),
          await option.image!.length(),
          filename: 'signature.png',
        ),
      });

      //TODO Don't upload if image is in deleted state
      final url =
          await formBuilderManager.uploadFiles(context, formData: formData);
      if (url?.isNotEmpty ?? false) {
        option.value = url ?? "";
      }
    }
  }

}
