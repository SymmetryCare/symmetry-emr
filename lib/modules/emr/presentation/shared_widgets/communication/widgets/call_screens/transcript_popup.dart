import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

import 'package:symmetry_emr/app/resources/color.dart';

class TranscriptPopup extends StatelessWidget {
  const TranscriptPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 450,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      decoration: BoxDecoration(
        color: ColorManager.greyShade,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transcript (Live)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey,size: IconSize.I18,),
                onPressed: () => Navigator.of(context).pop(), // Close the dialog
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Download Button
              Expanded(
                child: Container(
                  color: ColorManager.white,
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, size: IconSize.I16, color: Colors.grey),
                    label: const Text('Download', style: TextStyle(color: Colors.black54)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  color: ColorManager.white,
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.mail_outline, size: IconSize.I16, color: Colors.grey),
                    label: const Text('Mail', style: TextStyle(color: Colors.black54)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildTranscriptEntries(),
              ),
            ),
          ),
          const SizedBox(height: 40,),
          Container(
            height: 40,
          width: double.maxFinite,
          decoration:   BoxDecoration(
              color: ColorManager.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () {},
              child: const Text('Add Note',
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Colors.black54)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTranscriptEntries() {
    return [
      _transcriptLine('11:5am patient', 'Good morning, doctor. I’ve been feeling very tired lately.'),
      _transcriptLine('11:5am Doctor', 'Good morning. How long have you been experiencing this fatigue?'),
      _transcriptLine('11:5am patient', 'For almost two weeks now. Even after resting, I still feel weak.'),
      _transcriptLine('11:5am Doctor', 'I see. Do you have any other symptoms, like fever, cough, or loss of appetite?'),
    ];
  }

  Widget _transcriptLine(String speaker, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(speaker, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 10,color: Colors.black26)),
          const SizedBox(height: 5),
          Text(text, style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w500,color: Colors.black87)),
        ],
      ),
    );
  }
}
