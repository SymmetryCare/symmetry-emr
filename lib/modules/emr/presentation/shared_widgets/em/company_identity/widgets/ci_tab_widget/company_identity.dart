import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/manage_details_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/ci_manage_button/manage_details_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/manage_button_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/ci_tab_widget/widget/add_office_submit_button.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/error_pop_up.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/whitelabelling_screen.dart';
import 'package:symmetry_emr/app/resources/provider/office_location.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/company_identrity_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/company_identity/company_identity_data_.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/profile_bar/widget/pagination_widget.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';

class CompanyIdentity extends StatefulWidget {
  const CompanyIdentity({Key? key}) : super(key: key);

  @override
  State<CompanyIdentity> createState() => _CompanyIdentityState();
}

class _CompanyIdentityState extends State<CompanyIdentity> {
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobNumController = TextEditingController();
  TextEditingController secNumController = TextEditingController();
  TextEditingController OptionalController = TextEditingController();
  TextEditingController stateNameController = TextEditingController();
  TextEditingController countryNameController = TextEditingController();

  // FIX: promoted to instance field — created ONCE, not on every build()
  final StreamController<List<CompanyIdentityModel>> _companyIdentityController =
  StreamController<List<CompanyIdentityModel>>.broadcast();

  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  bool showStreamBuilder = true;
  bool showManageScreen = false;
  bool showWhitelabellingScreen = false;
  final ScrollController _horizontalScrollController = ScrollController();

  bool _isLoading = true;

  void loadData() {}

  @override
  void initState() {
    super.initState();
    _loadCompanyOfficeList();
  }

  // FIX: single source of truth for fetching + emitting data.
  // Called from initState and from any place that needs a refresh
  // (after add/edit/manage-return) — never from inside build()/StreamBuilder.
  Future<void> _loadCompanyOfficeList() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await companyOfficeListGet(context, 1, 30);
      if (!mounted) return;
      _companyIdentityController.add(data);
    } catch (e) {
      print("Error $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _companyIdentityController.close();
    _horizontalScrollController.dispose();
    nameController.dispose();
    addressController.dispose();
    emailController.dispose();
    mobNumController.dispose();
    secNumController.dispose();
    OptionalController.dispose();
    stateNameController.dispose();
    countryNameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String selectedOfficeID = '';
  String selectedOfficeName = '';
  String selectedStateName = '';
  String selectedCountryName = '';
  double selectedOfficeLat = 0.0;
  double selectedOfficeLon = 0.0;
  int selectedCompId = 0;
  int selectedCompOfficeId = 0;

  void showManageScreenFunction(
      {required String officeId,
        officeName,
        required double officeLat,
        required double officeLon,
        required int compId,
        required int companyOfficeId,
        required String stateName,
        required String countryName}) {
    setState(() {
      selectedOfficeLat = officeLat;
      selectedOfficeLon = officeLon;
      selectedStateName = stateName;
      selectedCountryName = countryName;
      selectedOfficeID = officeId;
      selectedOfficeName = officeName;
      selectedCompId = compId;
      selectedCompOfficeId = companyOfficeId;
      showManageScreen = true;
      showStreamBuilder = false;
      showWhitelabellingScreen = false;
    });
  }

  void showWhitelabellingScreenFunction() {
    setState(() {
      showStreamBuilder = false;
      showWhitelabellingScreen = true;
      showManageScreen = false;
    });
  }

  int currentPage = 1;
  int itemsPerPage = 12;
  final int totalPages = 5;
  bool _isHovered = false;

  void onPageNumberPressed(int page) {
    setState(() {
      currentPage = page;
    });
  }

  String _trimAddress(String address) {
    const int maxLength = 28;
    if (address.length > maxLength) {
      return '${address.substring(0, maxLength)}...';
    }
    return address;
  }

  bool isHeadOffice = false;

  String generateRandomString(int length) {
    const characters = 'abcdefghijklmnopqrstuvwxyz';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(length,
            (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }

  String? generatedString;
  List<ServiceList> selectedServices = [];

  @override
  Widget build(BuildContext context) {
    // FIX: controller is NO LONGER created here. Instance field handles it.
    return LayoutBuilder(builder: (context, constraints) {
      const double minContentWidth = 1200;
      final double contentWidth = constraints.maxWidth > minContentWidth
          ? constraints.maxWidth
          : minContentWidth;
      return CustomScrollbar(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppPadding.p10),
            child: SizedBox(
              width: contentWidth,
              height: constraints.maxHeight,
              child: Column(
                children: [
                  /// Render top row with buttons only if both manage and whitelabelling screens are not shown
                  if (!showManageScreen && !showWhitelabellingScreen)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSizeConst.A40, left: AppSizeConst.A40, bottom: AppPadding.p20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomElevatedButton(
                            width: AppSize.s150,
                            height: AppSize.s32,
                            text: AppStringEM.whitelabelling,
                            color: ColorManager.blueprime,
                            onPressed: showWhitelabellingScreenFunction,
                          ),
                          const SizedBox(
                            width: AppSize.s30,
                          ),
                          CustomIconButtonConst(
                            width: AppSize.s150,
                            text: AppStringEM.addNewOffice,
                            onPressed: () {
                              nameController.clear();
                              addressController.clear();
                              emailController.clear();
                              stateNameController.clear();
                              countryNameController.clear();
                              mobNumController.clear();
                              secNumController.clear();
                              OptionalController.clear();
                              selectedServices.clear();
                              Provider.of<LocationProvider>(context, listen: false).clearAllData();
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return _AddOfficeDialogContent(
                                    nameController: nameController,
                                    addressController: addressController,
                                    emailController: emailController,
                                    stateController: stateNameController,
                                    countryController: countryNameController,
                                    mobNumController: mobNumController,
                                    secNumController: secNumController,
                                    optionalController: OptionalController,
                                    formKey: _formKey,
                                  );
                                },
                              ).then((_) {
                                // FIX: refresh list once after dialog closes,
                                // instead of re-fetching on every rebuild.
                                _loadCompanyOfficeList();
                              });
                            },
                            icon: Icons.add,
                          ),
                        ],
                      ),
                    ),

                  /// Render list only if both manage and whitelabelling screens are not shown
                  if (!showManageScreen && !showWhitelabellingScreen)
                    Expanded(
                      child: showStreamBuilder
                          ? StreamBuilder<List<CompanyIdentityModel>>(
                        // FIX: single StreamBuilder, no nested FutureBuilder,
                        // no API call inside builder.
                        stream: _companyIdentityController.stream,
                        builder: (BuildContext context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                                child: CircularProgressIndicator(
                                    color: ColorManager.blueprime));
                          }
                          if (snapshot.data!.isEmpty) {
                            return Center(
                              child: Text(
                                ErrorMessageString.noOffice,
                                style: AllNoDataAvailable.customTextStyle(context),
                              ),
                            );
                          }

                          int totalItems = snapshot.data!.length;
                          int totalPages = (totalItems / itemsPerPage).ceil();
                          List<CompanyIdentityModel> paginatedData = snapshot.data!
                              .skip((currentPage - 1) * itemsPerPage)
                              .take(itemsPerPage)
                              .toList();

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizeConst.A40),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ScrollConfiguration(
                                    behavior: const ScrollBehavior().copyWith(scrollbars: false),
                                    child: LayoutBuilder(
                                      builder: (BuildContext context, BoxConstraints constraints) {
                                        double screenWidth = MediaQuery.of(context).size.width;

                                        int columns = 4;
                                        double childAspectRatio = 1;

                                        if (screenWidth <= 400) {
                                          columns = 1;
                                          childAspectRatio = 1.85;
                                        } else if (screenWidth <= 600) {
                                          columns = 2;
                                          childAspectRatio = 1.35;
                                        } else if (screenWidth <= 800) {
                                          columns = 2;
                                          childAspectRatio = 1.1;
                                        } else if (screenWidth <= 1000) {
                                          columns = 3;
                                          childAspectRatio = 0.9;
                                        } else if (screenWidth <= 1300) {
                                          columns = 3;
                                          childAspectRatio = 0.85;
                                        } else {
                                          columns = 4;
                                          childAspectRatio = 0.8;
                                        }
                                        return GridView.builder(
                                          shrinkWrap: true,
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: columns,
                                            crossAxisSpacing: 30,
                                            mainAxisSpacing: 20,
                                            childAspectRatio: childAspectRatio,
                                          ),
                                          itemCount: paginatedData.length,
                                          itemBuilder: (context, index) {
                                            int serialNumber = index + 1 + (currentPage - 1) * itemsPerPage;
                                            bool isHeadOffice = (currentPage == 1 && index == 0);

                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: AppSizeConst.A5),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(8),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.5),
                                                      spreadRadius: 1,
                                                      blurRadius: 4,
                                                      offset: const Offset(1, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    paginatedData[index].isHeadOffice == true
                                                        ? Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [
                                                        Container(
                                                          height: AppSize.s22,
                                                          width: AppSize.s100,
                                                          decoration: BoxDecoration(
                                                            color: ColorManager.faintOrange,
                                                            borderRadius: const BorderRadius.only(
                                                              bottomLeft: Radius.circular(4),
                                                              topRight: Radius.circular(4),
                                                            ),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              AppStringEM.headOffice,
                                                              style: TableHeading.customTextStyle(context),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                        : const SizedBox(height: AppSize.s22),
                                                    const SizedBox(height: AppSize.s8),
                                                    // Google Map Display
                                                    if (paginatedData[index].lat != null)
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: AppPadding.p25, right: AppPadding.p25),
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              height: AppSize.s181,
                                                              child: GoogleMap(
                                                                initialCameraPosition: CameraPosition(
                                                                  target: LatLng(
                                                                    double.parse(paginatedData[index].lat),
                                                                    double.parse(paginatedData[index].long),
                                                                  ),
                                                                  zoom: 15.0,
                                                                ),
                                                                markers: {
                                                                  Marker(
                                                                    markerId: const MarkerId(''),
                                                                    position: LatLng(
                                                                      double.parse(paginatedData[index].lat),
                                                                      double.parse(paginatedData[index].long),
                                                                    ),
                                                                  ),
                                                                },
                                                                zoomControlsEnabled: false,
                                                                mapToolbarEnabled: false,
                                                                scrollGesturesEnabled: false,
                                                                tiltGesturesEnabled: false,
                                                                rotateGesturesEnabled: false,
                                                                myLocationButtonEnabled: false,
                                                              ),
                                                            ),
                                                            const SizedBox(height: AppSize.s12),
                                                            Center(
                                                              child: InkWell(
                                                                onTap: () async {
                                                                  String googleMapsUrl =
                                                                      'https://www.google.com/maps/search/?api=1&query=${paginatedData[index].lat}, ${paginatedData[index].long}';
                                                                  if (await canLaunchUrlString(googleMapsUrl)) {
                                                                    await launchUrlString(googleMapsUrl);
                                                                  } else {
                                                                    print('Could not open the map.');
                                                                  }
                                                                },
                                                                child: Text(
                                                                  "View in map",
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.w600,
                                                                    fontSize: FontSize.s12,
                                                                    color: ColorManager.blueprime,
                                                                    decoration: TextDecoration.underline,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(height: AppSize.s12),
                                                            // Office Name and Address
                                                            Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Column(
                                                                      children: [
                                                                        Text(
                                                                          AppStringEM.officeName,
                                                                          textAlign: TextAlign.start,
                                                                          style: TableSubHeading.customTextStyle(context),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Flexible(
                                                                      child: Column(
                                                                        children: [
                                                                          Container(
                                                                            width: AppSize.s200,
                                                                            child: Text(
                                                                              paginatedData[index].officeName.toString(),
                                                                              textAlign: TextAlign.end,
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TableSubHeading.customTextStyle(context),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(height: AppSize.s8),
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Column(
                                                                      children: [
                                                                        Text(
                                                                          AppStringEM.officeAddress,
                                                                          textAlign: TextAlign.start,
                                                                          style: TableSubHeading.customTextStyle(context),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Flexible(
                                                                      child: Column(
                                                                        children: [
                                                                          Container(
                                                                            width: AppSize.s200,
                                                                            child: Text(
                                                                              paginatedData[index].address.toString(),
                                                                              textAlign: TextAlign.end,
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TableSubHeading.customTextStyle(context),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    const Spacer(),
                                                    Padding(
                                                      padding: const EdgeInsets.only(bottom: AppPadding.p15),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          CustomElevatedButton(
                                                            width: AppSize.s105,
                                                            height: AppSize.s30,
                                                            text: AppStringEM.manage,
                                                            color: ColorManager.blueprime,
                                                            onPressed: () async {
                                                              showManageScreenFunction(
                                                                officeId: paginatedData[index].officeId,
                                                                officeName: paginatedData[index].officeName,
                                                                compId: paginatedData[index].companyId,
                                                                companyOfficeId: paginatedData[index].companyOfficeId,
                                                                stateName: paginatedData[index].stateName,
                                                                countryName: paginatedData[index].countryName,
                                                                officeLat: double.parse(paginatedData[index].lat),
                                                                officeLon: double.parse(paginatedData[index].long),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                /// Pagination Controls
                                PaginationControlsWidget(
                                  currentPage: currentPage,
                                  items: snapshot.data!,
                                  itemsPerPage: itemsPerPage,
                                  onPreviousPagePressed: () {
                                    setState(() {
                                      currentPage = currentPage > 1 ? currentPage - 1 : 1;
                                    });
                                  },
                                  onPageNumberPressed: (pageNumber) {
                                    setState(() {
                                      currentPage = pageNumber;
                                    });
                                  },
                                  onNextPagePressed: () {
                                    setState(() {
                                      currentPage = currentPage < totalPages ? currentPage + 1 : totalPages;
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      )
                          : PageView(
                        controller: _pageController,
                        children: [
                          Container(
                            child: WhitelabellingScreen(
                              officeId: selectedOfficeID,
                              backButtonCallback: () {
                                setState(() {
                                  showManageScreen = true;
                                  showWhitelabellingScreen = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  /// Render manage screen if showManageScreen is true
                  if (showManageScreen)
                    Expanded(
                      child: ManageWidget(
                        officeID: selectedOfficeID,
                        officeName: selectedOfficeName,
                        companyID: selectedCompId,
                        backButtonCallBack: (bool val) {
                          if (val) {
                            setState(() {
                              showWhitelabellingScreen = false;
                              showManageScreen = false;
                              showStreamBuilder = true;
                            });
                            // FIX: refresh list once when returning from manage screen
                            _loadCompanyOfficeList();
                          }
                        },
                        companyOfficeId: selectedCompOfficeId,
                        stateName: selectedStateName,
                        countryName: selectedCountryName,
                        officeLat: selectedOfficeLat,
                        officeLon: selectedOfficeLon,
                      ),
                    ),

                  /// Render whitelabelling screen if showWhitelabellingScreen is true
                  if (showWhitelabellingScreen)
                    Expanded(
                      child: WhitelabellingScreen(
                        officeId: selectedOfficeID,
                        backButtonCallback: () {
                          setState(() {
                            showStreamBuilder = true;
                            showWhitelabellingScreen = false;
                          });
                          _loadCompanyOfficeList();
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

// FIX: wraps the Add Office dialog content so getServicesMetaData() is
// fetched exactly once (in initState) instead of being called inline in a
// FutureBuilder, which re-fired the API call on every rebuild of the dialog.
class _AddOfficeDialogContent extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController emailController;
  final TextEditingController stateController;
  final TextEditingController countryController;
  final TextEditingController mobNumController;
  final TextEditingController secNumController;
  final TextEditingController optionalController;
  final GlobalKey<FormState> formKey;

  const _AddOfficeDialogContent({
    required this.nameController,
    required this.addressController,
    required this.emailController,
    required this.stateController,
    required this.countryController,
    required this.mobNumController,
    required this.secNumController,
    required this.optionalController,
    required this.formKey,
  });

  @override
  State<_AddOfficeDialogContent> createState() => _AddOfficeDialogContentState();
}

class _AddOfficeDialogContentState extends State<_AddOfficeDialogContent> {
  late Future<List<ServicesMetaData>> _servicesMetaDataFuture;

  @override
  void initState() {
    super.initState();
    _servicesMetaDataFuture = getServicesMetaData(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ServicesMetaData>>(
        future: _servicesMetaDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: ColorManager.blueprime),
            );
          }
          if (snapshot.hasData) {
            return AddOfficeSumbitButton(
              nameController: widget.nameController,
              addressController: widget.addressController,
              emailController: widget.emailController,
              stateController: widget.stateController,
              countryController: widget.countryController,
              mobNumController: widget.mobNumController,
              secNumController: widget.secNumController,
              OptionalController: widget.optionalController,
              onPressed: () async {},
              formKey: widget.formKey,
              servicesList: snapshot.data!,
            );
          } else {
            return ErrorPopUp(title: "Received Error", text: snapshot.error.toString());
          }
        });
  }
}