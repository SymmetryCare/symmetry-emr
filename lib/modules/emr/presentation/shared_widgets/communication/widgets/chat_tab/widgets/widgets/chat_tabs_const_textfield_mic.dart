import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:record/record.dart';
import 'dart:html' as html;
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/communication_manger/chats_manager/clinician_manager/emp_clinician_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/communication_manger/chats_manager/patients_manager/patients_file.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/communication_data/chats_data/patients_data/patients.dart';

class ChatTabsConstTextfieldMic extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onMicTap;
  final ValueChanged<String> onSendDefaultTap;
  final VoidCallback? onSendByTap;
  final VoidCallback? onSend;
  final VoidCallback? onEmojiTap;
  final VoidCallback attaceFile;
  final VoidCallback? onRefresh;
  final int? selectedId;
  final bool isGrpoupChat;
  // FIX: without this, the send button only ever looks at the text field —
  // an image/file attached with no caption can never be sent (tapping does
  // nothing, since the button falls back to a plain non-interactive Icon).
  final bool hasAttachment;

  const ChatTabsConstTextfieldMic({
    super.key,
    this.onRefresh,
    this.onEmojiTap,
    this.selectedId,
    required this.controller,
    required this.onMicTap,
    required this.onSendDefaultTap,
    this.onSendByTap,
    this.onSend,
    required this.attaceFile, required this.isGrpoupChat,
    this.hasAttachment = false,
  });

  @override
  State<ChatTabsConstTextfieldMic> createState() =>
      _ChatTabsConstTextfieldMicState();
}

class _ChatTabsConstTextfieldMicState extends State<ChatTabsConstTextfieldMic> {
  String selectedOption = "Send Default";
  late ScrollController _textScrollController;
  final TextEditingController _controller = TextEditingController();
  final AudioRecorder _recorder = AudioRecorder(); // from `record` package

  bool _isRecording = false;
  bool _canSend = false;
  bool isLoadingVoiceSend = false;
  // NEW: playback state flag so we can show pause icon when audio is playing
  bool _isPlaying = false;

    // --- NEW: recording duration tracking ---
    int _recordDuration = 0; // seconds
    Timer? _recordTimer;

    // Public helper to allow parent / audio player to toggle playback UI
    void setPlaying(bool playing) {
    if (mounted) {
      setState(() {
        _isPlaying = playing;
      });
    }
    }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _startRecordTimer() {
    _recordTimer?.cancel();
    setState(() {
      _recordDuration = 0;
    });
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _recordDuration++;
      });
    });
  }

  void _stopRecordTimer() {
    _recordTimer?.cancel();
    _recordTimer = null;
  }
  // --- END NEW ---

  Future<void> _handleMicTap() async {
    if (!_isRecording) {
      // 👉 START RECORDING
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) return;

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.opus, // good for voice
          bitRate: 128000,
          sampleRate: 16000,
        ),
        path: '',
      );

      // start duration timer
      _startRecordTimer();

      setState(() => _isRecording = true);
    } else {
      // 👉 STOP RECORDING
      final path = await _recorder.stop();

      // capture duration to send
      final int durationToSend = _recordDuration;

      // stop timer and reset UI state
      _stopRecordTimer();
      setState(() {
        _isRecording = false;
        _recordDuration = 0;
      });

      if (path != null) {
        // On web this is a blob URL. You typically:
        // 1. Read bytes
        // 2. Upload to your server
        // 3. Send chat message with that URL

        // Example placeholder:
        await widget.isGrpoupChat ? _sendGroupVoiceNote(path, durationToSend) : _sendVoiceNote(path, durationToSend);
      }
    }
  }

  Future<void> _sendGroupVoiceNote(String audioPath, int durationInSeconds) async {
    try {
      // 👉 audioPath is a blob URL on Flutter Web (e.g. blob:https://...)
      final response = await html.HttpRequest.request(
        audioPath,
        responseType: 'arraybuffer',
      );

      // Convert the ArrayBuffer (JS) to Uint8List (Dart)
      final buffer = response.response as ByteBuffer;
      final bytes = Uint8List.view(buffer);

      // Convert to base64
      final String base64Audio = base64Encode(bytes);

      // You can also decide mimeType based on encoder you used
      // With AudioEncoder.opus this is usually 'audio/ogg' or 'audio/webm'
      const mimeType = 'audio/ogg';

      // Build your attachment payload (adjust to your API format)
      final voiceAttachment = {
        "fileName": "voice_${DateTime.now().millisecondsSinceEpoch}.mpeg",
        "contentType": mimeType,
        "base64Data": base64Audio,
        "attachmentType": "VOICE_NOTE",
        "duration": durationInSeconds,
      };

      // TODO: call your API here
      print('Attachment note ::: ${voiceAttachment}');
      if (voiceAttachment.isNotEmpty) {
        setState(() {
          isLoadingVoiceSend = true;
        });
        ApiData result = await sendGroupMessage(
          context,
          isVoiceNote: true,
          ptGroupId: widget.selectedId!,
          textContent: "",
          restrictPatientFromView: false,
          sentAsSms: false, isMedia: true,
        );
        if (result.statusCode == 200 || result.statusCode == 201) {
          final attachMedia = await uploadVoicePatientChat(
            context: context,
            patientChatId: result.ptChatId!,
            documentFile: bytes,
            documentName: "voice_${DateTime.now().millisecondsSinceEpoch}.mpeg",
            duration: durationInSeconds,
          );
          if (attachMedia.statusCode == 200 || attachMedia.statusCode == 201) {
            widget.onRefresh!();
          }
        }
      }

      print('Voice note ready as Base64, length: ${base64Audio}');
    } catch (e, st) {
      print('Error converting voice note to base64: $e');
      print(st);
    } finally {
      if (mounted) {
        setState(() {
          isLoadingVoiceSend = false;
        });
      }
    }
  }
  Future<void> _sendVoiceNote(String audioPath, int durationInSeconds) async {
    try {
      // 👉 audioPath is a blob URL on Flutter Web (e.g. blob:https://...)
      final response = await html.HttpRequest.request(
        audioPath,
        responseType: 'arraybuffer',
      );

      // Convert the ArrayBuffer (JS) to Uint8List (Dart)
      final buffer = response.response as ByteBuffer;
      final bytes = Uint8List.view(buffer);

      // Convert to base64
      final String base64Audio = base64Encode(bytes);

      // You can also decide mimeType based on encoder you used
      // With AudioEncoder.opus this is usually 'audio/ogg' or 'audio/webm'
      const mimeType = 'audio/ogg';

      // Build your attachment payload (adjust to your API format)
      final voiceAttachment = {
        "fileName": "voice_${DateTime.now().millisecondsSinceEpoch}.mpeg",
        "contentType": mimeType,
        "base64Data": base64Audio,
        "attachmentType": "VOICE_NOTE",
        "duration": durationInSeconds,
      };

      // TODO: call your API here
      print('Attachment note ::: ${voiceAttachment}');
      if (voiceAttachment.isNotEmpty) {
        setState(() {
          isLoadingVoiceSend = true;
        });
        ApiData result = await sendClinicianMessage(
          isVoiceNote: true,
          isMedia: true,   // ✅ use snapshot, not selectedFiles
          context,
          empId: widget.selectedId!,
          textContent: '',
        );
        if (result.statusCode == 200 || result.statusCode == 201) {
          final attachMedia = await uploadVoiceEmpChat(
            context: context,
            otherEmpChatId: result.empChatId!,
            documentFile: bytes,
            documentName: "voice_${DateTime.now().millisecondsSinceEpoch}.mpeg",
            duration: durationInSeconds,
          );
          if (attachMedia.statusCode == 200 || attachMedia.statusCode == 201) {
            widget.onRefresh!();
          }
        }
      }

      print('Voice note ready as Base64, length: ${base64Audio}');
    } catch (e, st) {
      print('Error converting voice note to base64: $e');
      print(st);
    } finally {
      if (mounted) {
        setState(() {
          isLoadingVoiceSend = false;
        });
      }
    }
  }


  @override
  void initState() {
    super.initState();
    _textScrollController = ScrollController();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // scroll to end
    try {
      _textScrollController.jumpTo(
        _textScrollController.position.maxScrollExtent,
      );
    } catch (_) {}

    // ✅ update send button state — a message can be sent with just an
    // attachment and no caption, so this must not require text alone.
    final hasText = widget.controller.text.trim().isNotEmpty || widget.hasAttachment;
    if (hasText != _canSend) {
      setState(() {
        _canSend = hasText;
      });
    }
  }

  @override
  void didUpdateWidget(covariant ChatTabsConstTextfieldMic oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Picking/removing a file changes sendability without the text itself
    // changing, so _onTextChanged's listener alone won't catch it.
    if (oldWidget.hasAttachment != widget.hasAttachment) {
      _onTextChanged();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _textScrollController.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (!_canSend) return; // already disabled or nothing to send

    final text = widget.controller.text.trim();
    if (text.isEmpty && !widget.hasAttachment) return;

    // Disable button immediately
    setState(() {
      _canSend = false;
    });

    // Call your callbacks
    widget.onSendDefaultTap(text);
    widget.onSend?.call();

    // Clear text – user must type again for next message
    widget.controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p16,
        vertical: AppPadding.p10,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              scrollController: _textScrollController,
              controller: widget.controller,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: 'Type a message',
                hintStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade600,
                ),
                filled: true,
                fillColor: ColorManager.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: ColorManager.bordercolor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: ColorManager.bordercolor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: ColorManager.bordercolor),
                ),
                prefixIcon: InkWell(
                  onTap: widget.onEmojiTap,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: SvgPicture.asset(
                      "images/communication/chat/smiley.svg",
                      height: 24,
                      width: 24,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                prefixIconConstraints: const BoxConstraints(
                  minHeight: 24,
                  minWidth: 24,
                ),

                suffixIcon: SizedBox(
                  width: AppSize.s70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: widget.attaceFile,
                          child: Icon(Icons.attach_file,
                              color: ColorManager.grey)),
                      const SizedBox(width: AppSize.s8),
                      _canSend
                          ? InkWell(
                              splashColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: _handleSend,
                              child: Icon(Icons.send, color: ColorManager.grey))
                          : Icon(Icons.send, color: Colors.grey.shade300),
                      const SizedBox(width: AppSize.s8),
                    ],
                  ),
                ),
              ),
              onSubmitted: (val) {
                _handleSend();
              },
            ),
          ),
          const SizedBox(width: AppSize.s15),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: _handleMicTap,
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      _isRecording ? Colors.red : ColorManager.blueprime,
                child: isLoadingVoiceSend
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : _isRecording
                          ? Icon(
                              Icons.stop,
                              color: ColorManager.white,
                              size: IconSize.I30,
                            )
                          : _isPlaying
                              ? Icon(
                                  Icons.pause,
                                  color: ColorManager.white,
                                  size: IconSize.I30,
                                )
                              : SvgPicture.asset(
                                  "images/communication/mic_logo.svg",
                                  height: IconSize.I24,
                                  width: IconSize.I24,
                                ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ContainerDataListTile extends StatelessWidget {
  final bool isActive;
  final String imagePath;
  final String name;
  final String message;
  final String time;
  final VoidCallback onImageTap;
  final int unseenCount;
  const ContainerDataListTile({
    super.key,
    required this.isActive,
    required this.imagePath,
    required this.name,
    required this.message,
    required this.time,
    required this.onImageTap,
    required this.unseenCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: unseenCount != 0
              ? BoxDecoration(
                  //  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFECF7FC),
            borderRadius: BorderRadius.circular(10),)
              : null,

          // color: isActive ? const Color(0xFFE7F0FD) : Colors.transparent,
          padding: const EdgeInsets.only(
            left: 12,
            right: 12,
            top: 5,
            bottom: 5,
          ),
          child: InkWell(
            onTap: onImageTap,
            child: Row(
              children: [
                ClipOval(
                  child: (imagePath!.isEmpty || imagePath == 'imgurl')
                      ? CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.transparent,
                          child: Image.asset("images/profilepic.png"),
                        )
                      : Builder(
                          builder: (context) {
                            return Image.network(
                              imagePath,
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                              // FIX: gaplessPlayback keeps showing the last frame while a
                              // new one loads. A loadingBuilder that unconditionally swaps
                              // in a spinner (ignoring `child`, the already-loaded frame)
                              // defeats that and reads as blinking on every poll — so this
                              // no longer overrides `child` with a spinner mid-poll.
                              gaplessPlayback: true,
                              errorBuilder: (context, error, stackTrace) {
                                //   print("❌ Failed to load image: $error"); // Optional: Print load failure
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  // backgroundColor: Colors.transparent,
                                  child: Image.asset(
                                    "images/profilepic.png",
                                    height: 30,
                                    width: 30,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      time,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    const SizedBox(height: 2),
                    unseenCount == 0
                        ? const SizedBox(height: 6)
                        : whatsappUnreadBadge(unseenCount)
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        )
      ],
    );
  }

  Widget whatsappUnreadBadge(int unseenCount) {
    if (unseenCount == 0) return const SizedBox();

    String display = unseenCount > 99 ? "99+" : unseenCount.toString();

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: unseenCount > 9 ? 3 : 5.5, vertical: 2),
      decoration: BoxDecoration(
        color: ColorManager.blueprime,
        borderRadius: BorderRadius.circular(15),
      ),
      constraints: const BoxConstraints(
        minWidth: 10,
        minHeight: 10,
      ),
      child: Center(
        child: Text(
          display,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class ContainerDataListTilepatient extends StatelessWidget {
  final bool isActive;
  final String imagePath;
  final String name;
  final String message; // 🔹 last message text
  final String time;
  final VoidCallback onImageTap;
  final int unseenCount;
  final List<GroupMember> members;

  const ContainerDataListTilepatient({
    super.key,
    required this.isActive,
    required this.imagePath,
    required this.name,
    required this.message,
    required this.time,
    required this.onImageTap,
    required this.unseenCount,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    final firstThree = members.take(3).toList();
    final remaining = members.length > 3 ? members.length - 3 : 0;

    // 🔹 First letter for GROUP name
    final String groupInitial =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    // 🔹 Derive "last message sender" from last member in the list
    String? lastSenderName;
    if (members.isNotEmpty) {
      final m = members.last;
      lastSenderName = '${m.firstName} ${m.lastName}'.trim();
      if (lastSenderName.isEmpty) {
        lastSenderName = null;
      }
    }

    final bool hasLastMessage =
        message.trim().isNotEmpty && lastSenderName != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: unseenCount != 0  ? const Color(0xFFECF7FC) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: onImageTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------------------------------------------
                // TOP ROW (GROUP IMAGE + NAME + TIME + UNREAD)
                // ---------------------------------------------------
                Row(
                  children: [
                    ClipOval(
                      child: imagePath.isEmpty
                          ? Image.asset(
                        "images/profilepic.png",
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      )
                          : Image.network(
                        imagePath,
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        errorBuilder: (_, __, ___) => Image.asset(
                          "images/profilepic.png",
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),

                          //🔸 message (groupDescription) removed from here
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          time,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        unseenCount > 0
                            ? whatsappUnreadBadge(unseenCount)
                            : const SizedBox(height: 12),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ---------------------------------------------------
                // MEMBER LIST (Up to 3 members)
                // ---------------------------------------------------
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...firstThree.map((m) {
                      final fullName = '${m.firstName} ${m.lastName}'.trim();

                      return Padding(
                        key: ValueKey(m.memberId),
                        padding: const EdgeInsets.only(bottom: 4, left: 52),
                        child: Row(
                          children: [
                            ClipOval(
                              child: m.imgUrl.isEmpty
                                  ? Image.asset(
                                "images/profilepic.png",
                                height: 24,
                                width: 24,
                                fit: BoxFit.cover,
                              )
                                  : Image.network(
                                m.imgUrl,
                                height: 24,
                                width: 24,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                                errorBuilder: (_, __, ___) =>
                                    Image.asset(
                                      "images/profilepic.png",
                                      height: 24,
                                      width: 24,
                                      fit: BoxFit.cover,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              fullName,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (remaining > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 52, top: 4),
                        child: Text(
                          "+ $remaining more",
                          style: const TextStyle(
                            fontSize: 11,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 52, top: 4),
                      child: Text(
                        message,
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget whatsappUnreadBadge(int unseenCount) {
    if (unseenCount == 0) return const SizedBox();

    final display = unseenCount > 99 ? "99+" : unseenCount.toString();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: unseenCount > 9 ? 3 : 5.5,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: ColorManager.blueprime, // or Colors.blue
        borderRadius: BorderRadius.circular(15),
      ),
      constraints: const BoxConstraints(
        minWidth: 10,
        minHeight: 10,
      ),
      child: Center(
        child: Text(
          display,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
