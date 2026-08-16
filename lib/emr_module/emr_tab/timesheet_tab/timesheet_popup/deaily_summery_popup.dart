import 'package:flutter/material.dart';

import '../../../../../../app/resources/color.dart';
import '../../../../../../app/resources/value_manager.dart';
import '../../../../../../app/services/api/managers/emr_module_manager/timesheet_tab_manager/timesheet_tab_manager.dart';
import '../../../../../../data/api_data/emr_module_data/timesheet_tab_data/timesheet_data.dart';
import '../../popup_const_emr.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class _SummaryRow {
  final String category;
  final String qty;
  final String earning;

  const _SummaryRow({
    required this.category,
    required this.qty,
    required this.earning,
  });
}

// ── StatefulWidget ────────────────────────────────────────────────────────────

class DailySummaryPopup extends StatefulWidget {
  final String date; // expects 'YYYY-MM-DD'

  const DailySummaryPopup({super.key, required this.date});

  @override
  State<DailySummaryPopup> createState() => _DailySummaryPopupState();
}

class _DailySummaryPopupState extends State<DailySummaryPopup> {
  bool _isLoading = true;
  DailySummaryData? _summary;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await getDailySummary(context, widget.date);
    setState(() {
      _summary = data;
      _isLoading = false;
    });
  }

  List<_SummaryRow> get _rows {
    if (_summary == null) return [];
    return [
      _SummaryRow(
        category: 'Submitted Visits',
        qty:      '${_summary!.submittedVisits.qty}',
        earning:  _summary!.submittedVisits.earnings > 0
            ? '\$${_summary!.submittedVisits.earnings.toStringAsFixed(2)}'
            : 'n/a',
      ),
      _SummaryRow(
        category: 'Pending Visits',
        qty:      '${_summary!.pendingVisits.qty}',
        earning:  _summary!.pendingVisits.earnings > 0
            ? '\$${_summary!.pendingVisits.earnings.toStringAsFixed(2)}'
            : 'n/a',
      ),
      _SummaryRow(
        category: 'Submitted Mileage',
        qty:      '${_summary!.submittedMileage.miles.toStringAsFixed(1)} mi',
        earning:  _summary!.submittedMileage.earnings > 0
            ? '\$${_summary!.submittedMileage.earnings.toStringAsFixed(2)}'
            : 'n/a',
      ),
      _SummaryRow(
        category: 'Pending Mileage',
        qty:      '${_summary!.pendingMileage.miles.toStringAsFixed(1)} mi',
        earning:  _summary!.pendingMileage.earnings > 0
            ? '\$${_summary!.pendingMileage.earnings.toStringAsFixed(2)}'
            : 'n/a',
      ),
      _SummaryRow(
        category: 'Miscellaneous',
        qty:      '${_summary!.miscellaneous.qty}',
        earning:  _summary!.miscellaneous.earnings > 0
            ? '\$${_summary!.miscellaneous.earnings.toStringAsFixed(2)}'
            : 'n/a',
      ),
    ];
  }

  String get _total {
    if (_summary == null) return '\$0.00';
    final t = _summary!.currentEarnings + _summary!.potentialEarnings;
    return '\$${t.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return DialogueTemplateNoButtonsColoum(
      width: 420,
      height: 320,
      title: 'Daily Summary',
      body: [
        if (_isLoading)
          const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[

          // ── Header row ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: AppPadding.p8),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Qty',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Earning',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade600,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ───────────────────────────────────────────────────
          Divider(height: 1, thickness: 0.8, color: Colors.grey.shade200),

          // ── Data rows ─────────────────────────────────────────────────
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _rows.length,
            itemBuilder: (_, i) => _DataRow(row: _rows[i]),
          ),

          // ── Divider ───────────────────────────────────────────────────
          Divider(height: 1, thickness: 0.8, color: Colors.grey.shade200),

          // ── Total row ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: AppPadding.p10),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'Total (current + potential)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const Expanded(flex: 2, child: SizedBox()),
                Expanded(
                  flex: 3,
                  child: Text(
                    _total,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue.shade600,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Single data row ───────────────────────────────────────────────────────────

class _DataRow extends StatelessWidget {
  final _SummaryRow row;

  const _DataRow({required this.row});

  bool get _isNA => row.earning == 'n/a';
  bool get _isPositive => row.earning.startsWith('\$');

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 0.8),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p10),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              row.category,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.qty,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              row.earning,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _isNA
                    ? Colors.grey.shade500
                    : _isPositive
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFC62828),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}