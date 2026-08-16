import 'package:flutter/material.dart';
import 'package:prohealth/app/resources/color.dart';
import '../../../../../app/services/api/managers/emr_module_manager/calender_map_tab_manager/calender_map_manager.dart';
import '../../../../../data/api_data/emr_module_data/calender_map_data/calender_map_data.dart';
import 'calender_tab_emr.dart';
import 'map_tab_emr.dart';

// ── Color Helpers ─────────────────────────────────────────────────────────────
Color apptBg(String type) {
  switch (type) {
    case 'SOC':    return const Color(0xFFB2DFDB);
    case 'RECERT': return const Color(0xFFFFF9C4);
    case 'PRN':    return const Color(0xFFDCEDC8);
    case 'ROC':    return const Color(0xFFFFCCBC);
    default:       return Colors.grey.shade100;
  }
}

Color apptAccent(String type) {
  switch (type) {
    case 'SOC':    return const Color(0xFF00796B);
    case 'RECERT': return const Color(0xFFF9A825);
    case 'PRN':    return const Color(0xFF558B2F);
    case 'ROC':    return const Color(0xFFBF360C);
    default:       return Colors.grey;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class EMRCalendarScreen extends StatefulWidget {
  const EMRCalendarScreen({super.key});
  @override
  State<EMRCalendarScreen> createState() => _EMRCalendarScreenState();
}

class _EMRCalendarScreenState extends State<EMRCalendarScreen> {
  int _tab = 0;
  List<ClinicianCalendarVisitData> _visits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVisits());
  }

  Future<void> _loadVisits() async {
    final now = DateTime.now();
    final dateFrom =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    final dateTo =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${DateUtils.getDaysInMonth(now.year, now.month).toString().padLeft(2, '0')}';

    final result = await getClinicianCalendarVisits(
      context: context,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );

    if (mounted) {
      setState(() {
        _visits = result ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),

            // ── TabBar ──────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (i) {
                final label = i == 0 ? 'Calendar' : 'Map';
                final active = _tab == i;
                return GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                              color: active ? ColorManager.bluebottom : Colors.grey,
                            )),
                        const SizedBox(height: 4),
                        Container(
                          height: 3, width: 100,
                          color: active ? ColorManager.bluebottom : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),

            // ── Body ────────────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _tab == 0
                  ? CalendarView(visits: _visits)
                  : MapView(visits: _visits),
            ),
          ],
        ),
      ),
    );
  }
}