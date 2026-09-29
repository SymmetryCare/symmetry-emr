import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/call_screens/transcript_popup.dart';

class VideoCallScreen extends StatelessWidget {
  final VoidCallback onEndCall;
  const VideoCallScreen({super.key, required this.onEndCall});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      color: const Color(0xFF073042), // Dark Teal/Blue background color from the image
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Caller Avatar/Info
                Container(
                    width: size.width * 0.15,
                    height: size.width * 0.15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.greenAccent, width: 1.5),
                    ),
                    child: const Center(
                      child: CircleAvatar(
                        radius: 130,
                        backgroundImage: AssetImage('images/profile.png'),
                      ),
                    )
                ),
                const SizedBox(height: 20),
                const Text(
                  'Leslie Alexander',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Mobile Number here | Country',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 15),
                const Text(
                  'DIALING...',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 100), // Space before controls
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: CallControls(onEndCall), // Stateful widget to manage controls/popup
          ),
        ],
      ),
    );
  }
}


class CallControls extends StatefulWidget {
  final VoidCallback onEndCall;
  const CallControls(this.onEndCall);

  @override
  State<CallControls> createState() => _CallControlsState();
}

class _CallControlsState extends State<CallControls> {
  void _showTranscriptPopup() {
    // Show the TranscriptPopup positioned in the bottom-right corner
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Transcript',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Align(
          alignment: Alignment.topRight, // Position in the top-right corner
          child: ScaleTransition(
            scale: anim1,
            child: FadeTransition(
              opacity: anim1,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 20, bottom: 20),
                child: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(12),
                  child: const TranscriptPopup(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _smallControlButton({
    IconData? icon,
    String? imageAsset,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: (icon != null)
                ? Icon(icon, color: isActive ? Colors.white : Colors.grey, size: 20)
                : (imageAsset != null)
                ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                                imageAsset,
                                color: isActive ? Colors.white : Colors.grey,
                                width: 20,
                                height: 20,
                              ),
                )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // CC Transcripts Status
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.closed_caption,size: 20,color: Colors.white),
                   Text(
                    ' Transcript Started',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),

        // Main Control Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CC Icon (Opens Transcript Popup)
            _smallControlButton(imageAsset:"images/communication/call/cc.png", isActive: true, onTap: _showTranscriptPopup),
            const SizedBox(width: 20),
            // Video Icon
            _smallControlButton(imageAsset:"images/communication/call/videocall.png", isActive: false, onTap: () {}),
            const SizedBox(width: 20),
            // Mic Icon
            _smallControlButton(imageAsset:"images/communication/call/mute.png", isActive: false, onTap: () {}),
            const SizedBox(width: 20),
            // Volume Icon
            _smallControlButton(imageAsset:"images/communication/call/speaker.png", isActive: true, onTap: () {}),
            const SizedBox(width: 20),

            // Hang Up Button
            _callControlButton(Icons.call_end, Colors.red, widget.onEndCall),
            const SizedBox(width: 20),

            // More Options
            _smallControlButton(imageAsset:"images/communication/call/dailpad.png", isActive: true, onTap: () {}),
            const SizedBox(width: 20),
            // Pause
            _smallControlButton(icon: Icons.pause_circle_outline,),
            const SizedBox(width: 20),
            // Pen/Note
            _smallControlButton(imageAsset:"images/communication/call/note.png", isActive: false, onTap: () {} ),
          ],
        ),
      ],
    );
  }

  static Widget _callControlButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
