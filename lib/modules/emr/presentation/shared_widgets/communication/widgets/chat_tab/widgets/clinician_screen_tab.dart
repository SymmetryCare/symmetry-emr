import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/camera_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/chat_file_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/chat_tabs_const_textfield_mic.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/voice_note_bubble.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/communication_model/communication_textstyle.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/calling/calling_Manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/communication_manger/chats_manager/clinician_manager/emp_clinician_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/communication_data/chats_data/clinitian_data/clinical_empChat_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/communication_data/chats_data/clinitian_data/clinitian_emp_data.dart';
// removed in extraction: import '../../../../../../main.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/onboarding/download_doc_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/widgets/referral_Screen_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widget_for_tab_mobile/communication_tablet/communication_tab_home_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/call_screens/new_videocall_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/toste_notify_const.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ClinicianScreenTabChats extends StatefulWidget {
  final bool showProfileUrl;
  final ValueChanged<bool>? onShowProfileUrlChanged;
  final ValueChanged<int>? onEmpSelected;
  const ClinicianScreenTabChats({super.key,
    required this.showProfileUrl,
    this.onShowProfileUrlChanged, this.onEmpSelected
  });

  @override
  State<ClinicianScreenTabChats> createState() => _ClinicianScreenTabChatsState();

  static Widget _circularIcon({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    Color iconColor = Colors.grey, // <-- make icon color configurable
  }) {
    final core = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // always keep light gray background
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: iconColor), // use custom icon color
        splashRadius: 20,
      ),
    );

    return tooltip == null ? core : Tooltip(message: tooltip, child: core);
  }

  static Widget _iconButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child:  Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200, width: 1)),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

}

class _ClinicianScreenTabChatsState extends State<ClinicianScreenTabChats> {
  final StreamController<List<EmpDepartmentChatdetails>> clinitianChatsController = StreamController<List<EmpDepartmentChatdetails>>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  int? currentUserId;
  int? cuserId;
  bool showEmojiPicker = false;
  ChatDepartmentGroupCommunicationData? chatData;
  bool isLoadingChat = false;
  int selectedOtherEmpId = 0;
  Timer? _chatTimer;
  Timer? _listTimer;
  bool _isFirstLoad = true;
  bool _isFirstListLoad = true;
  bool _isPolling = false; // only poll while this tab is actually visible
  bool _autoScroll = true;
  int _unreadCount = 0;
  bool showFilePick = false;
  bool _isOpeningCamera = false;
  String isSendViaSms = 'Send Default';
  List<Uint8List> selectedFiles = [];
  List<String> selectedFileNames = [];
  bool _fileAbove20Mb = false;
  @override
  void initState() {
    super.initState();
    // Polling is started/stopped by the VisibilityDetector in build(), so it
    // only runs while this tab is actually the one on screen.
    assignUserId();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      final position = _scrollController.position;

      // How much content is below current view
      final double extentAfter = position.extentAfter;

      // Tolerance values
      const double NEAR_BOTTOM_THRESHOLD = 0; // still considered "at bottom"
      const double FAR_FROM_BOTTOM_THRESHOLD = 0;

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

  // Start everything when the tab becomes visible.
  void _startPolling() {
    if (_isPolling) return;
    _isPolling = true;

    final query = _searchController.text.trim();
    startListeningList(query.isEmpty ? 'all' : query);

    // If a chat was already open before this tab was hidden, resume its polling.
    if (selectedOtherEmpId != 0) {
      startListeningGroup(selectedOtherEmpId);
    }
  }

  // Stop everything when the tab is hidden (user switches to another tab).
  void _stopPolling() {
    if (!_isPolling) return;
    _isPolling = false;
    _listTimer?.cancel();
    _chatTimer?.cancel();
  }

  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();
  void _onSearchChanged() {
    // cancel any previous timers to debounce
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 600), () {
      final query = _searchController.text.trim();
      _loadPatientGroups(query.isEmpty ? "all" : query);
    });
  }
  void assignUserId()async{
    final userId = await TokenManager.getuserId();
    setState(() {
      cuserId = userId;
    });
  }

  Future<void> _loadPatientGroups(String searchText) async {
    try {
      final data = await getAllChatsClinitianGroups(context,1,9999,searchText,
          'clinical');
      clinitianChatsController.add(data);
    } catch (e) {
      clinitianChatsController.addError(e);
    }
  }
  Future<void> startListeningList(String searchText) async {
    // Load first time
    await getAllChatsClinitianGroups(context,1,9999,searchText,
        'clinical');
    _isFirstListLoad = false;

    // Reset polling timer
    _listTimer?.cancel();

    _listTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || !_isPolling) return;

      _loadPatientGroups(searchText);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    clinitianChatsController.close();
    _listTimer?.cancel();
    _chatTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
  bool _isUserAtBottom = true;
  Future<void> loadGroupChat(int otherEmpId, {bool showLoader = false}) async {
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
      final data = await chatClinicalGroupCommunication(
        context,
        otherEmpId,
        1,
        999999,
      );

      if (mounted) {
        setState(() {
          selectedOtherEmpId = otherEmpId;
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
      if (!mounted || !_isPolling) return;

      loadGroupChat(groupId, showLoader: false);
    });
  }


  @override
  Widget build(BuildContext context) {
    assert(kIsWeb, 'This screen is intended for Flutter Web layouts.');

    return VisibilityDetector(
      key: const Key('clinician-screen-tab-visibility'),
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
                          'Clinician',
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
                      child: StreamBuilder<List<EmpDepartmentChatdetails>>(
                          stream: clinitianChatsController.stream,
                          builder: (context, snapshot) {
                            print('1111111');
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
                                  "Failed to load clinician chats!",
                                  style: AllNoDataAvailable.customTextStyle(context),
                                ),
                              );
                            }
                            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                              final clinical = snapshot.data!;
                              return ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context).copyWith(
                                  scrollbars: false,
                                  overscroll: false,
                                ),
                                child: ListView.builder(
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: clinical.length,
                                  // FIX: lets Flutter find an item's previous slot by its
                                  // key when the refetched list reorders it, so the Element
                                  // (and its already-decoded avatar image) is truly reused
                                  // instead of torn down and redecoded from scratch.
                                  findChildIndexCallback: (key) {
                                    final valueKey = key as ValueKey<int>;
                                    final index = clinical.indexWhere((p) => p.partnerEmpId == valueKey.value);
                                    return index == -1 ? null : index;
                                  },
                                  itemBuilder: (context, index) {
                                    final item = clinical[index];

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

                                    return ContainerDataListTile(
                                      key: ValueKey(item.partnerEmpId),
                                      unseenCount: item.unseenCount,
                                      isActive: false,
                                      imagePath: item.imageUrl,
                                      name:  item.userId ==  cuserId ?
                                      "${item.firstName} ${item.lastName} (You)"
                                          :"${item.firstName} ${item.lastName}",
                                      message: item.lastMessage,
                                      time: formattedTime(item.lastMessageTime),
                                      onImageTap: () {
                                        setState(() {
                                          isLoadingChat = false;
                                        });
                                        widget.onShowProfileUrlChanged?.call(false);
                                        loadGroupChat(item.partnerEmpId, showLoader: true);
                                        startListeningGroup(item.partnerEmpId);
                                      },);
                                  },
                                ),
                              );  }
                            return Center(
                              child: Text(
                                "No clinician chats data available!",
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
                "Select a clinician user to view messages!",
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
                              widget.onEmpSelected?.call(selectedOtherEmpId);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: (chatData!.empInfoData.imageUrl.isEmpty || chatData!.empInfoData.imageUrl == 'imgurl')
                                  ? Image.asset("images/profilepic.png",height: 55,width: 55, fit: BoxFit.cover,)
                                  : Builder(
                                builder: (context) {
                                  return CachedNetworkImage(
                                    imageUrl: chatData!.empInfoData.imageUrl,
                                    // FIX: caching by the URL with any query string/signed
                                    // token stripped means a poll-refetched contact whose URL
                                    // carries a fresh token still hits the same cache entry
                                    // instead of redecoding and flashing every poll.
                                    cacheKey: chatData!.empInfoData.imageUrl.split('?').first,
                                    height: 55,
                                    width: 55,
                                    fit: BoxFit.cover,
                                    fadeInDuration: Duration.zero,
                                    fadeOutDuration: Duration.zero,
                                    errorWidget: (context, url, error) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        // backgroundColor: Colors.transparent,
                                        child: Image.asset("images/profilepic.png",height: 55,width: 55, fit: BoxFit.cover,),
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
                                chatData!.empInfoData.userId ==  currentUserId
                                    ? "${chatData!.empInfoData.fullName} (You)"
                                    : chatData!.empInfoData.fullName,
                                style: const TextStyle(color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: FontSize.s12,),
                              ),
                              const SizedBox(height: 3),
                            ],
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          chatData!.empInfoData.userId == cuserId ? const Offstage(): ClinicianScreenTabChats._iconButton(Icons.videocam, ColorManager.blueprime, () async{
                            var callResponse = await addCallInitiate(context,
                                isVideo: true,
                                participantUserIds: [chatData!.empInfoData.userId],
                                callType: 'ONE_TO_ONE');
                            if(callResponse.statusCode == 201 || callResponse.statusCode == 200){
                              print('Call response ${callResponse.data}');
                              final data = callResponse.data as Map<String, dynamic>;
                              Navigator.push(context, MaterialPageRoute(builder: (_)=>
                                  VideoCallAgoraScreen(
                                    isVideoOn: true,
                                    isAudioOn: true,
                                    channelName: data['channelName'] ?? '',
                                    userImage: data['contactImage'] ?? '',
                                    userName: data['contactName'] ?? '',
                                    token: data['token'] ?? '',
                                    callId: data['callId'] ?? '',
                                    receiverImages: (data['receiverImages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
                                    receiverNames: (data['receiverNames'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
                                    receiverIds: (data['receiverUserId'] as List<dynamic>?)?.map((e) => int.tryParse(e.toString()) ?? 0).toList() ?? [],
                                  )));
                            }else{
                              print('Call error ${callResponse.message}');
                            }
                          }),
                          const SizedBox(width: 10),
                          chatData!.empInfoData.userId == cuserId ? const Offstage():  ClinicianScreenTabChats._iconButton(Icons.call, Colors.green, () async{
                            var callResponse = await addCallInitiate(context,
                                isVideo: false,
                                participantUserIds: [chatData!.empInfoData.userId],
                                callType: 'ONE_TO_ONE');
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
                                    receiverImages: (data['receiverImages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
                                    receiverNames: (data['receiverNames'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
                                    receiverIds: (data['receiverUserId'] as List<dynamic>?)?.map((e) => int.tryParse(e.toString()) ?? 0).toList() ?? [],
                                  )));
                            }else{
                              print('Call error ${callResponse.message}');
                            }
                          }),
                          const SizedBox(width: 10),

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
                                value: 'Info',
                                onTap: (){
                                  widget.onShowProfileUrlChanged?.call(!widget.showProfileUrl);
                                  widget.onEmpSelected?.call(selectedOtherEmpId);
                                },
                                child: Row(
                                  spacing: 15,
                                  children: [
                                    Image.asset('images/communication/chat/Iicon.png',height: 20,width: 20,color: ColorManager.mediumgrey,),
                                    Text('Info',style: ChatMoreInfoText.customTextStyle(context),),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'Clear Chat',
                                onTap: ()async{
                                  var responseChat = await deleteEmployeeChat(context,otherEmpId: chatData!.empInfoData.employeeId);
                                  if(responseChat.statusCode == 200 || responseChat.statusCode == 201){
                                    showTopRightToast(context, message: "Clinical chat clear successfully!", isSuccess: true);
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
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                // ---------------- Messages List ----------------
                Expanded(
                  child: Stack(
                    children: [
                      // Only build the list when chatData is not null
                      if (chatData != null)
                        NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            final metrics = notification.metrics;

                            const double bottomThreshold = 50.0;
                            final bool isAtBottom = metrics.extentAfter < bottomThreshold;

                            if (notification is ScrollUpdateNotification ||
                                notification is UserScrollNotification) {
                              if (isAtBottom) {
                                // user is near bottom → enable auto-scroll
                                if (!_autoScroll || _unreadCount > 0) {
                                  setState(() {
                                    _autoScroll = true;
                                    _unreadCount = 0;
                                  });
                                }
                              } else {
                                // user scrolled up → disable auto-scroll
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
                              final index = chatData!.messages.indexWhere((m) => m.empChatId == valueKey.value);
                              return index == -1 ? null : index;
                            },
                            itemBuilder: (context, index) {
                              final msg = chatData!.messages[index];
                              final bool isMe = msg.isMine;

                              String formattedTime;
                              try {
                                final dt = DateTime.parse(msg.dateCreated).toUtc();
                                final usEastern = dt.subtract(const Duration(hours: 4)); // EDT (UTC-4)
                                // For EST (UTC-5, Nov–Mar): use Duration(hours: 5)
                                formattedTime = DateFormat('hh:mm a').format(usEastern);
                              } catch (e) {
                                formattedTime = msg.dateCreated; // fallback
                              }

                              // ---- classify attachments using List<String> attachedMultimediaUrl ----

// 1) Look at the message text to see if it refers to a PDF
                              final String textLower = msg.textContent.toLowerCase();
                              final bool messageLooksLikePdf =
                                  textLower.trim().endsWith('.pdf') || textLower.contains('.pdf');

// 2) Image URLs: only if it's NOT obviously a PDF message
                              // FIX: strip a trailing query string/fragment (common on signed
                              // URLs) before checking the extension — otherwise a freshly
                              // attached image whose URL is e.g. "...jpg?token=..." fails
                              // this check and silently disappears from the bubble.
                              final List<String> imageUrls = msg.attachedMultimediaUrl
                                  .where((url) {
                                final lower = url.toLowerCase().split('?').first.split('#').first;

                                // If message looks like a PDF (filename .pdf), don't treat its attachments as images
                                if (messageLooksLikePdf) return false;

                                return lower.endsWith('.jpg') ||
                                    lower.endsWith('.jpeg') ||
                                    lower.endsWith('.png') ||
                                    lower.endsWith('.webp');
                              })
                                  .toList();
                              // FIX: strip a trailing query string/fragment (signed URL token)
                              // before checking the extension — same as imageUrls/pdfUrls above.
                              // Without this, a voice note URL like "...mpeg?sig=..." never
                              // matches endsWith('.mpeg') and the bubble silently never renders.
                              final voiceNoteUrl =
                              msg.voiceNoteUrl.where((url) {
                                final lower = url.toLowerCase().split('?').first.split('#').first;
                                return lower.endsWith('.mpeg') || lower.endsWith('.webm');
                              }).toList();
// 3) PDF URLs: if message text looks like PDF, or URL actually ends with .pdf
                              final List<String> pdfUrls = msg.attachedMultimediaUrl
                                  .where((url) {
                                final lower = url.toLowerCase().split('?').first.split('#').first;

                                if (messageLooksLikePdf) return true; // force this attachment to show as PDF
                                return lower.endsWith('.pdf');
                              })
                                  .toList();

                              // ------------------------------------------------------------------------

                              return Padding(
                                key: ValueKey(msg.empChatId),
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
                                          // ---------- IMAGES ----------
                                          // FIX: keyed per-URL (query string stripped) and
                                          // switched to CachedNetworkImage with a matching
                                          // cacheKey so a poll-refetched message — whose signed
                                          // URL may carry a fresh token each time — still hits
                                          // the same cache entry instead of redecoding the
                                          // image from scratch and flashing every poll.
                                          ...imageUrls.map(
                                                (url) => Padding(
                                              key: ValueKey(url.split('?').first),
                                              padding:
                                              const EdgeInsets.only(bottom: 4.0),
                                              child: InkWell(
                                                onTap: () async {
                                                  await openImageInNewTab(context: context,
                                                      fileUrl: url,
                                                      documentName:"commuchat_image_${url.split('?').first.split('/').last}",
                                                      apiPath: DownloadDocumentRepository.getCliniciansChatImageByFileName());
                                                },
                                                child: Container(
                                                  height: 200,
                                                  width: 250,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                    BorderRadius.circular(10),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    imageUrl: url,
                                                    cacheKey: url.split('?').first,
                                                    fit: BoxFit.contain,
                                                    fadeInDuration: Duration.zero,
                                                    fadeOutDuration: Duration.zero,
                                                    errorWidget: (context, url, error) {
                                                      debugPrint(
                                                          "IMAGE LOAD ERROR: $url → $error");
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

                                          // ---------- PDFs ----------
                                          ...pdfUrls.map(
                                                (url) => Padding(
                                              key: ValueKey(url.split('?').first),
                                              padding: const EdgeInsets.only(bottom: 4),
                                              child: InkWell(
                                                onTap: () async {
                                                  await downloadFile(context: context,
                                                      fileUrl: url,
                                                      documentName:"commuchat_pdf_${url.split('?').first.split('/').last}",
                                                      apiPath: DownloadDocumentRepository.getCliniciansChatImageByFileName());
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

                                          // ---------- TEXT ----------
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
                          bottom: showEmojiPicker ? 260 + 16 : 16, // keep above emoji panel
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
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
                              padding:  const EdgeInsets.only(right: 300,left: 20),
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
                      if (showFilePick)
                        Positioned(
                          right: 70,
                          bottom: 0,
                          child: ConstFilepickerAndMediaPicker(
                            // Documents (PDF) - allow multiple
                            pickDocuments: () async {
                              showFilePick = false;
                              FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
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
                              FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
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
                                      selectedFiles.add(
                                          Uint8List.fromList(f.bytes!)); // canonicalize
                                      selectedFileNames.add(f.name);
                                    }
                                  }
                                  _fileAbove20Mb = !isAbove20MB;
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
                                  final Uint8List imageBytes =
                                  Uint8List.fromList(rawBytes);
                                  final String fileName =
                                      "captured_${DateTime.now().millisecondsSinceEpoch}.jpg";

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

                      // First load: if chatData is null and loading, show full loader
                      if (isLoadingChat && chatData == null)
                        const Center(child: CircularProgressIndicator()),

                      // Subsequent loads: keep list visible, just overlay a small loader (optional)
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
                  isGrpoupChat: false,
                  hasAttachment: selectedFiles.isNotEmpty,
                  selectedId: selectedOtherEmpId,
                  onRefresh: (){
                    setState(() {
                      selectedFiles.clear();
                      selectedFileNames.clear();
                      _messageController.clear();
                      showEmojiPicker = false;
                      showFilePick = false;
                    });
                    loadGroupChat(selectedOtherEmpId);
                  },
                  attaceFile: () {
                    setState(() {
                      showFilePick = !showFilePick;
                    });
                  },
                  onEmojiTap: () {
                    setState(() {
                      showEmojiPicker = !showEmojiPicker;
                    });
                  },
                  onSend: () async {
                    // Use 0 as "no selection" sentinel (since selectedOtherEmpId is int, not nullable)
                    if (selectedOtherEmpId == 0) {
                      print("No group selected!");
                      return;
                    }

                    final text = _messageController.text.trim();

                    // ⛔ Prevent empty message or accidental send
                    if (text.isEmpty && selectedFiles.isEmpty) {
                      print("Empty message is not allowed");
                      return;
                    }

                    // 1️⃣ Take a snapshot of current media so we don't reuse future changes
                    final List<Uint8List> filesToSend =
                    selectedFiles.map((b) => Uint8List.fromList(b)).toList();
                    final List<String> namesToSend = List<String>.from(selectedFileNames);

                    try {
                      if(selectedFiles.isNotEmpty){
                        if(_fileAbove20Mb){
                          final ApiData result = await sendClinicianMessage(
                            isVoiceNote: false,
                            isMedia: filesToSend.isNotEmpty,   // ✅ use snapshot, not selectedFiles
                            context,
                            empId: selectedOtherEmpId,
                            textContent: text,
                          );

                          if (!result.success || result.empChatId == null) {
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

                          // 3️⃣ If there are media files, upload them in one go
                          if (filesToSend.isNotEmpty) {
                            final attachMedia = await uploadMediaEmpChat(
                              context: context,
                              employeeChatId: result.empChatId!,
                              documentFiles: filesToSend.first,     // ✅ snapshot of bytes
                              documentNames: namesToSend.first,     // ✅ snapshot of names
                            );

                            if (attachMedia.statusCode == 200 || attachMedia.statusCode == 201) {
                              print("Media uploaded and chat refreshed.");
                            } else {
                              print("Attach media failed: ${attachMedia.message}");
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
                          }
                          await loadGroupChat(selectedOtherEmpId);
                          print("Sent!");
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
                        final ApiData result = await sendClinicianMessage(
                          isVoiceNote: false,
                          isMedia: filesToSend.isNotEmpty,   // ✅ use snapshot, not selectedFiles
                          context,
                          empId: selectedOtherEmpId,
                          textContent: text,
                        );

                        if (!result.success || result.empChatId == null) {
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
                        await loadGroupChat(selectedOtherEmpId);
                        print("Sent!");
                      }

                      // 2️⃣ Send chat message (text + isMedia flag)


                      // 4️⃣ Refresh chat after sending

                    } catch (e) {
                      print("onSend error: $e");
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AddErrorPopup(
                            message: 'Something went wrong while sending. Please try again.',
                          );
                        },
                      );
                    } finally {
                      // 5️⃣ ALWAYS reset local state after one send
                      setState(() {
                        selectedFiles.clear();
                        selectedFileNames.clear();
                        _messageController.clear();
                        showEmojiPicker = false;
                      });
                    }
                  },

                  controller: _messageController,
                  onMicTap: () {},
                  onSendDefaultTap: (value) {
                    setState(() {
                      isSendViaSms = value;
                    });
                  },
                ),

              ],
            ),
          )
        ],
      ),
      ),
    );
  }

  Widget _chatTile({
    required String name,
    required String message,
    required String time,
    required String avatar,
    bool isActive = false,
    List<String>? groupMembers,
  }) {
    return Container(
      color: isActive ? const Color(0xFFE7F0FD) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'images/bg.jpg',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(message,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}
