import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/profile_setting_screen_emr/pending_visit_notes_tab.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/profile_setting_screen_emr/time_off_tab.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/services/api/managers/auth/auth_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/calling/calling_Manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/setting_profile_manager/emr_profile_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/hr_module_manager/progress_form_manager/onlink_general_manager.dart'; // ✅ re-added — needed for getGeneralIdPrefill (phone lookup)
import 'package:symmetry_emr/modules/emr/data/api/managers/user_appbar_manager.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/user/user_appbar.dart';
import 'package:symmetry_emr/presentation/screens/login_module/login/login_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/profile_setting_screen_emr/availability_tab.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/profile_setting_screen_emr/document_updated_tab.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/profile_setting_screen_emr/edit_profile_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/profile_setting_screen_emr/my_earning_tab.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({Key? key, required this.userId}) : super(key: key);
  final int userId; // ✅ passed in from EmrAppBar

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {

  // ── Tab state ────────────────────────────────────────────────
  int _activeTab = 0;

  TextEditingController searchController = TextEditingController();

  UserAppBar? _profileData;
  String _primaryPhoneNbr = ''; // ✅ NEW — sourced from OnlinkGeneralData, not UserAppBar
  bool _profileLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (mounted) {
      setState(() => _profileLoading = true);
    }
    try {
      final data = await getAppBarDetails(context);
      if (mounted) {
        setState(() {
          _profileData    = data;
          _profileLoading = false;
        });
      }

      // ✅ NEW — separate fetch purely to get the phone number, since
      // UserAppBar has no phone field. Uses employeeId from UserAppBar.
      await _loadPhoneNumber(data.employeeId);
    } catch (e) {
      debugPrint("Error loading clinician profile: $e");
      if (mounted) {
        setState(() => _profileLoading = false);
      }
    }
  }

  // ✅ NEW — silent refresh after edit popup success.
  // Does NOT touch _profileLoading, so the Scaffold/tabs stay mounted
  // and only the header text/avatar rebuild with the new values —
  // no full-screen spinner, no tab content getting wiped.
  Future<void> _refreshProfileAfterEdit() async {
    try {
      final data = await getAppBarDetails(context);
      if (mounted) {
        setState(() {
          _profileData = data;
        });
      }
      await _loadPhoneNumber(data.employeeId);
    } catch (e) {
      print("Error $e");
    }
  }

  // ✅ NEW
  Future<void> _loadPhoneNumber(int employeeId) async {
    try {
      final generalData = await getGeneralIdPrefill(context, employeeId);
      if (mounted) {
        setState(() => _primaryPhoneNbr = generalData.primaryPhoneNbr);
      }
    } catch (e) {
      debugPrint("Error loading phone number: $e");
      // Leave _primaryPhoneNbr as '' — non-fatal, screen still usable.
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_profileLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = _profileData;
    if (data == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Unable to load profile.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadInitialData,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final String displayName =
    (data.firstName.isNotEmpty)
        ? "${data.firstName} ${data.lastName}"
        : '  ';

    final String imageUrl =
    (data.imgUrl.isNotEmpty)
        ? data.imgUrl
        : 'https://randomuser.me/api/portraits/men/32.jpg';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            /// ── Custom Header ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 20,
                    children: [
                      InkWell(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios_outlined, size: 15)),
                      const Text(
                        "Profile Detail",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(thickness: 1),
            const SizedBox(height: 20),

            /// ── Profile Header ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 75,vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar with edit button
                  Stack(
                    children: [
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
                      Positioned(
                        bottom: 0,
                        right: 2,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierColor: Colors.black54,
                              builder: (context) =>  EditProfilePopup(
                                employeeId: data.employeeId,
                                userId: widget.userId,
                                avatarUrl: imageUrl,
                                firstNameController: TextEditingController(text: data.firstName),
                                lastNameController: TextEditingController(text: data.lastName),
                                phoneController: TextEditingController(text: _primaryPhoneNbr), // ✅ from OnlinkGeneralData
                                emailController: TextEditingController(text: data.email),
                                onUpdated: () {
                                  _refreshProfileAfterEdit(); // ✅ CHANGED — was _loadInitialData()
                                },
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'images/hh_emr/edit_profile.png',
                              width: 18,
                              height: 18,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                        data.email,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF757575)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _primaryPhoneNbr, // ✅ shown in header too, from OnlinkGeneralData
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF757575)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Logout button
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const _LogoutConfirmPopup(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
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
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ── Custom Tab Bar (full width) ────────────────────
            CustomTabBar(
              initialIndex: _activeTab,
              tabs:   [
                CustomTabItem(
                  isSvg: false,
                  label: 'Document Update',
                  imagePath: 'images/hh_emr/document_update.png',
                ),
                CustomTabItem(
                  isSvg: false,
                  label: 'Time Off',
                  imagePath: 'images/hh_emr/time_off.png',
                ),
                CustomTabItem(
                  isSvg: true,
                  label: 'Pending Visit Notes / Oasis',
                  imagePath: 'images/hh_emr/pending_visit.svg',
                ),
                CustomTabItem(
                  isSvg: false,
                  label: 'My Earning',
                  imagePath: 'images/hh_emr/my_earning.png',
                ),
                CustomTabItem(
                  isSvg: false,
                  label: 'Availability',
                  imagePath: 'images/hh_emr/available.png',
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
                    DocumentUpdateScreen(employeeId: data.employeeId),
                    TimeOffScreen(employeeId: data.employeeId),
                    PendingVisitNotesTab(employeeId: data.employeeId,),
                    MyEarningScreen(employeeId: data.employeeId),
                    const AvailabilityTab()
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


class CustomTabItem {
  final String imagePath;
  final String label;
  bool? isSvg;
  CustomTabItem({this.isSvg = true,required this.imagePath, required this.label});
}


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
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.tabs.length, (i) {
                final tab = widget.tabs[i];
                final active = _selectedIndex == i;
                final underlineWidth = _labelWidth(tab.label);

                return GestureDetector(
                  onTap: () => _onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: Colors.transparent,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              tab.isSvg == true
                                  ? SvgPicture.asset(
                                tab.imagePath,
                                width: 22,
                                height: 22,
                                colorFilter: const ColorFilter.mode(
                                  Colors.black45,
                                  BlendMode.srcIn,
                                ),
                              )
                                  : Image.asset(
                                tab.imagePath,
                                width: 22,
                                height: 22,
                                color: Colors.black45,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                tab.label,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 4,
                          width: underlineWidth,
                          child: Align(
                            alignment: Alignment.center,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              height: 4,
                              width: active ? underlineWidth : 0,
                              decoration: BoxDecoration(
                                color: active
                                    ? Colors.black45
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
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

  double _labelWidth(String label) => 18 + 6 + (label.length * 7.2) + 32;
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
        height: 300,
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
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
              const SizedBox(height: 25),
              const Text(
                'Are you sure?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you really want to\nlog out from your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9E9E9E),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.blueprime,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text(
                          'Cancel',
                          style:  TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          navigator.pop();

                          String fcmToken     = await TokenManager.getFcmTokenRegister();
                          String refreshToken = await TokenManager.getRefreshToken();

                          Future<void> goToLogin() async {
                            await TokenManager.clearSession();
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
                            await goToLogin();
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
                            await goToLogin();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ).copyWith(
                          overlayColor: WidgetStateProperty.all(Colors.transparent),
                        ),
                        child: const Text(
                          'Log Out',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
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