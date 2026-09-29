import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/call_screens/video_call_screen.dart';

import 'package:symmetry_emr/app/resources/color.dart';
class ReceivedVideoCall extends StatelessWidget {
  final VoidCallback onEndCall;
  const ReceivedVideoCall({super.key, required this.onEndCall});

  @override
  Widget build(BuildContext context) {
    // Determine screen size for responsive layout
    final size = MediaQuery
        .of(context)
        .size;

    return Container(
      color: ColorManager.callscereen,
      child: Stack(
        children: [
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center, // center horizontally
              children: [
                // Circular image with white border and padding
                Container(
                  width: 170, // total size including border
                  height: 170,
                  decoration:  const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white, // outer white border
                  ),
                  child: Container(
                    width: 150, // total size including border
                    height: 150,
                    decoration:  BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorManager.callscereen, // outer white border
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 150, // total size including border
                      height: 150,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        // color: Colors.indigo.shade900, // space around the image showing background color
                        image: DecorationImage(
                          image: AssetImage('images/profile.png',),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),


                const SizedBox(height: 12), // spacing between image and name
                // Name text
                const Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6), // spacing between name and subtext
                // Subtext
                const Text(
                  'Mobile Number here | Country',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10), // spacing between name and subtext
                // Subtext
                const Text(
                  'DIALING...',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Call controls at the bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: CallControls(
              onEndCall,
              // showTranscriptInitially: true,
            ),
          ),
        ],
      ),
    );


  }
  }