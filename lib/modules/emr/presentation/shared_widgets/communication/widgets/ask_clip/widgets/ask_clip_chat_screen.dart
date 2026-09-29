import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/ask_clip/widgets/ask_clip_chat_sidebar.dart';

class AskClipChatScreen extends StatelessWidget {
  const AskClipChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          MediaQuery.of(context).size.width >= 450 ? const SizedBox(
            width: 200,
            child: ChatSidebar(),
          ) : const Offstage(),
          const Expanded(
            child: ChatInterface(),
          ),
        ],
      );
  }
}

class ChatInterface extends StatefulWidget {
  const ChatInterface({super.key});

  @override
  State<ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> messages = [
    {"text": "Nice! Can I see the live tracking link?", "isUser": true},
    {
      "text": "Of course! Here's your tracking link: [🔗 Track Order]",
      "isUser": false
    },
    {"text": "Perfect, thanks for the quick help.", "isUser": true},
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      messages.add({"text": text.trim(), "isUser": true});
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 20,top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 6, right: 60),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message['isUser']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 5),
                    decoration: message['isUser'] ?
                    BoxDecoration(
                        color: ColorManager.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ColorManager.greyShade200,width: 1)
                    )
                    : BoxDecoration(
                      color: const Color(0xFFEA6191).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        color: ColorManager.mediumgrey,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0,vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      onSubmitted: _sendMessage,
                      decoration: InputDecoration(
                        hintText: "Ask anything",
                        hintStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400,color: Color(0xFF78787C)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: () => _sendMessage(_controller.text),
                   child: CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFEA6191),
                    child: SvgPicture.asset("images/communication/mic_logo.svg",height: IconSize.I22,width: IconSize.I22,),
                    ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,)
        ],
      ),
    );
  }
}
