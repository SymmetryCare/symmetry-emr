import 'package:flutter/material.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/profile_setting_screen_emr/time_off_tab.dart';

import '../../../../../app/resources/color.dart';
import '../../../../../app/services/api/managers/auth/auth_manager.dart';
import '../../../../../app/services/api/managers/calling/calling_Manager.dart';
import '../../../../../app/services/api/managers/emr_module_manager/setting_profile_manager/emr_profile_manager.dart';
import '../../../../../app/services/token/token_manager.dart';
import '../../../../../data/api_data/emr_module_data/setting_profile_data/emr_profile_data.dart';
import '../../../login_module/login/login_screen.dart';
import 'document_updated_tab.dart';
import 'my_earning_tab.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({Key? key}) : super(key: key);

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {

  // ── Tab state ────────────────────────────────────────────────
  int _activeTab = 0;

  TextEditingController searchController = TextEditingController();

  int? _employeeId;
  ClinicianProfileData? _profileData;
  bool _profileLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadEmployeeId(),
      _loadClinicianProfile(),
    ]);
  }

  Future<void> _loadEmployeeId() async {
    final int employeeId = await TokenManager.getEmployeeId();
    if (mounted) {
      setState(() => _employeeId = employeeId);
    }
  }

  Future<void> _loadClinicianProfile() async {
    final data = await getClinicianProfile(context: context);
    if (mounted) {
      setState(() {
        _profileData    = data;
        _profileLoading = false;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_employeeId == null || _profileLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String displayName =
    (_profileData?.clinicianFullName?.isNotEmpty == true)
        ? _profileData!.clinicianFullName!
        : '  ';

    final String imageUrl =
    (_profileData?.imageUrl?.isNotEmpty == true)
        ? _profileData!.imageUrl!
        : 'https://randomuser.me/api/portraits/men/32.jpg';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            /// ── Custom Header ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 5),
                        Icon(Icons.arrow_back_ios_outlined, size: 15),
                        SizedBox(width: 20),
                        Text(
                          "Profile Detail",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(thickness: 1),
            const SizedBox(height: 20),

            /// ── Profile Header ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const SizedBox(width: 60),

                  // Avatar with edit button
                  // Stack(
                  //   children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.transparent,
                        child: ClipOval(
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                            imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'images/profilepic.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                              : Image.asset(
                            'images/profilepic.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  //     Positioned(
                  //       bottom: 0,
                  //       right: 10,
                  //       child: GestureDetector(
                  //         onTap: () {},
                  //         child: Container(
                  //           padding: const EdgeInsets.all(10),
                  //           decoration: const BoxDecoration(
                  //             color: Colors.white,
                  //             shape: BoxShape.circle,
                  //           ),
                  //           child: Image.asset(
                  //             'images/hh_emr/edit_profile.png',
                  //             width: 18,
                  //             height: 18,
                  //             color: Colors.black45,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(width: 15),
                  // Profile info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _profileData?.email ?? '',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF757575)),
                      ),
                      const SizedBox(height: 6),
                      Text(_profileData?.mnumber ?? '',
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF757575)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Logout button
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const _LogoutConfirmPopup(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'images/hh_emr/logout.png',
                            width: 24,
                            height: 24,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Logout",
                            style: TextStyle(
                              color: ColorManager.mediumgrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 80),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ── Custom Tab Bar (full width) ────────────────────
            CustomTabBar(
              initialIndex: _activeTab,
              tabs: const [
                CustomTabItem(
                  label: 'Document Update',
                  imagePath: 'images/hh_emr/document_update.png',
                ),
                CustomTabItem(
                  label: 'Time Off',
                  imagePath: 'images/hh_emr/time_off.png',
                ),
                CustomTabItem(
                  label: 'My Earning',
                  imagePath: 'images/hh_emr/my_earning.png',
                ),
              ],
              onTabChanged: (i) => setState(() => _activeTab = i),
            ),

            const SizedBox(height: 15),

            /// ── Tab Content ────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: IndexedStack(
                  index: _activeTab,
                  children: [
                    DocumentUpdateScreen(employeeId: _employeeId!),
                    TimeOffScreen(employeeId: _employeeId!),
                    MyEarningScreen(employeeId: _employeeId!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomTabBar
// ─────────────────────────────────────────────────────────────────────────────

class CustomTabBar extends StatefulWidget {
  final List<CustomTabItem> tabs;
  final int initialIndex;
  final ValueChanged<int> onTabChanged;

  const CustomTabBar({
    Key? key,
    required this.tabs,
    required this.onTabChanged,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    widget.onTabChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [

          // ── Full-width divider stretches edge to edge ──────────
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
          ),

          // ── Tab row left-aligned with padding ─────────────────
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.tabs.length, (i) {
                final tab    = widget.tabs[i];
                final active = _selectedIndex == i;

                return GestureDetector(
                  onTap: () => _onTap(i),
                  behavior: HitTestBehavior.opaque, // no zombie ripple
                  child: Container(
                    color: Colors.transparent,      // no ink splash
                    padding: const EdgeInsets.symmetric(horizontal: 32), // increased spacing
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        // ── Image + Label ──────────────────
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                tab.imagePath,
                                width: 22,
                                height: 22,
                                color: Colors.black45,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                tab.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:  FontWeight.w600,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Animated underline indicator ───
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          height: 4,
                          width: active ? _labelWidth(tab.label) : 0,
                          decoration: BoxDecoration(
                            color: active
                                ? Colors.black45  // ← indicator color
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Approximate underline width based on label length
  double _labelWidth(String label) => 18 + 6 + (label.length * 7.2) + 32;
}

// ── Tab item model ────────────────────────────────────────────────────────────
class CustomTabItem {
  final String label;
  final String imagePath;

  const CustomTabItem({
    required this.label,
    required this.imagePath,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Logout Confirm Popup
// ─────────────────────────────────────────────────────────────────────────────

class _LogoutConfirmPopup extends StatefulWidget {
  const _LogoutConfirmPopup();

  @override
  State<_LogoutConfirmPopup> createState() => _LogoutConfirmPopupState();
}

class _LogoutConfirmPopupState extends State<_LogoutConfirmPopup> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 300,
        height: 350,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red, width: 2.5),
                ),
                child: const Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 32,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Are you Sure?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Are you sure you really want to\nlogout from your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9E9E9E),
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          navigator.pop();

                          String fcmToken     = await TokenManager.getFcmTokenRegister();
                          String refreshToken = await TokenManager.getRefreshToken();

                          void goToLogin() {
                            TokenManager.removeAccessToken();
                            TokenManager.removeFCMToken();
                            navigator.pushNamedAndRemoveUntil(
                              LoginScreen.routeName,
                                  (route) => false,
                            );
                          }

                          if (fcmToken.isEmpty) {
                            await AuthManager().logOutuserByToken(
                              refreshToken: refreshToken,
                              context: context,
                            );
                            goToLogin();
                          } else {
                            final response = await unRegisterDevice(
                              context: context,
                              fcmToken: fcmToken,
                            );
                            if (response.statusCode == 200 ||
                                response.statusCode == 201) {
                              await AuthManager().logOutuserByToken(
                                refreshToken: refreshToken,
                                context: context,
                              );
                            }
                            goToLogin();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text(
                          'Log Out',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BCD4),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}