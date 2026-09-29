import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/const_string.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/calling/calling_Manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/communication_manger/chats_manager/clinician_manager/emp_clinician_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/download_doc_get_api/download_doc_get_api.dart';
// removed in extraction: import '../../../../app/services/api/managers/sm_module_manager/sm_live_view_manager/map_clinical_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/user_appbar_manager.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/communication_data/chats_data/clinitian_data/clinical_empChat_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/user/user_appbar.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widget_for_tab_mobile/communication_tablet/communication_tab_home_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/call_screens/new_videocall_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/camera_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/chat_file_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/chat_tab/widgets/widgets/voice_note_bubble.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/onboarding/download_doc_const.dart';

class ChatBotContainer extends StatefulWidget {
  final VoidCallback onClose;
  final int receiverEmpId;
  final String receiverName;
  final String receiverImageUrl;
  final String receiverAbbreviation;
  final String receiverColor;

  const ChatBotContainer({
    super.key,
    required this.onClose,
    required this.receiverEmpId,
    required this.receiverName,
    required this.receiverImageUrl,
    required this.receiverAbbreviation,
    required this.receiverColor,
  });

  @override
  State<ChatBotContainer> createState() => _ChatBotContainerState();
}

class _ChatBotContainerState extends State<ChatBotContainer> {
  final TextEditingController _textController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  // Maximum file size = 20 MB
  static const int _maxFileSizeBytes = 20 * 1024 * 1024;

  ChatDepartmentGroupCommunicationData? chatData;

  List<Message> _messages = [];

  UserAppBar? _loggedInUser;

  int? _myEmployeeId;

  bool _isLoading = false;

  // Unread messages
  int _unreadCount = 0;

  bool _autoScroll = true;

  // File preparation state
  bool _isPreparingFile = false;

  // Sending state
  bool _isSending = false;

  // Emoji + file picker
  bool showEmojiPicker = false;
  bool showFilePick = false;

  // Selected files
  List<Uint8List> selectedFiles = [];
  List<String> selectedFileNames = [];

  // Pagination
  static const int _pageSize = 30;

  int _windowSize = _pageSize;

  bool _isLoadingOlder = false;

  bool _hasMoreEarlier = true;

  @override
  void initState() {
    super.initState();

    _initData();

    _scrollController.addListener(() {
      final bool isAtBottom = _scrollController.offset <= 20;

      if (isAtBottom && _unreadCount > 0) {
        setState(() {
          _unreadCount = 0;
          _autoScroll = true;
        });
      } else if (!isAtBottom) {
        _autoScroll = false;
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  // ============================================================
  // INIT DATA
  // ============================================================

  Future<void> _initData({
    bool showLoader = true,
  }) async {
    if (widget.receiverEmpId == 0) {
      debugPrint(
        "No receiver selected — skipping chat load",
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _messages = [];
        });
      }

      return;
    }

    if (mounted && showLoader) {
      setState(() {
        _isLoading = true;
        _messages = [];
        _unreadCount = 0;
        _autoScroll = true;

        _windowSize = _pageSize;

        _hasMoreEarlier = true;
      });
    }

    try {
      // Logged in user
      final user = await getAppBarDetails(context);

      _loggedInUser = user;

      _myEmployeeId = user.employeeId;

      // Load chat
      final result = await chatClinicalGroupCommunication(
        context,
        widget.receiverEmpId,
        1,
        _windowSize,
      );

      if (result != null) {
        chatData = result;

        final newMessages = result.messages.reversed.toList();

        if (mounted) {
          setState(() {
            _messages = newMessages;

            if (newMessages.length < _windowSize) {
              _hasMoreEarlier = false;
            }
          });
        }
      }
    } catch (e) {
      debugPrint(
        'Error in _initData: $e',
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      _scrollToBottom(jump: true);
    }
  }

  // ============================================================
  // SCROLL
  // ============================================================

  void _scrollToBottom({
    bool jump = false,
  }) {
    if (!_scrollController.hasClients) {
      return;
    }

    if (jump) {
      _scrollController.jumpTo(0.0);
    } else {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  // ============================================================
  // INCOMING MESSAGE
  // ============================================================

  void addIncomingMessage(Message msg) {
    final bool isSelf =
        _myEmployeeId != null && msg.senderEmpId == _myEmployeeId;

    setState(() {
      _messages.insert(0, msg);

      if (!isSelf && !_autoScroll) {
        _unreadCount++;
      }
    });

    if (_autoScroll) {
      _scrollToBottom();
    }
  }

  // ============================================================
  // LOAD EARLIER
  // ============================================================

  Future<void> _loadEarlierMessages() async {
    if (_isLoadingOlder || !_hasMoreEarlier) {
      return;
    }

    if (widget.receiverEmpId == 0) {
      return;
    }

    setState(() {
      _isLoadingOlder = true;
    });

    final double keepOffset =
        _scrollController.hasClients ? _scrollController.offset : 0;

    final int oldCount = _messages.length;

    _windowSize += _pageSize;

    try {
      final result = await chatClinicalGroupCommunication(
        context,
        widget.receiverEmpId,
        1,
        _windowSize,
      );

      if (result != null) {
        final newMessages = result.messages.reversed.toList();

        if (mounted) {
          setState(() {
            _messages = newMessages;

            if (newMessages.length < _windowSize ||
                newMessages.length == oldCount) {
              _hasMoreEarlier = false;
            }
          });
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scrollController.hasClients) {
            return;
          }

          _scrollController.jumpTo(
            keepOffset.clamp(
              0,
              _scrollController.position.maxScrollExtent,
            ),
          );
        });
      }
    } catch (e) {
      debugPrint(
        "Load earlier error: $e",
      );

      _windowSize -= _pageSize;
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOlder = false;
        });
      }
    }
  }

  bool _shouldShowLoadEarlier() {
    return _hasMoreEarlier && _messages.isNotEmpty;
  }

  Widget _buildLoadEarlierRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Center(
        child: _isLoadingOlder
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : TextButton(
                onPressed: _loadEarlierMessages,
                child: Text(
                  'Load earlier messages',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.blueprime,
                  ),
                ),
              ),
      ),
    );
  }

  // ============================================================
  // FILE HELPERS
  // ============================================================

  bool _isImageFile(String name) {
    final lower = name.toLowerCase();

    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }

  bool _isImageUrl(String url) {
    final path = (Uri.tryParse(url)?.path ?? url).toLowerCase();

    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp');
  }

  bool _isVoiceNoteUrl(String url) {
    final path = (Uri.tryParse(url)?.path ?? url).toLowerCase();

    return path.endsWith('.mpeg') ||
        path.endsWith('.m4a') ||
        path.endsWith('.mp3');
  }

  bool _isPdfUrl(String url) {
    final path = (Uri.tryParse(url)?.path ?? url).toLowerCase();

    return path.endsWith('.pdf');
  }

  String _getFileNameFromUrl(
    String url,
  ) {
    try {
      final uri = Uri.tryParse(url);

      String name;

      if (uri != null) {
        name = uri.pathSegments.isNotEmpty
            ? uri.pathSegments.last
            : 'document.pdf';
      } else {
        name = url.split('/').last.split('?').first;
      }

      return Uri.decodeComponent(name);
    } catch (_) {
      return 'document.pdf';
    }
  }

  void _appendFileNamesToController() {
    final existing = _textController.text.trim();

    final fileText = selectedFileNames.join(', ');

    _textController.text = existing.isEmpty ? fileText : '$existing, $fileText';

    _textController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: _textController.text.length,
      ),
    );
  }

  // ============================================================
  // SEND
  // ============================================================

  Future<void> _handleSend() async {
    if (widget.receiverEmpId == 0) {
      debugPrint(
        "No receiver selected!",
      );
      return;
    }

    final String text = _textController.text.trim();

    if (text.isEmpty && selectedFiles.isEmpty) {
      debugPrint(
        "Empty message is not allowed",
      );
      return;
    }

    if (_isSending || _isPreparingFile) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    final List<Uint8List> filesToSend = selectedFiles
        .map(
          (b) => Uint8List.fromList(b),
    )
        .toList();

    final List<String> namesToSend = List<String>.from(
      selectedFileNames,
    );

    final bool hasRealText = text.isNotEmpty;

    try {
      // ========================================================
      // MEDIA
      // ========================================================

      if (filesToSend.isNotEmpty) {
        // Create chat record
        final ApiData result = await sendClinicianMessage(
          context,
          empId: widget.receiverEmpId,
          textContent: hasRealText ? text : "",
          isMedia: true,
          isVoiceNote: false,
        );

        if (!result.success || result.empChatId == null) {
          debugPrint(
            "sendClinicianMessage failed: "
                "${result.message}",
          );

          if (mounted) {
            showDialog(
              context: context,
              builder: (_) => AddErrorPopup(
                message: result.message,
              ),
            );
          }

          return;
        }

        // Upload every selected file
        for (int i = 0; i < filesToSend.length; i++) {
          final ApiData attachMedia = await uploadMediaEmpChat(
            context: context,
            employeeChatId: result.empChatId!,
            documentFiles: filesToSend[i],
            documentNames: namesToSend[i],
          );

          if (attachMedia.statusCode == 200 || attachMedia.statusCode == 201) {
            debugPrint(
              "Media uploaded successfully: "
                  "${namesToSend[i]}",
            );
          } else {
            debugPrint(
              "Media upload failed: "
                  "${namesToSend[i]} - "
                  "${attachMedia.message}",
            );

            if (mounted) {
              showDialog(
                context: context,
                builder: (_) => AddErrorPopup(
                  message: attachMedia.message,
                ),
              );
            }
          }
        }

        await _initData(
          showLoader: false,
        );
      }

      // ========================================================
      // TEXT ONLY
      // ========================================================

      else {
        final ApiData result = await sendClinicianMessage(
          context,
          empId: widget.receiverEmpId,
          textContent: text,
          isMedia: false,
          isVoiceNote: false,
        );

        if (!result.success) {
          debugPrint(
            "Failed to send message: "
                "${result.message}",
          );

          if (mounted) {
            showDialog(
              context: context,
              builder: (_) => AddErrorPopup(
                message: result.message,
              ),
            );
          }

          return;
        }

        await _initData(
          showLoader: false,
        );
      }
    } catch (e, st) {
      debugPrint(
        "_handleSend error: $e\n$st",
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AddErrorPopup(
            message: AppString.somethingWentWrong,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          selectedFiles.clear();
          selectedFileNames.clear();

          _textController.clear();

          showEmojiPicker = false;
          showFilePick = false;

          _isSending = false;
        });
      }
    }
  }

  // ============================================================
  // MIC
  // ============================================================

  Future<void> _onMicTap() async {
    debugPrint(
      "Mic button clicked",
    );
  }

  // ============================================================
  // TIME
  // ============================================================

  String _formatTimeFromString(
    String raw,
  ) {
    if (raw.isEmpty) {
      return '';
    }

    try {
      final dt = DateTime.parse(raw).toLocal();

      return DateFormat(
        'hh:mm a',
      ).format(dt);
    } catch (_) {
      return '';
    }
  }

  // ============================================================
  // PHONE
  // ============================================================

  Future<void> _makePhoneCall(
    String phoneNumber,
  ) async {
    final Uri telUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      throw Exception(
        'Could not launch $phoneNumber',
      );
    }
  }

  Future<void> launchPhoneDialer(
    String contactNumber,
  ) async {
    final Uri phoneUri = Uri(
      scheme: "tel",
      path: contactNumber,
    );

    try {
      if (await canLaunch(
        phoneUri.toString(),
      )) {
        await launch(
          phoneUri.toString(),
        );
      }
    } catch (error) {
      throw ("Cannot dial");
    }
  }

  // ============================================================
  // COLOR
  // ============================================================

  Color _parseHexColor(
    String? hexColor,
  ) {
    if (hexColor == null || hexColor.trim().isEmpty) {
      return const Color(
        0xFF527FB9,
      );
    }

    var clean = hexColor.trim();

    if (clean.startsWith('#')) {
      clean = clean.substring(1);
    }

    if (clean.length != 6) {
      return const Color(
        0xFF527FB9,
      );
    }

    return Color(
      int.parse(
        '0xFF$clean',
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[300],
                          child: widget.receiverImageUrl.isEmpty
                              ? Text(
                                  widget.receiverName.isNotEmpty
                                      ? widget.receiverName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : ClipOval(
                                  child: Image.network(
                                    widget.receiverImageUrl,
                                    fit: BoxFit.cover,
                                    width: 40,
                                    height: 40,
                                    gaplessPlayback: true,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(
                        width: 7,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.receiverName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _parseHexColor(
                                widget.receiverColor,
                              ),
                              borderRadius: BorderRadius.circular(
                                4,
                              ),
                            ),
                            child: Text(
                              widget.receiverAbbreviation.isEmpty
                                  ? 'NA'
                                  : widget.receiverAbbreviation,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // ==================================================
                  // CALL BUTTONS
                  // ==================================================

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        child: Image.asset(
                          "images/communication/call/video_call.png",
                          height: 20,
                          width: 20,
                        ),
                        onTap: () async {
                          if (chatData == null) {
                            return;
                          }

                          final callResponse = await addCallInitiate(
                            context,
                            isVideo: true,
                            participantUserIds: [chatData!.empInfoData.userId],
                            callType: 'ONE_TO_ONE',
                          );

                          if (callResponse.statusCode == 201 ||
                              callResponse.statusCode == 200) {
                            final data =
                                callResponse.data as Map<String, dynamic>;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoCallAgoraScreen(
                                  isVideoOn: true,
                                  isAudioOn: true,
                                  channelName: data['channelName'] ?? '',
                                  userImage: data['contactImage'] ?? '',
                                  userName: data['contactName'] ?? '',
                                  token: data['token'] ?? '',
                                  callId: data['callId'] ?? '',
                                  receiverImages:
                                      (data['receiverImages'] as List<dynamic>?)
                                              ?.map(
                                                (e) => e.toString(),
                                              )
                                              .toList() ??
                                          [],
                                  receiverNames:
                                      (data['receiverNames'] as List<dynamic>?)
                                              ?.map(
                                                (e) => e.toString(),
                                              )
                                              .toList() ??
                                          [],
                                  receiverIds:
                                      (data['receiverUserId'] as List<dynamic>?)
                                              ?.map(
                                                (e) =>
                                                    int.tryParse(
                                                      e.toString(),
                                                    ) ??
                                                    0,
                                              )
                                              .toList() ??
                                          [],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        child: Image.asset(
                          "images/communication/call/audio_call.png",
                          height: 20,
                          width: 20,
                        ),
                        onTap: () async {
                          if (chatData == null) {
                            return;
                          }

                          final callResponse = await addCallInitiate(
                            context,
                            isVideo: false,
                            participantUserIds: [chatData!.empInfoData.userId],
                            callType: 'ONE_TO_ONE',
                          );

                          if (callResponse.statusCode == 201 ||
                              callResponse.statusCode == 200) {
                            final data =
                                callResponse.data as Map<String, dynamic>;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoCallAgoraScreen(
                                  isVideoOn: false,
                                  isAudioOn: true,
                                  channelName: data['channelName'] ?? '',
                                  userImage: data['contactImage'] ?? '',
                                  userName: data['contactName'] ?? '',
                                  token: data['token'] ?? '',
                                  callId: data['callId'] ?? '',
                                  receiverImages:
                                      (data['receiverImages'] as List<dynamic>?)
                                              ?.map(
                                                (e) => e.toString(),
                                              )
                                              .toList() ??
                                          [],
                                  receiverNames:
                                      (data['receiverNames'] as List<dynamic>?)
                                              ?.map(
                                                (e) => e.toString(),
                                              )
                                              .toList() ??
                                          [],
                                  receiverIds:
                                      (data['receiverUserId'] as List<dynamic>?)
                                              ?.map(
                                                (e) =>
                                                    int.tryParse(
                                                      e.toString(),
                                                    ) ??
                                                    0,
                                              )
                                              .toList() ??
                                          [],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        icon: const Icon(
                          Icons.close,
                        ),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ==================================================
            // MESSAGE LIST
            // ==================================================

            Expanded(
              child: _isLoading || _myEmployeeId == null
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          scrollbars: false,
                        ),
                        child: ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          itemCount: _messages.length +
                              (_shouldShowLoadEarlier() ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Load earlier
                            if (_shouldShowLoadEarlier() &&
                                index == _messages.length) {
                              return _buildLoadEarlierRow();
                            }

                            final msg = _messages[index];

                            final bool isSelf =
                                msg.senderEmpId == _myEmployeeId;

                            final time = _formatTimeFromString(
                              msg.dateCreated,
                            );

                            // ------------------------------------------
                            // ATTACHMENTS
                            // ------------------------------------------

                            final List<String> imageUrls =
                                msg.attachedMultimediaUrl
                                    .where(
                                      _isImageUrl,
                                    )
                                    .toList();

                            final List<String> pdfUrls =
                                msg.attachedMultimediaUrl
                                    .where(
                                      _isPdfUrl,
                                    )
                                    .toList();

                            final voiceNoteUrl = (msg.voiceNoteUrl ?? [])
                                .where(
                                  _isVoiceNoteUrl,
                                )
                                .toList();

                            return Container(
                              alignment: isSelf
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Column(
                                crossAxisAlignment: isSelf
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  // ==================================================
                                  // MESSAGE BUBBLE
                                  // ==================================================

                                  Container(
                                    decoration: BoxDecoration(
                                      color: isSelf
                                          ? ColorManager.blueprime
                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(
                                      10,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: isSelf
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        // ==================================================
                                        // IMAGES
                                        // ==================================================

                                        ...imageUrls.map(
                                          (url) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 4,
                                            ),
                                            child: InkWell(
                                              onTap: () async {
                                                await openImageInNewTab(
                                                  context: context,
                                                  fileUrl: url,
                                                  documentName:
                                                      "commuchat_image_${_getFileNameFromUrl(url)}",
                                                  apiPath:
                                                      DownloadDocumentRepository
                                                          .getPatientGroupChatImageByFileName(),
                                                );
                                              },
                                              child: Container(
                                                height: 200,
                                                width: 250,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10,
                                                  ),
                                                ),
                                                child: Image.network(
                                                  url,
                                                  fit: BoxFit.contain,
                                                  gaplessPlayback: true,
                                                  errorBuilder: (_, err, __) {
                                                    debugPrint(
                                                      "IMAGE LOAD ERROR: $url → $err",
                                                    );

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

                                        // ==================================================
                                        // SMALL PDF ATTACHMENT
                                        // ==================================================

                                        ...pdfUrls.map(
                                          (url) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 4,
                                            ),
                                            child: InkWell(
                                              onTap: () async {
                                                await downloadFile(
                                                  context: context,
                                                  fileUrl: url,
                                                  documentName:
                                                      "commuchat_pdf_${_getFileNameFromUrl(url)}",
                                                  apiPath:
                                                      DownloadDocumentRepository
                                                          .getPatientGroupChatImageByFileName(),
                                                );
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(
                                                9,
                                              ),
                                              child: Container(
                                                width: 235,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 9,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isSelf
                                                      ? Colors.white
                                                          .withOpacity(
                                                          0.12,
                                                        )
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    9,
                                                  ),
                                                  border: Border.all(
                                                    color: isSelf
                                                        ? Colors.white
                                                            .withOpacity(
                                                            0.25,
                                                          )
                                                        : Colors.grey.shade200,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    // PDF ICON
                                                    Container(
                                                      width: 34,
                                                      height: 34,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.red.shade50,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          7,
                                                        ),
                                                      ),
                                                      child: Icon(
                                                        Icons.picture_as_pdf,
                                                        color:
                                                            Colors.red.shade600,
                                                        size: 21,
                                                      ),
                                                    ),

                                                    const SizedBox(
                                                      width: 8,
                                                    ),

                                                    // PDF NAME
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            'PDF Document',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: isSelf
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black87,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 2,
                                                          ),
                                                          Text(
                                                            _getFileNameFromUrl(
                                                              url,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color: isSelf
                                                                  ? Colors
                                                                      .white70
                                                                  : Colors.grey
                                                                      .shade600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    const SizedBox(
                                                      width: 6,
                                                    ),

                                                    // DOWNLOAD
                                                    Icon(
                                                      Icons.download_outlined,
                                                      size: 18,
                                                      color: isSelf
                                                          ? Colors.white
                                                          : ColorManager
                                                              .blueprime,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // ==================================================
                                        // VOICE NOTE
                                        // ==================================================

                                        ...voiceNoteUrl.map(
                                          (url) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 4,
                                            ),
                                            child: VoiceNoteBubble(
                                              url: url,
                                              isMe: isSelf,
                                            ),
                                          ),
                                        ),

                                        // ==================================================
                                        // TEXT
                                        // ==================================================

                                        if (msg.textContent.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              msg.textContent,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isSelf
                                                    ? Colors.white
                                                    : ColorManager
                                                        .commuchatTextColor,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  // TIME
                                  Text(
                                    time,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ),

            // ==================================================
            // INPUT
            // ==================================================

            _buildInputArea(),
          ],
        ),

        // ======================================================
        // UNREAD BADGE
        // ======================================================

        if (_unreadCount > 0)
          Positioned(
            right: 16,
            bottom: showEmojiPicker ? 270 : 70,
            child: InkWell(
              onTap: () {
                _scrollToBottom();

                setState(() {
                  _unreadCount = 0;
                  _autoScroll = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: ColorManager.blueprime,
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      offset: const Offset(
                        0,
                        2,
                      ),
                      color: Colors.black.withOpacity(
                        0.2,
                      ),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_downward,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
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

        // ======================================================
        // FILE PICKER OVERLAY
        // ======================================================

        if (showFilePick)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                setState(() {
                  showFilePick = false;
                });
              },
              child: const SizedBox(),
            ),
          ),

        if (showFilePick)
          Positioned(
            right: 70,
            bottom: 60,
            child: ConstFilepickerAndMediaPicker(
              // ==================================================
              // PDF PICKER
              // ==================================================

              pickDocuments: () async {
                setState(() {
                  showFilePick = false;
                  _isPreparingFile = true;
                });

                try {
                  final FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                    allowMultiple: true,
                    withData: true,
                  );

                  if (result != null && result.files.isNotEmpty) {
                    final List<Uint8List> newBytes = [];

                    final List<String> newNames = [];

                    bool hasLargeFile = false;

                    for (final f in result.files) {
                      if (f.size > _maxFileSizeBytes) {
                        hasLargeFile = true;
                      }

                      if (f.bytes != null) {
                        newBytes.add(
                          Uint8List.fromList(
                            f.bytes!,
                          ),
                        );

                        newNames.add(
                          f.name,
                        );
                      }
                    }

                    if (hasLargeFile) {
                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (_) => const AddErrorPopup(
                            message:
                                'File is too large! Maximum size is 20 MB.',
                          ),
                        );
                      }

                      return;
                    }

                    if (mounted) {
                      setState(() {
                        selectedFiles.addAll(
                          newBytes,
                        );

                        selectedFileNames.addAll(
                          newNames,
                        );

                        _appendFileNamesToController();
                      });
                    }
                  }
                } catch (e) {
                  debugPrint(
                    "PDF picker error: $e",
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      _isPreparingFile = false;
                    });
                  }
                }
              },

              // ==================================================
              // CAMERA
              // ==================================================

              pickCamera: () async {
                // FIX: guard against re-entrant taps — without this, a second
                // tap on "Camera" before the first Navigator.push completes
                // could fire a second navigation, pushing a second
                // WebCameraScreen on top of/racing the first, which looks
                // like the app jumping to another screen before the camera
                // opens.
                if (_isPreparingFile) return;
                setState(() {
                  showFilePick = false;
                  _isPreparingFile = true;
                });

                try {
                  List<CameraDescription> camList = cameras ?? [];

                  if (camList.isEmpty) {
                    try {
                      camList = await availableCameras();
                    } catch (e) {
                      debugPrint(
                        "availableCameras failed: $e",
                      );
                    }
                  }

                  if (camList.isEmpty) {
                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (_) => const AddErrorPopup(
                          message: 'No camera found on this device.',
                        ),
                      );
                    }

                    return;
                  }

                  final picture = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WebCameraScreen(
                        cameras: camList,
                      ),
                    ),
                  );

                  if (picture != null) {
                    final Uint8List imageBytes = Uint8List.fromList(
                      await picture.readAsBytes(),
                    );

                    final bool isAbove20MB =
                        imageBytes.length > _maxFileSizeBytes;

                    if (isAbove20MB) {
                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (_) => const AddErrorPopup(
                            message:
                                'Image is too large! Maximum size is 20 MB.',
                          ),
                        );
                      }

                      return;
                    }

                    final String fileName =
                        "captured_${DateTime.now().millisecondsSinceEpoch}.jpg";

                    if (mounted) {
                      setState(() {
                        selectedFiles.add(
                          imageBytes,
                        );

                        selectedFileNames.add(
                          fileName,
                        );

                        _appendFileNamesToController();
                      });
                    }
                  }
                } catch (e) {
                  debugPrint(
                    "Camera picker error: $e",
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      _isPreparingFile = false;
                    });
                  }
                }
              },

              // ==================================================
              // GALLERY
              // ==================================================

              pickGallery: () async {
                setState(() {
                  showFilePick = false;
                  _isPreparingFile = true;
                });

                try {
                  final FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: [
                      'jpg',
                      'jpeg',
                      'png',
                      'webp',
                    ],
                    allowMultiple: true,
                    withData: true,
                  );

                  if (result != null && result.files.isNotEmpty) {
                    final List<Uint8List> newBytes = [];

                    final List<String> newNames = [];

                    bool hasLargeFile = false;

                    for (final f in result.files) {
                      if (f.size > _maxFileSizeBytes) {
                        hasLargeFile = true;
                      }

                      if (f.bytes != null) {
                        newBytes.add(
                          Uint8List.fromList(
                            f.bytes!,
                          ),
                        );

                        newNames.add(
                          f.name,
                        );
                      }
                    }

                    if (hasLargeFile) {
                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (_) => const AddErrorPopup(
                            message:
                                'Image is too large! Maximum size is 20 MB.',
                          ),
                        );
                      }

                      return;
                    }

                    if (mounted) {
                      setState(() {
                        selectedFiles.addAll(
                          newBytes,
                        );

                        selectedFileNames.addAll(
                          newNames,
                        );

                        _appendFileNamesToController();
                      });
                    }
                  }
                } catch (e) {
                  debugPrint(
                    "Gallery picker error: $e",
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      _isPreparingFile = false;
                    });
                  }
                }
              },
            ),
          ),

        // ======================================================
        // EMOJI OVERLAY
        // ======================================================

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
            bottom: 60,
            child: SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 130,
                  left: 10,
                ),
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    _textController.text += emoji.emoji;

                    _textController.selection = TextSelection.fromPosition(
                      TextPosition(
                        offset: _textController.text.length,
                      ),
                    );
                  },
                  config: Config(
                    height: 200,
                    bottomActionBarConfig: BottomActionBarConfig(
                      backgroundColor: ColorManager.blueprime,
                      buttonColor: ColorManager.blueprime,
                      showBackspaceButton: false,
                    ),
                    emojiViewConfig: const EmojiViewConfig(
                      emojiSizeMax: 16,
                    ),
                    categoryViewConfig: const CategoryViewConfig(
                      iconColor: Colors.grey,
                      iconColorSelected: Colors.blue,
                    ),
                    skinToneConfig: const SkinToneConfig(),
                    viewOrderConfig: const ViewOrderConfig(
                      top: EmojiPickerItem.categoryBar,
                      middle: EmojiPickerItem.emojiView,
                      bottom: EmojiPickerItem.searchBar,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // INPUT AREA
  // ============================================================

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      color: const Color(0xFFF7F8FA),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              cursorColor: Colors.black,
              onSubmitted: (_) => _handleSend(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,

                // ==================================================
                // EMOJI
                // ==================================================

                prefixIcon: IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  icon: const Icon(
                    Icons.insert_emoticon_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      showEmojiPicker = !showEmojiPicker;

                      if (showEmojiPicker) {
                        showFilePick = false;
                      }
                    });
                  },
                ),

                // ==================================================
                // ATTACHMENT + SEND
                // ==================================================

                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: -0.785398,
                      child: IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onPressed: () {
                          setState(() {
                            showFilePick = !showFilePick;

                            if (showFilePick) {
                              showEmojiPicker = false;
                            }
                          });
                        },
                        icon: const Icon(
                          Icons.attachment_outlined,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onPressed:
                          (_isSending || _isPreparingFile) ? null : _handleSend,
                      icon: _isSending
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ColorManager.blueprime,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.grey,
                            ),
                    ),
                  ],
                ),

                hintText: "Type a message...",

                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          // ==================================================
          // MIC
          // ==================================================

          GestureDetector(
            onTap: _onMicTap,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.mic_none_outlined,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
