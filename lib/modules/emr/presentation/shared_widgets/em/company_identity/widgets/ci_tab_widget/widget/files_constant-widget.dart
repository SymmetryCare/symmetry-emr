import 'dart:async';
import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/company_identity/new_org_doc.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/ci_org_doc_tab/widgets/heading_constant_widget.dart';

///stf
class PoliciesProcedureList extends StatefulWidget {
  final StreamController<List<NewOrgDocument>> controller;
  final Future<List<NewOrgDocument>> Function(BuildContext context) fetchDocuments;
  final String emptyMessage;
  final Function(NewOrgDocument doc) onEdit;
  final Function(NewOrgDocument doc) onDelete;
  final int itemsPerPage;

  const PoliciesProcedureList({
    super.key,
    required this.controller,
    required this.fetchDocuments,
    required this.emptyMessage,
    required this.onEdit,
    required this.onDelete,
    this.itemsPerPage = 10,
  });

  @override
  State<PoliciesProcedureList> createState() => _PoliciesProcedureListState();
}

class _PoliciesProcedureListState extends State<PoliciesProcedureList> {
  final ScrollController _horizontalScrollController = ScrollController();
  int flexVal = 2;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // FIX: cache the fetch here and call it once from initState instead of
  // calling widget.fetchDocuments(...) inline in the StreamBuilder below,
  // which re-fired the API call on every rebuild of this widget's builder.
  void _loadData() {
    widget.fetchDocuments(context).then((data) {
      if (mounted) widget.controller.add(data);
    }).catchError((error) {
      // Handle error
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int currentPage = 1;
    final _controller = widget.controller;

    return Expanded(
      child: StreamBuilder<List<NewOrgDocument>>(
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
                widget.emptyMessage,
                style: AllNoDataAvailable.customTextStyle(context),
              ),
            );
          }

          if (snapshot.hasData) {
            int totalItems = snapshot.data!.length;
            int totalPages = (totalItems / widget.itemsPerPage).ceil();
            List<NewOrgDocument> paginatedData = snapshot.data!
                .skip((currentPage - 1) * widget.itemsPerPage)
                .take(widget.itemsPerPage)
                .toList();

            return Column(
              children: [
                Expanded(
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
                            height: constraints.maxHeight,
                            child: Column(
                              children: [
                                const TableHeadingConst(),
                                const SizedBox(height: AppSize.s5),
                                Expanded(
                                  child: ScrollConfiguration(
                                    behavior: const ScrollBehavior().copyWith(scrollbars: false),
                                    child: ListView.builder(
                                      itemCount: paginatedData.length,
                                      itemBuilder: (context, index) {
                                        int serialNumber = index + 1 + (currentPage - 1) * widget.itemsPerPage;
                                        String formattedSerialNumber = serialNumber.toString().padLeft(2, '0');
                                        NewOrgDocument policiesdata = paginatedData[index];

                                        return Column(
                                          children: [
                                            const SizedBox(height: AppSize.s5),
                                            Container(
                                              padding: const EdgeInsets.only(bottom: AppPadding.p5),
                                              margin: const EdgeInsets.symmetric(horizontal: AppSizeConst.A40),
                                              decoration: BoxDecoration(
                                                color: ColorManager.white,
                                                borderRadius: BorderRadius.circular(4),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: ColorManager.grey.withOpacity(0.5),
                                                    spreadRadius: 1,
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              height: AppSize.s56,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  Expanded(
                                                    flex: flexVal,
                                                    child: Center(
                                                      child: Text(
                                                        formattedSerialNumber,
                                                        style: DocumentTypeDataStyle.customTextStyle(context),
                                                        textAlign: TextAlign.start,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: flexVal,
                                                    child: Text(
                                                      policiesdata.idOfDocument,
                                                      style: DocumentTypeDataStyle.customTextStyle(context),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: flexVal,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(right: 20),
                                                      child: Text(
                                                        policiesdata.docName,
                                                        textAlign: TextAlign.center,
                                                        style: DocumentTypeDataStyle.customTextStyle(context),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: flexVal,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: AppPadding.p30),
                                                      child: Text(
                                                        policiesdata.expiryReminder,
                                                        textAlign: TextAlign.center,
                                                        style: DocumentTypeDataStyle.customTextStyle(context),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: AppPadding.p25),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          IconButton(
                                                            hoverColor: Colors.transparent,
                                                            splashColor: Colors.transparent,
                                                            highlightColor: Colors.transparent,
                                                            onPressed: () => widget.onEdit(policiesdata),
                                                            icon: Icon(
                                                              Icons.edit_outlined,
                                                              size: IconSize.I18,
                                                              color: IconColorManager.blueprime,
                                                            ),
                                                          ),
                                                          IconButton(
                                                            hoverColor: Colors.transparent,
                                                            splashColor: Colors.transparent,
                                                            highlightColor: Colors.transparent,
                                                            onPressed: () => widget.onDelete(policiesdata),
                                                            icon: Icon(
                                                              Icons.delete_outline,
                                                              size: IconSize.I18,
                                                              color: IconColorManager.red,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                PaginationControlsWidget(
                  currentPage: currentPage,
                  items: snapshot.data!,
                  itemsPerPage: widget.itemsPerPage,
                  onPreviousPagePressed: () {
                    if (currentPage > 1) {
                      currentPage--;
                    }
                  },
                  onPageNumberPressed: (pageNumber) {
                    currentPage = pageNumber;
                  },
                  onNextPagePressed: () {
                    if (currentPage < totalPages) {
                      currentPage++;
                    }
                  },
                ),
              ],
            );
          }
          return const Offstage();
        },
      ),
    );
  }
}

///