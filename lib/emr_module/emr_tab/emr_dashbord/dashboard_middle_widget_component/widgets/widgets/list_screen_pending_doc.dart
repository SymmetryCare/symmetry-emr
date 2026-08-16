import 'package:flutter/material.dart';

import '../../../../../../../../app/resources/color.dart';
import '../../../../../../../../app/resources/common_resources/emr_theme_const.dart';
import '../../../../../../../../app/resources/value_manager.dart';
import 'constants/progress_circular_const.dart';

import 'package:flutter/material.dart';
import '../../../../../../../../app/resources/color.dart';
import '../../../../../../../../app/resources/common_resources/emr_theme_const.dart';
import '../../../../../../../../app/resources/value_manager.dart';
import 'constants/progress_circular_const.dart';

// ─── Data Model ───────────────────────────────────────────────────────────────

class PendingDocItem {
  final String avatarId;
  final Color avatarBg;
  final Color avatarFg;
  final String name;
  final String mrn;
  final String dob;
  final String age;
  final String diagnosis;
  final String formName;
  final String formDate;
  final String insurance;
  final double percentage;
  final String? note;

  const PendingDocItem({
    required this.avatarId,
    required this.avatarBg,
    required this.avatarFg,
    required this.name,
    required this.mrn,
    required this.dob,
    required this.age,
    required this.diagnosis,
    required this.formName,
    required this.formDate,
    required this.insurance,
    required this.percentage,
    this.note,
  });
}

// ─── List Screen ──────────────────────────────────────────────────────────────

class ListScreenPendingDoc extends StatelessWidget {
  final List<PendingDocItem> items = [
    PendingDocItem(
      avatarId: 'LG', avatarBg: Color(0xFFFFE0B2), avatarFg: Color(0xFFE65100),
      name: 'Lucas Garcia', mrn: '659653454',
      dob: '05/08/2001', age: '24y', diagnosis: 'Anxiety',
      formName: 'Skilled Nursing Visit', formDate: '05/04/2025',
      insurance: 'Medicare', percentage: 25,
      note: 'Patient requested morning visits only.',
    ),
    PendingDocItem(
      avatarId: 'DJ', avatarBg: Color(0xFFE3F2FD), avatarFg: Color(0xFF1565C0),
      name: 'Daniel Johnson', mrn: '659653455',
      dob: '12/14/1998', age: '26y', diagnosis: 'Hypertension',
      formName: 'Physical Therapy Eval', formDate: '05/06/2025',
      insurance: 'Medicaid', percentage: 60,
      note: '',
    ),
    PendingDocItem(
      avatarId: 'RM', avatarBg: Color(0xFFF3E5F5), avatarFg: Color(0xFF6A1B9A),
      name: 'Richard Miller', mrn: '659653456',
      dob: '03/22/1975', age: '50y', diagnosis: 'Diabetes',
      formName: 'Wound Care Assessment', formDate: '05/07/2025',
      insurance: 'Medicare', percentage: 80,
      note: 'Requires interpreter for Spanish during visits.',
    ),
    PendingDocItem(
      avatarId: 'JD', avatarBg: Color(0xFFE8F5E9), avatarFg: Color(0xFF2E7D32),
      name: 'Joseph Davis', mrn: '659653457',
      dob: '07/30/1990', age: '34y', diagnosis: 'COPD',
      formName: 'Occupational Therapy Plan', formDate: '05/08/2025',
      insurance: 'Private', percentage: 45,
      note: '',
    ),
  ];
   ListScreenPendingDoc({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header ────────────────────────────────────────────────────────────
        Container(
          height: AppSize.s33,
          decoration: BoxDecoration(
            color: ColorManager.SMFBlue,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.only(left: AppPadding.p60, right: AppPadding.p30),
          child: Row(
            children: [
              Expanded(flex: 2,
                  child: Text("Patient Name", style: EMRListViewHead.customTextStyle(context))),
              Expanded(flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppPadding.p0),
                    child: Text("Form Name", textAlign: TextAlign.center,
                        style: EMRListViewHead.customTextStyle(context)),
                  )),
              Expanded(flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p45),
                    child: Text("Form Date", style: EMRListViewHead.customTextStyle(context)),
                  )),
              Expanded(flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p35),
                    child: Text("Insurance", style: EMRListViewHead.customTextStyle(context)),
                  )),
              Expanded(flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppPadding.p20),
                    child: Text("% Complete", style: EMRListViewHead.customTextStyle(context)),
                  )),
            ],
          ),
        ),
        const SizedBox(height: AppSize.s10),

        // ── Rows ──────────────────────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            //separatorBuilder: (_, __) => Divider(color: Colors.grey.shade300),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: AppSize.s10),
                child: _PendingDocRow(item: items[index]),
              )
          ),
        ),
      ],
    );
  }
}

// ─── Row Widget ───────────────────────────────────────────────────────────────

class _PendingDocRow extends StatefulWidget {
  final PendingDocItem item;
  const _PendingDocRow({required this.item});

  @override
  State<_PendingDocRow> createState() => _PendingDocRowState();
}

class _PendingDocRowState extends State<_PendingDocRow> {
  bool _showNote = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showNote = !_showNote),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _showNote ? Colors.white : ColorManager.listTileColor,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
        ),
        padding: const EdgeInsets.only(
          left: AppPadding.p12,
          top: AppPadding.p10,
          bottom: AppPadding.p10,
        ),
        child: _showNote ? _buildNoteView() : _buildCardView(context),
      ),
    );
  }

  // ── Card view ─────────────────────────────────────────────────────────────
  Widget _buildCardView(BuildContext context) {
    return Row(
      children: [
        // Patient info
        Expanded(
          flex: 4,
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: widget.item.avatarBg,
                child: Text(
                  widget.item.avatarId,
                  style: TextStyle(
                    color: widget.item.avatarFg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSize.s10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.item.name,
                      style: EMRListViewHead.customTextStyle(context)),
                  const SizedBox(height: AppSize.s2),
                  Text("MRN: ${widget.item.mrn}",
                      style: EMRListViewHead.customTextStyle(context)
                          .copyWith(fontWeight: FontWeight.w400)),
                  Text("${widget.item.dob} | ${widget.item.age}",
                      style: EMRListViewHead.customTextStyle(context)
                          .copyWith(fontWeight: FontWeight.w400)),
                  Text(widget.item.diagnosis,
                      style: EMRListViewHead.customTextStyle(context)
                          .copyWith(fontWeight: FontWeight.w400)),
                ],
              ),
            ],
          ),
        ),

        // Form name
        Expanded(
          flex: 4,
          child: Text(widget.item.formName,
              style: EMRListViewHead.customTextStyle(context)
                  .copyWith(fontWeight: FontWeight.w400)),
        ),

        // Form date
        Expanded(
          flex: 3,
          child: Text(widget.item.formDate,
              style: EMRListViewHead.customTextStyle(context)
                  .copyWith(fontWeight: FontWeight.w400)),
        ),

        // Insurance
        Expanded(
          flex: 3,
          child: Text(widget.item.insurance,
              style: EMRListViewHead.customTextStyle(context)
                  .copyWith(fontWeight: FontWeight.w400)),
        ),

        // % Complete
        Expanded(
          flex: 2,
          child: AppCircularProgress(
            percentage: widget.item.percentage,
            progressColor: ColorManager.bluebottom,
          ),
        ),
      ],
    );
  }

  // ── Note view ─────────────────────────────────────────────────────────────
  Widget _buildNoteView() {
    final noteText = widget.item.note ?? '';
    final hasNote = noteText.isNotEmpty;

    return SizedBox(
      height: 58,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Note',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFBF360C),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: GestureDetector(
                  onTap: () => setState(() => _showNote = false),
                  child: const Icon(Icons.close, size: 20, color: Colors.black45),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            hasNote ? noteText : 'No Note here',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade700,
              fontStyle: hasNote ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
