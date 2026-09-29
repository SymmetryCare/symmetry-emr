import 'dart:async';
import 'dart:convert';
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
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/camera_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/chat_file_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/chat_tabs_const_textfield_mic.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/voice_note_bubble.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/toste_notify_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/onboarding/download_doc_const.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/modules/emr/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_patient_manager/emr_clinical_group_chatbot_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/patient_tab_data/emr_clinical_group_chatbot_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widget_for_tab_mobile/communication_tablet/communication_tab_home_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/call_screens/new_videocall_screen.dart';

class ClinicalGroupChatBot extends StatefulWidget {
  final int ptId;
  final VoidCallback onClose;

  const ClinicalGroupChatBot({
    super.key,
    required this.ptId,
    required this.onClose,
  });

  @override
  State<ClinicalGroupChatBot> createState() => _ClinicalGroupChatBotState();

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

class _ClinicalGroupChatBotState extends State<ClinicalGroupChatBot> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController      _scrollController  = ScrollController();

  int? currentUserId;

  PatientCareTeamChatData?    careTeamData;
  PatientGroupChatScreenData? chatData;

  bool isLoadingChat  = false;
  bool _groupNotFound = false;

  Timer? _chatTimer;
  bool _isFirstLoad = true;
  bool _autoScroll  = true;
  int  _unreadCount = 0;

  bool showEmojiPicker = false;
  bool showFilePick    = false;
  bool _isOpeningCamera = false;
  bool _fileAbove20Mb  = false;

  List<Uint8List> selectedFiles     = [];
  List<String>    selectedFileNames = [];

  String isSendViaSms = 'Send Default';

  // ── pagination window ───────────────────────────────────────────────────────
  // Instead of always requesting a flat 10000 rows (which meant every 3s poll
  // re-downloaded and re-parsed the entire chat history), we request a
  // growable "window" of recent messages. Polling re-fetches only the current
  // window size — cheap by default — and "Load earlier" grows it.
  static const int _pageSize = 50;
  int  _windowSize    = _pageSize;
  bool _isLoadingOlder = false;

  // ── lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      setState(() =>
      _autoScroll = _scrollController.position.extentAfter <= 0.0);
    });
    _resolveAndStartChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatTimer?.cancel();
    super.dispose();
  }

  // ── resolve ────────────────────────────────────────────────────────────────

  Future<void> _resolveAndStartChat() async {
    try {
      final PatientCareTeamChatData? data =
      await getCareTeamChat(context, widget.ptId);

      if (data == null) {
        print("ClinicalGroupChatBot: null for ptId=${widget.ptId}");
        if (mounted) setState(() => _groupNotFound = true);
        return;
      }

      print("ClinicalGroupChatBot: resolved ptGroupId=${data.ptGroupId}");
      if (mounted) {
        setState(() {
          careTeamData   = data;
          _groupNotFound = false;
        });
      }
      startListeningGroup(data.ptGroupId);
    } catch (e) {
      print("ClinicalGroupChatBot _resolveAndStartChat error: $e");
      if (mounted) setState(() => _groupNotFound = true);
    }
  }



  // ── data loading ───────────────────────────────────────────────────────────

  Future<void> loadGroupChat(int ptGroupId, {bool showLoader = false}) async {
    if (ptGroupId <= 0) return;

    final userId      = await TokenManager.getuserId();
    final bool scroll = _autoScroll;
    final int oldCount = chatData?.messages.length ?? 0;

    if (showLoader || chatData == null) {
      if (mounted) setState(() => isLoadingChat = true);
    }

    try {
      // ✅ request only the current window instead of a flat 10000 rows
      final data = await getGroupChatScreen(
        context,
        ptGroupId,
        1,
        _windowSize,
      );

      if (mounted) {
        setState(() {
          currentUserId = userId;
          chatData      = data;
          final int added = (chatData?.messages.length ?? 0) - oldCount;
          if (added > 0 && !_autoScroll) _unreadCount += added;
        });
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;
        if (scroll) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve:    Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print("ClinicalGroupChatBot loadGroupChat error: $e");
    } finally {
      if (mounted) setState(() => isLoadingChat = false);
    }
  }

  // ✅ Grows the window by one page and re-fetches. Since we're re-requesting
  // the same page (1) with a larger row count, this naturally returns more
  // history regardless of whether the API sorts ascending or descending —
  // no assumption about sort direction required.
  Future<void> _loadEarlierMessages() async {
    final int ptGroupId = careTeamData?.ptGroupId ?? 0;
    if (ptGroupId <= 0 || _isLoadingOlder) return;

    final int? totalKnown = chatData?.pagination.totalMessages;
    if (totalKnown != null && _windowSize >= totalKnown) return; // nothing more

    setState(() => _isLoadingOlder = true);

    // Preserve the user's visual position: capture how far from the bottom
    // the scroll offset currently is before the list grows upward.
    final double distanceFromBottom = _scrollController.hasClients
        ? _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels
        : 0;

    _windowSize += _pageSize;

    try {
      final data = await getGroupChatScreen(context, ptGroupId, 1, _windowSize);
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
      print("ClinicalGroupChatBot _loadEarlierMessages error: $e");
      _windowSize -= _pageSize; // roll back on failure
    } finally {
      if (mounted) setState(() => _isLoadingOlder = false);
    }
  }

  Future<void> startListeningGroup(int ptGroupId) async {
    if (ptGroupId <= 0) return;
    await loadGroupChat(ptGroupId, showLoader: _isFirstLoad);
    _isFirstLoad = false;
    _chatTimer?.cancel();
    _chatTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      loadGroupChat(ptGroupId, showLoader: false);
    });
  }

  // ── send ───────────────────────────────────────────────────────────────────

  Future<void> _handleSend() async {
    final int ptGroupId = careTeamData?.ptGroupId ?? 0;
    if (ptGroupId <= 0) return;
    if (_messageController.text.trim().isEmpty && selectedFiles.isEmpty) return;

    if (selectedFiles.isNotEmpty) {
      if (_fileAbove20Mb) {
        final ApiData result = await sendPatientGroupChat(
          context, ptGroupId, _messageController.text,
          restrictPatientFromView: false,
          sentAsSms: isSendViaSms != 'Send Default',
        );
        if (!result.success) return;

        final attachResult = await sendChatAttachment(
          context,
          result.ptChatId ?? 0,
          _bytesToBase64(selectedFiles.first, selectedFileNames.first),
          selectedFileNames.first,
        );
        if (attachResult.success) {
          if (mounted) {
            setState(() {
              selectedFiles.clear();
              selectedFileNames.clear();
              _messageController.clear();
            });
          }
          loadGroupChat(ptGroupId);
        } else {
          showTopRightToast(context,
              message: 'Failed to attach file. Please try again.',
              isSuccess: false);
          if (mounted) {
            setState(() {
              selectedFiles.clear();
              selectedFileNames.clear();
            });
          }
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
      final ApiData result = await sendPatientGroupChat(
        context, ptGroupId, _messageController.text,
        restrictPatientFromView: false,
        sentAsSms: isSendViaSms != 'Send Default',
      );
      if (!result.success) return;
      // ✅ single setState (was previously followed by loadGroupChat's own
      // setState calls firing right after) — cuts a redundant rebuild that
      // caused the send-time blink, same fix as EmrChatBotContainer.
      if (mounted) {
        setState(() {
          _messageController.clear();
          showEmojiPicker = false;
        });
      }
      loadGroupChat(ptGroupId);
    }
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  String _formattedTime(String timestamp) {
    try {
      final dt      = DateTime.parse(timestamp).toUtc();
      final eastern = dt.subtract(const Duration(hours: 4));
      return DateFormat('hh:mm a').format(eastern);
    } catch (_) {
      return '';
    }
  }

  String _bytesToBase64(Uint8List bytes, String fileName) {
    final ext  = fileName.split('.').last.toLowerCase();
    final mime = ext == 'pdf'
        ? 'application/pdf'
        : ext == 'png'
        ? 'image/png'
        : 'image/jpeg';
    return 'data:$mime;base64,${base64Encode(bytes)}';
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

  void _appendFileNamesToController() {
    final existing = _messageController.text.trim();
    final fileText = selectedFileNames.join(', ');
    _messageController.text =
    existing.isEmpty ? fileText : '$existing, $fileText';
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: _messageController.text.length),
    );
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {

    // ── group not found ──────────────────────────────────────────────────────
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
            Icon(Icons.group_off_outlined,
                size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              "Care team group not found",
              style: TextStyle(
                fontSize:   FontSize.s14,
                fontWeight: FontWeight.w600,
                color:      Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "The clinical group could not be loaded\nfor this patient.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: FontSize.s12, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _groupNotFound = false);
                _resolveAndStartChat();
              },
              icon:  const Icon(Icons.refresh, size: 16),
              label: const Text(
                "Retry",
                style: TextStyle(fontSize: FontSize.s12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.blueprime,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: widget.onClose,
              child: Text(
                "Close",
                style: TextStyle(
                    fontSize: FontSize.s12,
                    color:    ColorManager.mediumgrey),
              ),
            ),
          ],
        ),
      );
    }

    // ── main container ───────────────────────────────────────────────────────
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
          'Loading clinical group chat…',
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

  // ── header ─────────────────────────────────────────────────────────────────

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
                child: (chatData!.groupInfo.groupProfileUrl.isEmpty ||
                    chatData!.groupInfo.groupProfileUrl == 'imgurl')
                    ? CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.transparent,
                  child: Image.asset('images/profilepic.png'),
                )
                    : Image.network(
                  chatData!.groupInfo.groupProfileUrl,
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
                      "Clinical group — clinicians only",
                      style: TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),

          Row(
            children: [
              // Video call
              ClinicalGroupChatBot._iconButton(
                Icons.videocam,
                ColorManager.blueprime,
                    () async {
                  if ((careTeamData?.ptGroupId ?? 0) <= 0) return;
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
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => VideoCallAgoraScreen(
                        isVideoOn:      true,
                        isAudioOn:      true,
                        channelName:    data['channelName'] ?? '',
                        token:          data['token'] ?? '',
                        callId:         data['callId'] ?? '',
                        groupName:      data['groupName'] ?? '',
                        groupImage:     data['groupImage'] ?? '',
                        receiverImages: (data['receiverImages']
                        as List<dynamic>?)
                            ?.map((e) => e.toString())
                            .toList() ??
                            [],
                        receiverNames: (data['receiverNames']
                        as List<dynamic>?)
                            ?.map((e) => e.toString())
                            .toList() ??
                            [],
                        receiverIds: (data['receiverUserId']
                        as List<dynamic>?)
                            ?.map((e) =>
                        int.tryParse(e.toString()) ?? 0)
                            .toList() ??
                            [],
                      ),
                    ));
                  }
                },
              ),
              const SizedBox(width: 10),

              // Audio call
              ClinicalGroupChatBot._iconButton(
                Icons.call,
                ColorManager.greenDark,
                    () async {
                  if ((careTeamData?.ptGroupId ?? 0) <= 0) return;
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
                    Navigator.push(context, MaterialPageRoute(
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
                        receiverImages: (data['receiverImages']
                        as List<dynamic>?)
                            ?.map((e) => e.toString())
                            .toList() ??
                            [],
                        receiverNames: (data['receiverNames']
                        as List<dynamic>?)
                            ?.map((e) => e.toString())
                            .toList() ??
                            [],
                        receiverIds: (data['receiverUserId']
                        as List<dynamic>?)
                            ?.map((e) =>
                        int.tryParse(e.toString()) ?? 0)
                            .toList() ??
                            [],
                      ),
                    ));
                  }
                },
              ),
              const SizedBox(width: 10),

              // Close — calls parent onClose, not provider
              InkWell(
                onTap: widget.onClose,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.grey.shade200, width: 1),
                  ),
                  child: const Icon(Icons.close,
                      color: Colors.grey, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── recipient bar ──────────────────────────────────────────────────────────

  Widget _buildRecipientBar() {
    return Container(
      padding:
      const EdgeInsets.only(left: 20, top: 5, bottom: 5, right: 22),
      decoration:
      BoxDecoration(color: ColorManager.bordercolorcontainer),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Text(
                  'Clinicians',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize:   FontSize.s10),
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
                              padding:
                              const EdgeInsets.only(right: 10),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      border: Border.all(
                                          color: ColorManager.bluelight,
                                          width: 2),
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(10),
                                      child: (p.imgurl.isEmpty ||
                                          p.imgurl == 'imgurl')
                                          ? Image.asset(
                                          'images/profilepic.png',
                                          height: 19, width: 19)
                                          : Image.network(
                                        p.imgurl,
                                        height: 18,
                                        width:  18,
                                        fit: BoxFit.cover,
                                        gaplessPlayback: true, // ✅ no blink on rebuild
                                        errorBuilder:
                                            (_, __, ___) =>
                                            Image.asset(
                                                'images/profilepic.png',
                                                height: 19,
                                                width:  19),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  ConstrainedBox(
                                    constraints:
                                    const BoxConstraints(
                                        maxWidth: 130),
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
                            chatData!.participants
                                .any((p) => p.isOnline)
                                ? 'online'
                                : 'offline',
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

  // ── message list ───────────────────────────────────────────────────────────

  Widget _buildMessageList() {
    return Expanded(
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              final metrics    = notification.metrics;
              final bool isAtBottom = metrics.extentAfter < 50.0;
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
                  if (_autoScroll)
                    setState(() => _autoScroll = false);
                }
              }
              return false;
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, showEmojiPicker ? 260 : 12),
              // ✅ +1 for the "Load earlier" header row when applicable
              itemCount: chatData!.messages.length +
                  (_shouldShowLoadEarlier() ? 1 : 0),
              itemBuilder: (context, index) {
                if (_shouldShowLoadEarlier() && index == 0) {
                  return _buildLoadEarlierRow();
                }
                final int msgIndex =
                    index - (_shouldShowLoadEarlier() ? 1 : 0);
                final ChatMessageData msg = chatData!.messages[msgIndex];

                final bool isMe =
                    msg.sender.userId == currentUserId;
                final String formattedTime =
                _formattedTime(msg.dateCreated);

                final imageUrls = msg.attachedMultimediaUrl
                    .where(_isImageUrl)
                    .toList();

                final pdfUrls = msg.attachedMultimediaUrl
                    .where(_isPdfUrl)
                    .toList();

                final voiceNoteUrls = (msg.voiceNoteUrl != null &&
                    _isVoiceNoteUrl(msg.voiceNoteUrl!))
                    ? [msg.voiceNoteUrl!]
                    : <String>[];

                return Padding(
                  // ✅ stable key so the list diffs cheaply on refetch instead of
                  // repainting every row (reduces the send-time blink further)
                  key: ValueKey(msg.ptChatId),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: isMe
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!isMe)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            msg.sender.imgurl,
                            width: 28, height: 28,
                            fit: BoxFit.cover,
                            gaplessPlayback: true, // ✅ no blink on rebuild
                            errorBuilder: (_, __, ___) => ClipRRect(
                              borderRadius:
                              BorderRadius.circular(4),
                              child: Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.person,
                                    size: 28,
                                    color: Colors.grey[400]),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),

                      Container(
                        constraints:
                        const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMe
                              ? ColorManager.blueprime
                              : ColorManager.commuchatBackColor,
                          borderRadius: isMe
                              ? const BorderRadius.only(
                            topRight:   Radius.circular(10),
                            topLeft:    Radius.circular(10),
                            bottomLeft: Radius.circular(10),
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
                            // images
                            ...imageUrls.map((url) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 4),
                              child: InkWell(
                                onTap: () async =>
                                await openImageInNewTab(context: context,
                                    fileUrl: url,
                                    documentName:"commuchat_image_${url.split('/').last}",
                                    apiPath: DownloadDocumentRepository.getPatientGroupChatImageByFileName()),
                                child: Container(
                                  height: 200, width: 250,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.contain,
                                    gaplessPlayback: true, // ✅ no blink on rebuild
                                    errorBuilder: (_, __, ___) =>
                                    const Center(
                                      child: Icon(
                                          Icons.broken_image,
                                          size: 50),
                                    ),
                                  ),
                                ),
                              ),
                            )),

                            // pdfs
                            ...pdfUrls.map((url) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 4),
                              child: InkWell(
                                onTap: () async =>
                                await downloadFile(context: context,
                                    fileUrl: url,
                                    documentName:"commuchat_pdf_${url.split('/').last}",
                                    apiPath: DownloadDocumentRepository.getPatientGroupChatImageByFileName()),
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

                            // voice notes
                            ...voiceNoteUrls.map((url) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 4),
                              child: VoiceNoteBubble(
                                  url: url, isMe: isMe),
                            )),

                            // text
                            if (msg.textContent.isNotEmpty)
                              Padding(
                                padding:
                                const EdgeInsets.only(top: 4),
                                child: Text(
                                  msg.textContent,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isMe
                                        ? Colors.white
                                        : ColorManager
                                        .commuchatTextColor,
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
                            msg.sender.imgurl,
                            width: 28, height: 28,
                            fit: BoxFit.cover,
                            gaplessPlayback: true, // ✅ no blink on rebuild
                            errorBuilder: (_, __, ___) => ClipRRect(
                              borderRadius:
                              BorderRadius.circular(4),
                              child: Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.person,
                                    size: 28,
                                    color: Colors.grey[400]),
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

          // unread badge
          if (_unreadCount > 0)
            Positioned(
              right:  16,
              bottom: showEmojiPicker ? 276 : 16,
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color:        ColorManager.blueprime,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 6,
                        offset:     const Offset(0, 2),
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
                        '$_unreadCount new message'
                            '${_unreadCount > 1 ? 's' : ''}',
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
                onTap: () =>
                    setState(() => showEmojiPicker = false),
                child: const SizedBox(),
              ),
            ),

          if (showEmojiPicker)
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: SizedBox(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.only(
                      right: 300, left: 20),
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
                      emojiViewConfig:
                      const EmojiViewConfig(emojiSizeMax: 16),
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
                onTap: () =>
                    setState(() => showFilePick = false),
                child: const SizedBox(),
              ),
            ),

          if (showFilePick)
            Positioned(
              right: 70, bottom: 0,
              child: ConstFilepickerAndMediaPicker(
                pickDocuments: () async {
                  setState(() => showFilePick = false);
                  FilePickerResult? result =
                  await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                    allowMultiple: false,
                    withData: true,
                  );
                  if (result != null) {
                    final isAbove20MB =
                        result.files.first.size > (20 * 1024 * 1024);
                    setState(() {
                      selectedFiles.clear();
                      selectedFileNames.clear();
                      _messageController.clear();
                      for (final f in result.files) {
                        if (f.bytes != null) {
                          selectedFiles.add(
                              Uint8List.fromList(f.bytes!));
                          selectedFileNames.add(f.name);
                        }
                      }
                      _fileAbove20Mb = !isAbove20MB;
                      _appendFileNamesToController();
                    });
                  }
                },
                pickGallery: () async {
                  setState(() => showFilePick = false);
                  FilePickerResult? result =
                  await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['png', 'jpg', 'jpeg'],
                    allowMultiple: false,
                    withData: true,
                  );
                  if (result != null) {
                    final isAbove20MB =
                        result.files.first.size > (20 * 1024 * 1024);
                    setState(() {
                      selectedFiles.clear();
                      selectedFileNames.clear();
                      _messageController.clear();
                      for (final f in result.files) {
                        if (f.bytes != null) {
                          selectedFiles.add(
                              Uint8List.fromList(f.bytes!));
                          selectedFileNames.add(f.name);
                        }
                      }
                      _fileAbove20Mb = !isAbove20MB;
                      _appendFileNamesToController();
                    });
                  }
                },
                pickCamera: () async {
                  // FIX: guard against re-entrant taps — without this, a second
                  // tap on "Camera" before the first Navigator.push completes
                  // could fire a second navigation, pushing a second
                  // WebCameraScreen on top of/racing the first, which looks
                  // like the app jumping to another screen before the camera
                  // opens.
                  if (_isOpeningCamera) return;
                  setState(() {
                    showFilePick = false;
                    _isOpeningCamera = true;
                  });
                  try {
                    final picture = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              WebCameraScreen(cameras: cameras!)),
                    );
                    if (picture != null) {
                      final rawBytes   = await picture.readAsBytes();
                      final imageBytes = Uint8List.fromList(rawBytes);
                      final fileName =
                          'captured_${DateTime.now().millisecondsSinceEpoch}.jpg';
                      setState(() {
                        selectedFiles.clear();
                        selectedFileNames.clear();
                        _messageController.clear();
                        selectedFiles.add(imageBytes);
                        selectedFileNames.add(fileName);
                        _fileAbove20Mb = true;
                        _appendFileNamesToController();
                      });
                    }
                  } finally {
                    if (mounted) setState(() => _isOpeningCamera = false);
                  }
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

  // ✅ true when the server says there are more messages than our current window
  bool _shouldShowLoadEarlier() {
    final int? total = chatData?.pagination.totalMessages;
    if (total == null) return false;
    return total > _windowSize;
  }

  // ✅ "Load earlier messages" header row shown at the top of the list
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

  // ── input area ─────────────────────────────────────────────────────────────

  Widget _buildInputArea() {
    final int ptGroupId = careTeamData?.ptGroupId ?? 0;
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
        loadGroupChat(ptGroupId);
      },
      selectedId:       ptGroupId,
      attaceFile:       () =>
          setState(() => showFilePick = !showFilePick),
      onEmojiTap:       () =>
          setState(() => showEmojiPicker = !showEmojiPicker),
      onSend:           _handleSend,
      controller:       _messageController,
      onMicTap:         () {},
      onSendDefaultTap: (value) =>
          setState(() => isSendViaSms = value),
    );
  }
}