import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/company_identity/ci_org_document.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/manage_history_version.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/newpopup_manager.dart';
import 'package:symmetry_emr/app/services/base64/download_file_base64.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/ci_manage_button/newpopup_data.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/error_popups/delete_success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/onboarding/download_doc_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/upload_edit_popup.dart';

class CiDme extends StatefulWidget {
  final int docId;
  final int subDocId;
  final int companyID;
  final String officeId;
  const CiDme(
      {super.key,
      required this.companyID,
      required this.officeId,
      required this.docId,
      required this.subDocId});

  @override
  State<CiDme> createState() => _CiDmeState();
}

class _CiDmeState extends State<CiDme> {
  TextEditingController docNameController = TextEditingController();
  TextEditingController docIdController = TextEditingController();
  TextEditingController calenderController = TextEditingController();
  TextEditingController idOfDocController = TextEditingController();
  int docTypeMetaIdVC = FrontendConfigStore.data!.config.vendorContracts;
  int docTypeMetaIdVCdme = FrontendConfigStore.data!.config.subDocId8DME;
  final StreamController<List<MCorporateComplianceModal>> vendorDMEController =
      StreamController<List<MCorporateComplianceModal>>();
  final StreamController<List<IdentityDocumentIdData>> _identityDataController =
      StreamController<List<IdentityDocumentIdData>>.broadcast();

  String? selectedValue;
  late List<Color> hrcontainerColors;
  int docTypeMetaId = 0;
  int docSubTypeMetaId = 0;
  String? expiryType;
  bool _isLoading = false;

  int currentPage = 1;
  final int itemsPerPage = 10;
  final int totalPages = 5;

  void onPageNumberPressed(int pageNumber) {
    setState(() {
      currentPage = pageNumber;
    });
  }

  int docTypeId = 0;
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

  // FIX: cache the prefill future once per edit-click instead of calling
  // getPrefillNewOrgOfficeDocument() inline inside the dialog's FutureBuilder,
  // which re-fired the API call on every rebuild of the dialog.
  Future<MCorporateCompliancePreFillModal>? _dmePrefillFuture;

  @override
  void initState() {
    super.initState();
    _loadDmeData();
  }

  // FIX: moved out of the StreamBuilder's builder callback, which re-fired
  // this API call on every rebuild instead of only once.
  void _loadDmeData() {
    getListMCorporateCompliancefetch(
            context,
            FrontendConfigStore.data!.config.vendorContracts,
            widget.officeId,
            FrontendConfigStore.data!.config.subDocId8DME,
            1,
            9999)
        .then((data) {
      if (mounted) vendorDMEController.add(data);
    }).catchError((error) {
      // Handle error
    });
  }

  // FIX: public hook so the parent Add-Document dialog (owned by
  // CiCcVendorContractScreen) can refresh this tab's list after a
  // successful add, since the Add button lives outside this widget.
  void reloadDmeData() => _loadDmeData();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: StreamBuilder<List<MCorporateComplianceModal>>(
                stream: vendorDMEController.stream,
                builder: (context, snapshot) {
                  print('55555555');
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
                        ErrorMessageString.noDME,
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
                          child:  ScrollConfiguration(
                            behavior: const ScrollBehavior().copyWith(scrollbars: false),
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: paginatedData.length,
                                itemBuilder: (context, index) {
                                  int serialNumber = index +
                                      1 +
                                      (currentPage - 1) * itemsPerPage;
                                  String formattedSerialNumber =
                                      serialNumber.toString().padLeft(2, '0');
                                  var vcDME = snapshot.data![index];
                                  var fileUrl = vcDME.docurl;
                                  final fileExtension = fileUrl.split('/').last;

                                  MCorporateComplianceModal dmeData =
                                      paginatedData[index];
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: AppSize.s8,),
                                      Container(
                                          margin: const EdgeInsets.symmetric(horizontal: AppSize.s5),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xff000000)
                                                    .withOpacity(0.25),
                                                spreadRadius: 0,
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          height: AppSize.s65,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: AppPadding.p30),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                    const SizedBox(width: AppSize.s10),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "ID : ${dmeData.idOfDocument}",
                                                          style:  DocDefineTableDataID.customTextStyle(context),
                                                        ),
                                                        const SizedBox(height: AppSize.s8,),
                                                        Text(
                                                          dmeData.fileName
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:  DocDefineTableData.customTextStyle(context),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              ManageHistoryPopup(
                                                            docHistory: dmeData
                                                                .docHistory,
                                                          ),
                                                        );
                                                      },
                                                      icon:  Icon(
                                                        Icons.history,
                                                        size: IconSize.I22,
                                                        color: IconColorManager
                                                            .blueprime,
                                                      ),
                                                      hoverColor: Colors.transparent,
                                                      splashColor: Colors.transparent,
                                                      highlightColor: Colors.transparent,
                                                    ),
                                                    const SizedBox(width: AppSize.s10,),
                                                    IconButton(
                                                      onPressed: () {
                                                        print(
                                                            "FileExtension:${fileExtension}");
                                                        // DowloadFile()
                                                        //     .downloadPdfFromBase64(
                                                        //         fileExtension,
                                                        //         "DME.pdf");
                                                        downloadFile(context: context,
                                                            fileUrl: fileUrl,
                                                            documentName:snapshot.data![index].fileName,
                                                            apiPath: DownloadDocumentRepository.getOrgOfficeDocumentByFileName());
                                                      },
                                                      icon:  Icon(
                                                          Icons
                                                              .print_outlined,
                                                          size: IconSize.I22,
                                                          color: IconColorManager
                                                              .blueprime),
                                                      hoverColor: Colors.transparent,
                                                      splashColor: Colors.transparent,
                                                      highlightColor: Colors.transparent,
                                                    ),
                                                    const SizedBox(width: AppSize.s10,),
                                                    PdfDownloadButton(
                                                        apiPath: DownloadDocumentRepository.getOrgOfficeDocumentByFileName(),
                                                        apiUrl: dmeData.docurl,
                                                        iconsize: IconSize.I22,
                                                        documentName: dmeData.fileName),
                                                    const SizedBox(width: AppSize.s10,),
                                                    IconButton(
                                                      onPressed: () {
                                                        String?
                                                            selectedExpiryType =
                                                            expiryType;
                                                        _dmePrefillFuture = getPrefillNewOrgOfficeDocument(
                                                            context,
                                                            dmeData
                                                                .orgOfficeDocumentId);
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return FutureBuilder<
                                                                MCorporateCompliancePreFillModal>(
                                                              future: _dmePrefillFuture,
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
                                                                      void Function(
                                                                              void Function())
                                                                          setState) {
                                                                    return VCScreenPopupEditConst(
                                                                      fileName: snapshotPrefill.data!.fileName,
                                                                      url: snapshotPrefill.data!.url,
                                                                      expiryDate: snapshotPrefill.data!.expiry_date,
                                                                      title: EditPopupString.editDME ,
                                                                      loadingDuration: _isLoading,
                                                                      officeId: widget.officeId,
                                                                      docTypeMetaIdCC: widget.docId,
                                                                      selectedSubDocId: widget.subDocId,
                                                                      orgDocId: snapshotPrefill.data!.orgOfficeDocumentId,
                                                                      orgDocumentSetupid: snapshotPrefill.data!.documentSetupId,
                                                                      docName: snapshotPrefill.data!.docName,
                                                                      selectedExpiryType: snapshotPrefill.data!.expType,
                                                                      documentType: AppStringEM.vendorContracts,
                                                                      documentSubType: AppStringEM.dme,
                                                                      isOthersDocs: snapshotPrefill.data!.isOthersDocs,
                                                                      idOfDoc: snapshotPrefill.data!.idOfDocument,
                                                                      expiryType: snapshotPrefill.data!.expType,
                                                                      threshhold: snapshotPrefill.data!.threshould,
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ).then((_) => _loadDmeData()); // FIX: reload list so edits reflect immediately
                                                      },
                                                      icon: Icon(Icons.edit_outlined,
                                                        size:IconSize.I22,color: IconColorManager.blueprime,),
                                                      hoverColor: Colors.transparent,
                                                      splashColor: Colors.transparent,
                                                      highlightColor: Colors.transparent,
                                                    ),
                                                    const SizedBox(width: AppSize.s10,),
                                                    IconButton(
                                                        hoverColor: Colors.transparent,
                                                        splashColor: Colors.transparent,
                                                        highlightColor: Colors.transparent,
                                                        onPressed: () {
                                                          // FIX: dialogIsOpen/setDialogState guard the dialog's own
                                                          // setState from firing after Navigator.pop has closed it.
                                                          bool dialogIsOpen = true;
                                                          showDialog(
                                                              context: context,
                                                              builder: (context) =>
                                                                  StatefulBuilder(
                                                                    builder: (BuildContext
                                                                            context,
                                                                        void Function(void Function())
                                                                            setDialogState) {
                                                                      return DeletePopup(
                                                                          title:
                                                                          DeletePopupString.deleteDME  ,
                                                                          loadingDuration:
                                                                              _isLoading,
                                                                          onCancel:
                                                                              () {
                                                                            dialogIsOpen = false;
                                                                            Navigator.pop(context);
                                                                          },
                                                                          onDelete:
                                                                              () async {
                                                                            setState(() {
                                                                              _isLoading = true;
                                                                            });
                                                                            if (dialogIsOpen) setDialogState(() {});
                                                                            try {
                                                                              await deleteOrgDoc(
                                                                                context: context,
                                                                                orgDocId: dmeData.orgOfficeDocumentId,
                                                                              );
                                                                              dialogIsOpen = false;
                                                                              Navigator.pop(context);
                                                                              _loadDmeData(); // FIX: reload list so deleted row disappears immediately
                                                                              if (mounted) {
                                                                                showDialog(context: context, builder: (context) => const DeleteSuccessPopup());
                                                                              }
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
                                                        icon:  Icon(
                                                          Icons.delete_outline,
                                                          size:IconSize.I22,color: IconColorManager.red,
                                                        )),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )),
                                    ],
                                  );
                                }),
                          ),
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
    );
  }
}