import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/user_appbar_manager.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/user/user_appbar.dart';
import 'package:symmetry_emr/presentation/screens/login_module/login/login_screen.dart';

import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/calling/calling_Manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/company_logo_widget.dart';

/// ✅ NEW — shared guard so a null/empty/literal-"null" value never
/// renders as visible text in the UI.
String displayOrEmpty(String? value) {
  if (value == null) return '';
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return '';
  return value;
}

class SmAppBar extends StatelessWidget {
  const SmAppBar({
    super.key,
    required this.headingText,
    required this.body,
  });

  final String headingText;
  final List<Widget> body;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SizedBox(
        height: AppBar().preferredSize.height + 15,
        width: double.maxFinite,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            children: [
              // ── Left: Logo + Heading ───────────────────────────────────────
              Row(
                children: [
                  // ✅ Shared logo widget — fetches once, reuses cache
                  Container(
                    margin: const EdgeInsets.only(left: AppPadding.p20),
                    child: const CompanyLogoWidget(),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      headingText,
                      style: const TextStyle(
                        fontSize: FontSize.s14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff3E3B3B),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),

              // ── SM tab bar ─────────────────────────────────────────────────
              Flexible(
                fit: FlexFit.loose,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: body,
                  ),
                ),
              ),

              // ── Right: user avatar / name ──────────────────────────────────
              const UserAppBarWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── UserAppBarWidget ──────────────────────────────────────────────────────────
class UserAppBarWidget extends StatefulWidget {
  const UserAppBarWidget({Key? key}) : super(key: key);

  @override
  State<UserAppBarWidget> createState() => _UserAppBarWidgetState();
}

class _UserAppBarWidgetState extends State<UserAppBarWidget> {
  String? loginName = '';
  bool isLoggedIn = true;

  // ✅ NEW — lets us programmatically trigger the same popup menu the
  // arrow icon opens, when the user taps the name instead
  final GlobalKey<PopupMenuButtonState<String>> _popupMenuKey =
  GlobalKey<PopupMenuButtonState<String>>();

  // FIX: cache these futures once instead of calling getAppBarDetails()/
  // user() inline inside FutureBuilder's `future:` param — that re-fired
  // the underlying API calls on every rebuild. Mirrors the fix applied to
  // hh_emr_appbar.dart's _UserAppBarWidgetEmrState.
  late final Future<UserAppBar> _appBarFuture;
  late final Future<String> _userFuture;

  @override
  void initState() {
    super.initState();
    _appBarFuture = getAppBarDetails(context);
    _userFuture = _loadUser();
  }

  Future<String> _loadUser() async {
    loginName = await TokenManager.getUserName();
    return loginName ?? ''; // ✅ guard: avoid ! crash if token not set yet
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          FutureBuilder<UserAppBar>(
            future: _appBarFuture,
            builder: (context, snapshot) {
              Widget avatar = CircleAvatar(
                backgroundColor: Colors.grey[100],
                radius: 20,
                backgroundImage: const AssetImage('images/profilepic.png'),
              );
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData &&
                  snapshot.data!.imgUrl.isNotEmpty) {
                avatar = CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 20,
                  backgroundImage: NetworkImage(snapshot.data!.imgUrl),
                );
              }
              return avatar;
            },
          ),
          const SizedBox(width: 3),

          // Name + dropdown
          FutureBuilder(
            future: _userFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    // ✅ NEW — tapping the name now opens the same popup
                    // menu as tapping the dropdown arrow
                    child: GestureDetector(
                      // behavior: HitTestBehavior.opaque,
                      onTap: () =>
                          _popupMenuKey.currentState?.showButtonMenu(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          displayOrEmpty(loginName), // ✅ never shows "null"
                          style: const TextStyle(
                            color: Color(0xFF2EA3D4),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                    ),
                    child: PopupMenuButton<String>(
                      key: _popupMenuKey, // ✅ NEW — lets the name tap trigger this
                      tooltip: '',
                      splashRadius: 0,
                      color: Colors.white,
                      offset: const Offset(0, 40),
                      padding: EdgeInsets.zero,
                      itemBuilder: (context) => _buildMenuItems(context),
                      child: const Icon(
                        Icons.keyboard_arrow_down_outlined,
                        color: Color(0xFF2EA3D4),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(BuildContext context) => [
    // ── Hidden for now — Settings ────────────────────────────────────────────
    // _menuItem(
    //   context,
    //   value: 'Settings',
    //   icon: Icons.settings,
    //   label: 'Settings',
    //   onTap: () {},
    // ),
    // ── Hidden for now — Notification ────────────────────────────────────────
    // _menuItem(
    //   context,
    //   value: 'Notification',
    //   icon: Icons.notifications_rounded,
    //   label: 'Notification',
    //   onTap: () {},
    // ),
    _menuItem(
      context,
      value: 'Logout',
      icon: Icons.logout,
      label: 'Log Out',
      onTap: () {
        Navigator.pop(context);
        if (isLoggedIn) {
          showDialog(
            context: context,
            builder: (_) => DeletePopup(
              onCancel: () => Navigator.pop(context),
              onDelete: () async {
                final fcmToken = await TokenManager.getFcmTokenRegister();
                if (fcmToken.isEmpty) {
                  TokenManager.removeAccessToken();
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginScreen.routeName, (r) => false);
                } else {
                  final res = await unRegisterDevice(
                      context: context, fcmToken: fcmToken);
                  if (res.statusCode == 200 || res.statusCode == 201) {
                    TokenManager.removeFCMToken();
                    TokenManager.removeAccessToken();
                    Navigator.pushNamedAndRemoveUntil(
                        context, LoginScreen.routeName, (r) => false);
                  }
                }
              },
              btnText: 'Log Out',
              title: 'Log Out',
              text: 'Do you really want to log out?',
            ),
          );
        }
      },
    ),
  ];

  PopupMenuItem<String> _menuItem(
      BuildContext context, {
        required String value,
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
    return PopupMenuItem<String>(
      height: 25,
      value: value,
      padding: EdgeInsets.zero,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: onTap,
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 12),
          width: 120,
          height: 40,
          child: Column(
            children: [
              const SizedBox(height: 5.5),
              Row(
                children: [
                  Icon(icon, size: 18, color: ColorManager.mediumgrey),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: CustomTextStylesCommon.commonStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: FontSize.s12,
                      color: ColorManager.mediumgrey,
                    ),
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}