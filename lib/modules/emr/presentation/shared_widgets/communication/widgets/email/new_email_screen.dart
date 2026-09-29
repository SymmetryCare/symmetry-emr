
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/email/sign_popup.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/communication_manger/email_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/user_appbar_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/user/user_appbar.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/toste_notify_const.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

class NewMessageContainer extends StatefulWidget {
 final gmail.GmailApi gmailApi; // Gmail session from parent screen
  final String fromEmail;
  final String? fromPhotoUrl;

  const NewMessageContainer({
    super.key,
   required this.gmailApi,
    required this.fromEmail,
    this.fromPhotoUrl,
  });

  @override
  State<NewMessageContainer> createState() => _NewMessageContainerState();

  // ✅ Icon helper with hover + splash + padding
  static Widget _FunctionalIcon({
    IconData? icon,
    String? assetPath, // <-- Add assetPath for image
    VoidCallback? onTap,
    double size = 17,
    double asssize = 15,
    Color color = Colors.black54,
  }) {
    assert(icon != null || assetPath != null, 'Either icon or assetPath must be provided');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: icon != null
            ? Icon(icon, size: size, color: color)
            : Image.asset(assetPath!, width: asssize, height: asssize,color: color),
      ),
    );
  }
}

class _NewMessageContainerState extends State<NewMessageContainer> {
  UserAppBar? _user; // your own model

  bool _showEmojiPicker = false;

  final TextEditingController _subjectController = TextEditingController();

  // ✅ Separate controllers for To / Cc / Bcc
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _bccController = TextEditingController();

  // ✅ Separate recipient lists
  List<String> _toRecipients = [];
  List<String> _ccRecipients = [];
  List<String> _bccRecipients = [];


  final FocusNode _toFocusNode = FocusNode();
  final FocusNode _ccFocusNode = FocusNode();
  final FocusNode _bccFocusNode = FocusNode();

  // ✅ Show/hide cc+bcc rows
  bool _showCc = false;
  bool _showBcc = false;

  late quill.QuillController _quillController;

  final FocusNode _bodyFocusNode = FocusNode();
  final ScrollController _bodyScrollController = ScrollController();

  List<PlatformFile> _attachments = [];
  bool _isSending = false;

  // ✅ CHANGED: Display name -> Quill font key (safer, handles "Open Sans")
  // ✅ Use real font family names (not open-sans, not lowercase)
  final Map<String, String> _fontFamilies = const {
    'Roboto': 'Roboto',
    'Lato': 'Lato',
    'Poppins': 'Poppins',
    'Montserrat': 'Montserrat',
    'Open Sans': 'Open Sans',
    'Oswald': 'Oswald',
    'Nunito': 'Nunito',
    'Fira Sans': 'Fira_Sans',
  };

// selected display name
  String _selectedFont = 'Roboto';

// Convert stored "font" value into actual TextStyle
  TextStyle _fontFromFamilyOrDefault(String? family) {
    if (family == null) return const TextStyle();

    switch (family) {
      case 'Roboto':
        return GoogleFonts.roboto();
      case 'Lato':
        return GoogleFonts.lato();
      case 'Poppins':
        return GoogleFonts.poppins();
      case 'Montserrat':
        return GoogleFonts.montserrat();
      case 'Open Sans':
        return GoogleFonts.openSans();
      case 'Oswald':
        return GoogleFonts.oswald();
      case 'Nunito':
        return GoogleFonts.nunito();
      case 'Fira_Sans':
        return const TextStyle(fontFamily: 'Fira_Sans');
      default:
        return const TextStyle(); // fallback
    }
  }



  // 🔠 Font size dropdown data
  final List<double> _fontSizes = const [12, 14, 16, 18, 20, 24];
  double _selectedFontSize = 14;

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
    _loadUserDetails();
  }

  @override
  void dispose() {
    _bodyFocusNode.dispose();
    _bodyScrollController.dispose();
    _quillController.dispose();
    _subjectController.dispose();

    _toController.dispose();
    _ccController.dispose();
    _bccController.dispose();


    _toFocusNode.dispose();
    _ccFocusNode.dispose();
    _bccFocusNode.dispose();

    super.dispose();
  }

  String _formatFileSize(PlatformFile file) {
    final bytes = file.size; // PlatformFile.size is in bytes
    if (bytes <= 0) return "0 KB";

    const kb = 1024;
    const mb = kb * 1024;

    if (bytes >= mb) {
      return "${(bytes / mb).toStringAsFixed(2)} MB";
    } else {
      return "${(bytes / kb).toStringAsFixed(0)} KB";
    }
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });

    if (_showEmojiPicker) {
      // Hide keyboard when emoji picker is open
      _bodyFocusNode.unfocus();
    } else {
      // Bring focus back to editor
      FocusScope.of(context).requestFocus(_bodyFocusNode);
    }
  }

// Insert emoji into Quill at current cursor position
  void _insertEmoji(String emoji) {
    final selection = _quillController.selection;
    int index = selection.baseOffset;
    if (index < 0) {
      index = _quillController.document.length;
    }

    _quillController.replaceText(
      index,
      0,
      emoji,
      TextSelection.collapsed(offset: index + emoji.length),
    );
  }


  Widget _buildAttachmentChip(PlatformFile file) {
    final fileSize = _formatFileSize(file);

    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FBF8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon container
          Container(
            height: 40,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: SvgPicture.asset(
              "images/communication/email/file_download.svg",
            ),
          ),

          const SizedBox(width: 10),

          // filename + size
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  fileSize,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // delete icon
          GestureDetector(
            onTap: () {
              setState(() {
                _attachments.remove(file);
              });
            },
            child: const Icon(
              Icons.close,
              size: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserDetails() async {
    final user = await getAppBarDetails(context); // your helper
    setState(() => _user = user);
  }
  // -------------------------------------------------------------
  // Build HTML body from the Quill document (for sending rich email)
  // -------------------------------------------------------------
  String _buildHtmlBodyFromQuill() {
    final delta = _quillController.document.toDelta();
    final ops = List<Map<String, dynamic>>.from(delta.toJson());

    final converter = QuillDeltaToHtmlConverter(
      ops,
      ConverterOptions.forEmail(), // good defaults for email clients
    );

    final htmlBody = converter.convert();

    // Wrapping in HTML structure helps some email clients
    return '''
<!DOCTYPE html>
<html>
  <body>
    $htmlBody
  </body>
</html>
''';
  }

  // -------------------------------------------------------------
  // Build and send Gmail MIME message with attachments (HTML body)
  // -------------------------------------------------------------
  Future<void> _sendEmail() async {
    // ✅ At least one recipient in TO/CC/BCC
    if (_toRecipients.isEmpty &&
        _ccRecipients.isEmpty &&
        _bccRecipients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one recipient.")),
      );
      return;
    }

    final subject = _subjectController.text.trim();

    // For validation only (plain text)
    final bodyPlain = _quillController.document.toPlainText().trim();

    // For actual sending (HTML)
    final bodyHtml = _buildHtmlBodyFromQuill();

    final toHeader = _toRecipients.join(',');
    final ccHeader = _ccRecipients.join(',');
    final bccHeader = _bccRecipients.join(',');

    if (subject.isEmpty && bodyPlain.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Subject or body cannot be empty.")),
      );
      return;
    }

    print("📨 SENDING EMAIL...");
    print("FROM: ${widget.fromEmail}");
    print("TO: $toHeader");
    print("CC: $ccHeader");
    print("BCC: $bccHeader");
    print("SUBJECT: $subject");
    print("BODY CHAR COUNT (plain): ${bodyPlain.length}");
    print("ATTACHMENTS COUNT: ${_attachments.length}");

    setState(() => _isSending = true);

    try {
      final boundary =
          'flutter_boundary_${DateTime.now().millisecondsSinceEpoch}';
      final buffer = StringBuffer();

      // ---------- Common headers ----------
      buffer.writeln('From: ${widget.fromEmail}');
      if (toHeader.isNotEmpty) buffer.writeln('To: $toHeader');
      if (ccHeader.isNotEmpty) buffer.writeln('Cc: $ccHeader');
      if (bccHeader.isNotEmpty) buffer.writeln('Bcc: $bccHeader');
      buffer.writeln('Subject: $subject');
      buffer.writeln('MIME-Version: 1.0');

      if (_attachments.isEmpty) {
        // ==========================================
        // SIMPLE HTML EMAIL (no attachments)
        // ==========================================
        buffer.writeln('Content-Type: text/html; charset="utf-8"');
        buffer.writeln('Content-Transfer-Encoding: 7bit\n');
        buffer.writeln(bodyHtml);
      } else {
        // ==========================================
        // MULTIPART EMAIL (HTML + attachments)
        // ==========================================
        buffer.writeln('Content-Type: multipart/mixed; boundary="$boundary"\n');

        // ---- HTML BODY PART ----
        buffer.writeln('--$boundary');
        buffer.writeln('Content-Type: text/html; charset="utf-8"');
        buffer.writeln('Content-Transfer-Encoding: 7bit\n');
        buffer.writeln(bodyHtml);

        // ---- ATTACHMENTS ----
        for (final file in _attachments) {
          final bytes = file.bytes;
          if (bytes == null) continue;

          final mimeType =
              lookupMimeType(file.name) ?? 'application/octet-stream';
          final base64Data = base64Encode(bytes);

          buffer.writeln('\n--$boundary');
          buffer.writeln('Content-Type: $mimeType; name="${file.name}"');
          buffer.writeln('Content-Transfer-Encoding: base64');
          buffer.writeln(
              'Content-Disposition: attachment; filename="${file.name}"\n');
          buffer.writeln(base64Data);
        }

        // ---- END BOUNDARY ----
        buffer.writeln('\n--$boundary--');
      }

      final mimeMessage = buffer.toString();

      // Gmail-safe base64
      String raw = base64Url
          .encode(utf8.encode(mimeMessage))
          .replaceAll('+', '-')
          .replaceAll('/', '_')
          .replaceAll('=', '');

      await widget.gmailApi.users.messages.send(
        gmail.Message(raw: raw),
        'me',
      );

      print("✅ EMAIL SENT SUCCESSFULLY!");

      // Reset UI
      setState(() {
        _toRecipients.clear();
        _ccRecipients.clear();
        _bccRecipients.clear();

        _toController.clear();
        _ccController.clear();
        _bccController.clear();
        _subjectController.clear();
        _attachments.clear();

        _showCc = false;
        _showBcc = false;

        _quillController.replaceText(
          0,
          _quillController.document.length,
          '',
          const TextSelection.collapsed(offset: 0),
        );
      });

      Navigator.of(context).pop();
      showTopRightToast(
        context,
        message: "Email sent successfully!",
        isSuccess: true,
      );
    } catch (e) {
      print("❌ ERROR SENDING EMAIL: $e");
      showTopRightToast(
        context,
        message: "Failed to send!",
        isSuccess: false,
      );
    } finally {
      setState(() => _isSending = false);
      print("📭 SEND OPERATION FINISHED.");
    }
  }


  String _buildFromInitial() {
    final email = widget.fromEmail.trim();
    if (email.isEmpty) return ''; // no symbol fallback

    // Take part before @ if possible
    final namePart = email.split('@').first.trim();
    final source = namePart.isNotEmpty ? namePart : email;

    return source[0].toUpperCase();
  }



  final Map<String, bool> _isAdding = {}; // track adding state per field

// helper to check adding state safely
  bool _isAddingFor(String label) => _isAdding[label] ?? false;

// Call this once when you create each focusNode (e.g. in initState or right after focusNode created):
  void attachFocusListener(
      String label,
      FocusNode focusNode,
      TextEditingController controller,
      ) {
    focusNode.addListener(() {
      if (!mounted) return; // prevent setState after dispose

      if (!focusNode.hasFocus) {
        // If user leaves the field AND the text is empty → exit adding mode
        if (controller.text.trim().isEmpty) {
          setState(() {
            _isAdding[label] = false;
          });
        }
      }
    });
  }




  // -------------------------------------------------------------
  // UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 750,
          height: 550,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: [
            // ================= HEADER (fixed) =================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration:  BoxDecoration(color: ColorManager.greenBright),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'New Message',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ============== MIDDLE CONTENT (scrollable / flexible) ==============
            Expanded(
              child: Column(
                children: [
                  // From row
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Row(
                      children: [
                        if (widget.fromPhotoUrl != null &&
                            widget.fromPhotoUrl!.isNotEmpty)
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: NetworkImage(widget.fromPhotoUrl!),
                          )
                        else
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.blueGrey.shade100,
                            child: Text(
                              _buildFromInitial(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Text(
                          widget.fromEmail,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),


                  const Divider(height: 1),

                  // TO row with Cc/Bcc buttons
                  // TO row with Cc/Bcc buttons
                  _buildRecipientField(
                    label: 'To:',
                    recipients: _toRecipients,
                    controller: _toController,
                    focusNode: _toFocusNode,
                    hint: "",
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_showCc)
                          Padding(
                            padding: const EdgeInsets.only(right: 10, top: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xffF3F3F3),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: InkWell(
                                onTap: () => setState(() => _showCc = true),
                                child: const Text('Cc', style: TextStyle(color: Colors.black)),
                              ),
                            ),
                          ),
                        if (!_showBcc)
                          Padding(
                            padding: const EdgeInsets.only(right: 10, top: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xffF3F3F3),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: InkWell(
                                onTap: () => setState(() => _showBcc = true),
                                child: const Text('Bcc', style: TextStyle(color: Colors.black)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  if (_showCc)
                    _buildRecipientField(
                      label: 'Cc:',
                      recipients: _ccRecipients,
                      controller: _ccController,
                      focusNode: _ccFocusNode ,
                      hint: '',
                    ),

                  if (_showBcc)
                    _buildRecipientField(
                      label: 'Bcc:',
                      recipients: _bccRecipients,
                      controller: _bccController,
                      focusNode: _bccFocusNode ,
                      hint: '',
                    ),

                  // Subject
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                    child: TextField(
                      controller: _subjectController,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Subject',
                        hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const Divider(height: 1, thickness: 1),

                  // ======= BODY + ATTACHMENTS + TOOLBAR all share remaining height =======
                  // ======= BODY + ATTACHMENTS + TOOLBAR all share remaining height =======
                  Expanded(
                    child: Column(
                      children: [
                        // Scrollable content (body + attachments)
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _bodyScrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // === BODY (Quill, no internal scroll) ===

                                // === ATTACHMENTS in same scroll ===

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                  child: QuillEditor(
                                    focusNode: _bodyFocusNode,
                                    scrollController: ScrollController(),
                                    controller: _quillController,
                                    config: QuillEditorConfig(
                                      scrollable: false,
                                      autoFocus: false,
                                      showCursor: true,
                                      expands: false,
                                      padding: EdgeInsets.zero,
                                      customStyleBuilder: (attribute) {
                                        if (attribute.key == quill.Attribute.font.key) {
                                          return _fontFromFamilyOrDefault(attribute.value?.toString());
                                        }
                                        return const TextStyle();
                                      },
                                    ),
                                  ),
                                ),

                                if (_attachments.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: _attachments
                                          .map((file) => _buildAttachmentChip(file))
                                          .toList(),
                                    ),
                                  ),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),

                        // === FIXED TOOLBAR AT BOTTOM ===
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: _buildTextFormattingToolbar(),
                        ),

                        const Divider(height: 1),
                      ],
                    ),
                  ),


                ],
              ),
            ),

            // ================== BOTTOM ACTIONS (fixed) ==================
            Container(
              color: const Color(0xffF3F3F3),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      flex: MediaQuery .of(context) .size .width >= 1100 ? 3 : 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isSending ? null : _sendEmail,
                            iconAlignment: IconAlignment.end,
                            icon: _isSending
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Icon(
                              Icons.arrow_drop_down_outlined,
                              size: 18,
                            ),
                            label:
                            Text(_isSending ? "Sending..." : "Send",style:const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorManager.greenBright,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),

                          // 📎 Open Files (PDF / DOC / ZIP / ANY)
                          NewMessageContainer._FunctionalIcon(
                            icon:Icons.attach_file,
                            onTap: () async {
                              final result =
                              await FilePicker.platform.pickFiles(
                                allowMultiple: true,
                                withData: true,
                              );

                              if (result != null &&
                                  result.files.isNotEmpty) {
                                setState(() {
                                  _attachments.addAll(result.files);
                                });

                                for (final f in result.files) {
                                  print("Attached file: ${f.name} (${f.bytes?.lengthInBytes} bytes)");
                                }
                              } else {
                                print("File selection cancelled");
                              }
                            },
                          ),

                          // 😀 Emoji (future)
                          NewMessageContainer._FunctionalIcon(
                            icon:  CupertinoIcons.smiley,
                            onTap: () {
                              print("Emoji tapped");
                              _toggleEmojiPicker();
                            },
                          ),

                          // 🖼️ PICK ONLY JPG/JPEG, SHOW IN BODY + ATTACH
                          // 🖼️ PICK ONLY JPG/JPEG, SHOW IN BODY + ATTACH
                          // 🖼️ PICK ONLY JPG/JPEG, SHOW ONLY AS ATTACHMENT
                          NewMessageContainer._FunctionalIcon(
                            icon: Icons.image,
                            onTap: () async {
                              final result = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['jpg', 'jpeg'], // add 'png' if you want
                                allowMultiple: true,
                                withData: true, // needed so bytes is set
                              );

                              if (result != null && result.files.isNotEmpty) {
                                setState(() {
                                  // ✅ only add to attachments
                                  _attachments.addAll(result.files);
                                });

                                for (final f in result.files) {
                                  print(
                                    "Attached image as attachment only: "
                                        "${f.name} (${f.bytes?.lengthInBytes} bytes)",
                                  );
                                }
                              } else {
                                print("Image selection cancelled");
                              }
                            },
                          ),



                          // ✏️ Signature: add ONLY as attachment chip
                          NewMessageContainer._FunctionalIcon(
                            assetPath: "images/communication/email/sign_pen.png",
                            onTap: () {
                              print("Pen tapped");
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => SignatureDialog(
                                  onSubmit: (selected) async {
                                    print(
                                        "Signature selected: ${selected.signatureUrl}");

                                    try {
                                      final url =
                                          selected.signatureUrl;

                                      Uint8List bytes;
                                      String fileName;

                                      if (url.startsWith('data:')) {
                                        // data:image/png;base64,...
                                        final base64Part =
                                            url.split(',').last;
                                        bytes =
                                            base64Decode(base64Part);
                                        fileName = 'signature.png';
                                      } else {
                                        // normal HTTPS URL (S3)
                                        final uri = Uri.parse(url);
                                        final response =
                                        await http.get(uri);

                                        if (response.statusCode !=
                                            200) {
                                          print(
                                              "❌ Failed to download signature: ${response.statusCode}");
                                          return;
                                        }

                                        bytes = response.bodyBytes;
                                        fileName = p.basename(
                                          uri.path.isNotEmpty
                                              ? uri.path
                                              : 'signature.png',
                                        );
                                      }

                                      final signatureFile =
                                      PlatformFile(
                                        name: fileName,
                                        bytes: bytes,
                                        size: bytes.length,
                                      );

                                      setState(() {
                                        _attachments
                                            .add(signatureFile);
                                      });

                                      // 🚫 not inserting into editor
                                      // insertImageIntoQuill(bytes, fileName);

                                      print(
                                          "✅ Signature added as attachment only!");
                                    } catch (e) {
                                      print(
                                          "❌ Error handling signature: $e");
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      flex: MediaQuery .of(context) .size .width >= 1100 ? 3 : 1,
                      child: Container(),
                    ),

                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          NewMessageContainer._FunctionalIcon(
                            assetPath: "images/communication/email/dustbin.png",
                            onTap: () {
                              print("Delete tapped");
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),

        if (_showEmojiPicker)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                setState(() {
                  _showEmojiPicker = false;
                });
              },
              child: const SizedBox(),
            ),
          ),

        // 2) Emoji Picker at bottom
        if (_showEmojiPicker)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: 200,width: 100,
              child: Padding(
                padding:const EdgeInsets.only(right: 300,),
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    _insertEmoji(emoji.emoji);
                  },
                  config:  Config(
                    height: 200,
                    bottomActionBarConfig: BottomActionBarConfig(
                        backgroundColor: ColorManager.blueprime,
                        buttonColor: ColorManager.blueprime,
                        showBackspaceButton: false
                    ),
                    emojiViewConfig: const EmojiViewConfig(
                      emojiSizeMax: 24,
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

  // ✅ Generic recipient field for To / Cc / Bcc
  Widget _buildRecipientField({
    required String label,
    required List<String> recipients,
    required TextEditingController controller,
    required FocusNode focusNode,
    String hint = 'Add recipient',
    Widget? trailing,
  }) {
    // ensure map has an entry
    _isAdding.putIfAbsent(label, () => false);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label (To / Cc / Bcc)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Chips + input + optional Cc/Bcc buttons
              Expanded(
                child: Row(
                  children: [
                    // Chips + input scrolling region
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Existing Chips
                            for (var r in recipients)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Chip(
                                  backgroundColor: Colors.grey.shade200,
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.blue,
                                        child: Text(
                                          r.isNotEmpty ? r[0].toUpperCase() : '?',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(r),
                                    ],
                                  ),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    setState(() => recipients.remove(r));
                                  },
                                ),
                              ),

                            // Show + icon only when:
                            //  - there is at least one recipient
                            //  - AND we're NOT currently in "adding" mode
                            if (recipients.isNotEmpty && !_isAddingFor(label))
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    // Enter adding mode: hide + and focus textfield
                                    setState(() => _isAdding[label] = true);
                                    FocusScope.of(context).requestFocus(focusNode);
                                  },
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade300,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.add,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            // Text input field
                            SizedBox(
                              width: 220,
                              child: TextField(
                                focusNode: focusNode,
                                controller: controller,
                                decoration: InputDecoration(
                                  hintText: hint,
                                  isCollapsed: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  border: InputBorder.none,
                                ),
                                onChanged: (_) {
                                  // optional: you can show/hide other UI as user types
                                  setState(() {});
                                },
                                onSubmitted: (value) {
                                  final text = value.trim();
                                  if (text.isNotEmpty) {
                                    setState(() {
                                      recipients.add(text);
                                      controller.clear();
                                      // exit adding mode so + shows again
                                      _isAdding[label] = false;
                                    });
                                    // keep focus on the textfield if you want user to continue typing:
                                    // FocusScope.of(context).requestFocus(focusNode);
                                  } else {
                                    // if submitted empty, just exit adding mode
                                    setState(() => _isAdding[label] = false);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Trailing Cc/Bcc buttons
                    if (trailing != null) trailing,
                  ],
                ),
              ),
            ],
          ),
        ),
        // Divider for ALL To, Cc, Bcc rows
        const Divider(thickness: 1),
      ],
    );
  }



  Widget _buildTextFormattingToolbar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Row(
              children: <Widget>[
                // Undo / Redo
                NewMessageContainer._FunctionalIcon(
                  icon:  Icons.undo,
                  onTap: () => _quillController.undo(),
                ),
                NewMessageContainer._FunctionalIcon(
                  icon:  Icons.redo,
                  onTap: () => _quillController.redo(),
                ),

                _verticalDivider(),

                // 🔤 FONT FAMILY DROPDOWN — smaller width + centered divider
                SizedBox(
                  width: 110,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedFont,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down),
                    items:_fontFamilies.keys.map((displayName) {
                      return DropdownMenuItem<String>(
                        value: displayName,
                        child: Text(
                          displayName,
                          style: GoogleFonts.getFont(displayName == 'Fira Sans' ? 'Fira Sans' : displayName, fontSize: 12),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() => _selectedFont = value);

                      final family = _fontFamilies[value]!;

                      // ✅ Apply to selected text (or future typing)
                      _quillController.formatSelection(
                        quill.Attribute.fromKeyValue('font', family),
                      );
                    },
                  ),
                ),



                _verticalDivider(),

                // 🔠 FONT SIZE DROPDOWN — smaller width
                SizedBox(
                  width: 55,
                  child: DropdownButton<double>(
                    isExpanded: true,
                    value: _selectedFontSize,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down),
                    items: _fontSizes.map((double size) {
                      return DropdownMenuItem<double>(
                        value: size,
                        child: Text(
                          size.toInt().toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedFontSize = value);

                      _quillController.formatSelection(
                        quill.Attribute.fromKeyValue(
                          'size',
                          value.toInt().toString(),
                        ),
                      );
                    },
                  ),
                ),

                _verticalDivider(),

                // BOLD
                NewMessageContainer._FunctionalIcon(
                  icon: Icons.format_bold,
                  onTap: () {
                    final attrs = _quillController.getSelectionStyle().attributes;
                    final isBold = attrs.containsKey(quill.Attribute.bold.key);

                    _quillController.formatSelection(
                      isBold
                          ? quill.Attribute(quill.Attribute.bold.key,
                          quill.Attribute.bold.scope, null)
                          : quill.Attribute.bold,
                    );
                  },
                ),

                // ITALIC
                NewMessageContainer._FunctionalIcon(
                  icon:   Icons.format_italic,
                  onTap: () {
                    final attrs = _quillController.getSelectionStyle().attributes;
                    final isItalic =
                    attrs.containsKey(quill.Attribute.italic.key);

                    _quillController.formatSelection(
                      isItalic
                          ? quill.Attribute(
                        quill.Attribute.italic.key,
                        quill.Attribute.italic.scope,
                        null,
                      )
                          : quill.Attribute.italic,
                    );
                  },
                ),

                // UNDERLINE
                NewMessageContainer._FunctionalIcon(
                  icon:  Icons.format_underline,
                  onTap: () {
                    final attrs = _quillController.getSelectionStyle().attributes;
                    final isUnderlined =
                    attrs.containsKey(quill.Attribute.underline.key);

                    _quillController.formatSelection(
                      isUnderlined
                          ? quill.Attribute(
                        quill.Attribute.underline.key,
                        quill.Attribute.underline.scope,
                        null,
                      )
                          : quill.Attribute.underline,
                    );
                  },
                ),

                _verticalDivider(),
                // ALIGN LEFT
                NewMessageContainer._FunctionalIcon(
                  icon:   Icons.format_align_left,
                  onTap: () =>
                      _quillController.formatSelection(quill.Attribute.leftAlignment),
                ),

                // ALIGN CENTER
                NewMessageContainer._FunctionalIcon(
                  icon:  Icons.format_align_center,
                  onTap: () => _quillController
                      .formatSelection(quill.Attribute.centerAlignment),
                ),

                // ALIGN RIGHT
                NewMessageContainer._FunctionalIcon(
                  icon:  Icons.format_align_right,
                  onTap: () =>
                      _quillController.formatSelection(quill.Attribute.rightAlignment),
                ),

                // BULLET LIST
                NewMessageContainer._FunctionalIcon(
                  icon:  Icons.format_list_bulleted,
                  onTap: () {
                    final attrs = _quillController.getSelectionStyle().attributes;
                    final isList =
                        attrs[quill.Attribute.list.key] == quill.Attribute.ul;

                    _quillController.formatSelection(
                      isList
                          ? quill.Attribute.clone(quill.Attribute.list, null)
                          : quill.Attribute.ul,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ---- Vertical Divider Widget ---- ///
  Widget _verticalDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        height: 22,
        child: VerticalDivider(
          color: Colors.grey.shade300,
          thickness: 1,
          width: 1,
        ),
      ),
    );
  }

}
