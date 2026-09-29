import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/communication_manger/chats_manager/patients_manager/patients_file.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/camera_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/chat_file_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/chat_tabs_const_textfield_mic.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/voice_note_bubble.dart';
import 'package:record/record.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/communication_model/communication_textstyle.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/calling/calling_Manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/communication_data/chats_data/patients_data/patients.dart';
import 'package:symmetry_emr/modules/emr/data/models/communication_data/chats_data/patients_data/patients_chat.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/onboarding/download_doc_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'dart:async';         // for base64Encode
import 'dart:typed_data';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widget_for_tab_mobile/communication_tablet/communication_tab_home_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/call_screens/new_videocall_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/toste_notify_const.dart';
import 'package:visibility_detector/visibility_detector.dart';

class PatientScreen extends StatefulWidget {
  final bool showProfileUrl;
  final ValueChanged<bool>? onShowProfileUrlChanged;
  final ValueChanged<int>? onGroupSelected;

  const PatientScreen({super.key,
    required this.showProfileUrl,
    this.onShowProfileUrlChanged,
    this.onGroupSelected,});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
  static Widget _iconButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child:  Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
            border: Border.all(color:Colors.grey.shade200, width: 1)),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _PatientScreenState extends State<PatientScreen> {
  final StreamController<List<PatientGroup>> patientsChatsController = StreamController<List<PatientGroup>>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  // simple in-memory data
  int? currentUserId;


  ChatPatientsGroupCommunicationData? chatData;
  bool isLoadingChat = false;
  int selectedGroupId = 0;
  Timer? _chatTimer;
  Timer? _listTimer;
  bool _isFirstLoad = true;
  bool _isFirstListLoad = true;
  bool _autoScroll = true;
  int _unreadCount = 0;
  bool showEmojiPicker = false;
  bool showFilePick = false;
  bool _isOpeningCamera = false;
  bool _fileAbove20Mb = false;
  bool _isPolling = false; // 👈 NEW: tracks whether this screen is visible & polling

  List<Uint8List> selectedFiles = [];
  List<String> selectedFileNames = [];


  String isSendViaSms = 'Send Default';
  @override
  void initState() {
    super.initState();
    // ❌ startListeningList('all');  → REMOVED.
    // VisibilityDetector in build() starts polling only when this screen
    // actually becomes visible, and stops it when you leave the screen.
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      final position = _scrollController.position;

      // How much content is below current view
      final double extentAfter = position.extentAfter;

      // Tolerance values
      const double NEAR_BOTTOM_THRESHOLD = 0.0; // still considered "at bottom"
      const double FAR_FROM_BOTTOM_THRESHOLD = 0.0; // really scrolled up

      // User is close to bottom → keep/enable auto-scroll
      if (extentAfter < NEAR_BOTTOM_THRESHOLD) {
        _autoScroll = true;
      }
      // User has scrolled up far enough → disable auto-scroll
      else if (extentAfter > FAR_FROM_BOTTOM_THRESHOLD) {
        _autoScroll = false;
      }

      // 👉 Result:
      // - small scrolls up (extentAfter between 0 and ~150) still treated as "at bottom"
      // - only when user scrolls more (~300px+) we stop auto-scrolling
    });

  }

  // 👇 NEW: start everything when the screen becomes visible
  void _startPolling() {
    if (_isPolling) return;
    _isPolling = true;

    final query = _searchController.text.trim();
    startListeningList(query.isEmpty ? 'all' : query);

    // If a group was already open before leaving the screen, resume its chat polling
    if (selectedGroupId != 0) {
      startListeningGroup(selectedGroupId);
    }
  }

  // 👇 NEW: stop everything when the screen is hidden (user goes to another screen/tab)
  void _stopPolling() {
    if (!_isPolling) return;
    _isPolling = false;
    _listTimer?.cancel();
    _chatTimer?.cancel();
  }

  Timer? _debounce;




  void _onSearchChanged() {
    // cancel any previous timers to debounce
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 600), () {
      final query = _searchController.text.trim();
      _loadPatientGroups(query.isEmpty ? "all" : query);
    });
  }

  Future<void> _loadPatientGroups(String searchText) async {
    try {
      final data = await getAllChatsPatientGroups(context,1,9999,searchText);
      if (!patientsChatsController.isClosed) {
        patientsChatsController.add(data);
      }
    } catch (e) {
      if (!patientsChatsController.isClosed) {
        patientsChatsController.addError(e);
      }
    }
  }
  Future<void> startListeningList(String searchText) async {
    // Load first time (👇 FIXED: result now goes into the stream immediately)
    await _loadPatientGroups(searchText);
    _isFirstListLoad = false;

    // Reset polling timer
    _listTimer?.cancel();

    _listTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || !_isPolling) return; // 👈 don't poll when screen is hidden

      _loadPatientGroups(searchText);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    _listTimer?.cancel();
    _chatTimer?.cancel();
    patientsChatsController.close();
    _scrollController.dispose();
    super.dispose();
  }
  bool _isUserAtBottom = true;
  Future<void> loadGroupChat(int groupId, {bool showLoader = false}) async {
    final userId = await TokenManager.getuserId();

    // Save user scroll state before updating data
    final bool shouldScrollToBottom = _autoScroll;
    final int oldCount = chatData?.messages.length ?? 0;

    if (showLoader || chatData == null) {
      if (mounted) {
        setState(() => isLoadingChat = true);
      }
    }

    try {
      final data = await chatPatientsGroupCommunication(
        context,
        groupId,
        1,
        999999,
      );

      if (mounted) {
        setState(() {
          selectedGroupId = groupId;
          currentUserId = userId;
          chatData = data;
          final int newCount = chatData?.messages.length ?? 0;
          final int added = newCount - oldCount;

          // 👇 Only count as "unread" when user is scrolled up
          if (added > 0 && !_autoScroll) {
            _unreadCount += added;
          }
        });
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;

        if (shouldScrollToBottom) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });

      // ❌ DO NOT call startListeningGroup here
    } catch (e) {
      debugPrint('loadGroupChat error: $e');
    } finally {
      if (mounted) {
        setState(() => isLoadingChat = false);
      }
    }
  }


  Future<void> startListeningGroup(int groupId) async {
    // Load first time
    await loadGroupChat(groupId, showLoader: _isFirstLoad);
    _isFirstLoad = false;

    // Reset polling timer
    _chatTimer?.cancel();

    _chatTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_isPolling) return; // 👈 don't poll when screen is hidden

      loadGroupChat(groupId, showLoader: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(kIsWeb, 'This screen is intended for Flutter Web layouts.');

    // 👇 NEW: VisibilityDetector wraps the whole screen.
    // - When this screen appears  → _startPolling() (APIs start)
    // - When you go to another screen/tab → _stopPolling() (APIs stop)
    return VisibilityDetector(
      key: const Key('patient-screen-visibility'),
      onVisibilityChanged: (info) {
        if (!mounted) return;
        if (info.visibleFraction > 0) {
          _startPolling();
        } else {
          _stopPolling();
        }
      },
      child: Container(
        decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
            border: Border.all(color: ColorManager.bordercolorcontainer)
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MediaQuery.of(context).size.width <= 400 ? const Offstage() : Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10, vertical: AppPadding.p12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: AppPadding.p10,top: AppPadding.p10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Patient',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: AppSize.s14),
                          CustomSearchFieldCM(
                            searchController: _searchController,
                            onPressed: () {
                              final query = _searchController.text.trim();
                              startListeningList(query.isEmpty ? "all" : query);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSize.s8),
                    Expanded(
                        child: StreamBuilder<List<PatientGroup>>(
                            stream: patientsChatsController.stream,
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
                                    "Failed to load patients chats!",
                                    style: AllNoDataAvailable.customTextStyle(context),
                                  ),
                                );
                              }
                              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                final patients = snapshot.data!;
                                return ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context).copyWith(
                                    scrollbars: false,
                                    overscroll: false,
                                  ),
                                  child:Padding(
                                    padding:const EdgeInsets.only(left: AppPadding.p10),
                                    child: ListView.builder(
                                      physics: const ClampingScrollPhysics(),
                                      itemCount: patients.length,
                                      // FIX: without this, ListView.builder only matches
                                      // elements by their slot index, not by key — so when
                                      // polling re-sorts the list (e.g. most-recent-message
                                      // first), every reordered tile is torn down and
                                      // recreated from scratch despite having a stable key,
                                      // forcing its avatar to reload. This lets Flutter find
                                      // an item's PREVIOUS slot by its key and truly reuse it.
                                      findChildIndexCallback: (key) {
                                        final valueKey = key as ValueKey<int>;
                                        final index = patients.indexWhere((p) => p.ptGroupId == valueKey.value);
                                        return index == -1 ? null : index;
                                      },
                                      itemBuilder: (context, index) {
                                        final item = patients[index];

                                        String formattedTime(String timestamp) {
                                          try {
                                            final dateTime = DateTime.parse(timestamp).toUtc();
                                            final usEastern = dateTime.subtract(const Duration(hours: 4)); // EDT (UTC-4)
                                            // For EST (UTC-5, Nov–Mar): use Duration(hours: 5)
                                            return DateFormat('h:mm a').format(usEastern);
                                          } catch (e) {
                                            return '';
                                          }
                                        }
                                        return ContainerDataListTilepatient(
                                          key: ValueKey(item.ptGroupId),
                                          unseenCount: item.unseenMessageCount,
                                          isActive: item.isActive,
                                          imagePath: item.groupProfileUrl,
                                          name: item.groupName,
                                          message: item.lastMessageText ?? "",     // 👈 last message from API
                                          time: formattedTime(item.lastMessageTimestamp),
                                          members: item.groupMembers,
                                          onImageTap: () {
                                            widget.onShowProfileUrlChanged?.call(false);
                                            widget.onGroupSelected?.call(item.ptGroupId);
                                            loadGroupChat(item.ptGroupId, showLoader: true);
                                            startListeningGroup(item.ptGroupId);
                                          },
                                        );
                                      },
                                    ),
                                  ),


                                );  }
                              return Center(
                                child: Text(
                                  "No patient group chat data available!",
                                  style: AllNoDataAvailable.customTextStyle(context),
                                ),
                              );
                            })

                    ),
                  ],
                ),
              ),
            ),
            MediaQuery.of(context).size.width <= 400 ? const Offstage() :  const VerticalDivider(thickness: 2, ),
            Expanded(
              flex: 7,
              child: chatData == null
                  ? Center(
                child: Text(
                  "Select a patient group to view messages!",
                  style: AllNoDataAvailable.customTextStyle(context),
                ),
              )
                  : Column(
                children: [
                  Container(
                    height: 75,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: (){
                                widget.onShowProfileUrlChanged?.call(!widget.showProfileUrl);
                                widget.onGroupSelected?.call(selectedGroupId);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: (chatData!.groupInfo.groupProfileUrl!.isEmpty || chatData!.groupInfo.groupProfileUrl == 'imgurl')
                                    ? CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.transparent,
                                  child: Image.asset("images/profilepic.png"),
                                )
                                    : Builder(
                                  builder: (context) {
                                    return CachedNetworkImage(
                                      imageUrl: chatData!.groupInfo.groupProfileUrl,
                                      // FIX: caching by the URL with any query string/signed
                                      // token stripped means a poll-refetched group whose URL
                                      // carries a fresh token still hits the same cache entry
                                      // instead of redecoding and flashing every poll.
                                      cacheKey: chatData!.groupInfo.groupProfileUrl.split('?').first,
                                      height: 55,
                                      width: 55,
                                      fit: BoxFit.cover,
                                      fadeInDuration: Duration.zero,
                                      fadeOutDuration: Duration.zero,
                                      errorWidget: (context, url, error) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.asset("images/profilepic.png",height: 55,width: 55,),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chatData!.groupInfo.groupName,
                                  style: const TextStyle(color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: FontSize.s12,),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Text(
                                        'Please note that it\'s a patient group',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2,),
                              ],
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            PatientScreen._iconButton(Icons.videocam, ColorManager.blueprime, () async{
                              var callResponse = await addCallInitiate(context,
                                  participantUserIds: chatData!.participants
                                      .map((e) => e.userId)
                                      .where((id) => id != currentUserId)
                                      .toList(),
                                  callType: 'GROUP',
                                  isVideo: true);
                              if(callResponse.statusCode == 201 || callResponse.statusCode == 200){
                                print('Call response ${callResponse.data}');
                                final data = callResponse.data as Map<String, dynamic>;
                                Navigator.push(context, MaterialPageRoute(builder: (_)=>
                                    VideoCallAgoraScreen(
                                      isVideoOn: true,
                                      isAudioOn: true,
                                      channelName: data['channelName'] ?? '',
                                      token: data['token'] ?? '',
                                      callId: data['callId'] ?? '',
                                      groupName:data['groupName'] ?? '' ,
                                      groupImage: data['groupImage'] ?? '',
                                      receiverImages: (data['receiverImages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
                                      receiverNames: (data['receiverNames'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
                                      receiverIds: (data['receiverUserId'] as List<dynamic>?)?.map((e) => int.tryParse(e.toString()) ?? 0).toList() ?? [],
                                    )));
                              }else{
                                print('Call error ${callResponse.message}');
                              }
                            }),
                            const SizedBox(width: 10),
                            PatientScreen._iconButton(Icons.call, ColorManager.greenDark, () async{
                              var callResponse = await addCallInitiate(context,
                                  participantUserIds: chatData!.participants
                                      .map((e) => e.userId)
                                      .where((id) => id != currentUserId)
                                      .toList(),
                                  callType: 'GROUP',
                                  isVideo: false);
                              if(callResponse.statusCode == 201 || callResponse.statusCode == 200){
                                print('Call response ${callResponse.data}');
                                final data = callResponse.data as Map<String, dynamic>;
                                Navigator.push(context, MaterialPageRoute(builder: (_)=>
                                    VideoCallAgoraScreen(
                                      isVideoOn: false,
                                      isAudioOn: true,
                                      channelName: data['channelName'] ?? '',
                                      token: data['token'] ?? '',
                                      callId: data['callId'] ?? '',
                                      userImage: data['contactImage'] ?? '',
                                      userName: data['contactName'] ?? '',
                                      groupName:data['groupName'] ?? '' ,
                                      groupImage: data['groupImage'] ?? '',
                                      receiverImages: (data['receiverImages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
                                      receiverNames: (data['receiverNames'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
                                      receiverIds: (data['receiverUserId'] as List<dynamic>?)?.map((e) => int.tryParse(e.toString()) ?? 0).toList() ?? [],

                                    )));
                              }else{
                                print('Call error ${callResponse.message}');
                              }
                            }),
                            const SizedBox(width: 10),

                            // ⬇️ Use PopupMenuButton for the "more" icon
                            PopupMenuButton<String>(
                              offset: const Offset(0, 32),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey.shade200, width: 1)),
                                child: const Icon(Icons.more_horiz, color: Colors.grey, size: 20),
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(

                                  onTap: (){
                                    widget.onShowProfileUrlChanged?.call(!widget.showProfileUrl);
                                    widget.onGroupSelected?.call(selectedGroupId);
                                  },
                                  value: 'Group Info',
                                  child: Row(
                                    spacing: 15,
                                    children: [
                                      Image.asset('images/communication/chat/Iicon.png',height: 20,width: 20,color: ColorManager.mediumgrey,),
                                      Text('Info',style: ChatMoreInfoText.customTextStyle(context)),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'Clear Chat',
                                  onTap: ()async{
                                    var responseChat = await clearPatientGropChatPatch(context,id: chatData!.groupInfo.ptGroupId);
                                    if(responseChat.statusCode == 200 || responseChat.statusCode == 201){
                                      showTopRightToast(context, message: "Group chat clear successfully!", isSuccess: true);
                                    }else{
                                      showTopRightToast(context, message: "Something went wrong!", isSuccess: false);
                                    }
                                  },
                                  child: Row(
                                    spacing: 15,
                                    children: [
                                      Image.asset('images/communication/chat/chat.png',height: 20,width: 20,color: ColorManager.mediumgrey,),
                                      Text('Clear Chat',style: ChatMoreInfoText.customTextStyle(context),),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'Exit Group',
                                  onTap: ()async{
                                    var response = await patchexitPatientGrop(context,patientId: chatData!.groupInfo.ptGroupId);
                                    if(response.statusCode == 200 || response.statusCode == 201){
                                      showTopRightToast(context, message: "Group exit successfully!", isSuccess: true);
                                      _loadPatientGroups('all');
                                    }else{
                                      showTopRightToast(context, message: "Something went wrong!", isSuccess: false);
                                    }
                                  },
                                  child: Row(
                                    spacing: 15,
                                    children: [
                                      Image.asset('images/communication/chat/exitGrp.png',height: 20,width: 20,color: ColorManager.mediumgrey,),
                                      Text('Exit Group',style: ChatMoreInfoText.customTextStyle(context)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 20, top: 5, bottom: 5, right: 22),
                    decoration: BoxDecoration(
                      color: ColorManager.bordercolorcontainer,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Text(
                                "Recipient",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: FontSize.s10,
                                ),
                              ),
                              const SizedBox(width: 10),

                              // 👇 All participants + status inside same scrollable ROW
                              Expanded(
                                child: ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        // ---- Participants ----
                                        ...chatData!.participants.map((p) {
                                          return Padding(
                                            key: ValueKey(p.participantId),
                                            padding: const EdgeInsets.only(right: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                      color: ColorManager.bluelight,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child:  ClipRRect(
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: (p.imgUrl.isEmpty || p.imgUrl == 'imgurl')
                                                        ? Image.asset("images/profilepic.png", height: 19,
                                                      width: 19,)
                                                        : Builder(
                                                      builder: (context) {
                                                        return CachedNetworkImage(
                                                          imageUrl: p.imgUrl,
                                                          cacheKey: p.imgUrl.split('?').first,
                                                          height: 18,
                                                          width: 18,
                                                          fit: BoxFit.cover,
                                                          fadeInDuration: Duration.zero,
                                                          fadeOutDuration: Duration.zero,
                                                          errorWidget: (context, url, error) {
                                                            return ClipRRect(
                                                              borderRadius: BorderRadius.circular(10),
                                                              child: Image.asset("images/profilepic.png", height: 19,
                                                                width: 19,),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),

                                                ConstrainedBox(
                                                  constraints: const BoxConstraints(maxWidth: 130),
                                                  child: Text(
                                                    p.fullName,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: FontSize.s10,
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(width: 10),
                                              ],
                                            ),
                                          );
                                        }).toList(),

                                        // ---- Status INSIDE THE SCROLL ROW ----
                                        Text(
                                          chatData!.participants.any((p) => p.isOnline)
                                              ? "online"
                                              : "offline — messages will be sent via SMS",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: FontSize.s10,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),


                  // ---------------- Messages List ----------------
                  Expanded(
                    child: Stack(
                      children: [
                        if (chatData != null)
                          NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              final metrics = notification.metrics;
                              const double bottomThreshold = 50.0;
                              final bool isAtBottom = metrics.extentAfter < bottomThreshold;

                              if (notification is ScrollUpdateNotification ||
                                  notification is UserScrollNotification) {
                                if (isAtBottom) {
                                  if (!_autoScroll || _unreadCount > 0) {
                                    setState(() {
                                      _autoScroll = true;
                                      _unreadCount = 0;
                                    });
                                  }
                                } else {
                                  if (_autoScroll) {
                                    setState(() {
                                      _autoScroll = false;
                                    });
                                  }
                                }
                              }
                              return false;
                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.fromLTRB(
                                16,
                                12,
                                16,
                                showEmojiPicker ? 260 : 12, // room for emoji panel
                              ),
                              itemCount: chatData!.messages.length,
                              // FIX: lets Flutter find a message's previous slot by its
                              // key when the refetched list shifts it, so the Element
                              // (and its already-decoded avatar image) is truly reused
                              // instead of torn down and redecoded from scratch.
                              findChildIndexCallback: (key) {
                                final valueKey = key as ValueKey<int>;
                                final index = chatData!.messages.indexWhere((m) => m.ptChatId == valueKey.value);
                                return index == -1 ? null : index;
                              },
                              itemBuilder: (context, index) {
                                final msg = chatData!.messages[index];
                                final bool isMe = msg.ptUserId == 0
                                    ? msg.ptEmpUserId == currentUserId
                                    : msg.sender.userId == currentUserId;
                                print('UserId ${msg.ptUserId} ptEmpUserId ${msg.ptEmpUserId} currentUserId ${currentUserId} senderUserId ${msg.sender.userId}');

                                String formattedTime;
                                try {
                                  final dt = DateTime.parse(msg.dateCreated).toUtc();
                                  final usEastern = dt.subtract(const Duration(hours: 4)); // EDT (UTC-4)
                                  // For EST (UTC-5, Nov–Mar): use Duration(hours: 5)
                                  formattedTime = DateFormat('hh:mm a').format(usEastern);
                                } catch (e) {
                                  formattedTime = msg.dateCreated; // fallback
                                }

                                // Separate attachments
                                // FIX: strip a trailing query string/fragment (common on
                                // signed URLs) before checking the extension — otherwise a
                                // freshly attached image whose URL is e.g. "...jpg?token=..."
                                // fails this check and silently disappears from the bubble.
                                final imageUrls = msg.attachedMultimediaUrls
                                    .where((url) {
                                  final lower = url.toLowerCase().split('?').first.split('#').first;
                                  return lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png');
                                })
                                    .toList();
                                // FIX: strip a trailing query string/fragment (signed URL token)
                                // before checking the extension — same as imageUrls/pdfUrls above.
                                // Without this, a voice note URL like "...mpeg?sig=..." never
                                // matches endsWith('.mpeg') and the bubble silently never renders.
                                final voiceNoteUrl =
                                msg.voiceNoteUrl!.where((url) {
                                  final lower = url.toLowerCase().split('?').first.split('#').first;
                                  return lower.endsWith('.mpeg') || lower.endsWith('.webm');
                                }).toList();
                                final pdfUrls = msg.attachedMultimediaUrls
                                    .where((url) => url.toLowerCase().split('?').first.split('#').first.endsWith('.pdf'))
                                    .toList();

                                return Padding(
                                  key: ValueKey(msg.ptChatId),
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                    isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                                    children: [
                                      if (!isMe)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: CachedNetworkImage(
                                            imageUrl: msg.sender.imgUrl,
                                            cacheKey: msg.sender.imgUrl.split('?').first,
                                            width: 28,
                                            height: 28,
                                            fit: BoxFit.cover,
                                            fadeInDuration: Duration.zero,
                                            fadeOutDuration: Duration.zero,
                                            errorWidget: (context, url, error) => ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: Container(
                                                color: Colors.grey[300],
                                                child: Icon(
                                                  Icons.person,
                                                  size: 28,
                                                  color: Colors.grey[400],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      Container(
                                        constraints: const BoxConstraints(maxWidth: 400),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isMe
                                              ? ColorManager.blueprime
                                              : ColorManager.commuchatBackColor,
                                          borderRadius: isMe
                                              ? const BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            topLeft: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                          )
                                              : const BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            topLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: isMe
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          children: [
                                            // Display images
                                            // FIX: keyed per-URL (stripped of any query string)
                                            // and switched to CachedNetworkImage with a matching
                                            // cacheKey so a poll-refetched message — whose signed
                                            // URL may carry a fresh token each time — still hits
                                            // the same cache entry instead of redecoding the
                                            // image from scratch and flashing every poll.
                                            ...imageUrls.map(
                                                  (url) => Padding(
                                                key: ValueKey(url.split('?').first),
                                                padding: const EdgeInsets.only(bottom: 4),
                                                child: InkWell(
                                                  onTap: () async {
                                                    await openImageInNewTab(context: context,
                                                        fileUrl: url,
                                                        documentName:"commuchat_image_${url.split('?').first.split('/').last}",
                                                        apiPath: DownloadDocumentRepository.getPatientGroupChatImageByFileName());
                                                  },
                                                  child: Container(
                                                    height: 200,
                                                    width: 250,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: CachedNetworkImage(
                                                      imageUrl: url,
                                                      cacheKey: url.split('?').first,
                                                      fit: BoxFit.contain,
                                                      fadeInDuration: Duration.zero,
                                                      fadeOutDuration: Duration.zero,
                                                      errorWidget: (context, url, error) {
                                                        debugPrint("IMAGE LOAD ERROR: $url → $error");
                                                        return const Center(
                                                          child: Icon(
                                                            Icons.broken_image,
                                                            size: 50,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),


                                            // Display PDFs
                                            ...pdfUrls.map(
                                                  (url) => Padding(
                                                key: ValueKey(url.split('?').first),
                                                padding: const EdgeInsets.only(bottom: 4),
                                                child: InkWell(
                                                  onTap: () async {
                                                    await downloadFile(context: context,
                                                        fileUrl: url,
                                                        documentName:"commuchat_pdf_${url.split('?').first.split('/').last}",
                                                        apiPath: DownloadDocumentRepository.getPatientGroupChatImageByFileName());
                                                  },
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.description,
                                                        size: 30,
                                                        color: isMe ? Colors.white : Colors.black,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Flexible(
                                                        child: Text(
                                                          // FIX: show only the clean file name, not the
                                                          // raw URL/query string (e.g. a signed token).
                                                          url.split('?').first.split('/').last,
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: isMe
                                                                ? Colors.white
                                                                : ColorManager.commuchatTextColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            ...voiceNoteUrl.map(
                                                  (url) => Padding(
                                                // FIX: keyed by URL (query string stripped) so a
                                                // poll-driven rebuild reuses the same Element/
                                                // AudioPlayer instead of disposing it mid-load.
                                                key: ValueKey(url.split('?').first),
                                                padding: const EdgeInsets.only(bottom: 4),
                                                child: VoiceNoteBubble(
                                                  url: url,
                                                  isMe: isMe,
                                                ),
                                              ),
                                            ),

                                            // Display text
                                            if (msg.textContent.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4),
                                                child: Text(
                                                  msg.textContent,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: isMe
                                                        ? Colors.white
                                                        : ColorManager.commuchatTextColor,
                                                  ),
                                                ),
                                              ),

                                            const SizedBox(height: 4),
                                            Text(
                                              formattedTime,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isMe
                                                    ? Colors.white54
                                                    : ColorManager.commuchatTimeColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (isMe)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: CachedNetworkImage(
                                              imageUrl: msg.sender.imgUrl,
                                              cacheKey: msg.sender.imgUrl.split('?').first,
                                              width: 28,
                                              height: 28,
                                              fit: BoxFit.cover,
                                              fadeInDuration: Duration.zero,
                                              fadeOutDuration: Duration.zero,
                                              errorWidget: (context, url, error) =>
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(4),
                                                    child: Container(
                                                      color: Colors.grey[300],
                                                      child: Icon(
                                                        Icons.person,
                                                        size: 28,
                                                        color: Colors.grey[400],
                                                      ),
                                                    ),
                                                  )
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                        // Unread messages indicator
                        if (_unreadCount > 0)
                          Positioned(
                            right: 16,
                            bottom: showEmojiPicker ? 260 + 16 : 16,
                            child: InkWell(
                              onTap: () {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                );
                                setState(() {
                                  _unreadCount = 0;
                                  _autoScroll = true;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: ColorManager.blueprime,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                      color: Colors.black.withOpacity(0.2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.arrow_downward,
                                        color: Colors.white, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$_unreadCount new message${_unreadCount > 1 ? 's' : ''}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Emoji picker overlay
                        if (showEmojiPicker)
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                setState(() {
                                  showEmojiPicker = false;
                                });
                              },
                              child: const SizedBox(),
                            ),
                          ),
                        if (showEmojiPicker)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: SizedBox(
                              height: 200,
                              width: 100,
                              child: Padding(
                                padding:const EdgeInsets.only(right: 300,left: 20),
                                child: EmojiPicker(
                                  onEmojiSelected: (category, emoji) {
                                    _messageController.text += emoji.emoji;
                                  },
                                  config:  Config(
                                    height: 200,
                                    bottomActionBarConfig: BottomActionBarConfig(
                                        backgroundColor: ColorManager.blueprime,
                                        buttonColor: ColorManager.blueprime,
                                        showBackspaceButton: false
                                    ),
                                    emojiViewConfig: const EmojiViewConfig(
                                      emojiSizeMax: 16,
                                    ),
                                    categoryViewConfig: CategoryViewConfig(
                                      iconColor: Colors.grey,
                                      iconColorSelected: ColorManager.blueprime,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // File picker overlay
                        if (showFilePick)
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                setState(() {
                                  showFilePick = false;
                                });
                              },
                              child: const SizedBox(), // transparent full-screen
                            ),
                          ),
                        if(showFilePick)
                          Positioned(
                            right: 70,
                            bottom: 0,
                            child: ConstFilepickerAndMediaPicker(
                              // Documents (PDF) - allow multiple
                              pickDocuments: () async {
                                showFilePick = false;
                                FilePickerResult? result = await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['pdf'],
                                  allowMultiple: false,
                                  withData: true,
                                );
                                final fileSize = result?.files.first.size;
                                final isAbove20MB = fileSize! > (20 * 1024 * 1024);
                                if (result != null) {
                                  setState(() {
                                    for (final f in result.files) {
                                      if (f.bytes != null) {
                                        // canonicalize bytes to avoid typed_data mismatch
                                        selectedFiles.add(Uint8List.fromList(f.bytes!));
                                        selectedFileNames.add(f.name);
                                        _fileAbove20Mb = !isAbove20MB;
                                      }
                                    }
                                    final existingText = _messageController.text.trim();

                                    final fileText = selectedFileNames.join(', ');

                                    if (existingText.isEmpty) {
                                      _messageController.text = fileText;
                                    } else {
                                      _messageController.text = '$existingText, $fileText';
                                    }

// keep cursor at end
                                    _messageController.selection = TextSelection.fromPosition(
                                      TextPosition(offset: _messageController.text.length),
                                    );
                                  });
                                }
                              },

// Gallery (images) - allow multiple
                              pickGallery: () async {
                                showFilePick = false;
                                FilePickerResult? result = await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['png', 'jpg', 'jpeg'],
                                  allowMultiple: false,
                                  withData: true,
                                );
                                final fileSize = result?.files.first.size;
                                final isAbove20MB = fileSize! > (20 * 1024 * 1024);
                                if (result != null) {
                                  setState(() {
                                    for (final f in result.files) {
                                      if (f.bytes != null) {
                                        selectedFiles.add(Uint8List.fromList(f.bytes!)); // canonicalize
                                        selectedFileNames.add(f.name);
                                        _fileAbove20Mb = !isAbove20MB;
                                      }
                                    }
                                    final existingText = _messageController.text.trim();

                                    final fileText = selectedFileNames.join(', ');

                                    if (existingText.isEmpty) {
                                      _messageController.text = fileText;
                                    } else {
                                      _messageController.text = '$existingText, $fileText';
                                    }

// keep cursor at end
                                    _messageController.selection = TextSelection.fromPosition(
                                      TextPosition(offset: _messageController.text.length),
                                    );
                                  });
                                }
                              },
                              // Camera - append single capture (you can call multiple times)
                              pickCamera: () async {
                                // FIX: guard against re-entrant taps — without this, a second
                                // tap on "Camera" while the first availableCameras()/Navigator.push
                                // is still in flight (the popup was never rebuilt closed, so it
                                // stayed tappable) fired a second navigation, pushing a second
                                // WebCameraScreen on top of/racing the first — this is what looked
                                // like the app jumping to another screen before the camera opened.
                                if (_isOpeningCamera) return;
                                setState(() {
                                  showFilePick = false;
                                  _isOpeningCamera = true;
                                });

                                try {
                                  // FIX: don't force-unwrap the global `cameras` list — fetch fresh here
                                  // and guard against failures/empty results instead of crashing.
                                  List<CameraDescription> availableCams;
                                  try {
                                    availableCams = await availableCameras();
                                  } catch (e) {
                                    debugPrint('availableCameras() failed: $e');
                                    if (mounted) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return const AddErrorPopup(
                                            message: 'Camera access is unavailable.',
                                          );
                                        },
                                      );
                                    }
                                    return;
                                  }

                                  if (availableCams.isEmpty) {
                                    if (mounted) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return const AddErrorPopup(
                                            message: 'No camera found on this device.',
                                          );
                                        },
                                      );
                                    }
                                    return;
                                  }

                                  final picture = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => WebCameraScreen(cameras: availableCams),
                                    ),
                                  );

                                  if (picture != null) {
                                    // read raw bytes and canonicalize
                                    final rawBytes = await picture.readAsBytes();
                                    final Uint8List imageBytes = Uint8List.fromList(rawBytes);
                                    final String fileName = "captured_${DateTime.now().millisecondsSinceEpoch}.jpg";

                                    setState(() {
                                      selectedFiles.add(imageBytes);
                                      selectedFileNames.add(fileName);
                                      _fileAbove20Mb = true;
                                      final existingText = _messageController.text.trim();

                                      final fileText = selectedFileNames.join(', ');

                                      if (existingText.isEmpty) {
                                        _messageController.text = fileText;
                                      } else {
                                        _messageController.text = '$existingText, $fileText';
                                      }

// keep cursor at end
                                      _messageController.selection = TextSelection.fromPosition(
                                        TextPosition(offset: _messageController.text.length),
                                      );
                                    });

                                    print("Captured image converted successfully.");
                                  }
                                } finally {
                                  if (mounted) setState(() => _isOpeningCamera = false);
                                }
                              },


                            ),
                          ),

                        // First load spinner
                        if (isLoadingChat && chatData == null)
                          const Center(child: CircularProgressIndicator()),

                        // Subsequent loading overlay
                        if (isLoadingChat && chatData != null)
                          const Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  ChatTabsConstTextfieldMic(
                    isGrpoupChat: true,
                    hasAttachment: selectedFiles.isNotEmpty,
                    onRefresh: ()async{
                      setState(() {
                        selectedFiles.clear();
                        selectedFileNames.clear();
                        _messageController.clear();
                        showEmojiPicker = false;
                        showFilePick = false;
                      });
                      loadGroupChat(selectedGroupId);
                    },
                    selectedId: chatData!.groupInfo.ptGroupId,
                    attaceFile: (){
                      setState(() {
                        showFilePick = !showFilePick;
                      });
                    },
                    onEmojiTap: (){
                      setState(() {
                        showEmojiPicker = !showEmojiPicker;
                      });
                    },
                    onSend: () async {
                      if (selectedGroupId == 0) {
                        print("No group selected!");
                        return;
                      }

                      if (_messageController.text.trim().isEmpty && selectedFiles.isEmpty) {
                        print("Empty message is not allowed");
                        return;
                      }

                      // First send the chat message
                      if(selectedFiles.isNotEmpty){
                        if(_fileAbove20Mb){
                          ApiData result = await sendGroupMessage(
                            isVoiceNote: false,
                            context,
                            ptGroupId: selectedGroupId,
                            textContent: _messageController.text,
                            restrictPatientFromView: false,
                            sentAsSms: isSendViaSms == 'Send Default' ? false : true,
                            isMedia: selectedFiles.isNotEmpty,
                          );

                          if (!result.success || result.ptChatId == null) {
                            print("Failed to send message: ${result.message}");
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AddErrorPopup(
                                  message: result.message.isNotEmpty ? result.message : 'Failed to send message.',
                                );
                              },
                            );
                            return;
                          }
                          final List<Uint8List> filesForUpload = selectedFiles
                              .map((b) => Uint8List.fromList(b)) // ensures canonical dart:typed_data Uint8List
                              .toList();

                          var attachMedia = await uploadMediaPatientChat(
                            context: context,
                            patientChatId: result.ptChatId!,
                            documentFiles: filesForUpload.first,
                            documentNames: selectedFileNames.first,
                          );

                          if (attachMedia.statusCode == 200 || attachMedia.statusCode == 201) {
                            setState(() {
                              selectedFiles.clear();
                              selectedFileNames.clear();
                              _messageController.clear();
                            });
                            loadGroupChat(selectedGroupId);
                            print("Media uploaded and chat refreshed.");
                          } else {
                            print("Attach media failed: ${attachMedia.message}");
                            // Keep files selected so the user can retry the send.
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AddErrorPopup(
                                  message: attachMedia.message.isNotEmpty
                                      ? attachMedia.message
                                      : 'Failed to attach the image. Please try sending again.',
                                );
                              },
                            );
                          }
                        }else{
                          setState(() {
                            selectedFiles.clear();
                            selectedFileNames.clear();
                            _messageController.clear();
                            showEmojiPicker = false;
                          });
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const AddErrorPopup(
                                message: 'File is too large!',
                              );
                            },
                          );
                        }

                      }else{
                        ApiData result = await sendGroupMessage(
                          isVoiceNote: false,
                          context,
                          ptGroupId: selectedGroupId,
                          textContent: _messageController.text,
                          restrictPatientFromView: false,
                          sentAsSms: isSendViaSms == 'Send Default' ? false : true,
                          isMedia: selectedFiles.isNotEmpty,
                        );

                        if (!result.success || result.ptChatId == null) {
                          print("Failed to send message: ${result.message}");
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AddErrorPopup(
                                message: result.message.isNotEmpty ? result.message : 'Failed to send message.',
                              );
                            },
                          );
                          return;
                        }
                        if (result.success) {
                          setState(() {
                            _messageController.clear();
                            showEmojiPicker = false;
                          });
                          loadGroupChat(selectedGroupId);
                          print("Sent!");
                        }
                      }
                    },
                    controller: _messageController,
                    onMicTap: (){},
                    onSendDefaultTap: (value)  {
                      setState(() {
                        isSendViaSms = value;
                      });
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}