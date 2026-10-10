import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/manage_hr/manage_work_schedule/work_schedule/widgets/delete_popup_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/app_clickable_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:symmetry_emr/app/constants/app_config.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/provider/em_provider/em_main_provider.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/calling/calling_Manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/user_appbar_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/user/user_appbar.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/const_appbar/controller.dart';
import 'package:symmetry_emr/app/services/session/app_session.dart';
import 'package:go_router/go_router.dart';
import 'package:symmetry_emr/app/router/emr_routes.dart';

class AppBarWeb extends StatefulWidget {
  AppBarWeb({super.key, required this.headingText,
    this.paddingLogo, this.paddingLogoRight,
    this.onMove});
  final String headingText;
  final double? paddingLogo;
  final double? paddingLogoRight;
  VoidCallback? onMove;

  @override
  State<AppBarWeb> createState() => _AppBarWebState();
}

class _AppBarWebState extends State<AppBarWeb> {
  final HRController hrController = Get.put(HRController());

  int? dept; // 👈 department stored in state

  // FIX: cache these futures once instead of calling getAppBarDetails()/
  // user() inline inside FutureBuilder's `future:` param — that re-fired
  // the underlying API calls on every rebuild. Mirrors the fix applied to
  // hh_emr_appbar.dart's _UserAppBarWidgetEmrState.
  late final Future<UserAppBar> _appBarFuture;
  late final Future<String> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadDepartment();
    _appBarFuture = getAppBarDetails(context);
    _userFuture = _loadUser();
  }

  Future<void> _loadDepartment() async {
    int departmentId = await TokenManager.getdepartmentId();
    print("DEPARTMENT AFTER LOGIN: $departmentId");

    setState(() {
      dept = departmentId;
    });
  }

  String? _selectedValue;

  String? loginName = '';
  String? loginEmail = '';
  //int loginUserId = 0;
  bool isLoggedIn = true;
  Future<String> _loadUser() async {
    loginName = await TokenManager.getUserName();
    //loginName = userName;
    print("UserName login ${loginName}");
    return loginName!;
  }

  Future<String> email() async {
    loginEmail = await TokenManager.getEmail();
    //loginName = userName;
    print("loginEmail login ${loginEmail}");
    return loginEmail!;
  }
  // Future<void> setUserId() async {
  //   loginUserId = await TokenManager.getuserId();
  //   print("UserId for appbar: $loginUserId");
  //   setState(() {}); // Ensure UI updates with the new user ID
  // }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   // setUserId();
  // }

  @override
  Widget build(BuildContext context) {
    //user();
    final tabState = Provider.of<EmMainProvider>(context, listen: false);
    print('user ${loginName}');
    print('email ${loginEmail}');
    print('///////////////////////////////////////////////////////');
    print("Constant salesId ${FrontendConfigStore.data!.config.salesId}");
    print("Constant deptId ${dept}");
    print("Constant salesId ${FrontendConfigStore.data!.config.clinicalId}");
    print(MediaQuery.of(context).size.width);
    return Material(
      color: Colors.white,
      child: SizedBox(
        height: AppBar().preferredSize.height + 15,
        width: double.maxFinite,
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ///logo
            Container(
              width: AppSize.s181,
              //color: Colors.red,
              margin: EdgeInsets.only(
                left: widget.paddingLogo ?? AppPadding.p50,
                right: widget.paddingLogoRight ?? AppPadding.p0,
              ),
              // margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Image.asset(
                'images/logo_login.png',
                fit: BoxFit.fill,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 242,
              margin:
                  const EdgeInsets.only(left: 10, right: 0, top: 5, bottom: 5),
              child: Material(
                elevation: 8,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xff51B5E6),
                        Color(0xff008ABD),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 240,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ///ask klip
                          Expanded(
                            flex: MediaQuery.of(context).size.width >= 1024
                                ? 2
                                : 4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(22),
                                  elevation: 4,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1,
                                        ),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xff51B5E6),
                                            Color(0xff008ABD),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(22)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Image.asset("images/mike.png"),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Ask',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Text("KLIP",
                                                style: TextStyle(
                                                  color: ColorManager.white,
                                                  fontSize: FontSize.s14,
                                                  fontWeight: FontWeight.w400,
                                                  decoration:
                                                      TextDecoration.none,
                                                )),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                ///Heading text
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        color: ColorManager.white,
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x40000000),
                                            blurRadius: 4,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            widget.headingText,
                                            style: const TextStyle(
                                              fontSize: FontSize.s14,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xff2B647F),
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: AppSize.s10,
                                          ),
                                          if (dept != null &&
                                              dept !=FrontendConfigStore.data!.config.salesId &&
                                              dept != FrontendConfigStore.data!.config.clinicalId)
                                          AppClickableWidget(
                                            onTap: widget.onMove == null ? () {
                                              tabState.clearValue();
                                              // Home is the clinician
                                              // Dashboard, a URL on the
                                              // signed-in router.
                                              final GoRouter? router =
                                                  GoRouter.maybeOf(context);
                                              if (router != null) {
                                                router.go(
                                                    EmrRoutes.clinicianHome);
                                                return;
                                              }
                                              Navigator.of(context)
                                                  .pushNamedAndRemoveUntil(
                                                "/home", // The target route name you want to go back to
                                                ModalRoute.withName(
                                                    "/home"), // Condition to pop until the target route
                                              );
                                              // Navigator.push(
                                              //     context,
                                              //     MaterialPageRoute(
                                              //         builder: (context) =>
                                              //             const HomeScreen()));
                                            } : widget.onMove!,
                                            onHover: (bool val) {},
                                            child: Icon(
                                              Icons.close,
                                              color: const Color(0xff434343),
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  100,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: AppSize.s10,
                                    ),

                                    ///add button
                                    Container(
                                      width: AppSize.s33,
                                      height: AppSize.s33,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0x40000000),
                                            blurRadius: 4,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                        color: Colors.white,
                                      ),
                                      child: Center(
                                        child: AppClickableWidget(
                                          onTap: () async {
                                            //const url = "http://localhost:52425/#/home";
                                            var baseUrl =
                                                html.window.location.origin;
                                            String url = "${baseUrl}/#/home";
                                            if (await canLaunch(url)) {
                                              await launch(url);
                                              //    Navigator.push(
                                              //      context,
                                              //      MaterialPageRoute(
                                              //       builder: (context) => OnBoardingWelcome(),
                                              //     ),
                                              //    );
                                            } else {
                                              throw 'Could not launch $url';
                                            }
                                          },
                                          onHover: (bool val) {},
                                          child: const Icon(
                                            Icons.add,
                                            color:
                                                Color(0xff2B647F), // Icon color
                                            size: 20, // Icon size
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MediaQuery.of(context).size.width >= 1024
                                    ? Expanded(
                                        flex: 5,
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  40),
                                          child: Material(
                                            elevation: 4,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(20)),
                                            child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 10),
                                                decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(18)),
                                                  color: Colors.white,
                                                ),
                                                child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      SvgPicture.asset(
                                                        'images/phone_app_bar.svg',
                                                      ),
                                                      SvgPicture.asset(
                                                        'images/message_app_bar.svg',
                                                      ),
                                                      InkWell(
                                                        onTap: () async {
                                                          // Get the email address asynchronously
                                                          String userEmail =
                                                              await email();

                                                          // Only open the email client if the email is not empty
                                                          if (userEmail
                                                              .isNotEmpty) {
                                                            final Uri emailUri =
                                                                Uri(
                                                                    scheme:
                                                                        'mailto',
                                                                    path:
                                                                        userEmail);
                                                            if (await canLaunch(
                                                                emailUri
                                                                    .toString())) {
                                                              await launch(emailUri
                                                                  .toString());
                                                            } else {
                                                              throw 'Could not launch email app';
                                                            }
                                                          } else {
                                                            // Handle case if no email is found (you can show a message to the user, etc.)
                                                            print(
                                                                "No email address found");
                                                          }
                                                        },
                                                        child: SvgPicture.asset(
                                                          'images/email_app_bar.svg',
                                                        ),
                                                      ),
                                                    ])),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(
                                        width: 1,
                                      ),

                                ///dropdown
                                MediaQuery.of(context).size.width >= 1024
                                    ? const Expanded(flex: 3, child: AppBarDropdown()
                                        //    Container(
                                        // //margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 160),
                                        //   padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                                        //      decoration: BoxDecoration(
                                        //        borderRadius: BorderRadius.circular(18),
                                        //        border: Border.all(color: Colors.white, width: 2),
                                        //        color: Colors.transparent,
                                        //      ),
                                        //      child: Center(
                                        //        child: DropdownButton<String>(
                                        //          underline: Container(),
                                        //          value: _selectedValue,
                                        //          hint: Text(
                                        //            'Super User',
                                        //            style: TextStyle(
                                        //              fontSize: 12,
                                        //              fontWeight: FontWeight.w500,
                                        //              color: Colors.white,
                                        //            ),
                                        //          ),
                                        //          icon: Padding(
                                        //            padding: const EdgeInsets.only(left: 8),
                                        //            child: Icon(
                                        //              Icons.arrow_drop_down,
                                        //              color: Colors.white,
                                        //              size: 20,
                                        //            ),
                                        //          ),
                                        //          items: <String>['Super User', 'Admin', 'Staff', 'Patient']
                                        //              .map((String value) {
                                        //            return DropdownMenuItem<String>(
                                        //              value: value,
                                        //              child: Text(
                                        //                value,
                                        //                style: TextStyle(
                                        //                  fontSize: 11,
                                        //                  fontWeight: FontWeight.w500,
                                        //                  color: _selectedValue == value
                                        //                      ? Colors.white
                                        //                      : ColorManager.white,
                                        //                ),
                                        //              ),
                                        //            );
                                        //          }).toList(),
                                        //          onChanged: (String? newValue) {
                                        //            setState(() {
                                        //              _selectedValue = newValue;
                                        //            });
                                        //          },
                                        //          dropdownColor: ColorManager.blueprime,
                                        //        ),
                                        //      ),
                                        //    ),
                                        )
                                    : const SizedBox(
                                        width: AppSize.s1,
                                      ),
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AppClickableWidget(
                                        onTap: () {},
                                        onHover: (bool val) {},
                                        child: Container(
                                          // padding: const EdgeInsets.symmetric(
                                          //     horizontal: 5, vertical: 3),
                                          child: const Center(
                                            child: Icon(
                                              Icons.notifications_none_outlined,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSize.s15),
                                      AppClickableWidget(
                                        onTap: () {},
                                        onHover: (bool val) {},
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 3),
                                          child: const Center(
                                            child: Icon(
                                              Icons.settings_outlined,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MouseRegion(
                                        onEnter: (_) {},
                                        onExit: (_) {
                                          // Handle mouse leave
                                        },
                                        child: FutureBuilder<UserAppBar>(
                                          future: _appBarFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              print("Future is loading...");
                                              return GestureDetector(
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      Colors.grey[100],
                                                  radius: 13,
                                                  backgroundImage: const AssetImage(
                                                      "images/profilepic.png"),
                                                ),
                                                onTap: () {
                                                  print(
                                                      "userid appbar (waiting state): ${snapshot.data?.userId}");
                                                },
                                              );
                                            } else if (snapshot.hasError ||
                                                snapshot.data == null ||
                                                snapshot.data!.imgUrl.isEmpty) {
                                              print(
                                                  "Error or empty imgUrl or snapshot data is null");
                                              return GestureDetector(
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      Colors.grey[100],
                                                  radius: 13,
                                                  backgroundImage: const AssetImage(
                                                      "images/profilepic.png"),
                                                ),
                                                onTap: () {
                                                  print(
                                                      "userid appbar (error or empty imgUrl): ${snapshot.data?.userId}");
                                                },
                                              );
                                            } else if (snapshot.hasData &&
                                                snapshot
                                                    .data!.imgUrl.isNotEmpty) {
                                              print(
                                                  "Data exists and imgUrl is not empty: ${snapshot.data!.imgUrl}");
                                              return GestureDetector(
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  radius:
                                                      13, // Adjust size as needed
                                                  backgroundImage: NetworkImage(
                                                    snapshot.data!.imgUrl,
                                                  ),

                                                  // child: ClipOval(
                                                  //   child: Image.network(
                                                  //     snapshot.data!.imgUrl,
                                                  //     fit: BoxFit.cover,
                                                  //     loadingBuilder: (context, child, loadingProgress) {
                                                  //       if (loadingProgress == null) {
                                                  //         print("Image loaded successfully");
                                                  //         return child; // When image has fully loaded
                                                  //       } else {
                                                  //         print("Image is loading...");
                                                  //         return Center(child: CircularProgressIndicator());
                                                  //       }
                                                  //     },
                                                  //     errorBuilder: (context, error, stackTrace) {
                                                  //       print("Error loading image, fallback to default");
                                                  //       // Fallback to default image if error occurs (invalid URL, etc.)
                                                  //       return Image.asset("images/profilepic.png", fit: BoxFit.cover);
                                                  //     },
                                                  //   ),
                                                  // ),
                                                ),
                                                onTap: () {
                                                  print(
                                                      "userid appbar (network image): ${snapshot.data?.userId}");
                                                },
                                              );
                                            } else {
                                              print(
                                                  "No data or image URL empty, fallback to default");
                                              return GestureDetector(
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      Colors.grey[100],
                                                  radius: 13,
                                                  backgroundImage: const AssetImage(
                                                      "images/profilepic.png"),
                                                ),
                                                onTap: () {},
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: AppSize.s5),
                                      FutureBuilder(
                                        future: _userFuture,
                                        builder: (context, snap) {
                                          if (snap.connectionState ==
                                              ConnectionState.waiting) {
                                            print("User data is loading...");
                                            return const SizedBox();
                                          }

                                          return MouseRegion(
                                            onEnter: (_) {
                                              // Show logout popup when hovering over username
                                              print("Showing logout menu...");
                                              showMenu(
                                                context: context,
                                                position: const RelativeRect.fromLTRB(
                                                    70,
                                                    70,
                                                    0,
                                                    0), // Adjust position as needed
                                                items: [
                                                  PopupMenuItem(
                                                    padding: EdgeInsets.zero,
                                                    height: 30,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (isLoggedIn) {
                                                          print(
                                                              "Logging out...");
                                                          // Handle logout
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    DeletePopup(
                                                              onCancel: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              onDelete: () async{
                                                                String fcmToken = await TokenManager.getFcmTokenRegister();
                                                                if(fcmToken.isEmpty){
                                                                  TokenManager.removeAccessToken();
                                                                  AppSession.signedOut(context);
                                                                }else{
                                                                  var response = await unRegisterDevice(context: context, fcmToken: fcmToken);
                                                                  if(response.statusCode == 201 || response.statusCode == 200){
                                                                    TokenManager.removeFCMToken();
                                                                    TokenManager.removeAccessToken();
                                                                    AppSession.signedOut(context);
                                                                  }
                                                                }
                                                              },
                                                              btnText:
                                                                  "Log Out",
                                                              title: "Log Out",
                                                              text:
                                                                  "Do you really want to log out?",
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      child: Container(
                                                        height: 25,
                                                        width: 90,
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                                horizontal: 5,
                                                                vertical: 5),
                                                        child: const Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons.logout,
                                                              size: 12,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            Text(
                                                              'Log Out',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                            child: Text(
                                              loginName!,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    8, // Adjust font size as needed
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                ///
                                // Expanded(
                                //   flex: 2,
                                //   child: Column(
                                //     mainAxisAlignment: MainAxisAlignment.center,
                                //     children: [
                                //       MouseRegion(
                                //         onEnter: (_) {},
                                //         onExit: (_) {
                                //           // Handle mouse leave
                                //         },
                                //
                                //         child: FutureBuilder<UserAppBar>(
                                //           future: getAppBarDetails(context),
                                //           builder: (context, snapshot) {
                                //             if (snapshot.connectionState == ConnectionState.waiting) {
                                //               return
                                //
                                //                   GestureDetector(
                                //                     child: CircleAvatar(
                                //                       backgroundColor: Colors.grey[100],
                                //                       radius: 13,
                                //                       backgroundImage: AssetImage("images/profilepic.png"),
                                //                     ),
                                //                     onTap: () {
                                //                       print("userid appbar : ${snapshot.data?.userId}");
                                //                       print(snapshot.data?.employeeId);
                                //                       print(snapshot.data?.imgUrl);
                                //                       print(snapshot.data?.companyId);
                                //                       print(snapshot.data?.userId);
                                //                       // Optional: Handle tap on the profile image
                                //                     },
                                //                   );
                                //
                                //             } else if (snapshot.hasError || snapshot.data == null || snapshot.data!.imgUrl.isEmpty || snapshot.data == "") {
                                //               return
                                //
                                //                 GestureDetector(
                                //                 child: CircleAvatar(
                                //                   backgroundColor: Colors.grey[100],
                                //                   radius: 12,
                                //                   backgroundImage: AssetImage("images/profilepic.png"),
                                //                 ),
                                //                 onTap: () {
                                //                   print("userid appbar : ${snapshot.data?.userId}");
                                //                   print(snapshot.data?.employeeId);
                                //                   print(snapshot.data?.imgUrl);
                                //                   print(snapshot.data?.companyId);
                                //                   print(snapshot.data?.userId);
                                //                   // Optional: Handle tap on the profile image
                                //                 },
                                //               );
                                //             } else if(snapshot.hasData) {
                                //             return GestureDetector(
                                //             child: CircleAvatar(
                                //               backgroundColor: Colors.transparent,
                                //             backgroundImage: NetworkImage(snapshot.data!.imgUrl),
                                //             radius: 13, // Adjust size as needed
                                //             ),
                                //             onTap: () {
                                //             print("userid appbar : ${snapshot.data?.userId}");
                                //             print(snapshot.data?.employeeId);
                                //             print(snapshot.data?.imgUrl);
                                //             print(snapshot.data?.companyId);
                                //             print(snapshot.data?.userId);
                                //             // Optional: Handle tap on the profile image
                                //             },
                                //             );
                                //             }
                                //             else {
                                //               return
                                //                 GestureDetector(
                                //                 child: CircleAvatar(
                                //                   backgroundColor: Colors.grey[100],
                                //                   radius: 13,
                                //                   backgroundImage: AssetImage("images/profilepic.png"),
                                //                 ),
                                //                 onTap: () {},
                                //               );
                                //             }
                                //           },
                                //         ),
                                //       ),
                                //      const SizedBox(height: AppSize.s5),
                                //       FutureBuilder(
                                //         future: user(),
                                //         builder: (context, snap) {
                                //           if (snap.connectionState == ConnectionState.waiting) {
                                //             return SizedBox();
                                //           }
                                //
                                //           return MouseRegion(
                                //             onEnter: (_) {
                                //               // Show logout popup when hovering over username
                                //               showMenu(
                                //                 context: context,
                                //                 position: RelativeRect.fromLTRB(
                                //                     70,
                                //                     70,
                                //                     0,
                                //                     0), // Adjust position as needed
                                //                 items: [
                                //                   PopupMenuItem(
                                //                     padding: EdgeInsets.zero,
                                //                     height: 30,
                                //                     child: GestureDetector(
                                //                       onTap: () {
                                //                         if (isLoggedIn) {
                                //                           // Replace 'value' with 'isLoggedIn'
                                //                           print("User logged out");
                                //                           showDialog(
                                //                             context: context,
                                //                             builder: (context) => DeletePopup(
                                //                               onCancel: () {
                                //                                 Navigator.pop(context);
                                //                               },
                                //                               onDelete: () {
                                //                                 TokenManager.removeAccessToken();
                                //                                 Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName,
                                //                                   (route) => false,
                                //                                 );
                                //                               },
                                //                               btnText: "Log Out",
                                //                               title: "Log Out",
                                //                               text: "Do you really want to logout?",
                                //                             ),
                                //                           );
                                //                         }
                                //                         print('Logging out');
                                //                       },
                                //                       child: Container(
                                //                         height: 25, // Reduced height for the logout button
                                //                         width: 90,
                                //                         // margin: EdgeInsets.symmetric(vertical: 10),
                                //                         padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                                //                         child: Row(
                                //                           mainAxisAlignment: MainAxisAlignment.spaceAround,
                                //                           crossAxisAlignment: CrossAxisAlignment.center,
                                //                           children: [
                                //                             Icon(Icons.logout,
                                //                               size: 12, // Set icon size
                                //                               color: Colors.black,
                                //                             ),
                                //                             // SizedBox(width: 8),
                                //                             Text(
                                //                               'Log Out',
                                //                               style: TextStyle(
                                //                                   fontSize: 12, // Set font size
                                //                                   color: Colors.black,
                                //                                   fontWeight: FontWeight.w600),
                                //                             ),
                                //                           ],
                                //                         ),
                                //                       ),
                                //                     ),
                                //                   ),
                                //                 ],
                                //               );
                                //             },
                                //             child: Text(
                                //               loginName!,
                                //               textAlign: TextAlign.center,
                                //               style: TextStyle(
                                //                 color: Colors.white,
                                //                 fontSize: 8,//FontSize.s10,
                                //                 fontWeight: FontWeight.w400,
                                //               ),
                                //             ),
                                //           );
                                //         },
                                //       ),
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
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

class AppBarDropdown extends StatefulWidget {
  final String? initialValue;
  final Function(String)? onChange;
  final bool? isEnabled;
  const AppBarDropdown(
      {super.key, this.initialValue, this.onChange, this.isEnabled});

  @override
  State<AppBarDropdown> createState() => _AppBarDropdownState();
}

class _AppBarDropdownState extends State<AppBarDropdown> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  void _showCustomDropdown() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  width: 150,

                  decoration: BoxDecoration(
                    color: ColorManager.blueprime,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  constraints: const BoxConstraints(
                    maxHeight: 200, // Limit height for scrolling
                  ),
                  child: SingleChildScrollView(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: ['Super User', 'Admin', 'Staff', 'Patient']
                          .map((String item) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedValue = item;
                              widget.onChange?.call(item);
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: const BoxDecoration(
                                // border: Border(
                                //   bottom: BorderSide(color: Colors.white54, width: 0.5),
                                // ),
                                ),
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // SingleChildScrollView(
                  //   child: ListView(
                  //     padding: EdgeInsets.zero,
                  //     shrinkWrap: true,
                  //     children: ['Super User','Admin','Staff','Patient'].map((String item) {
                  //       return ListTile(
                  //         title: Text(
                  //           item,
                  //           style: TextStyle(
                  //             fontSize: 12,
                  //             fontWeight: FontWeight.w500,
                  //             color: Colors.white,
                  //           ),
                  //         ),
                  //         onTap: () {
                  //           setState(() {
                  //             _selectedValue = item;
                  //             widget.onChange?.call(item);
                  //           });
                  //           Navigator.pop(context);
                  //         },
                  //       );
                  //     }).toList(),
                  //   ),
                  // ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showCustomDropdown,
      child: Container(
        //margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 160),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white, width: 2),
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
                child: Text(
                  _selectedValue ?? 'Super User',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: ColorManager.white,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p8),
              child: Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Expanded(
//                                   flex: 2,
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       MouseRegion(
//                                         onEnter: (_) {},
//                                         onExit: (_) {
//                                           // Handle mouse leave
//                                         },
//                                         // child: FutureBuilder<UserAppBar>(
//                                         //   future: getAppBarDetails(context),
//                                         //   builder: (context, snapshot) {
//                                         //     if (snapshot.connectionState == ConnectionState.waiting) {
//                                         //       return SizedBox(
//                                         //         width: 15,
//                                         //         height: 15,
//                                         //         child: CircularProgressIndicator(
//                                         //           strokeWidth: 2,
//                                         //           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                         //         ),
//                                         //       );
//                                         //     }
//                                         //     String imageUrl = snapshot.hasData && snapshot.data?.imgUrl != null && snapshot.data!.imgUrl.isNotEmpty
//                                         //         ? snapshot.data!.imgUrl
//                                         //         : "images/profilepic.png"; // Local asset fallback
//                                         //
//                                         //     return GestureDetector(
//                                         //       child: CircleAvatar(
//                                         //         backgroundColor: Colors.transparent, // Optional: Background color
//                                         //         radius: 13,
//                                         //         backgroundImage: imageUrl.startsWith("http")
//                                         //             ? NetworkImage(imageUrl) as ImageProvider
//                                         //             : AssetImage(imageUrl), // Fallback to asset image
//                                         //       ),
//                                         //       onTap: () {
//                                         //         print("User ID: ${snapshot.data?.userId}");
//                                         //         print("Employee ID: ${snapshot.data?.employeeId}");
//                                         //         print("Image URL: ${snapshot.data?.imgUrl}");
//                                         //         print("Company ID: ${snapshot.data?.companyId}");
//                                         //       },
//                                         //     );
//                                         //   },
//                                         // ),
//                                         child: FutureBuilder<UserAppBar>(
//                                           future: getAppBarDetails(context),
//                                           builder: (context, snapshot) {
//                                             if (snapshot.connectionState == ConnectionState.waiting) {
//                                               return
//                                                 // SizedBox(
//                                                 //     width: 15, // Adjust size according to your requirement
//                                                 //     height: 15,
//                                                 //     child: CircularProgressIndicator(
//                                                 //       strokeWidth: 2,
//                                                 //       valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Change color if needed
//                                                 //     ),
//                                                 //   );
//                                                   GestureDetector(
//                                                     child: CircleAvatar(
//                                                       backgroundColor: Colors.grey[100],
//                                                       radius: 13,
//                                                       backgroundImage: AssetImage("images/profilepic.png"),
//                                                     ),
//                                                     onTap: () {
//                                                       print("userid appbar : ${snapshot.data?.userId}");
//                                                       print(snapshot.data?.employeeId);
//                                                       print(snapshot.data?.imgUrl);
//                                                       print(snapshot.data?.companyId);
//                                                       print(snapshot.data?.userId);
//                                                       // Optional: Handle tap on the profile image
//                                                     },
//                                                   );
//
//                                             } else if (snapshot.hasError || snapshot.data == null || snapshot.data!.imgUrl.isEmpty || snapshot.data == "") {
//                                               return
//                                               // SizedBox(
//                                               //   width: 15, // Adjust size according to your requirement
//                                               //   height: 15,
//                                               //   child: CircularProgressIndicator(
//                                               //     strokeWidth: 2,
//                                               //     valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Change color if needed
//                                               //   ),
//                                               // );
//                                                 GestureDetector(
//                                                 child: CircleAvatar(
//                                                   backgroundColor: Colors.grey[100],
//                                                   radius: 12,
//                                                   backgroundImage: AssetImage("images/profilepic.png"),
//                                                 ),
//                                                 onTap: () {
//                                                   print("userid appbar : ${snapshot.data?.userId}");
//                                                   print(snapshot.data?.employeeId);
//                                                   print(snapshot.data?.imgUrl);
//                                                   print(snapshot.data?.companyId);
//                                                   print(snapshot.data?.userId);
//                                                   // Optional: Handle tap on the profile image
//                                                 },
//                                               );
//                                             } else if(snapshot.hasData) {
//                                             return GestureDetector(
//                                             child: CircleAvatar(
//                                               backgroundColor: Colors.transparent,
//                                             backgroundImage: NetworkImage(snapshot.data!.imgUrl),
//                                             radius: 13, // Adjust size as needed
//                                             ),
//                                             onTap: () {
//                                             print("userid appbar : ${snapshot.data?.userId}");
//                                             print(snapshot.data?.employeeId);
//                                             print(snapshot.data?.imgUrl);
//                                             print(snapshot.data?.companyId);
//                                             print(snapshot.data?.userId);
//                                             // Optional: Handle tap on the profile image
//                                             },
//                                             );
//                                             }
//                                             else {
//                                               return
//                                                 GestureDetector(
//                                                 child: CircleAvatar(
//                                                   backgroundColor: Colors.grey[100],
//                                                   radius: 13,
//                                                   backgroundImage: AssetImage("images/profilepic.png"),
//                                                 ),
//                                                 onTap: () {},
//                                               );
//                                             }
//                                           },
//                                         ),
//                                       ),
//                                      const SizedBox(height: AppSize.s5),
//                                       FutureBuilder(
//                                         future: user(),
//                                         builder: (context, snap) {
//                                           if (snap.connectionState == ConnectionState.waiting) {
//                                             return SizedBox();
//                                           }
//
//                                           return MouseRegion(
//                                             onEnter: (_) {
//                                               // Show logout popup when hovering over username
//                                               showMenu(
//                                                 context: context,
//                                                 position: RelativeRect.fromLTRB(
//                                                     70,
//                                                     70,
//                                                     0,
//                                                     0), // Adjust position as needed
//                                                 items: [
//                                                   PopupMenuItem(
//                                                     padding: EdgeInsets.zero,
//                                                     height: 30,
//                                                     child: GestureDetector(
//                                                       onTap: () {
//                                                         if (isLoggedIn) {
//                                                           // Replace 'value' with 'isLoggedIn'
//                                                           print("User logged out");
//                                                           showDialog(
//                                                             context: context,
//                                                             builder: (context) =>
//                                                                     DeletePopup(
//                                                               onCancel: () {
//                                                                 Navigator.pop(
//                                                                     context);
//                                                               },
//                                                               onDelete: () {
//                                                                 TokenManager
//                                                                     .removeAccessToken();
//                                                                 Navigator
//                                                                     .pushNamedAndRemoveUntil(
//                                                                   context,
//                                                                   LoginScreen
//                                                                       .routeName,
//                                                                   (route) =>
//                                                                       false,
//                                                                 );
//                                                               },
//                                                               btnText:
//                                                                   "Log Out",
//                                                               title: "Log Out",
//                                                               text:
//                                                                   "Do you really want to logout?",
//                                                             ),
//                                                           );
//                                                         }
//                                                         print('Logging out');
//                                                       },
//                                                       child: Container(
//                                                         height:
//                                                             25, // Reduced height for the logout button
//                                                         width: 90,
//                                                         // margin: EdgeInsets.symmetric(vertical: 10),
//                                                         padding: EdgeInsets
//                                                             .symmetric(
//                                                                 horizontal: 5,
//                                                                 vertical: 5),
//                                                         child: Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .spaceAround,
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment
//                                                                   .center,
//                                                           children: [
//                                                             Icon(
//                                                               Icons.logout,
//                                                               size:
//                                                                   12, // Set icon size
//                                                               color:
//                                                                   Colors.black,
//                                                             ),
//                                                             // SizedBox(width: 8),
//                                                             Text(
//                                                               'Log Out',
//                                                               style: TextStyle(
//                                                                   fontSize:
//                                                                       12, // Set font size
//                                                                   color: Colors
//                                                                       .black,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w600),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               );
//                                             },
//                                             child: Text(
//                                               loginName!,
//                                               textAlign: TextAlign.center,
//                                               style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 8,//FontSize.s10,
//                                                 fontWeight: FontWeight.w400,
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ),
