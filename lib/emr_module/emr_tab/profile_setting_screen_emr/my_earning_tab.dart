import 'package:flutter/material.dart';

import '../../../../../../data/api_data/emr_module_data/setting_profile_data/my_earning_data.dart';
import '../../../../../app/services/api/managers/emr_module_manager/setting_profile_manager/my_earning_manager.dart';


class MyEarningScreen extends StatefulWidget {
  final int employeeId;
  const MyEarningScreen({Key? key, required this.employeeId}) : super(key: key);

  @override
  State<MyEarningScreen> createState() => _MyEarningScreenState();
}

class _MyEarningScreenState extends State<MyEarningScreen> {
  // ── state ──────────────────────────────────────────────
  bool _isLoading = true;

  ClinicianEarningData? _earningData;
  CompletedVisitsStatsData? _visitStatsData;
  List<TodayCompletedVisitData> _todayVisits = [];

  // ── lifecycle ──────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // defer until the first frame so `context` is fully mounted
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAll());
  }

  Future<void> _fetchAll() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      getClinicianEarning(
        context: context,
        clinicianId: widget.employeeId, // ← employeeId passed as clinicianId
      ),
      getCompletedVisitsStats(context: context),
      getTodayCompletedVisits(context: context),
    ]);

    if (!mounted) return;

    setState(() {
      _earningData     = results[0] as ClinicianEarningData?;
      _visitStatsData  = results[1] as CompletedVisitsStatsData?;
      _todayVisits     = (results[2] as List<TodayCompletedVisitData>?) ?? [];
      _isLoading       = false;
    });
  }

  // ── helpers ────────────────────────────────────────────
  String _fmt(num? v) => v == null ? '\$0' : '\$${v.toStringAsFixed(0)}';
  String _fmtVisit(num? v) => v == null ? '0' : v.toString();

  // ── build ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// ===== TOP SECTION (UNCHANGED UI) =====
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Total Earning ──
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Earning",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              StatBox(
                                title: "Total Earnings",
                                value: _fmt(_earningData?.total),
                                color: Colors.blue,
                                imagePath: 'images/hh_emr/total_earning.png',
                              ),
                              const SizedBox(width: 15),
                              StatBox(
                                title: "Today",
                                value: _fmt(_earningData?.today),
                                color: Colors.orange,
                                imagePath: 'images/hh_emr/today.png',
                              ),
                              const SizedBox(width: 15),
                              StatBox(
                                title: "This Week",
                                value: _fmt(_earningData?.thisWeek),
                                color: Colors.red,
                                imagePath: 'images/hh_emr/this_week.png',
                              ),
                              const SizedBox(width: 15),
                              StatBox(
                                title: "This Month",
                                value: _fmt(_earningData?.thisMonth),
                                color: Colors.purple,
                                imagePath: 'images/hh_emr/this_month.png',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 15),

                    // ── Total Visit ──
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Visit",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              StatBox(
                                title: "Total Visits",
                                value: _fmtVisit(_visitStatsData?.total),
                                color: Colors.blue,
                                imagePath: 'images/hh_emr/total_visit.png',
                              ),
                              const SizedBox(width: 15),
                              StatBox(
                                title: "Today",
                                value: _fmtVisit(_visitStatsData?.today),
                                color: Colors.orange,
                                imagePath: 'images/hh_emr/today.png',
                              ),
                              const SizedBox(width: 15),
                              StatBox(
                                title: "This Week",
                                value: _fmtVisit(_visitStatsData?.thisWeek),
                                color: Colors.red,
                                imagePath: 'images/hh_emr/this_week.png',
                              ),
                              const SizedBox(width: 15),
                              StatBox(
                                title: "This Month",
                                value: _fmtVisit(_visitStatsData?.thisMonth),
                                color: Colors.purple,
                                imagePath: 'images/hh_emr/this_month.png',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Expanded(flex: 1, child: SizedBox()),
                  ],
                ),

                const SizedBox(height: 20),

                /// ===== TODAY VISIT LIST =====
                Row(
                  children: [
                    Expanded(
                      flex: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Today's Visit",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),

                          // Summary container
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // Number of Visits
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20),
                                        child: Text(
                                          "${_todayVisits.length} Visit",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Total Prize
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "\$${_todayVisits.fold<num>(0, (sum, v) => sum + (v.visitCharge)).toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // List of visits
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _todayVisits.length,
                            itemBuilder: (context, index) {
                              final visit = _todayVisits[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: VisitTile(
                                  name:   visit.patientName,
                                  time:   '${visit.startTime} - ${visit.endTime}',
                                  amount: visit.visitCharge.toStringAsFixed(2),
                                  avatarUrl: visit.patientAvatarUrl,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const Expanded(flex: 2, child: SizedBox()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// API functions  (unchanged from what you provided)
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Widgets  (UI completely unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class StatBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final String imagePath;

  const StatBox({
    Key? key,
    required this.title,
    required this.value,
    required this.color,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Image.asset(imagePath, width: 25, height: 25, color: color),
          const SizedBox(height: 15),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VisitTile extends StatelessWidget {
  final String name;
  final String time;
  final String amount;
  final String avatarUrl; // ← new: used for network avatar when available

  const VisitTile({
    Key? key,
    required this.name,
    required this.time,
    required this.amount,
    this.avatarUrl = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circle Avatar — shows network image if URL is present
          CircleAvatar(
            radius: 24,
            backgroundImage:
            avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            child: avatarUrl.isEmpty ? const Icon(Icons.person) : null,
          ),

          const SizedBox(width: 20),

          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Image.asset('images/hh_emr/today_list.png',
                        width: 15, height: 15),
                    const SizedBox(width: 6),
                    const Text("Today's",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            flex: 3,
            child: Text(
              time,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),

          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                "\$$amount",
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const Expanded(flex: 5, child: SizedBox()),
        ],
      ),
    );
  }
}