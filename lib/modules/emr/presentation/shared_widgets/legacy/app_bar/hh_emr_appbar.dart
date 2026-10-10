import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/user_appbar_manager.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/user/user_appbar.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/app_clickable_widget.dart';

import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/app/services/api/managers/auth/auth_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/calling/calling_Manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/profile_setting_screen_emr/profile_emr_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/company_logo_widget.dart';
import 'package:symmetry_emr/app/services/session/app_session.dart';
// removed in extraction: import '../../../main.dart'; // ✅ gives access to global navigatorKey

/// ✅ NEW — shared guard so a null/empty/literal-"null" value never
/// renders as visible text in the UI. Use everywhere a nullable
/// display string (username, first name, last name, etc.) is shown.
String displayOrEmpty(String? value) {
  if (value == null) return '';
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return '';
  return value;
}

class EmrAppBar extends StatelessWidget {
  const EmrAppBar({
    super.key,
    required this.headingText,
    required this.body,
    this.isHrModule = false,
    this.isEmrClinicianModule = false,
    this.hideNameOnSmallScreen = false,
    this.shortHeadingText, // ✅ NEW
  });

  final String headingText;
  final bool isHrModule;
  final bool isEmrClinicianModule;
  final List<Widget> body;
  final bool hideNameOnSmallScreen;
  final String? shortHeadingText; // ✅ NEW

  // ✅ NEW — same breakpoint used by UserAppBarWidgetEmr's name-hide logic
  static const double _headingShrinkBreakpoint = 1320;

  @override
  Widget build(BuildContext context) {
    // ✅ NEW — swap in the short label below 1200px, only when the caller
    // opted in via hideNameOnSmallScreen and actually provided one. This
    // frees up horizontal space so the tab/body Row doesn't need to scroll.
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool useShortHeading = hideNameOnSmallScreen &&
        shortHeadingText != null &&
        screenWidth < _headingShrinkBreakpoint;
    final String displayHeading = useShortHeading ? shortHeadingText! : headingText;

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

                  // Module heading / breadcrumb
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      displayHeading, // ✅ was headingText
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

              // ── Tab bar ────────────────────────────────────────────────────
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
              UserAppBarWidgetEmr(
                isEmrClinicianModule: isEmrClinicianModule,
                hideNameOnSmallScreen: hideNameOnSmallScreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///
///

class UserAppBarWidgetEmr extends StatefulWidget {
  const UserAppBarWidgetEmr({
    Key? key,
    this.isEmrClinicianModule = false,
    this.hideNameOnSmallScreen = false, // ✅ NEW — default false
  }) : super(key: key);

  final bool isEmrClinicianModule;
  final bool hideNameOnSmallScreen; // ✅ NEW

  @override
  State<UserAppBarWidgetEmr> createState() => _UserAppBarWidgetEmrState();
}

class _UserAppBarWidgetEmrState extends State<UserAppBarWidgetEmr> {
  late final Future<UserAppBar> _appBarFuture;
  late final Future<String> _userFuture;

  String? loginName = '';
  int? _userId; // ✅ NEW
  bool isLoggedIn = true;

  // ✅ NEW — breakpoint below which the login name is hidden
  static const double _nameHideBreakpoint = 1350;

  // ✅ NEW — lets us programmatically trigger the same popup menu the
  // arrow icon opens, when the user taps the name instead
  final GlobalKey<PopupMenuButtonState<String>> _popupMenuKey =
  GlobalKey<PopupMenuButtonState<String>>();

  @override
  void initState() {
    super.initState();
    _appBarFuture = getAppBarDetails(context);
    _userFuture = _loadUser();
  }

  Future<String> _loadUser() async {
    loginName = await TokenManager.getUserName();
    _userId = await TokenManager.getuserId(); // ✅ NEW — fetched once here
    print("UserName login $loginName, userId $_userId");
    return loginName ?? ''; // ✅ guard: avoid ! crash if token not set yet
  }

  @override
  Widget build(BuildContext context) {
    // ✅ NEW — only relevant when caller opted in via hideNameOnSmallScreen
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool shouldHideName =
        widget.hideNameOnSmallScreen && screenWidth < _nameHideBreakpoint;

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
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData &&
                  snapshot.data!.imgUrl.isNotEmpty) {
                return CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 20,
                  backgroundImage: NetworkImage(snapshot.data!.imgUrl),
                );
              }
              return CircleAvatar(
                backgroundColor: Colors.grey[100],
                radius: 20,
                backgroundImage:
                const AssetImage("images/profilepic.png"),
              );
            },
          ),
          const SizedBox(width: 3),

          // Login name + dropdown
          FutureBuilder<String>(
            future: _userFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ NEW — name collapses to zero width instead of removing
                  // the widget outright, so popup menu position stays stable
                  if (!shouldHideName)
                    Flexible(
                      // ✅ NEW — tapping the name now opens the same popup
                      // menu as tapping the dropdown arrow, via the
                      // PopupMenuButton's own showButtonMenu() on its key
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            _popupMenuKey.currentState?.showButtonMenu(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            displayOrEmpty(loginName), // ✅ never shows "null"
                            style:  TextStyle(
                              color: ColorManager.blueprime,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Popup menu
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
                      itemBuilder: (BuildContext context) => [
                        if (widget.isEmrClinicianModule)
                        // Settings
                          PopupMenuItem<String>(
                            height: 25,
                            value: 'Settings',
                            padding: EdgeInsets.zero,
                            child: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProfileDetailScreen(  userId: _userId ?? 0, ),
                                  ),
                                );
                              },
                              child: Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 12),
                                width: 130,
                                height: 40,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 5.5),
                                    Row(
                                      children: [
                                        Icon(Icons.settings,
                                            size: 18,
                                            color: ColorManager.mediumgrey),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Settings',
                                          style:
                                          CustomTextStylesCommon.commonStyle(
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
                          ),

                        // Log Out
                        PopupMenuItem<String>(
                          height: 25,
                          value: 'Logout',
                          padding: EdgeInsets.zero,
                          child: InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onTap: () {
                              Navigator.pop(context);
                              if (isLoggedIn) {
                                showDialog(
                                  context: context,
                                  builder: (context) => DeletePopup(
                                    onCancel: () => Navigator.pop(context),
                                    onDelete: () async {
                                      String fcmToken = await TokenManager.getFcmTokenRegister();
                                      String refreshToken = await TokenManager.getRefreshToken();
                                      if (fcmToken.isEmpty) {
                                        var refreshTokenLogout = await AuthManager().logOutuserByToken(
                                          refreshToken: refreshToken,
                                          context: context,
                                        );
                                        if (refreshTokenLogout.statusCode == 200 ||
                                            refreshTokenLogout.statusCode == 204) {
                                          print('User logged out successfully');
                                          await TokenManager.clearSession(); // ✅ clear on success too
                                          AppSession.signedOut(context);
                                        } else {
                                          print('Failed to log out user');
                                          await TokenManager.clearSession(); // ✅ was: removeAccessToken()
                                          AppSession.signedOut(context);
                                        }
                                      } else {
                                        var response = await unRegisterDevice(
                                          context: context,
                                          fcmToken: fcmToken,
                                        );
                                        if (response.statusCode == 201 || response.statusCode == 200) {
                                          var refreshTokenLogout = await AuthManager().logOutuserByToken(
                                            refreshToken: refreshToken,
                                            context: context,
                                          );
                                          if (refreshTokenLogout.statusCode == 200 ||
                                              refreshTokenLogout.statusCode == 204) {
                                            print('User logged out successfully');
                                            await TokenManager.clearSession(); // ✅ was: removeFCMToken() only
                                            AppSession.signedOut(context);
                                          } else {
                                            print('Failed to log out user');
                                            await TokenManager.clearSession(); // ✅ was: removeAccessToken()
                                            AppSession.signedOut(context);
                                          }
                                        }
                                      }
                                    },
                                    btnText: "Log Out",
                                    title: "Log Out",
                                    text: "Do you really want to log out?",
                                  ),
                                );
                              }
                            },
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 12),
                              width: 130,
                              height: 40,
                              child: Column(
                                children: [
                                  const SizedBox(height: 5.5),
                                  Row(
                                    children: [
                                      Icon(Icons.logout,
                                          size: 18,
                                          color: ColorManager.mediumgrey),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Log Out',
                                        style:
                                        CustomTextStylesCommon.commonStyle(
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
                        ),
                      ],
                      child: Icon(
                        Icons.keyboard_arrow_down_outlined,
                        color: ColorManager.blueprime,
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
}
///
//
///

//nociteg824@noyavip.com  RN new user RN
//
// vedayaj820@nriza.com   PT User PT
//
//     OT clinician
//
// mepix47097@nriza.com         OT user 202 maxi lee
//
// kibivom298@nriza.com ST user  kibivom298@nriza.com
//
// yifej90134@nuitx.com    dme@123
//
// managersujata@gmail.com       QA manager@123
//
// gohoji5803@hitzcart.com  CEO sujata@123

//copoy11850@hitzcart.com
//
// qasujata01@gmail.com     qa@123  QA-Cordinator
//
// codersujata@gmail.com   coder@123 Coder
//
//devawa8533@ifcoat.com Clinical manager --sujata@123
///

///
//flutter build web --release --dart-define=API_ENDPOINT=https://prohealth-dev.symmetry.care --dart-define="APP_VERSION=Version 1.1.4 (1) dev"


//flutter build web --release --dart-define=API_ENDPOINT=https://demo.symmetry.care --dart-define="APP_VERSION=Version 1.1.4 (1) demo"

// class UserAppBarWidgetEmr extends StatefulWidget {
//    UserAppBarWidgetEmr({Key? key, this.isEmrClinicianModule = false}) : super(key: key);
//   final bool isEmrClinicianModule;
//
//   @override
//   State<UserAppBarWidgetEmr> createState() => _UserAppBarWidgetEmrState();
// }
//
// class _UserAppBarWidgetEmrState extends State<UserAppBarWidgetEmr> {
//   String? loginName = '';
//
//   String? loginEmail = '';
//
//   //int loginUserId = 0;
//   bool isLoggedIn = true;
//
//   Future<String> user() async {
//     loginName = await TokenManager.getUserName();
//     //loginName = userName;
//     print("UserName login ${loginName}");
//     return loginName!;
//   }
//
//   Future<String> email() async {
//     loginEmail = await TokenManager.getEmail();
//     //loginName = userName;
//     print("loginEmail login ${loginEmail}");
//     return loginEmail!;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 10,right: 5),
//       child:Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Avatar (non-tappable)
//           FutureBuilder<UserAppBar>(
//             future: getAppBarDetails(context),
//             builder: (context, snapshot) {
//               Widget avatar = CircleAvatar(
//                 backgroundColor: Colors.grey[100],
//                 radius: 20,
//                 backgroundImage: const AssetImage("images/profilepic.png"),
//               );
//
//               if (snapshot.connectionState == ConnectionState.done &&
//                   snapshot.hasData &&
//                   snapshot.data!.imgUrl.isNotEmpty) {
//                 avatar = CircleAvatar(
//                   backgroundColor: Colors.transparent,
//                   radius: 20,
//                   backgroundImage: NetworkImage(snapshot.data!.imgUrl),
//                 );
//               }
//
//               return avatar; // purely visual
//             },
//           ),
//           const SizedBox(width: 3),
//
//           // Login name and dropdown icon
//           FutureBuilder(
//             future: user(),
//             builder: (context, snap) {
//               if (snap.connectionState == ConnectionState.waiting) {
//                 return const SizedBox();
//               }
//
//               return Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Flexible(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 4),
//                       child: Text(
//                         loginName ?? "",
//                         style: const TextStyle(
//                           color: Color(0xFF2EA3D4),
//                           fontSize: 13,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ),
//
//
//
//                   // Custom styled popup menu with icons
//                   Theme(
//                     data: Theme.of(context).copyWith(
//                       splashColor: Colors.transparent,
//                       highlightColor: Colors.transparent,
//                       hoverColor: Colors.transparent,
//                       splashFactory: NoSplash.splashFactory,
//                     ),
//                     child: PopupMenuButton<String>(
//                       tooltip: '',
//                       splashRadius: 0,
//                       color: Colors.white,
//                       offset: const Offset(0, 40),
//                       padding: EdgeInsets.zero,
//
//                       itemBuilder: (BuildContext context) => [
//                         // Settings
//                         PopupMenuItem<String>(
//                           height: 25,
//                           value: 'Settings',
//                           padding: EdgeInsets.zero,
//                           child: InkWell(
//                             splashColor: Colors.transparent,
//                             highlightColor: Colors.transparent,
//                             hoverColor: Colors.transparent,
//                             onTap: () {
//                               if (widget.isEmrClinicianModule) {
//                                 Navigator.pop(context);
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => const ProfileDetailScreen(),
//                                   ),
//                                 );
//                               }
//                             },
//                             // onTap: () {
//                             //   Navigator.pop(context); // Close the popup menu first
//                             //   Navigator.push(
//                             //     context,
//                             //     MaterialPageRoute(
//                             //       builder: (context) => const ProfileDetailScreen(),
//                             //     ),
//                             //   );
//                             //   // Navigator.pop(context);
//                             //   // Navigate or perform settings logic
//                             // },
//                             child: Container(
//                               alignment: Alignment.centerLeft,
//                               padding: const EdgeInsets.only(left: 12,),
//                               width: 130,
//                               height: 40,
//                               child: Column(
//                                 children: [
//                                   const SizedBox(height: 5.5),
//                                   Row(
//                                     children: [
//                                       Icon(Icons.settings, size: 18, color: ColorManager.mediumgrey),
//                                       const SizedBox(width: 10),
//                                       Text(
//                                         'Settings',
//                                         style: CustomTextStylesCommon.commonStyle(
//                                           fontWeight: FontWeight.w700,
//                                           fontSize: FontSize.s12,
//                                           color: ColorManager.mediumgrey,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Divider(),
//                                 ],
//                               ),
//                             ),
//
//                           ),
//                         ),
//
//                         // Divider
//                         //  const PopupMenuDivider(),
//
//                         // Notification
//                         // PopupMenuItem<String>(
//                         //   height: 25,
//                         //   value: 'Notification',
//                         //   padding: EdgeInsets.zero,
//                         //   child: InkWell(
//                         //     splashColor: Colors.transparent,
//                         //     highlightColor: Colors.transparent,
//                         //     hoverColor: Colors.transparent,
//                         //     onTap: () {
//                         //       //  Navigator.pop(context);
//                         //       // Notification logic
//                         //     },
//                         //     child: Container(
//                         //       alignment: Alignment.centerLeft,
//                         //       padding: const EdgeInsets.only(left: 12, ),
//                         //       width: 130,
//                         //       height: 40,
//                         //       child: Column(
//                         //         children: [
//                         //           const SizedBox(height: 5.5),
//                         //           Row(
//                         //             children: [
//                         //               Image.asset('images/hh_emr/sick_leave.png', width: 18, height: 18,color: ColorManager.mediumgrey),
//                         //               // Icon(Icons.notifications_rounded, size: 18, color: ColorManager.mediumgrey),
//                         //               const SizedBox(width: 10),
//                         //               Text(
//                         //                 'Sick Leave (40h)',
//                         //                 style: CustomTextStylesCommon.commonStyle(
//                         //                   fontWeight: FontWeight.w700,
//                         //                   fontSize: FontSize.s12,
//                         //                   color: ColorManager.mediumgrey,
//                         //                 ),
//                         //               ),
//                         //             ],
//                         //           ),
//                         //           Divider(),
//                         //         ],
//                         //       ),
//                         //     ),
//                         //   ),
//                         // ),
//
//                         // Divider
//                         // const PopupMenuDivider(),
//
//                         // Log Out
//                         PopupMenuItem<String>(
//                           height: 25,
//                           value: 'Logout',
//                           padding: EdgeInsets.zero,
//                           child: InkWell(
//                             splashColor: Colors.transparent,
//                             highlightColor: Colors.transparent,
//                             hoverColor: Colors.transparent,
//                             onTap: () {
//                               Navigator.pop(context);
//                               if (isLoggedIn) {
//                                 showDialog(
//                                   context: context,
//                                   builder: (context) => DeletePopup(
//                                     onCancel: () => Navigator.pop(context),
//                                     onDelete: () async{
//                                       String fcmToken = await TokenManager.getFcmTokenRegister();
//                                       String refreshToken = await TokenManager.getRefreshToken();
//                                       if(fcmToken.isEmpty){
//                                         var refreshTokenLogout = await AuthManager().logOutuserByToken(refreshToken: refreshToken, context: context);
//                                         if(refreshTokenLogout.statusCode == 200 || refreshTokenLogout.statusCode == 204){
//                                           print('User logged out successfully');
//                                           // TokenManager.removeAccessToken();
//                                           // Navigator.pushNamedAndRemoveUntil(
//                                           //     buildContext, LoginScreen.routeName, (route) => false);
//                                         }else{
//                                           print('Failed to log out user');
//                                           TokenManager.removeAccessToken();
//                                           Navigator.pushNamedAndRemoveUntil(
//                                               context,
//                                               LoginScreen.routeName,
//                                                   (route) => false);
//                                         }
//
//                                       }else{
//                                         var response = await unRegisterDevice(context: context, fcmToken: fcmToken);
//                                         if(response.statusCode == 201 || response.statusCode == 200){
//                                           var refreshTokenLogout = await AuthManager().logOutuserByToken(refreshToken: refreshToken, context: context);
//                                           if(refreshTokenLogout.statusCode == 200 || refreshTokenLogout.statusCode == 204){
//                                             TokenManager.removeFCMToken();
//                                             print('User logged out successfully');
//                                             // TokenManager.removeAccessToken();
//                                             // Navigator.pushNamedAndRemoveUntil(
//                                             //     buildContext, LoginScreen.routeName, (route) => false);
//                                           }else{
//                                             print('Failed to log out user');
//                                             TokenManager.removeAccessToken();
//                                             Navigator.pushNamedAndRemoveUntil(
//                                                 context,
//                                                 LoginScreen.routeName,
//                                                     (route) => false);
//                                           }
//
//                                           // TokenManager.removeAccessToken();
//                                           // Navigator.pushNamedAndRemoveUntil(
//                                           //     context,
//                                           //     LoginScreen.routeName,
//                                           //         (route) => false);
//                                         }
//                                       }
//                                     },
//                                     btnText: "Log Out",
//                                     title: "Log Out",
//                                     text: "Do you really want to logout?",
//                                   ),
//                                 );
//                               }
//                             },
//                             child: Container(
//                               alignment: Alignment.centerLeft,
//                               padding: const EdgeInsets.only(left: 12, ),
//                               width: 130,
//                               height: 40,
//                               child: Column(
//                                 children: [
//                                   const SizedBox(height: 5.5),
//                                   Row(
//                                     children: [
//                                       Icon(Icons.logout, size: 18, color: ColorManager.mediumgrey),
//                                       const SizedBox(width: 10),
//                                       Text(
//                                         'Log Out',
//                                         style: CustomTextStylesCommon.commonStyle(
//                                           fontWeight: FontWeight.w700,
//                                           fontSize: FontSize.s12,
//                                           color: ColorManager.mediumgrey,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Divider(),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         //   const PopupMenuDivider(),
//                       ],
//                       child: const Icon(
//                         Icons.keyboard_arrow_down_outlined,
//                         color: Color(0xFF2EA3D4),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//
//
//       ///
//       // Row(
//       //   mainAxisAlignment: MainAxisAlignment.end,
//       //   crossAxisAlignment: CrossAxisAlignment.center,
//       //   children: [
//       //     MouseRegion(
//       //       onEnter: (_) {},
//       //       onExit: (_) {},
//       //       child: FutureBuilder<UserAppBar>(
//       //         future: getAppBarDetails(context),
//       //         builder: (context, snapshot) {
//       //           Widget avatar = CircleAvatar(
//       //             backgroundColor: Colors.grey[100],
//       //             radius: 20,
//       //             backgroundImage: const AssetImage("images/profilepic.png"),
//       //           );
//       //
//       //           if (snapshot.connectionState == ConnectionState.waiting) {
//       //             return GestureDetector(child: avatar, onTap: () {});
//       //           } else if (snapshot.hasData && snapshot.data!.imgUrl.isNotEmpty) {
//       //             avatar = CircleAvatar(
//       //               backgroundColor: Colors.transparent,
//       //               radius: 20,
//       //               backgroundImage: NetworkImage(snapshot.data!.imgUrl),
//       //             );
//       //           }
//       //
//       //           return GestureDetector(
//       //             child: avatar,
//       //             onTap: () {
//       //               print("userid appbar: ${snapshot.data?.userId}");
//       //             },
//       //           );
//       //         },
//       //       ),
//       //     ),
//       //     const SizedBox(width: 3),
//       //     FutureBuilder(
//       //       future: user(),
//       //       builder: (context, snap) {
//       //         if (snap.connectionState == ConnectionState.waiting) {
//       //           return const SizedBox();
//       //         }
//       //
//       //         return MouseRegion(
//       //           onEnter: (_) {
//       //             showMenu(
//       //               context: context,
//       //               position: const RelativeRect.fromLTRB(70, 70, 0, 0),
//       //               items: [
//       //                 // PopupMenuItem(
//       //                 //   padding: EdgeInsets.zero,
//       //                 //   height: 30,
//       //                 //   child: GestureDetector(
//       //                 //     onTap: () {
//       //                 //       if (isLoggedIn) {
//       //                 //         showDialog(
//       //                 //           context: context,
//       //                 //           builder: (context) => DeletePopup(
//       //                 //             onCancel: () => Navigator.pop(context),
//       //                 //             onDelete: () {
//       //                 //               TokenManager.removeAccessToken();
//       //                 //               Navigator.pushNamedAndRemoveUntil(
//       //                 //                 context,
//       //                 //                 LoginScreen.routeName,
//       //                 //                     (route) => false,
//       //                 //               );
//       //                 //             },
//       //                 //             btnText: "Log Out",
//       //                 //             title: "Log Out",
//       //                 //             text: "Do you really want to logout?",
//       //                 //           ),
//       //                 //         );
//       //                 //       }
//       //                 //     },
//       //                 //     child: Container(
//       //                 //       height: 25,
//       //                 //       width: 90,
//       //                 //       padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//       //                 //       child: Row(
//       //                 //         mainAxisAlignment: MainAxisAlignment.spaceAround,
//       //                 //         crossAxisAlignment: CrossAxisAlignment.center,
//       //                 //         children: const [
//       //                 //           Icon(Icons.logout, size: 12, color: Colors.black),
//       //                 //           Text(
//       //                 //             'Log Out',
//       //                 //             style: TextStyle(
//       //                 //               fontSize: 12,
//       //                 //               color: Colors.black,
//       //                 //               fontWeight: FontWeight.w600,
//       //                 //             ),
//       //                 //           ),
//       //                 //         ],
//       //                 //       ),
//       //                 //     ),
//       //                 //   ),
//       //                 // ),
//       //                 ///
//       //                 ///
//       //                 PopupMenuItem(
//       //                   padding: EdgeInsets.zero,
//       //                   height: 30,
//       //                   child: GestureDetector(
//       //                     onTap: () {
//       //                       // Add your navigation or action here
//       //                      // Navigator.pushNamed(context, '/profile'); // Example
//       //                     },
//       //                     child: Container(
//       //                       height: 30,
//       //                       width: 90,
//       //                       padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//       //                       child: Row(
//       //                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//       //                         crossAxisAlignment: CrossAxisAlignment.center,
//       //                         children: const [
//       //                           Icon(Icons.notifications_rounded, size: 12, color: Colors.black),
//       //                           Text(
//       //                             'Notification',
//       //                             style: TextStyle(
//       //                               fontSize: 12,
//       //                               color: Colors.black,
//       //                               fontWeight: FontWeight.w600,
//       //                             ),
//       //                           ),
//       //                         ],
//       //                       ),
//       //                     ),
//       //                   ),
//       //                 ),
//       //
//       //                 // Settings item
//       //                 PopupMenuItem(
//       //                   padding: EdgeInsets.zero,
//       //                   height: 30,
//       //                   child: GestureDetector(
//       //                     onTap: () {
//       //                       // Add your navigation or action here
//       //                      // Navigator.pushNamed(context, '/settings'); // Example
//       //                     },
//       //                     child: Container(
//       //                       height: 25,
//       //                       width: 90,
//       //                       padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//       //                       child: Row(
//       //                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//       //                         crossAxisAlignment: CrossAxisAlignment.center,
//       //                         children: const [
//       //                           Icon(Icons.settings, size: 12, color: Colors.black),
//       //                           Text(
//       //                             'Settings',
//       //                             style: TextStyle(
//       //                               fontSize: 12,
//       //                               color: Colors.black,
//       //                               fontWeight: FontWeight.w600,
//       //                             ),
//       //                           ),
//       //                         ],
//       //                       ),
//       //                     ),
//       //                   ),
//       //                 ),
//       //
//       //                 // Log Out item
//       //                 PopupMenuItem(
//       //                   padding: EdgeInsets.zero,
//       //                   height: 30,
//       //                   child: GestureDetector(
//       //                     onTap: () {
//       //                       if (isLoggedIn) {
//       //                         showDialog(
//       //                           context: context,
//       //                           builder: (context) => DeletePopup(
//       //                             onCancel: () => Navigator.pop(context),
//       //                             onDelete: () {
//       //                               TokenManager.removeAccessToken();
//       //                               Navigator.pushNamedAndRemoveUntil(
//       //                                 context,
//       //                                 LoginScreen.routeName,
//       //                                     (route) => false,
//       //                               );
//       //                             },
//       //                             btnText: "Log Out",
//       //                             title: "Log Out",
//       //                             text: "Do you really want to logout?",
//       //                           ),
//       //                         );
//       //                       }
//       //                     },
//       //                     child: Container(
//       //                       height: 25,
//       //                       width: 90,
//       //                       padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//       //                       child: Row(
//       //                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//       //                         crossAxisAlignment: CrossAxisAlignment.center,
//       //                         children: const [
//       //                           Icon(Icons.logout, size: 12, color: Colors.black),
//       //                           Text(
//       //                             'Log Out',
//       //                             style: TextStyle(
//       //                               fontSize: 12,
//       //                               color: Colors.black,
//       //                               fontWeight: FontWeight.w600,
//       //                             ),
//       //                           ),
//       //                         ],
//       //                       ),
//       //                     ),
//       //                   ),
//       //                 ),
//       //               ],
//       //             );
//       //           },
//       //           child: Row(
//       //             mainAxisSize: MainAxisSize.min,
//       //             children: [
//       //               Text(
//       //                 loginName ?? "",
//       //                 style: TextStyle(
//       //                   color: Color(0xFF2EA3D4),
//       //                   fontSize: 13,
//       //                   fontWeight: FontWeight.w700,
//       //                 ),
//       //               ),
//       //               const SizedBox(width: 4),
//       //               Icon(Icons.keyboard_arrow_down_outlined, color: Color(0xFF2EA3D4)),
//       //             ],
//       //           ),
//       //         );
//       //       },
//       //     ),
//       //   ],
//       // ),
//     );
//   }
// }
