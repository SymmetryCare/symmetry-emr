import 'dart:async';
import 'dart:html' as html;

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';

import 'package:symmetry_emr/modules/emr/data/api/managers/calling/calling_Manager.dart';

String get appId => dotenv.env['AGORA_APP_ID'] ?? "a7cde21575824bd5aa83fc2d54750430";

class VideoCallAgoraScreen extends StatefulWidget {
  final bool isVideoOn;
  final bool isAudioOn;
  final String? userName;
  final String channelName;
  final String token;
  final int? callId;
  final String? status;
  final String? userImage;
  final bool? isBusyCall;
  final String? groupName;
  final String? groupImage;
  final String? receiverName;
  final String? receiverImage;
  final List<String>? receiverNames;
  final List<String>? receiverImages;
  final List<dynamic>? receiverIds;
  final dynamic localUserId;

  const VideoCallAgoraScreen({
    Key? key,
    this.groupImage,
    this.groupName,
    this.userImage,
    this.isBusyCall = false,
    required this.isVideoOn,
    required this.isAudioOn,
    required this.channelName,
    required this.token,
    this.callId,
    this.status,
    this.userName,
    this.receiverImage,
    this.receiverName,
    this.receiverNames,
    this.receiverImages,
    this.receiverIds,
    this.localUserId,
  }) : super(key: key);

  @override
  State<VideoCallAgoraScreen> createState() => _VideoCallAgoraScreenState();
}

class _VideoCallAgoraScreenState extends State<VideoCallAgoraScreen> {
  final List<int> _remoteUids = [];
  bool _localUserJoined = false;
  bool _muted = false;
  late RtcEngine _engine;

  final Map<int, bool> remoteVideoOff = {};
  final Map<int, bool> remoteAudioMuted = {};
  final Map<int, bool> remoteSpeaking = {};
  final Map<int, bool> remoteHasVideoFrame = {};
  final Map<int, Timer> _remoteFrameFallbackTimers = {};

  bool _localSpeaking = false;
  bool _isLocalVideoOff = true;

  Timer? _waitingTimer;
  int _waitingSeconds = 0;
  final int maxWaitSeconds = 120;

  Timer? _callTimer;
  int _callSeconds = 0;
  bool _callStarted = false;
  bool _engineInitialized = false;

  final Map<int, String> uidToName = {};
  final Map<int, String> uidToImage = {};
  final Map<int, String> agoraUidToBackendId = {};
  final Map<String, int> backendIdToAgoraUid = {};

  List<String> get _receiverIdsAsString =>
      (widget.receiverIds ?? []).map((e) => e.toString()).toList();

  VideoViewController? _localVideoController;

  @override
  void initState() {
    super.initState();
    _isLocalVideoOff = !widget.isVideoOn;
    initAgora();
    startWaitTimer();
  }

  void startWaitTimer() {
    _waitingTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remoteUids.isNotEmpty) {
        timer.cancel();
        return;
      }
      if (!mounted) return;
      setState(() => _waitingSeconds++);
      if (_waitingSeconds >= maxWaitSeconds) {
        timer.cancel();
        await handleCallRejected({"callId": widget.callId});
        if (mounted) Navigator.pop(context);
      }
    });
  }

  void _startCallTimer() {
    if (_callStarted) return;
    _callStarted = true;
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _callSeconds++);
    });
  }

  void _stopCallTimer() {
    _callTimer?.cancel();
    _callTimer = null;
  }

  String get _formattedCallDuration {
    final int hours = _callSeconds ~/ 3600;
    final int minutes = (_callSeconds % 3600) ~/ 60;
    final int seconds = _callSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }

  List<String> _getRemoteNames() {
    if (widget.receiverNames != null && widget.receiverNames!.isNotEmpty) {
      return widget.receiverNames!;
    }
    return [widget.receiverName ?? "Participant"];
  }

  List<String> _getRemoteImages() {
    if (widget.receiverNames != null && widget.receiverNames!.isNotEmpty) {
      return widget.receiverImages ??
          List.generate(widget.receiverNames!.length, (i) => "");
    }
    return [widget.receiverImage ?? ""];
  }

  void _resolveIdentityForAgoraUid({required int agoraUid, String? backendUserId}) {
    final names = _getRemoteNames();
    final images = _getRemoteImages();
    final ids = _receiverIdsAsString;

    if (backendUserId != null && ids.isNotEmpty) {
      final idx = ids.indexOf(backendUserId);
      if (idx >= 0) {
        uidToName[agoraUid] = (idx < names.length) ? names[idx] : "User $backendUserId";
        uidToImage[agoraUid] = (idx < images.length) ? images[idx] : "";
        return;
      }
    }
    if (names.length == 1) {
      uidToName[agoraUid] = names.first;
      uidToImage[agoraUid] = images.first;
      return;
    }
    if (!uidToName.containsKey(agoraUid) || !uidToImage.containsKey(agoraUid)) {
      final int idx = uidToName.length;
      uidToName[agoraUid] = idx < names.length ? names[idx] : "User $agoraUid";
      uidToImage[agoraUid] = idx < images.length ? images[idx] : "";
    }
  }

  void _startRemoteFrameFallback(int uid) {
    _remoteFrameFallbackTimers[uid]?.cancel();
    _remoteFrameFallbackTimers[uid] = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (remoteVideoOff[uid] == true) return;
      if (remoteHasVideoFrame[uid] == true) return;
      setState(() => remoteHasVideoFrame[uid] = true);
    });
  }

  void _cancelRemoteFrameFallback(int uid) {
    _remoteFrameFallbackTimers[uid]?.cancel();
    _remoteFrameFallbackTimers.remove(uid);
  }

  Future<void> initAgora() async {
    try {
      await html.window.navigator.getUserMedia(
        audio: widget.isAudioOn,
        video: widget.isVideoOn,
      );

      _engine = createAgoraRtcEngine();

      await _engine.initialize(
        RtcEngineContext(
          appId: appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            if (!mounted) return;
            setState(() => _localUserJoined = true);
          },

          onUserJoined: (_, uid, __) {
            if (!mounted) return;
            if (!_remoteUids.contains(uid)) _remoteUids.add(uid);
            remoteVideoOff[uid] = remoteVideoOff[uid] ?? false;
            remoteAudioMuted[uid] = remoteAudioMuted[uid] ?? false;
            remoteSpeaking[uid] = remoteSpeaking[uid] ?? false;
            remoteHasVideoFrame[uid] = remoteHasVideoFrame[uid] ?? false;
            _startRemoteFrameFallback(uid);
            _resolveIdentityForAgoraUid(agoraUid: uid);
            _waitingTimer?.cancel();
            _startCallTimer();
            setState(() {});
          },

          onUserInfoUpdated: (int uid, UserInfo info) {
            if (!mounted) return;
            final backendId = (info.userAccount ?? '').toString();
            if (backendId.isNotEmpty) {
              agoraUidToBackendId[uid] = backendId;
              backendIdToAgoraUid[backendId] = uid;
              _resolveIdentityForAgoraUid(agoraUid: uid, backendUserId: backendId);
            }
            setState(() {});
          },

          onUserOffline: (_, uid, __) {
            if (!mounted) return;
            _cancelRemoteFrameFallback(uid);
            final backendId = agoraUidToBackendId.remove(uid);
            if (backendId != null) backendIdToAgoraUid.remove(backendId);
            setState(() {
              _remoteUids.remove(uid);
              remoteVideoOff.remove(uid);
              remoteAudioMuted.remove(uid);
              remoteSpeaking.remove(uid);
              remoteHasVideoFrame.remove(uid);
              uidToName.remove(uid);
              uidToImage.remove(uid);
            });
          },

          onUserMuteVideo: (_, uid, muted) {
            if (!mounted) return;
            setState(() {
              remoteVideoOff[uid] = muted;
              if (muted) {
                remoteHasVideoFrame[uid] = false;
                _cancelRemoteFrameFallback(uid);
              } else {
                remoteHasVideoFrame[uid] = false;
                _startRemoteFrameFallback(uid);
              }
            });
          },

          onUserMuteAudio: (_, uid, muted) {
            if (!mounted) return;
            setState(() => remoteAudioMuted[uid] = muted);
          },

          onFirstRemoteVideoFrame: (connection, uid, width, height, elapsed) {
            if (!mounted) return;
            _cancelRemoteFrameFallback(uid);
            setState(() => remoteHasVideoFrame[uid] = true);
          },

          onAudioVolumeIndication: (
              RtcConnection connection,
              List<AudioVolumeInfo> speakers,
              int speakerNumber,
              int totalVolume,
              ) {
            if (!mounted) return;
            setState(() {
              _localSpeaking = false;
              for (var uid in _remoteUids) remoteSpeaking[uid] = false;
              for (final s in speakers) {
                final uid = s.uid;
                final vol = s.volume ?? 0;
                if (uid == null) continue;
                if (uid == 0) {
                  _localSpeaking = vol > 30;
                } else if (_remoteUids.contains(uid)) {
                  remoteSpeaking[uid] = vol > 30;
                }
              }
            });
          },
        ),
      );

      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await _engine.enableVideo();
      await _engine.enableAudio();

      if (_isLocalVideoOff) {
        await _engine.muteLocalVideoStream(true);
      } else {
        await _engine.muteLocalVideoStream(false);
        await _engine.startPreview();
      }

      await _engine.enableAudioVolumeIndication(
        interval: 200,
        smooth: 3,
        reportVad: true,
      );

      var localAccount = await TokenManager.getuserId();
      print('local user Id $localAccount');
      print('remote user id ${widget.receiverIds}');

      await _engine.joinChannel(
        token: "",
        channelId: widget.channelName,
        uid: localAccount,
        options: const ChannelMediaOptions(
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );

      if (!widget.isAudioOn) {
        _muted = true;
        await _engine.muteLocalAudioStream(true);
      }

      _localVideoController = VideoViewController(
        rtcEngine: _engine,
        canvas: const VideoCanvas(uid: 0),
      );

      if (mounted) setState(() => _engineInitialized = true);
    } catch (e) {
      debugPrint("Agora Init Error: $e");
    }
  }

  @override
  void dispose() {
    _waitingTimer?.cancel();
    _stopCallTimer();
    for (final t in _remoteFrameFallbackTimers.values) t.cancel();
    _remoteFrameFallbackTimers.clear();
    if (_engineInitialized) {
      _engine.leaveChannel();
      _engine.release();
    }
    super.dispose();
  }

  // ─────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (!_engineInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double totalWidth = constraints.maxWidth;
          final double totalHeight = constraints.maxHeight;

          return SizedBox(
            width: totalWidth,
            height: totalHeight,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [

                // ── 1. VIDEO / AUDIO GRID (fills full screen) ──────────────
                Positioned.fill(
                  child: widget.isVideoOn
                      ? _videoGrid(totalWidth, totalHeight)
                      : _audioCenterAvatars(),
                ),

                // ── 2. CALL TIMER (top center) ──────────────────────────────
                if (_callStarted)
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _formattedCallDuration,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ),

                // ── 3. PARTICIPANTS LIST (top right) ────────────────────────
                Positioned(
                    top: 25, right: 10, child: _callParticipantsList()),

                // ── 4. LOCAL PiP (top left) ─────────────────────────────────
                if (widget.isVideoOn)
                  Positioned(
                    top: 60,
                    left: 20,
                    child: ClipRect(
                      child: SizedBox(
                        width: 120,
                        height: 150,
                        child: _isLocalVideoOff
                            ? Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            Positioned.fill(
                              child: (widget.groupName != null &&
                                  widget.groupName!.isNotEmpty)
                                  ? _profileAvatar(
                                  widget.groupImage, widget.groupName)
                                  : _profileAvatar(
                                  widget.userImage, widget.userName),
                            ),
                            if (_localSpeaking)
                              const Positioned(
                                bottom: 4,
                                right: 4,
                                child: Icon(Icons.graphic_eq,
                                    color: Colors.greenAccent, size: 20),
                              ),
                          ],
                        )
                            : _localVideoController != null
                            ? AgoraVideoView(
                          key: const ValueKey('local_video_pip'),
                          controller: _localVideoController!,
                        )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),

                // ── 5. BOTTOM CONTROLS overlaid on video (bottom center) ────
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        // subtle frosted bar so buttons stay readable
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: bottomControls(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────
  // VIDEO GRID
  // ─────────────────────────────────────────
  Widget _videoGrid(double totalWidth, double totalHeight) {
    if (_remoteUids.isEmpty) {
      return Center(
        child: Text(
          widget.isBusyCall == true
              ? "This user is on another call..."
              : "Dialing...",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    final int count = _remoteUids.length > 4 ? 4 : _remoteUids.length;
    final int cols = count == 1 ? 1 : 2;
    final int rows = (count / cols).ceil();
    final double tileW = totalWidth / cols;
    final double tileH = totalHeight / rows;

    return Wrap(
      children: List.generate(count, (i) {
        final int uid = _remoteUids[i];
        return _remoteTile(uid: uid, width: tileW, height: tileH);
      }),
    );
  }

  Widget _remoteTile({
    required int uid,
    required double width,
    required double height,
  }) {
    final bool videoMuted = remoteVideoOff[uid] == true;
    final bool hasFrame = remoteHasVideoFrame[uid] == true;
    final bool speaking = remoteSpeaking[uid] == true;
    final bool audioMuted = remoteAudioMuted[uid] ?? false;

    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration:
          BoxDecoration(border: Border.all(color: Colors.white30)),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // AgoraVideoView always in tree — Visibility keeps DOM node alive
              Positioned.fill(
                child: Visibility(
                  visible: !videoMuted,
                  maintainState: true,
                  maintainAnimation: true,
                  maintainSize: true,
                  child: AgoraVideoView(
                    key: ValueKey('remote_view_$uid'),
                    controller: VideoViewController.remote(
                      rtcEngine: _engine,
                      canvas: VideoCanvas(uid: uid),
                      connection:
                      RtcConnection(channelId: widget.channelName),
                    ),
                  ),
                ),
              ),

              // Avatar overlay when muted or no frame yet
              if (videoMuted || !hasFrame)
                Positioned.fill(
                  child: Container(
                    color: Colors.black,
                    child: Center(
                      child: _profileAvatar(
                        uidToImage[uid] ?? "",
                        uidToName[uid] ?? "User $uid",
                      ),
                    ),
                  ),
                ),

              // Speaking indicator
              if (speaking && !audioMuted)
                const Positioned(
                  bottom: 8,
                  right: 8,
                  child: Icon(Icons.graphic_eq,
                      color: Colors.greenAccent, size: 22),
                ),

              // Muted mic indicator
              if (audioMuted)
                const Positioned(
                  bottom: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.mic_off, size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // PARTICIPANTS SIDEBAR
  // ─────────────────────────────────────────
  Widget _callParticipantsList() {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _remoteUids.length,
          separatorBuilder: (_, __) =>
          const Divider(color: Colors.white30, height: 5),
          itemBuilder: (_, index) {
            final int uid = _remoteUids[index];
            final String name = uidToName[uid] ?? "User $uid";
            final String image = uidToImage[uid] ?? "";
            final bool muted = remoteAudioMuted[uid] ?? false;
            final bool speaking = remoteSpeaking[uid] ?? false;
            return Row(
              children: [
                Stack(
                  children: [
                    ClipOval(
                      child: image.isEmpty
                          ? CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey.shade800,
                        child: const Icon(Icons.person,
                            color: Colors.white),
                      )
                          : Image.network(image,
                          width: 36, height: 36, fit: BoxFit.cover),
                    ),
                    if (muted)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.mic_off,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    if (speaking && !muted)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                              color: Colors.green, shape: BoxShape.circle),
                          child: const Icon(Icons.graphic_eq,
                              size: 14, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(name,
                      style:
                      const TextStyle(color: Colors.white, fontSize: 14),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // AUDIO MODE
  // ─────────────────────────────────────────
  Widget _audioCenterAvatars() {
    if (_remoteUids.isEmpty) {
      return Center(
        child: Text(
          widget.isBusyCall == true
              ? "This user is on another call..."
              : "Dialing...",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    final List<Widget> tiles = [
      _audioParticipantTile(
        image: widget.userImage,
        name: widget.userName ?? "You",
        isMe: true,
        speaking: _localSpeaking,
        muted: _muted,
      ),
    ];
    for (final uid in _remoteUids) {
      tiles.add(_audioParticipantTile(
        image: uidToImage[uid],
        name: uidToName[uid] ?? "User $uid",
        isMe: false,
        speaking: remoteSpeaking[uid] ?? false,
        muted: remoteAudioMuted[uid] ?? false,
      ));
    }

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 32,
        runSpacing: 32,
        children: tiles,
      ),
    );
  }

  Widget _audioParticipantTile({
    required String? image,
    required String name,
    required bool isMe,
    required bool speaking,
    required bool muted,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (speaking && !muted)
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.greenAccent, width: 3),
                ),
              ),
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.shade800,
              backgroundImage: (image != null && image.isNotEmpty)
                  ? NetworkImage(image)
                  : null,
              child: (image == null || image.isEmpty)
                  ? Icon(isMe ? Icons.person : Icons.person_outline,
                  color: Colors.white, size: 40)
                  : null,
            ),
            if (muted)
              const Positioned(
                bottom: 4,
                right: 4,
                child: CircleAvatar(
                  radius: 11,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.mic_off, size: 14, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(name,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            overflow: TextOverflow.ellipsis),
        if (isMe)
          const Text("(You)",
              style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────
  Widget _profileAvatar(String? image, String? name) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        image == null || image.isEmpty
            ? CircleAvatar(
          radius: 45,
          backgroundColor: Colors.grey.shade800,
          child:
          const Icon(Icons.person, color: Colors.white, size: 50),
        )
            : ClipOval(
          child: Image.network(image,
              width: 100, height: 100, fit: BoxFit.cover),
        ),
        const SizedBox(height: 8),
        Text(name ?? "Participant",
            style: const TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }

  // ─────────────────────────────────────────
  // BOTTOM CONTROLS — overlaid on video
  // ─────────────────────────────────────────
  Widget bottomControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        circleButton(
          icon: _muted ? Icons.mic_off : Icons.mic,
          color: _muted ? Colors.red : Colors.white,
          onPressed: () {
            setState(() => _muted = !_muted);
            _engine.muteLocalAudioStream(_muted);
          },
        ),
        const SizedBox(width: 25),
        callControlButton(
          icon: Icons.call_end,
          color: Colors.red,
          onPressed: () async {
            await handleCallRejected({"callId": widget.callId});
            _engine.leaveChannel();
            if (mounted) Navigator.pop(context);
          },
        ),
        if (widget.isVideoOn) const SizedBox(width: 25),
        if (widget.isVideoOn)
          circleButton(
            icon: _isLocalVideoOff ? Icons.videocam_off : Icons.videocam,
            color: _isLocalVideoOff ? Colors.red : Colors.white,
            onPressed: () async {
              setState(() => _isLocalVideoOff = !_isLocalVideoOff);
              if (_isLocalVideoOff) {
                await _engine.muteLocalVideoStream(true);
                await _engine.updateChannelMediaOptions(
                  const ChannelMediaOptions(publishCameraTrack: false),
                );
              } else {
                await _engine.muteLocalVideoStream(false);
                await _engine.startPreview();
                await _engine.updateChannelMediaOptions(
                  const ChannelMediaOptions(publishCameraTrack: true),
                );
              }
            },
          ),
      ],
    );
  }

  Widget circleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onPressed,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey.shade800.withOpacity(0.8),
        child: Icon(icon, color: color),
      ),
    );
  }

  static Widget callControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onPressed,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}