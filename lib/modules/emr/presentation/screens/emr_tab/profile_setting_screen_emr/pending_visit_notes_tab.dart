import 'package:flutter/material.dart';

import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/pending_visit_notes_model.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dashboard_tab_manager/emr_profile_manager.dart';

/// Color/label styling for a visit card, derived from the API's
/// `visitType.name` string (e.g. "Physical Therapy Visit Note",
/// "Physical Therapy Discharge Visit Note", "Supervisory Notes").
class VisitCardStyle {
  final String label;
  final Color color;

  const VisitCardStyle({required this.label, required this.color});

  factory VisitCardStyle.fromVisitTypeName(String name) {
    final lower = name.toLowerCase();

    if (lower.contains('discharge')) {
      return const VisitCardStyle(
        label: 'Discharge',
        color: Color(0xFF5C8AA6), // muted blue
      );
    } else if (lower.contains('soc') || lower.contains('start of care')) {
      return const VisitCardStyle(
        label: 'SOC',
        color: Color(0xFFC97575), // dusty red/pink
      );
    } else if (lower.contains('evaluation')) {
      return const VisitCardStyle(
        label: 'Evaluation',
        color: Color(0xFF1F3A6E), // navy blue
      );
    } else if (lower.contains('supervisory')) {
      return const VisitCardStyle(
        label: 'Supervisory',
        color: Color(0xFF6B6B6B), // neutral grey
      );
    } else if (lower.contains('revisit')) {
      return const VisitCardStyle(
        label: 'Revisit',
        color: Color(0xFF5C8AA6), // muted blue
      );
    }
    return VisitCardStyle(
      label: name.isNotEmpty ? name : 'Visit',
      color: const Color(0xFF1F3A6E),
    );
  }
}

class PendingVisitNotesTab extends StatefulWidget {
  final int employeeId;

  const PendingVisitNotesTab({super.key, required this.employeeId});

  @override
  State<PendingVisitNotesTab> createState() => _PendingVisitNotesTabState();
}

class _PendingVisitNotesTabState extends State<PendingVisitNotesTab> {
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = false;
  String? _errorMessage;
  List<PendingVisitItem> _visits = [];

  @override
  void initState() {
    super.initState();
    _fetchVisits();
  }

  String get _apiDate {
    final y = _selectedDate.year.toString().padLeft(4, '0');
    final m = _selectedDate.month.toString().padLeft(2, '0');
    final d = _selectedDate.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _fetchVisits() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final PendingVisitNotesModel? result = await getPendingVisitNotes(
      context: context,
      employeeId: widget.employeeId,
      date: _apiDate,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result == null) {
        _errorMessage = 'Unable to load pending visit notes.';
        _visits = [];
      } else {
        _visits = result.items;
      }
    });
  }

  String get _formattedDate {
    const months = [
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
      'December'
    ];
    return '${months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}';
  }

  void _shiftDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _fetchVisits();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDate: _selectedDate,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchVisits();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDateNavigator(),
                    const SizedBox(height: 16),
                    Expanded(child: _buildBody()),
                  ],
                ),
              ),
              const Expanded(child: SizedBox())
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFF8A8A8A)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _fetchVisits,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_visits.isEmpty) {
      return Center(
        child: Text(
          'No pending visit notes available!',
          style: AllNoDataAvailable.customTextStyle(context),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchVisits,
      child: ListView.separated(
        itemCount: _visits.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _VisitCard(visit: _visits[index]);
        },
      ),
    );
  }

  Widget _buildDateNavigator() {
    return Row(
      children: [
        _NavIconButton(
          icon: Icons.chevron_left,
          onTap: () => _shiftDate(-1),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEEF0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formattedDate,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF2B2B2B),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _NavIconButton(
          icon: Icons.chevron_right,
          onTap: () => _shiftDate(1),
        ),
        const SizedBox(width: 8),
        _NavIconButton(
          icon: Icons.calendar_today_outlined,
          onTap: _pickDate,
        ),
      ],
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEDEEF0),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 20, color: const Color(0xFF3A3A3A)),
        ),
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final PendingVisitItem visit;

  const _VisitCard({required this.visit});

  @override
  Widget build(BuildContext context) {
    final style =
    VisitCardStyle.fromVisitTypeName(visit.visitType.name);
    final bool hasImage = visit.imageUrl.isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      elevation: 0.5,
      shadowColor: Colors.black12,
      child: SizedBox(
        height: 84,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Colored vertical label tab.
            Container(
              width: 40,
              decoration: BoxDecoration(
                color: ColorManager.SMYellow,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomLeft: Radius.circular(6),
                ),
              ),
              alignment: Alignment.center,
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  visit.visitType.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            // Avatar + name/condition.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.transparent,
                      child: ClipOval(
                        child: hasImage
                            ? Image.network(
                          visit.imageUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'images/profilepic.png',
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Image.asset(
                          'images/profilepic.png',
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            visit.patientName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            visit.primaryDiagnosis.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8A8A8A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Price box.
            Container(
              width: 64,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              alignment: Alignment.center,
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  '\$${visit.visitCharge.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}