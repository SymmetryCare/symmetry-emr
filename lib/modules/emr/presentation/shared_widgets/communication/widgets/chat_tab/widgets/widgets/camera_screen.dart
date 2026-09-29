import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/color.dart';

class WebCameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const WebCameraScreen({super.key, required this.cameras});

  @override
  State<WebCameraScreen> createState() => _WebCameraScreenState();
}

class _WebCameraScreenState extends State<WebCameraScreen> {
  CameraController? controller;

  @override
  void initState() {
    super.initState();

    controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.max,     // Highest quality for full screen
      enableAudio: false,
    );

    controller!.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(color: ColorManager.blueprime),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          /// 🔥 Full screen camera preview
          Positioned.fill(
            child: CameraPreview(controller!),
          ),

          /// 🔥 Capture button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                spacing: 30,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side:  BorderSide(
                          color: ColorManager.blueprime, // Border color
                          width: 2,
                        ),
                      ),
                      backgroundColor: Colors.white, // White fill color
                      foregroundColor: ColorManager.blueprime, // Text color
                      elevation: 0, // Optional: remove shadow for clean border look
                    ),
                    onPressed: () async {
                      Navigator.pop(context, null);
                    },
                    child:  Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 18,
                        color: ColorManager.blueprime, // Blue text color
                      ),
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: ColorManager.blueprime,
                    ),
                    onPressed: () async {
                      final picture = await controller!.takePicture();
                      Navigator.pop(context, picture);
                    },
                    child: const Text(
                      "Capture",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
