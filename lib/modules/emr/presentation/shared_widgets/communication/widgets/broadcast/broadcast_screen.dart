import 'dart:async';
import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/communication_model/communication_string.dart';
import 'package:symmetry_emr/modules/emr/data/models/communication_data/broadcast_data/broadcast.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/broadcast/widgets/broadcast_popup.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/theme_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/communication_manger/broadcast_manager/broadcast_file.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/button_constant.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';

class BroadcastScreenCommunication extends StatefulWidget {
  const BroadcastScreenCommunication({super.key});

  @override
  State<BroadcastScreenCommunication> createState() => _BroadcastScreenCommunicationState();
}

class _BroadcastScreenCommunicationState extends State<BroadcastScreenCommunication> {
  final StreamController<BrodcastModelData> broadcastController = StreamController<BrodcastModelData>();
  TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadBroadcasts(searchText: 'all');
  }

  Future<void> _loadBroadcasts({required String searchText}) async {
    try {
      final data = await getAllBroadcast( context: context, pageNo: 1, rows: 999, searchText: searchText);
      print("✅ API returned ${data.data!.length} broadcasts");
      broadcastController.add(data);
    } catch (e) {
      print("❌ Broadcast API Error: $e");
      broadcastController.addError(e);
    }
  }
  @override
  void dispose() {
    broadcastController.close();
    super.dispose();
  }
  bool _isDarkColor(Color color) {
    double perceivedBrightness =
        color.red * 0.299 + color.green * 0.587 + color.blue * 0.114;
    return perceivedBrightness <
        128;
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p10,horizontal: AppPadding.p20),
      child: Column(
        children: [
          const SizedBox(height: AppSize.s10,),
          Row(
            children: [
              Expanded(
                child: CustomSearchFieldCM(
                  height: 40,
                  iconSize: IconSize.I16,
                  searchController: _searchController,
                  onPressed:() {
                    _loadBroadcasts(searchText: _searchController.text.isEmpty ? 'all' :_searchController.text );
                  },
                ),
              ),
              const SizedBox(width: AppSize.s15,),
              CustomElevatedButtonCM(
                elevation: 0,
                height: 40,
                borderRadius: 10,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: FontSize.s12,
                  fontWeight: FontWeight.w700
                ),
                onPressed: () {
                  showDialog(context: context, builder: (BuildContext context){
                    return SendBroadcastPopup(onRefresh: () {_loadBroadcasts(searchText: 'all');  },);
                  });
                },
                text: CommunicationString.sendBroadcast,
              textColor: ColorManager.white,
              color: ColorManager.orangeBright,)
            ],
          ),
          const SizedBox(height: AppSize.s15,),
          Expanded(
              child: StreamBuilder<BrodcastModelData>(
                  stream: broadcastController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: ColorManager.blueprime,
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Failed to load broadcasts!",
                          style: AllNoDataAvailable.customTextStyle(context),
                        ),
                      );
                    }
                    if (snapshot.data!.data!.isEmpty) {
                      return Center(
                          child: Text(
                            "No broadcast data available!",
                            style: AllNoDataAvailable.customTextStyle(context),
                          )
                      );
                    }
                    if (snapshot.hasData && snapshot.data!.data!.isNotEmpty) {
                      final broadcasts = snapshot.data!.data;
                      return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView.builder(
                    itemCount: broadcasts!.length,
                    // FIX: lets Flutter find an item's previous slot by its key when
                    // the refetched list reorders it, so the Element (and its already-
                    // decoded avatar) is truly reused instead of torn down and
                    // redecoded from scratch.
                    findChildIndexCallback: (key) {
                      final valueKey = key as ValueKey<int>;
                      final index = broadcasts.indexWhere((b) => b.alertId == valueKey.value);
                      return index == -1 ? null : index;
                    },
                    itemBuilder: (BuildContext context, int index) {
                      final item = broadcasts[index];
                      var hexColor = item.clinician.color.replaceAll("#", "");
                      return Padding(
                        key: ValueKey(item.alertId),
                        padding: const EdgeInsets.only(
                          top: AppPadding.p6,
                          left: AppPadding.p3,
                          right: AppPadding.p3,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE67514).withValues(alpha: 0.04),
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12)),
                            border: Border(
                              bottom: BorderSide(
                                color: ColorManager.greyShade300,
                                width: 3,
                              ),
                              left: BorderSide(
                                color: ColorManager.greyShade300,
                                width: 1,
                              ),
                              right: BorderSide(
                                color: ColorManager.greyShade300,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Container(
                            width: AppPadding.p6,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  topLeft: Radius.circular(12)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p20,vertical: AppPadding.p10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Stack(
                                    children: [
                                      ClipOval(
                                        child: (item.clinician.imgurl == null || item.clinician.imgurl.isEmpty || item.clinician.imgurl == 'imgurl')
                                            ? CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.transparent,
                                          child: Image.asset("images/profilepic.png"),
                                        )
                                            : Builder(
                                          builder: (context) {
                                            return Image.network(
                                              item.clinician.imgurl,
                                              height: 45,
                                              width: 45,
                                              fit: BoxFit.cover,
                                              gaplessPlayback: true,
                                              errorBuilder: (context, error, stackTrace) {
                                                return CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor: Colors.transparent,
                                                  child: Image.asset("images/profilepic.png"),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      Positioned(
                                        right: 2,
                                        bottom: 1,
                                        child: Container(
                                          width: AppSize.s18,
                                          height: AppSize.s13,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(3),
                                            color: hexColor == 'string'
                                                ? Colors.white
                                                : Color(int.parse('0xFF$hexColor')),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: AppPadding.p1,horizontal: AppPadding.p1),
                                          child: Center(
                                            child: Text('${item.clinician.abbreviation}',style: CustomTextStylesCommon
                                                .commonStyle(
                                              fontSize: FontSize.s9,
                                              fontWeight: FontWeight.w700,
                                              color:
                                              _isDarkColor(hexColor == 'string'
                                                  ? Colors.white
                                                  : Color(int.parse('0xFF$hexColor')))
                                                  ? ColorManager.black
                                                  : ColorManager.white,
                                            ),),
                                          ),

                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(width: AppSize.s15),
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${item.clinician.fullName}",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: FontSize.s14,
                                            color: ColorManager.mediumgrey,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: AppSize.s10,
                                        ),
                                        Text(
                                          item.alertBody,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontSize: FontSize.s11,
                                            fontWeight: FontWeight.w400,
                                            color: ColorManager.mediumgrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text( "${item.day} | ${item.createdAt}",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: FontSize.s12,
                                              fontWeight: FontWeight.w300,
                                              color: ColorManager.mediumgrey,
                                            )),
                                        const SizedBox(height: AppSize.s5,),
                                        Text("${item.time}",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: FontSize.s12,
                                              fontWeight: FontWeight.w300,
                                              color: ColorManager.mediumgrey,
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                ),
              );
              }
                    return Center(
                      child: Text(
                        "No broadcast data available",
                        style: AllNoDataAvailable.customTextStyle(context),
                      ),
                    );
}),

          )
        ],
      ),
    );
  }
}