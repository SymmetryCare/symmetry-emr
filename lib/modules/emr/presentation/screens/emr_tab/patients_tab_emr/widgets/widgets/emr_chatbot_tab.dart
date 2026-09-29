import 'dart:async';
import 'dart:typed_data';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/communication_model/communication_textstyle.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/calling/calling_Manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/communication_manger/chats_manager/patients_manager/patients_file.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/communication_data/chats_data/patients_data/patients.dart';
import 'package:symmetry_emr/modules/emr/data/models/communication_data/chats_data/patients_data/patients_chat.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/camera_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/chat_file_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/chat_tabs_const_textfield_mic.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/voice_note_bubble.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widget_for_tab_mobile/communication_tablet/communication_tab_home_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/toste_notify_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/onboarding/download_doc_const.dart';
import 'package:provider/provider.dart';
import 'package:symmetry_emr/modules/emr/providers/emr_provider/emr_patient_provider.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/call_screens/new_videocall_screen.dart';
import 'package:visibility_detector/visibility_detector.dart';

class EmrChatBotContainer extends StatefulWidget {
  final int ptGroupId;

  const EmrChatBotContainer({
    super.key,
    required this.ptGroupId,
  });

  @override
  State<EmrChatBotContainer> createState() => _EmrChatBotContainerState();

  static Widget _iconButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _EmrChatBotContainerState extends State<EmrChatBotContainer> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int? currentUserId;
  ChatPatientsGroupCommunicationData? chatData;
  bool isLoadingChat = false;

  int  _resolvedGroupId = 0;
  bool _groupNotFound   = false;

  Timer? _chatTimer;
  Timer? _visibilityDebounce;
  bool _isFirstLoad = true;
  bool _isPolling = false;
  bool _autoScroll  = true;
  int  _unreadCount = 0;

  bool showEmojiPicker = false;
  bool showFilePick    = false;
  bool _fileAbove20Mb  = false;
  bool _isSending      = false;
  bool _isPickingFile  = false;

  List<Uint8List> selectedFiles     = [];
  List<String>    selectedFileNames = [];

  String isSendViaSms = 'Send Default';

  bool get _isBusy => _isSending || _isPickingFile;

  static const int _pageSize = 50;
  int  _windowSize     = _pageSize;
  bool _isLoadingOlder = false;

  static const Duration _minFetchGap = Duration(seconds: 8);
  DateTime? _lastFetchAt;
  bool _fetchInFlight = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final double extentAfter = _scrollController.position.extentAfter;
      setState(() => _autoScroll = extentAfter <= 0.0);
    });
  }

  void _startPolling() {
    if (_isPolling) return;
    _isPolling = true;

    if (_resolvedGroupId > 0) {
      startListeningGroup(_resolvedGroupId);
    } else {
      _resolveAndStartChat();
    }
  }

  void _stopPolling() {
    if (!_isPolling) return;
    _isPolling = false;
    _chatTimer?.cancel();
  }

  @override
  void dispose() {
    _visibilityDebounce?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _chatTimer?.cancel();
    super.dispose();
  }

  Future<void> _resolveAndStartChat() async {
    try {
      final List<PatientGroup> groups = await getAllChatsPatientGroups(
        context,
        1,
        9999,
        'all',
      );

      if (groups.isEmpty) {
        if (mounted) setState(() => _groupNotFound = true);
        return;
      }

      final matched = groups
          .where((g) => g.ptGroupId == widget.ptGroupId)
          .firstOrNull;

      if (matched == null) {
        if (mounted) setState(() => _groupNotFound = true);
        return;
      }

      _resolvedGroupId = matched.ptGroupId;
      startListeningGroup(_resolvedGroupId);
    } catch (e) {
      print("EmrChatBot _resolveAndStartChat error: $e");
      if (mounted) setState(() => _groupNotFound = true);
    }
  }

  // ✅ cheap equality check so polling doesn't force a rebuild when
  // nothing actually changed. Prevents the periodic "blink."
  bool _isSameChatData(
      ChatPatientsGroupCommunicationData? oldData,
      ChatPatientsGroupCommunicationData newData,
      ) {
    if (oldData == null) return false;
    if (oldData.messages.length != newData.messages.length) return false;
    if (oldData.messages.isEmpty) return true;
    final oldLast = oldData.messages.last;
    final newLast = newData.messages.last;
    return oldLast.ptChatId == newLast.ptChatId &&
        oldLast.dateCreated == newLast.dateCreated &&
        oldLast.textContent == newLast.textContent;
  }

  Future<void> loadGroupChat(int groupId, {bool showLoader = false, bool force = false}) async {
    if (groupId <= 0) return;
    if (_fetchInFlight) return;

    if (!force && _lastFetchAt != null) {
      final elapsed = DateTime.now().difference(_lastFetchAt!);
      if (elapsed < _minFetchGap) return;
    }

    _fetchInFlight = true;
    _lastFetchAt = DateTime.now();

    final userId            = await TokenManager.getuserId();
    final bool shouldScroll = _autoScroll;
    final int  oldCount     = chatData?.messages.length ?? 0;

    // ✅ only show the loader on an explicit first load, never on background polls
    final bool willShowLoader = showLoader && chatData == null;
    if (willShowLoader) {
      if (mounted) setState(() => isLoadingChat = true);
    }

    try {
      final data = await chatPatientsGroupCommunication(
        context,
        groupId,
        1,
        _windowSize,
      );

      // ✅ skip setState entirely if content is unchanged — no rebuild, no blink
      final bool unchanged = _isSameChatData(chatData, data!);

      if (mounted && !unchanged) {
        setState(() {
          currentUserId = userId;
          chatData      = data;
          final int newCount = chatData?.messages.length ?? 0;
          final int added    = newCount - oldCount;
          if (added > 0 && !_autoScroll) _unreadCount += added;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scrollController.hasClients) return;
          if (shouldScroll) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      } else if (mounted) {
        currentUserId = userId;
      }
    } catch (e) {
      print("EmrChatBotContainer loadGroupChat error: $e");
    } finally {
      _fetchInFlight = false;
      // ✅ only setState if isLoadingChat was actually true — avoids a no-op rebuild
      if (mounted && isLoadingChat) {
        setState(() => isLoadingChat = false);
      }
    }
  }

  Future<void> _loadEarlierMessages() async {
    final int groupId = chatData?.groupInfo.ptGroupId ?? _resolvedGroupId;
    if (groupId <= 0 || _isLoadingOlder) return;

    final int? totalKnown = chatData?.pagination.totalMessages;
    if (totalKnown != null && _windowSize >= totalKnown) return;

    setState(() => _isLoadingOlder = true);

    final double distanceFromBottom = _scrollController.hasClients
        ? _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels
        : 0;

    _windowSize += _pageSize;

    try {
      final data = await chatPatientsGroupCommunication(
        context,
        groupId,
        1,
        _windowSize,
      );
      _lastFetchAt = DateTime.now();
      if (mounted) {
        setState(() => chatData = data);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;
        final double target =
            _scrollController.position.maxScrollExtent - distanceFromBottom;
        _scrollController.jumpTo(target.clamp(
          0,
          _scrollController.position.maxScrollExtent,
        ));
      });
    } catch (e) {
      print("EmrChatBotContainer _loadEarlierMessages error: $e");
      _windowSize -= _pageSize;
    } finally {
      if (mounted) setState(() => _isLoadingOlder = false);
    }
  }

  Future<void> startListeningGroup(int groupId) async {
    if (groupId <= 0) return;

    await loadGroupChat(groupId, showLoader: _isFirstLoad, force: true);
    _isFirstLoad = false;

    _chatTimer?.cancel();
    _chatTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted || !_isPolling) return;
      loadGroupChat(groupId, showLoader: false);
    });
  }

  void _appendFileNamesToController() {
    final existing = _messageController.text.trim();
    final fileText = selectedFileNames.join(', ');
    _messageController.text =
    existing.isEmpty ? fileText : '$existing, $fileText';
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: _messageController.text.length),
    );
  }

  Future<void> _handleSend() async {
    if (_isBusy) return;

    final int groupId = chatData?.groupInfo.ptGroupId ?? _resolvedGroupId;
    if (groupId <= 0) return;
    if (_messageController.text.trim().isEmpty && selectedFiles.isEmpty) return;

    setState(() => _isSending = true);

    try {
      if (selectedFiles.isNotEmpty) {
        if (_fileAbove20Mb) {
          ApiData result = await sendGroupMessage(
            isVoiceNote: false,
            context,
            ptGroupId: groupId,
            textContent: _messageController.text,
            restrictPatientFromView: false,
            sentAsSms: isSendViaSms != 'Send Default',
            isMedia: true,
          );

          if (!result.success || result.ptChatId == null) return;

          final filesForUpload =
          selectedFiles.map((b) => Uint8List.fromList(b)).toList();

          final attachMedia = await uploadMediaPatientChat(
            context: context,
            patientChatId: result.ptChatId!,
            documentFiles: filesForUpload.first,
            documentNames: selectedFileNames.first,
          );

          if (attachMedia.statusCode == 200 || attachMedia.statusCode == 201) {
            if (mounted) {
              setState(() {
                selectedFiles.clear();
                selectedFileNames.clear();
                _messageController.clear();
              });
            }
            loadGroupChat(groupId, force: true);
          }
        } else {
          if (mounted) {
            setState(() {
              selectedFiles.clear();
              selectedFileNames.clear();
              _messageController.clear();
              showEmojiPicker = false;
            });
          }
          showDialog(
            context: context,
            builder: (_) => const AddErrorPopup(message: 'File is too large!'),
          );
        }
      } else {
        ApiData result = await sendGroupMessage(
          isVoiceNote: false,
          context,
          ptGroupId: groupId,
          textContent: _messageController.text,
          restrictPatientFromView: false,
          sentAsSms: isSendViaSms != 'Send Default',
          isMedia: false,
        );

        if (!result.success || result.ptChatId == null) return;

        // ✅ collapsed into a single setState (was two back-to-back rebuilds:
        // this one + the one in `finally` below) to cut a redundant repaint.
        if (mounted) {
          setState(() {
            _messageController.clear();
            showEmojiPicker = false;
            _isSending = false;
          });
        }
        loadGroupChat(groupId, force: true);
        return;
      }
    } finally {
      // Only reached by the file-upload branch(es) above, since the plain-text
      // success path already reset `_isSending` and returned early.
      if (mounted && _isSending) setState(() => _isSending = false);
    }
  }

  String _formattedTime(String timestamp) {
    try {
      final dt      = DateTime.parse(timestamp).toUtc();
      final eastern = dt.subtract(const Duration(hours: 4));
      return DateFormat('hh:mm a').format(eastern);
    } catch (_) {
      return '';
    }
  }

  bool _isImageUrl(String url) {
    final path = (Uri.tryParse(url)?.path ?? url).toLowerCase();
    return path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png');
  }

  bool _isVoiceNoteUrl(String url) {
    final path = (Uri.tryParse(url)?.path ?? url).toLowerCase();
    return path.endsWith('.mpeg') || path.endsWith('.m4a') || path.endsWith('.mp3');
  }

  bool _isPdfUrl(String url) {
    final path = (Uri.tryParse(url)?.path ?? url).toLowerCase();
    return path.endsWith('.pdf');
  }

  Future<void> _runFilePick(Future<void> Function() pickAction) async {
    // FIX: guard against re-entrant taps — without this, a second tap on
    // "Camera" (or Documents/Gallery) before the first pick/navigation
    // completes could fire a second Navigator.push, pushing a second
    // WebCameraScreen on top of/racing the first, which looks like the app
    // jumping to another screen before the camera opens.
    if (_isPickingFile) return;
    setState(() => _isPickingFile = true);
    try {
      await pickAction();
    } catch (e) {
      print("EmrChatBot file pick error: $e");
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('emr-chatbot-tab-visibility'),
      onVisibilityChanged: (info) {
        if (!mounted) return;
        _visibilityDebounce?.cancel();
        _visibilityDebounce = Timer(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          if (info.visibleFraction > 0.1) {
            _startPolling();
          } else {
            _stopPolling();
          }
        });
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_groupNotFound) {
      return Container(
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: const BorderRadius.only(
            bottomLeft:  Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          border: Border.all(color: ColorManager.bordercolorcontainer),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              "No matching group found",
              style: TextStyle(
                fontSize:   FontSize.s14,
                fontWeight: FontWeight.w600,
                color:      Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Chat will be available once a group\nis configured for this patient.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: FontSize.s12, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: const BorderRadius.only(
          bottomLeft:  Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        border: Border.all(color: ColorManager.bordercolorcontainer),
      ),
      child: chatData == null && isLoadingChat
          ? const Center(child: CircularProgressIndicator())
          : chatData == null
          ? Center(
        child: Text(
          'Loading patient chat…',
          style: AllNoDataAvailable.customTextStyle(context),
        ),
      )
          : Column(
        children: [
          _buildHeader(),
          _buildRecipientBar(),
          _buildMessageList(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: (chatData!.groupInfo.groupProfileUrl == null ||
                    chatData!.groupInfo.groupProfileUrl!.isEmpty ||
                    chatData!.groupInfo.groupProfileUrl == 'imgurl')
                    ? CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.transparent,
                  child: Image.asset('images/profilepic.png'),
                )
                    : Image.network(
                  chatData!.groupInfo.groupProfileUrl!,
                  height: 55, width: 55, fit: BoxFit.cover,
                  gaplessPlayback: true, // ✅ prevents blank-frame blink on rebuild
                  errorBuilder: (_, __, ___) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('images/profilepic.png',
                        height: 55, width: 55),
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
                    style: const TextStyle(
                      color:      Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize:   FontSize.s12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color:        Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Please note that it's a patient group",
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              EmrChatBotContainer._iconButton(
                Icons.videocam,
                ColorManager.blueprime,
                    () async {
                  if (_resolvedGroupId <= 0) return;
                  var callResponse = await addCallInitiate(
                    context,
                    participantUserIds: chatData!.participants
                        .map((e) => e.userId)
                        .where((id) => id != currentUserId)
                        .toList(),
                    callType: 'GROUP',
                    isVideo:  true,
                  );
                  if (callResponse.statusCode == 201 ||
                      callResponse.statusCode == 200) {
                    final data = callResponse.data as Map<String, dynamic>;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoCallAgoraScreen(
                          isVideoOn:      true,
                          isAudioOn:      true,
                          channelName:    data['channelName'] ?? '',
                          token:          data['token'] ?? '',
                          callId:         data['callId'] ?? '',
                          groupName:      data['groupName'] ?? '',
                          groupImage:     data['groupImage'] ?? '',
                          receiverImages: (data['receiverImages'] as List<dynamic>?)
                              ?.map((e) => e.toString()).toList() ?? [],
                          receiverNames:  (data['receiverNames'] as List<dynamic>?)
                              ?.map((e) => e.toString()).toList() ?? [],
                          receiverIds:    (data['receiverUserId'] as List<dynamic>?)
                              ?.map((e) => int.tryParse(e.toString()) ?? 0).toList() ?? [],
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 10),
              EmrChatBotContainer._iconButton(
                Icons.call,
                ColorManager.greenDark,
                    () async {
                  if (_resolvedGroupId <= 0) return;
                  var callResponse = await addCallInitiate(
                    context,
                    participantUserIds: chatData!.participants
                        .map((e) => e.userId)
                        .where((id) => id != currentUserId)
                        .toList(),
                    callType: 'GROUP',
                    isVideo:  false,
                  );
                  if (callResponse.statusCode == 201 ||
                      callResponse.statusCode == 200) {
                    final data = callResponse.data as Map<String, dynamic>;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoCallAgoraScreen(
                          isVideoOn:      false,
                          isAudioOn:      true,
                          channelName:    data['channelName'] ?? '',
                          token:          data['token'] ?? '',
                          callId:         data['callId'] ?? '',
                          userImage:      data['contactImage'] ?? '',
                          userName:       data['contactName'] ?? '',
                          groupName:      data['groupName'] ?? '',
                          groupImage:     data['groupImage'] ?? '',
                          receiverImages: (data['receiverImages'] as List<dynamic>?)
                              ?.map((e) => e.toString()).toList() ?? [],
                          receiverNames:  (data['receiverNames'] as List<dynamic>?)
                              ?.map((e) => e.toString()).toList() ?? [],
                          receiverIds:    (data['receiverUserId'] as List<dynamic>?)
                              ?.map((e) => int.tryParse(e.toString()) ?? 0).toList() ?? [],
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 10),
              PopupMenuButton<String>(
                offset: const Offset(0, 32),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: const Icon(Icons.more_horiz, color: Colors.grey, size: 20),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'Clear Chat',
                    onTap: () async {
                      if (_resolvedGroupId <= 0) return;
                      var response = await clearPatientGropChatPatch(
                        context,
                        id: chatData!.groupInfo.ptGroupId,
                      );
                      if (response.statusCode == 200 || response.statusCode == 201) {
                        showTopRightToast(context,
                            message: 'Group chat cleared successfully!',
                            isSuccess: true);
                        loadGroupChat(_resolvedGroupId, force: true);
                      } else {
                        showTopRightToast(context,
                            message: 'Something went wrong!',
                            isSuccess: false);
                      }
                    },
                    child: Row(
                      children: [
                        Image.asset('images/communication/chat/chat.png',
                            height: 20, width: 20, color: ColorManager.mediumgrey),
                        const SizedBox(width: 15),
                        Text('Clear Chat',
                            style: ChatMoreInfoText.customTextStyle(context)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'Exit Group',
                    onTap: () async {
                      if (_resolvedGroupId <= 0) return;
                      var response = await patchexitPatientGrop(
                        context,
                        patientId: chatData!.groupInfo.ptGroupId,
                      );
                      if (response.statusCode == 200 || response.statusCode == 201) {
                        showTopRightToast(context,
                            message: 'Group exited successfully!',
                            isSuccess: true);
                        context.read<EmrPatientProvider>().toggleQaChat();
                      } else {
                        showTopRightToast(context,
                            message: 'Something went wrong!',
                            isSuccess: false);
                      }
                    },
                    child: Row(
                      children: [
                        Image.asset('images/communication/chat/exitGrp.png',
                            height: 20, width: 20, color: ColorManager.mediumgrey),
                        const SizedBox(width: 15),
                        Text('Exit Group',
                            style: ChatMoreInfoText.customTextStyle(context)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => context.read<EmrPatientProvider>().toggleQaChat(),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: const Icon(Icons.close, color: Colors.grey, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientBar() {
    return Container(
      padding: const EdgeInsets.only(left: 20, top: 5, bottom: 5, right: 22),
      decoration: BoxDecoration(color: ColorManager.bordercolorcontainer),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Text(
                  'Recipient',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: FontSize.s10),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...chatData!.participants.map((p) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: ColorManager.bluelight, width: 2),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: (p.imgUrl.isEmpty || p.imgUrl == 'imgurl')
                                          ? Image.asset('images/profilepic.png',
                                          height: 19, width: 19)
                                          : Image.network(
                                        p.imgUrl,
                                        height: 18, width: 18, fit: BoxFit.cover,
                                        gaplessPlayback: true, // ✅ no blink on rebuild
                                        errorBuilder: (_, __, ___) =>
                                            Image.asset('images/profilepic.png',
                                                height: 19, width: 19),
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
                                        fontSize:   FontSize.s10,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            );
                          }),
                          Text(
                            chatData!.participants.any((p) => p.isOnline)
                                ? 'online'
                                : 'offline — messages will be sent via SMS',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize:   FontSize.s10,
                              color:      Colors.black,
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
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Expanded(
      child: Stack(
        children: [
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
                      _autoScroll  = true;
                      _unreadCount = 0;
                    });
                  }
                } else {
                  if (_autoScroll) setState(() => _autoScroll = false);
                }
              }
              return false;
            },
            child: ListView.builder(
              controller:  _scrollController,
              padding: EdgeInsets.fromLTRB(16, 12, 16, showEmojiPicker ? 260 : 12),
              itemCount: chatData!.messages.length +
                  (_shouldShowLoadEarlier() ? 1 : 0),
              itemBuilder: (context, index) {
                if (_shouldShowLoadEarlier() && index == 0) {
                  return _buildLoadEarlierRow();
                }
                final int msgIndex =
                    index - (_shouldShowLoadEarlier() ? 1 : 0);
                final msg   = chatData!.messages[msgIndex];
                final bool isMe = msg.ptUserId == 0
                    ? msg.ptEmpUserId == currentUserId
                    : msg.sender.userId == currentUserId;
                final String formattedTime = _formattedTime(msg.dateCreated);

                final imageUrls =
                msg.attachedMultimediaUrls.where(_isImageUrl).toList();
                final voiceNoteUrl =
                msg.voiceNoteUrl!.where(_isVoiceNoteUrl).toList();
                final pdfUrls =
                msg.attachedMultimediaUrls.where(_isPdfUrl).toList();

                return Padding(
                  // ✅ stable key so the list diffs cheaply on refetch instead of
                  // repainting every row (reduces the send-time blink further)
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
                          child: Image.network(
                            msg.sender.imgUrl,
                            width: 28, height: 28, fit: BoxFit.cover,
                            gaplessPlayback: true, // ✅ no blink on rebuild
                            errorBuilder: (_, __, ___) => ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.person,
                                    size: 28, color: Colors.grey[400]),
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
                            topRight:    Radius.circular(10),
                            topLeft:     Radius.circular(10),
                            bottomLeft:  Radius.circular(10),
                          )
                              : const BorderRadius.only(
                            topRight:    Radius.circular(10),
                            topLeft:     Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            ...imageUrls.map((url) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: InkWell(
                                onTap: () async => await openImageInNewTab(context: context,
                                    fileUrl: url,
                                    documentName:"commuchat_image_${url.split('/').last}",
                                    apiPath: DownloadDocumentRepository.getEmployeesChatImageByFileName()),
                                child: Container(
                                  height: 200, width: 250,
                                  decoration: BoxDecoration(
                                    color:        Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Image.network(url,
                                      fit: BoxFit.contain,
                                      gaplessPlayback: true, // ✅ no blink on rebuild
                                      errorBuilder: (_, __, ___) =>
                                      const Center(
                                        child: Icon(Icons.broken_image,
                                            size: 50),
                                      )),
                                ),
                              ),
                            )),
                            ...pdfUrls.map((url) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: InkWell(
                                onTap: () async => await downloadFile(context: context,
                                    fileUrl: url,
                                    documentName:"commuchat_pdf_${url.split('/').last}",
                                    apiPath: DownloadDocumentRepository.getCliniciansChatImageByFileName()),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.description,
                                        size: 30,
                                        color: isMe
                                            ? Colors.white
                                            : Colors.black),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        url.split('/').last,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isMe
                                              ? Colors.white
                                              : ColorManager
                                              .commuchatTextColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                            ...voiceNoteUrl.map((url) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: VoiceNoteBubble(url: url, isMe: isMe),
                            )),
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
                          child: Image.network(
                            msg.sender.imgUrl,
                            width: 28, height: 28, fit: BoxFit.cover,
                            gaplessPlayback: true, // ✅ no blink on rebuild
                            errorBuilder: (_, __, ___) => ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.person,
                                    size: 28, color: Colors.grey[400]),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_unreadCount > 0)
            Positioned(
              right:  16,
              bottom: showEmojiPicker ? 260 + 16 : 16,
              child: InkWell(
                onTap: () {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 250),
                    curve:    Curves.easeOut,
                  );
                  setState(() {
                    _unreadCount = 0;
                    _autoScroll  = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color:        ColorManager.blueprime,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 6,
                        offset:     const Offset(0, 2),
                        color:      Colors.black.withOpacity(0.2),
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
                          color:      Colors.white,
                          fontSize:   12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (showEmojiPicker)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => setState(() => showEmojiPicker = false),
                child: const SizedBox(),
              ),
            ),
          if (showEmojiPicker)
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: SizedBox(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.only(right: 300, left: 20),
                  child: EmojiPicker(
                    onEmojiSelected: (_, emoji) {
                      _messageController.text += emoji.emoji;
                    },
                    config: Config(
                      height: 200,
                      bottomActionBarConfig: BottomActionBarConfig(
                        backgroundColor:     ColorManager.blueprime,
                        buttonColor:         ColorManager.blueprime,
                        showBackspaceButton: false,
                      ),
                      emojiViewConfig:    const EmojiViewConfig(emojiSizeMax: 16),
                      categoryViewConfig: CategoryViewConfig(
                        iconColor:         Colors.grey,
                        iconColorSelected: ColorManager.blueprime,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (showFilePick)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => setState(() => showFilePick = false),
                child: const SizedBox(),
              ),
            ),
          if (showFilePick)
            Positioned(
              right: 70, bottom: 0,
              child: ConstFilepickerAndMediaPicker(
                pickDocuments: () async {
                  setState(() => showFilePick = false);
                  await _runFilePick(() async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type:              FileType.custom,
                      allowedExtensions: ['pdf'],
                      allowMultiple:     false,
                      withData:          true,
                    );
                    if (result != null) {
                      final fileSize    = result.files.first.size;
                      final isAbove20MB = fileSize > (20 * 1024 * 1024);
                      setState(() {
                        for (final f in result.files) {
                          if (f.bytes != null) {
                            selectedFiles.add(Uint8List.fromList(f.bytes!));
                            selectedFileNames.add(f.name);
                          }
                        }
                        _fileAbove20Mb = !isAbove20MB;
                        _appendFileNamesToController();
                      });
                    }
                  });
                },
                pickGallery: () async {
                  setState(() => showFilePick = false);
                  await _runFilePick(() async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type:              FileType.custom,
                      allowedExtensions: ['png', 'jpg', 'jpeg'],
                      allowMultiple:     false,
                      withData:          true,
                    );
                    if (result != null) {
                      final fileSize    = result.files.first.size;
                      final isAbove20MB = fileSize > (20 * 1024 * 1024);
                      setState(() {
                        for (final f in result.files) {
                          if (f.bytes != null) {
                            selectedFiles.add(Uint8List.fromList(f.bytes!));
                            selectedFileNames.add(f.name);
                          }
                        }
                        _fileAbove20Mb = !isAbove20MB;
                        _appendFileNamesToController();
                      });
                    }
                  });
                },
                pickCamera: () async {
                  setState(() => showFilePick = false);
                  await _runFilePick(() async {
                    final picture = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => WebCameraScreen(cameras: cameras!)),
                    );
                    if (picture != null) {
                      final rawBytes   = await picture.readAsBytes();
                      final imageBytes = Uint8List.fromList(rawBytes);
                      final fileName   =
                          'captured_${DateTime.now().millisecondsSinceEpoch}.jpg';
                      setState(() {
                        selectedFiles.add(imageBytes);
                        selectedFileNames.add(fileName);
                        _fileAbove20Mb = true;
                        _appendFileNamesToController();
                      });
                    }
                  });
                },
              ),
            ),
          if (isLoadingChat && chatData != null)
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _shouldShowLoadEarlier() {
    final int? total = chatData?.pagination.totalMessages;
    if (total == null) return false;
    return total > _windowSize;
  }

  Widget _buildLoadEarlierRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: _isLoadingOlder
            ? const SizedBox(
          width: 18, height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : TextButton(
          onPressed: _loadEarlierMessages,
          child: Text(
            'Load earlier messages',
            style: TextStyle(
              fontSize:   FontSize.s12,
              fontWeight: FontWeight.w600,
              color:      ColorManager.blueprime,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    final int groupId = chatData?.groupInfo.ptGroupId ?? _resolvedGroupId;

    return ChatTabsConstTextfieldMic(
      isGrpoupChat: true,
      onRefresh: () async {
        setState(() {
          selectedFiles.clear();
          selectedFileNames.clear();
          _messageController.clear();
          showEmojiPicker = false;
          showFilePick    = false;
        });
        loadGroupChat(groupId, force: true);
      },
      selectedId:       groupId,
      attaceFile:       () {
        if (_isPickingFile) return;
        setState(() => showFilePick = !showFilePick);
      },
      onEmojiTap:       () => setState(() => showEmojiPicker = !showEmojiPicker),
      onSend:           _isBusy ? () {} : _handleSend,
      controller:       _messageController,
      onMicTap:         () {},
      onSendDefaultTap: (value) => setState(() => isSendViaSms = value),
    );
  }
}