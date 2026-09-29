import 'package:flutter/material.dart';
// TODO: verify these import paths match your project structure
import 'package:symmetry_emr/app/resources/value_manager.dart'; // AppPadding
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart'; // AllNoDataAvailable

class AvailabilityTab extends StatefulWidget {
  const AvailabilityTab({super.key});

  @override
  State<AvailabilityTab> createState() => _AvailabilityTabState();
}

class _AvailabilityTabState extends State<AvailabilityTab> {
  // ---- Design tokens -------------------------------------------------
  static const Color _panelBg = Color(0xFFF2F2F3);
  static const Color _accentBlue = Color(0xFF3FB6E5);
  static const Color _accentBlueBg = Color(0xFFEAF7FC);
  static const Color _borderGrey = Color(0xFFE2E2E4);
  static const Color _textDark = Color(0xFF23272B);
  static const Color _textMuted = Color(0xFF9AA0A6);
  static const Color _textPlaceholder = Color(0xFFBFC3C7);

  // ---- State -----------------------------------------------------------
  DateTime _focusedMonth = DateTime(2025, 9);
  int _selectedDay = 8;

  // Days (within the visible grid) that have existing availability slots,
  // shown in bold in the calendar.
  final Set<int> _availableDays = {10, 16, 22, 28, 3};

  final Map<int, List<_Slot>> _slotsByDay = {
    8: [_Slot(label: 'Wed', from: '10:30 am', to: '04:00am')],
  };

  static const List<String> _weekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
  }

  /// Builds a 5x6 grid (Mon–Sat) of day numbers to display, mirroring the
  /// layout in the design (Sunday column is hidden).
  List<List<int>> _buildGridWeeks() {
    // Anchor the grid the same way the design shows it: first visible row
    // starts on the Monday on/before the 6th of the month, for a total of
    // 5 rows x 6 columns.
    final firstOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 6);
    final weekdayIndex = firstOfMonth.weekday - 1; // Monday = 0
    final gridStart = firstOfMonth.subtract(Duration(days: weekdayIndex));

    final weeks = <List<int>>[];
    for (int week = 0; week < 5; week++) {
      final row = <int>[];
      for (int day = 0; day < 6; day++) {
        final date = gridStart.add(Duration(days: week * 7 + day));
        row.add(date.day);
      }
      weeks.add(row);
    }
    return weeks;
  }

  bool _isCurrentMonthDay(int rowIndex, int colIndex, int dayNumber) {
    // Simple heuristic matching the screenshot: first & last row may spill
    // into adjacent months when the day number resets low near the edges.
    if (rowIndex == 0 && dayNumber > 20) return false;
    if (rowIndex == 4 && dayNumber < 10) return false;
    return true;
  }

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    // ── TEMP: UI hidden — showing development placeholder ──────────────────
    // The original UI is preserved below in `_buildActualUi`, just not
    // called from here. Swap the return back to `_buildActualUi(context)`
    // once the forms builder dependency is ready.
    //
    // FIX: was `Expanded(...)`. This widget is rendered inside an
    // IndexedStack (ProfileDetailScreen's tab content), not a Flex/Row/
    // Column, so Expanded has no valid Flex ancestor to attach its
    // FlexParentData to -> "Incorrect use of ParentDataWidget" crash.
    // SizedBox.expand fills the available space safely under any parent.
    return SizedBox.expand(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p40),
          child: Text(
            'Dependency on forms builder which is under development!',
            textAlign: TextAlign.center,
            style: AllNoDataAvailable.customTextStyle(context),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Original UI — kept intact, currently unused (see build() above)
  // ---------------------------------------------------------------------
  Widget _buildActualUi(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCalendarPanel(),
                          const SizedBox(width: 24),
                          Expanded(child: _buildDetailsPanel()),
                        ],
                      ),
                    ),
                    const Expanded(child: SizedBox())
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Calendar (left) panel
  // ---------------------------------------------------------------------
  Widget _buildCalendarPanel() {
    final weeks = _buildGridWeeks();

    return Container(
      width: 340,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        color: _panelBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: < September - 2025 >
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navArrow(Icons.chevron_left, () => _changeMonth(-1)),
              Text(
                '${_months[_focusedMonth.month - 1]} - ${_focusedMonth.year}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              _navArrow(Icons.chevron_right, () => _changeMonth(1)),
            ],
          ),
          const SizedBox(height: 28),

          // Weekday labels
          Row(
            children: _weekdayLabels
                .map(
                  (d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            )
                .toList(),
          ),
          const SizedBox(height: 18),

          // Weeks
          for (int r = 0; r < weeks.length; r++) ...[
            Row(
              children: [
                for (int c = 0; c < weeks[r].length; c++)
                  Expanded(child: _buildDayCell(r, c, weeks[r][c])),
              ],
            ),
            if (r != weeks.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _navArrow(IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 20, color: _textDark),
      ),
    );
  }

  Widget _buildDayCell(int rowIndex, int colIndex, int day) {
    final isSelected = day == _selectedDay && colIndex == 2; // "Wed" column
    final isCurrentMonth = _isCurrentMonthDay(rowIndex, colIndex, day);
    final isBold = _availableDays.contains(day);

    final textColor = !isCurrentMonth
        ? _textPlaceholder
        : (isSelected ? _textDark : _textDark);

    return Center(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDay = day),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: isSelected
              ? BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          )
              : null,
          child: Text(
            day.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Details (right) panel
  // ---------------------------------------------------------------------
  Widget _buildDetailsPanel() {
    final slots = _slotsByDay[_selectedDay] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // From / To row
        const Row(
          children: [
            Expanded(
              child: _TimeField(
                label: 'From',
                value: '10:30 am',
                isFilled: true,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _TimeField(
                label: 'To',
                value: '00:00',
                isFilled: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Existing slots
        for (int i = 0; i < slots.length; i++) ...[
          _buildSlotCard(slots[i]),
          const SizedBox(height: 12),
        ],

        const Spacer(),

        // Add New button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentBlue,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              '+ Add New',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlotCard(_Slot slot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _borderGrey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                slot.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              Text(
                '${slot.from} to ${slot.to}',
                style: const TextStyle(
                  fontSize: 13,
                  color: _textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _ActionButton(icon: Icons.edit_outlined, label: 'Edit', onTap: () {}),
            const SizedBox(width: 10),
            _ActionButton(
              icon: Icons.delete_outline,
              label: 'Delete',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Reusable pieces
// ---------------------------------------------------------------------

class _Slot {
  final String label;
  final String from;
  final String to;

  _Slot({required this.label, required this.from, required this.to});
}

class _TimeField extends StatelessWidget {
  final String label;
  final String value;
  final bool isFilled;

  const _TimeField({
    required this.label,
    required this.value,
    required this.isFilled,
  });

  static const Color _accentBlue = Color(0xFF3FB6E5);
  static const Color _accentBlueBg = Color(0xFFEAF7FC);
  static const Color _borderGrey = Color(0xFFE2E2E4);
  static const Color _textDark = Color(0xFF23272B);
  static const Color _textPlaceholder = Color(0xFFBFC3C7);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isFilled ? _accentBlueBg : Colors.white,
        border: Border.all(color: isFilled ? _accentBlue : _borderGrey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 18, color: _textDark),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(width: 8),
          const Text('|', style: TextStyle(color: _borderGrey, fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: isFilled ? _textDark : _textPlaceholder,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  static const Color _borderGrey = Color(0xFFE2E2E4);
  static const Color _textDark = Color(0xFF23272B);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            border: Border.all(color: _borderGrey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: _textDark),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}