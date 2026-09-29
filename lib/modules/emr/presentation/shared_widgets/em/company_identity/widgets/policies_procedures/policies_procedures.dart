import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/company_identity/ci_org_document.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/manage_history_version.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/newpopup_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/ci_manage_button/newpopup_data.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/onboarding/download_doc_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/error_pop_up.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/upload_add_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/upload_edit_popup.dart';

class CiPoliciesAndProcedures extends StatefulWidget {
  final int docID;
  final int subDocID;
  final int companyID;
  final String officeId;
  const CiPoliciesAndProcedures(
      {super.key,
      required this.docID,
      required this.subDocID,
      required this.companyID,
      required this.officeId});

  @override
  State<CiPoliciesAndProcedures> createState() =>
      _CiPoliciesAndProceduresState();
}
class _CiPoliciesAndProceduresState extends State<CiPoliciesAndProcedures> {
  TextEditingController nameOfDocController = TextEditingController();
  TextEditingController idOfDocController = TextEditingController();
  TextEditingController docNamecontroller = TextEditingController();
  TextEditingController docIdController = TextEditingController();
  final StreamController<List<MCorporateComplianceModal>> _controller =
      StreamController<List<MCorporateComplianceModal>>();
  TextEditingController calenderController = TextEditingController();
  final StreamController<List<IdentityDocumentIdData>> _identityDataController =
      StreamController<List<IdentityDocumentIdData>>.broadcast();
  int docTypeMetaIdPP = FrontendConfigStore.data!.config.policiesAndProcedure;
  int selectedSubDocId = FrontendConfigStore.data!.config.subDocId0;
  int docTypeMetaId = FrontendConfigStore.data!.config.policiesAndProcedure;
  int docSubTypeMetaId = FrontendConfigStore.data!.config.subDocId0;
  String? expiryType;
  bool _isLoading = false;
  TextEditingController expiryDateController = TextEditingController();
  bool showExpiryDateField = false;

  int currentPage = 1;
  int docTypeId = 0;
  String? documentID;
  final int itemsPerPage = 10;
  final int totalPages = 5;

  void onPageNumberPressed(int pageNumber) {
    setState(() {
      currentPage = pageNumber;
    });
  }

  String? documentTypeName;
  dynamic filePath;
  String? selectedDocType;
  String fileName = '';
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        filePath = result.files.first.bytes;
        fileName = result.files.first.name;
        print('File path ${filePath}');
        print('File name ${fileName}');
      });
    }
  }

  // FIX: cache the type-of-doc future once — docTypeMetaIdPP/selectedSubDocId
  // are fixed for this widget's lifetime, so this can be fetched once in
  // initState instead of being re-invoked inline on every rebuild of the
  // "Add Document" dialog.
  late Future<List<TypeofDocpopup>> _typeofDocFuture;

  // FIX: cache the prefill future once per edit-click instead of calling
  // getPrefillNewOrgOfficeDocument() inline inside the dialog's FutureBuilder,
  // which re-fired the API call on every rebuild of the dialog.
  Future<MCorporateCompliancePreFillModal>? _policyPrefillFuture;

  @override
  void initState() {
    super.initState();
    _typeofDocFuture = getTypeofDoc(context, docTypeMetaIdPP, selectedSubDocId);
    _loadPoliciesData();
  }

  // FIX: moved out of the StreamBuilder's builder callback, which re-fired
  // this API call on every rebuild instead of only once.
  void _loadPoliciesData() {
    getListMCorporateCompliancefetch(
            context,
            FrontendConfigStore.data!.config.policiesAndProcedure,
            widget.officeId,
            FrontendConfigStore.data!.config.subDocId0,
            1,
            9999)
        .then((data) {
      if (mounted) _controller.add(data);
    }).catchError((error) {
      // Handle error
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizeConst.A40),
        child: Column(
          children: [
            const SizedBox(height: AppSizeConst.A20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomIconButtonConst(
                    icon: Icons.add,
                    text: AppStringEM.addDocument,
                    onPressed: () async {
                      int? selectedDocTypeId;
                      String? selectedExpiryType = expiryType;
                      calenderController.clear();
                      docIdController.clear();
                      docNamecontroller.clear();
                      selectedExpiryType = "";

                      showDialog(
                          context: context,
                          builder: (context) {
                            return FutureBuilder<List<TypeofDocpopup>>(
                                future: _typeofDocFuture,
                                builder: (contex, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasData) {
                                    return UploadDocumentAddPopup(
                                      loadingDuration: _isLoading,
                                      title: 'Upload Document',
                                      officeId: widget.officeId,
                                      docTypeMetaIdCC: docTypeMetaIdPP,
                                      selectedSubDocId: selectedSubDocId,
                                      dataList: snapshot.data!,
                                      docTypeText: AppStringEM.policiesAndProcedures,
                                      subDocTypeText: '',
                                      onSuccess: _loadPoliciesData, // FIX: refresh list after add
                                    );
                                  } else {
                                    return ErrorPopUp(
                                        title: "Received Error",
                                        text: snapshot.error.toString());
                                  }
                                });
                          });
                    }),
              ],
            ),
            const SizedBox(height: AppSize.s10),
            Expanded(
              child: StreamBuilder<List<MCorporateComplianceModal>>(
                  stream: _controller.stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: ColorManager.blueprime,
                        ),
                      );
                    }
                    if (snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          ErrorMessageString.noPolicyProcedure,
                          style: AllNoDataAvailable.customTextStyle(context),
                        ),
                      );
                    }
                    if (snapshot.hasData) {
                      int totalItems = snapshot.data!.length;
                      int totalPages = (totalItems / itemsPerPage).ceil();
                      List<MCorporateComplianceModal> paginatedData = snapshot
                          .data!
                          .skip((currentPage - 1) * itemsPerPage)
                          .take(itemsPerPage)
                          .toList();
                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: paginatedData.length,
                                itemBuilder: (context, index) {
                                  int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;
                                  String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                                  MCorporateComplianceModal policiesdata = paginatedData[index];
                                  var fileUrl = policiesdata.docurl;
                                  final fileExtension = fileUrl.split('/').last;

                                  Widget fileWidget;
                                  if (['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
                                    fileWidget = Image.network(
                                      fileUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.broken_image,
                                          size: IconSize.I45,
                                          color: ColorManager.faintGrey,
                                        );
                                      },
                                    );
                                  }
                                  else if (['pdf', 'doc', 'docx'].contains(fileExtension)) {
                                    fileWidget = Icon(
                                      Icons.description,
                                      size: IconSize.I45,
                                      color: ColorManager.faintGrey,
                                    );
                                  }
                                  else {
                                    fileWidget = Icon(
                                      Icons.insert_drive_file,
                                      size: IconSize.I45,
                                      color: ColorManager.faintGrey,
                                    );
                                  }
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Container(
                                          margin: const EdgeInsets.symmetric(horizontal: AppSize.s5),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xff000000).withOpacity(0.25),
                                                spreadRadius: 0,
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          height: AppSize.s65,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p30),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  focusColor: Colors.transparent,
                                                      onTap: (){
                                                        print("FileExtension:${fileExtension}");
                                                        downloadFile(context: context,
                                                            fileUrl: fileUrl,
                                                            documentName:snapshot.data![index].fileName,
                                                            apiPath: DownloadDocumentRepository.getOrgOfficeDocumentByFileName());
                                                      },
                                                      child: Container(
                                                          width: AppSize.s62,
                                                          height: AppSize.s45,
                                                          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10,vertical: AppPadding.p8),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(4),
                                                            border: Border.all(width: 2, color: ColorManager.faintGrey),
                                                          ),
                                                          child: SvgPicture.asset('images/doc_vector.svg')),
                                                    ),
                                                    const SizedBox(width: AppSize.s10,),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          "ID : ${policiesdata.idOfDocument}",
                                                          style:  DocDefineTableDataID.customTextStyle(context),
                                                        ),
                                                        const SizedBox(height: AppSize.s8,),
                                                        Text(
                                                          policiesdata.fileName.toString(),
                                                          textAlign: TextAlign.center,
                                                          style:  DocDefineTableData.customTextStyle(context),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),

                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              ManageHistoryPopup(
                                                            docHistory: policiesdata.docHistory,
                                                          ),
                                                        );
                                                      },
                                                      icon: Icon(
                                                        Icons.history,
                                                        size:IconSize.I22,color: IconColorManager.blueprime,
                                                      ),
                                                      splashColor: Colors.transparent,
                                                      highlightColor: Colors.transparent,
                                                      hoverColor: Colors.transparent,
                                                    ),
                                                    const SizedBox(width: AppSize.s10,),
                                                    ///print
                                                    IconButton(
                                                      onPressed: () {
                                                        print("FileExtension:${fileExtension}");
                                                        downloadFile(context: context,
                                                            fileUrl: fileUrl,
                                                            documentName:snapshot.data![index].fileName,
                                                            apiPath: DownloadDocumentRepository.getOrgOfficeDocumentByFileName());
                                                      },
                                                      icon: Icon(
                                                        Icons
                                                            .print_outlined,
                                                        size:IconSize.I22,color: IconColorManager.blueprime,
                                                      ),
                                                      splashColor:
                                                      Colors.transparent,
                                                      highlightColor:
                                                      Colors.transparent,
                                                      hoverColor:
                                                      Colors.transparent,
                                                    ),
                                                    const SizedBox(width: AppSize.s10,),
                                                    ///download saloni
                                                    PdfDownloadButton(
                                                      apiPath: DownloadDocumentRepository.getOrgOfficeDocumentByFileName(),
                                                        apiUrl: policiesdata.docurl,
                                                        iconsize: IconSize.I22,
                                                        documentName: policiesdata.fileName!),
                                                    const SizedBox(width: AppSize.s10,),
                                                    ///edit
                                                    IconButton(
                                                      onPressed: () {
                                                        String?
                                                            selectedExpiryType =
                                                            expiryType;
                                                        _policyPrefillFuture = getPrefillNewOrgOfficeDocument(
                                                            context,
                                                            policiesdata
                                                                .orgOfficeDocumentId);
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return FutureBuilder<
                                                                MCorporateCompliancePreFillModal>(
                                                              future: _policyPrefillFuture,
                                                              builder: (context,
                                                                  snapshotPrefill) {
                                                                if (snapshotPrefill
                                                                        .connectionState ==
                                                                    ConnectionState
                                                                        .waiting) {
                                                                  return Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      color: ColorManager
                                                                          .blueprime,
                                                                    ),
                                                                  );
                                                                }

                                                                var calender =
                                                                    snapshotPrefill
                                                                        .data!
                                                                        .expiry_date;
                                                                calenderController =
                                                                    TextEditingController(
                                                                  text: snapshotPrefill
                                                                      .data!
                                                                      .expiry_date,
                                                                );
                                                                return StatefulBuilder(
                                                                  builder: (BuildContext
                                                                          context,
                                                                      void Function(void Function())
                                                                          setState) {
                                                                    return VCScreenPopupEditConst(
                                                                      fileName: snapshotPrefill
                                                                          .data!
                                                                          .fileName,
                                                                      url: snapshotPrefill.data!.url,
                                                                      expiryDate: snapshotPrefill.data!.expiry_date,
                                                                      title: EditPopupString.editPolicy,
                                                                      loadingDuration: _isLoading,
                                                                      officeId: widget.officeId,
                                                                      docTypeMetaIdCC: widget.docID,
                                                                      selectedSubDocId: widget.subDocID,
                                                                      orgDocId: snapshotPrefill.data!.orgOfficeDocumentId,
                                                                      orgDocumentSetupid: snapshotPrefill.data!.documentSetupId,
                                                                      docName: snapshotPrefill.data!.docName,
                                                                      selectedExpiryType: snapshotPrefill.data!.expType,
                                                                      documentType: AppStringEM.policiesAndProcedures,
                                                                      documentSubType: '',
                                                                                      isOthersDocs: snapshotPrefill.data!.isOthersDocs,
                                                                      idOfDoc: snapshotPrefill.data!.idOfDocument,
                                                                      expiryType: snapshotPrefill.data!.expType,
                                                                      threshhold: snapshotPrefill.data!.threshould,
                                                                      onSuccess: _loadPoliciesData, // FIX: refresh list after edit
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          },
                                                        );
                                                      },
                                                      icon: Icon(
                                                        Icons.edit_outlined,
                                                        size:IconSize.I22,color: IconColorManager.blueprime,
                                                      ),
                                                      splashColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                    ),
                                                    const SizedBox(width: AppSize.s10,),
                                                    ///delete
                                                    IconButton(
                                                        splashColor: Colors.transparent,
                                                        highlightColor: Colors.transparent,
                                                        hoverColor: Colors.transparent,
                                                        onPressed: () {
                                                          // FIX: dialogIsOpen guard avoids calling the
                                                          // dialog-scoped setDialogState after the dialog's
                                                          // own Navigator.pop has already removed it, and
                                                          // the reload call below refreshes the list on delete.
                                                          bool dialogIsOpen = true;
                                                          showDialog(context: context,
                                                              builder: (context) => StatefulBuilder(
                                                                builder: (BuildContext context, void Function(void Function()) setDialogState) {
                                                                  return  DeletePopup(
                                                                      title: 'Delete Policies & Procedure',
                                                                      loadingDuration: _isLoading,
                                                                      onCancel: (){
                                                                        dialogIsOpen = false;
                                                                        Navigator.pop(context);
                                                                      },
                                                                      onDelete: () async{
                                                                    setState(() {
                                                                      _isLoading = true;
                                                                    });
                                                                    if (dialogIsOpen) setDialogState(() {});
                                                                    try {
                                                                      await deleteOrgDoc(
                                                                          context: context,
                                                                          orgDocId: policiesdata.orgOfficeDocumentId);
                                                                      dialogIsOpen = false;
                                                                      Navigator.pop(context);
                                                                      showDialog(context: context, builder: (context) => const DeleteSuccessPopup());
                                                                      _loadPoliciesData(); // FIX: reload list after delete
                                                                    } finally {
                                                                      if (mounted) {
                                                                        setState(() {
                                                                          _isLoading = false;
                                                                        });
                                                                      }
                                                                      if (dialogIsOpen) setDialogState(() {});
                                                                    }
                                                                  });
                                                                },

                                                              ));
                                                        },
                                                        icon: Icon(
                                                          Icons
                                                              .delete_outline,
                                                          size:IconSize.I24,color: IconColorManager.red,
                                                        )),
                                                  ],
                                                )
                                              ],
                                            ),
                                          )),
                                    ],
                                  );
                                }),
                          ),
                          PaginationControlsWidget(
                            currentPage: currentPage,
                            items: snapshot.data!,
                            itemsPerPage: itemsPerPage,
                            onPreviousPagePressed: () {
                              setState(() {
                                currentPage =
                                    currentPage > 1 ? currentPage - 1 : 1;
                              });
                            },
                            onPageNumberPressed: (pageNumber) {
                              setState(() {
                                currentPage = pageNumber;
                              });
                            },
                            onNextPagePressed: () {
                              setState(() {
                                currentPage = currentPage < totalPages
                                    ? currentPage + 1
                                    : totalPages;
                              });
                            },
                          ),
                        ],
                      );
                    }
                    return const Offstage();
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

