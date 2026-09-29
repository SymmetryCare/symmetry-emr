import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/email/new_email_screen.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/user_appbar_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/user/user_appbar.dart';
import 'dart:convert';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:http/http.dart' as http;
import 'dart:js' as js;
import 'dart:html' as html_dom;

import 'package:flutter_html/flutter_html.dart' as html;

import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/toste_notify_const.dart';
import 'dart:async';


/// Simple HTTP client with Bearer token (web)
class _WebClient extends http.BaseClient {
  final String accessToken;
  final http.Client _inner = http.Client();

  _WebClient(this.accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $accessToken';
    print('➡️ [HTTP] ${request.method} ${request.url}');
    return _inner.send(request);
  }
}

class EmailAttachment {
  final String fileName;
  final int sizeBytes;
  final String attachmentId;
  final String messageId;

  EmailAttachment({
    required this.fileName,
    required this.sizeBytes,
    required this.attachmentId,
    required this.messageId,
  });
}

class _FunctionalIcon extends StatelessWidget {
  final String assetPath;
  final VoidCallback? onTap;
  final Color? color;

  const _FunctionalIcon({
    super.key,
    required this.assetPath,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onTap,
      child: Center(
        child: SvgPicture.asset(
          assetPath,
          color: color,
          width: 16,
          height: 16,
        ),
      ),
    );
  }
}


class EmailScreenCommunication extends StatefulWidget {
  const EmailScreenCommunication({super.key});

  @override
  State<EmailScreenCommunication> createState() => _EmailScreenCommunicationState();

  static Widget _attachmentChip({
    required String fileName,
    required String fileSize,
    required VoidCallback onDownload,
  }) {
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
          Container(
            height: 40,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorManager.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: SvgPicture.asset(
              "images/communication/email/file_download.svg",
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 180,
                  child: Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: FontSize.s12,
                      color: ColorManager.mediumgrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  fileSize,
                  style: TextStyle(
                    fontSize: FontSize.s12,
                    color: ColorManager.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: onDownload,
            child: Icon(
              Icons.download_rounded,
              size: 20,
              color: ColorManager.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailScreenCommunicationState extends State<EmailScreenCommunication>
    with WidgetsBindingObserver {

  /// --- UI State ---
  final List<Map<String, String>> sidebarItems = [
    {"icon": "images/communication/email/inbox.svg", "label": "Inbox"},
    {"icon": "images/communication/email/star.svg", "label": "Starred"},
    {"icon": "images/communication/email/archieve.svg", "label": "Archive"},
    {"icon": "images/communication/email/sent.svg", "label": "Sent"},
    {"icon": "images/communication/email/spam.svg", "label": "Spam"},
    {"icon": "images/communication/email/thrash.svg", "label": "Trash"},
  ];

  int selectedIndex = 0;
  UserAppBar? _user;
  bool _isLoadingUser = true;
  String? _gmailUserEmail;
  String? _gmailPhotoUrl;

  /// --- Gmail state ---
  String? _gmailToken;
  gmail.GmailApi? _gmailApi;
  List<gmail.Message> _emails = [];
  gmail.Message? _selectedEmail;
  bool _isInitializingGmail = true;
  bool _isGmailLoading = false;
  String _currentLabelId = 'INBOX';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Live inbox polling
  Timer? _inboxPollTimer;
  bool _isPolling = false;
  String? _lastSeenInboxTopId;
  bool _pollRequestRunning = false;

  // Pagination / infinite scroll
  final ScrollController _emailListController = ScrollController();
  String? _nextPageToken;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  // Async email body
  String _selectedBodyHtml = '';
  bool _isBodyLoading = false;


  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 KB";
    const kb = 1024;
    const mb = kb * 1024;
    if (bytes >= mb) {
      return "${(bytes / mb).toStringAsFixed(2)} MB";
    } else {
      return "${(bytes / kb).toStringAsFixed(0)} KB";
    }
  }


  Future<void> _onDeletePressed() async {
    if (_selectedEmail == null || _gmailApi == null) return;

    try {
      final messageId = _selectedEmail!.id!;
      print("🗑 Moving message $messageId to TRASH...");
      await _gmailApi!.users.messages.trash('me', messageId);

      setState(() {
        _emails.removeWhere((m) => m.id == messageId);
        _selectedEmail = _emails.isNotEmpty ? _emails.first : null;
      });

      showTopRightToast(context, message: "Email moved to Trash", isSuccess: true);
    } catch (e) {
      print("❌ Failed to move to Trash: $e");
      showTopRightToast(context, message: "Failed to move email to Trash", isSuccess: false);
    }
  }

  Future<void> _onArchivePressed() async {
    if (_selectedEmail == null || _gmailApi == null) return;

    try {
      final messageId = _selectedEmail!.id!;
      print("📦 Archiving message $messageId (remove INBOX)...");

      await _gmailApi!.users.messages.modify(
        gmail.ModifyMessageRequest(removeLabelIds: ['INBOX']),
        'me',
        messageId,
      );

      if (_currentLabelId == 'INBOX') {
        setState(() {
          _emails.removeWhere((m) => m.id == messageId);
          _selectedEmail = _emails.isNotEmpty ? _emails.first : null;
        });
      }

      print("✅ Archived successfully");
      showTopRightToast(context, message: "Email archived", isSuccess: true);
    } catch (e) {
      print("❌ Failed to archive: $e");
      showTopRightToast(context, message: "Failed to archive email", isSuccess: false);
    }
  }


  Future<void> _toggleStar() async {
    if (_selectedEmail == null || _gmailApi == null) return;

    final messageId = _selectedEmail!.id!;
    final currentLabels = List<String>.from(_selectedEmail!.labelIds ?? const []);
    final isStarred = currentLabels.contains('STARRED');

    setState(() {
      if (isStarred) {
        currentLabels.remove('STARRED');
      } else {
        currentLabels.add('STARRED');
      }
      _selectedEmail!.labelIds = currentLabels;

      final idx = _emails.indexWhere((m) => m.id == messageId);
      if (idx != -1) {
        _emails[idx].labelIds = currentLabels;
      }
    });

    try {
      await _gmailApi!.users.messages.modify(
        gmail.ModifyMessageRequest(
          addLabelIds: isStarred ? null : ['STARRED'],
          removeLabelIds: isStarred ? ['STARRED'] : null,
        ),
        'me',
        messageId,
      );

      showTopRightToast(
        context,
        message: isStarred ? "Email removed from Starred" : "Email added to Starred",
        isSuccess: true,
      );
    } catch (e) {
      print("❌ Failed to toggle star: $e");
      showTopRightToast(context, message: "Failed to update star", isSuccess: false);
    }
  }

  Future<void> _markAsRead(gmail.Message msg) async {
    if (_gmailApi == null || msg.id == null) return;

    final currentLabels = List<String>.from(msg.labelIds ?? const []);
    if (!currentLabels.contains('UNREAD')) return;

    setState(() {
      currentLabels.remove('UNREAD');
      msg.labelIds = currentLabels;

      final idx = _emails.indexWhere((m) => m.id == msg.id);
      if (idx != -1) {
        _emails[idx].labelIds = List<String>.from(currentLabels);
      }
    });

    try {
      await _gmailApi!.users.messages.modify(
        gmail.ModifyMessageRequest(removeLabelIds: ['UNREAD']),
        'me',
        msg.id!,
      );
    } catch (e) {
      print("❌ Failed to mark as read: $e");
    }
  }


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _emailListController.addListener(() {
      if (_emailListController.position.pixels >=
          _emailListController.position.maxScrollExtent - 200) {
        _loadMoreEmails();
      }
    });

    _loadUser();
    _startWebLogin();
  }


  String _sanitizeEmailHtml(String inputHtml) {
    var out = inputHtml;
    out = out.replaceAll(
      RegExp(r'<script\b[^>]*>.*?</script>', caseSensitive: false, dotAll: true),
      '',
    );
    out = out.replaceAll(
      RegExp(r'<iframe\b[^>]*>.*?</iframe>', caseSensitive: false, dotAll: true),
      '',
    );
    return out;
  }


  String _injectResponsiveImageCss(String htmlStr) {
    const css = '''
<style>
  img { max-width: 100% !important; height: auto !important; display: block; }
  body { margin: 0; padding: 0; }
</style>
''';

    final headRegex = RegExp(r'<head[^>]*>', caseSensitive: false);
    if (headRegex.hasMatch(htmlStr)) {
      return htmlStr.replaceFirstMapped(headRegex, (m) => '${m.group(0)}$css');
    }
    return css + htmlStr;
  }


  String _normalizeCid(String cid) {
    cid = cid.trim();
    if (cid.startsWith('<') && cid.endsWith('>')) {
      cid = cid.substring(1, cid.length - 1);
    }
    return cid;
  }

  Future<Map<String, String>> _cidToDataUrlMap(gmail.Message msg) async {
    final map = <String, String>{};
    if (_gmailApi == null || msg.id == null || msg.payload == null) return map;

    void walk(gmail.MessagePart p, List<gmail.MessagePart> out) {
      out.add(p);
      for (final c in p.parts ?? const <gmail.MessagePart>[]) {
        walk(c, out);
      }
    }

    final allParts = <gmail.MessagePart>[];
    walk(msg.payload!, allParts);

    for (final part in allParts) {
      final mt = (part.mimeType ?? '').toLowerCase();
      if (!mt.startsWith('image/')) continue;

      final headers = part.headers ?? const <gmail.MessagePartHeader>[];
      final contentId = headers
          .firstWhere(
            (h) => (h.name ?? '').toLowerCase() == 'content-id',
        orElse: () => gmail.MessagePartHeader(),
      )
          .value;

      final attachmentId = part.body?.attachmentId;

      if (contentId == null || contentId.trim().isEmpty) continue;
      if (attachmentId == null || attachmentId.isEmpty) continue;

      final att = await _gmailApi!.users.messages.attachments.get(
        'me',
        msg.id!,
        attachmentId,
      );

      final data = att.data;
      if (data == null || data.isEmpty) continue;

      final b64 = data.replaceAll('-', '+').replaceAll('_', '/');
      final cid = _normalizeCid(contentId);
      map[cid] = 'data:$mt;base64,$b64';
    }

    return map;
  }

  Future<String> _replaceCidImages(gmail.Message msg, String htmlStr) async {
    final cidMap = await _cidToDataUrlMap(msg);
    var out = htmlStr;

    cidMap.forEach((cid, dataUrl) {
      out = out.replaceAll('src="cid:$cid"', 'src="$dataUrl"');
      out = out.replaceAll("src='cid:$cid'", "src='$dataUrl'");
      out = out.replaceAll('src="cid:<$cid>"', 'src="$dataUrl"');
      out = out.replaceAll("src='cid:<$cid>'", "src='$dataUrl'");
    });

    return out;
  }


  void _loadUser() async {
    print("👤 Loading user for app bar...");
    final userData = await getAppBarDetails(context);
    setState(() {
      _user = userData;
      _isLoadingUser = false;
    });
    print("✅ User loaded: ${_user?.email}");
  }

  void _startWebLogin() {
    print("🔐 Starting Gmail OAuth via JS (requestGmailAccessToken)...");
    try {
      js.context.callMethod("requestGmailAccessToken", [
            (token) {
          print("✅ Gmail access token received: $token");
          setState(() {
            _gmailToken = token;
          });
          _createApiClient();
        }
      ]);
    } catch (e) {
      print("❌ Error calling requestGmailAccessToken: $e");
      setState(() {
        _isInitializingGmail = false;
      });
    }
  }


  Future<void> _loadGmailProfile() async {
    if (_gmailApi == null) return;
    try {
      final profile = await _gmailApi!.users.getProfile('me');
      final email = profile.emailAddress;
      if (email != null && email.isNotEmpty) {
        setState(() {
          _gmailUserEmail = email;
          _gmailPhotoUrl = null;
        });
        print("✅ Gmail profile loaded: $_gmailUserEmail");
      } else {
        print("⚠️ Gmail profile emailAddress was null, retrying...");
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        final retry = await _gmailApi!.users.getProfile('me');
        if (retry.emailAddress != null && retry.emailAddress!.isNotEmpty) {
          setState(() {
            _gmailUserEmail = retry.emailAddress;
            _gmailPhotoUrl = null;
          });
          print("✅ Gmail profile loaded on retry: $_gmailUserEmail");
        } else {
          print("❌ Gmail profile emailAddress still null after retry");
        }
      }
    } catch (e) {
      print("❌ Failed to load Gmail profile: $e");
    }
  }


  Future<String> _getPartText(gmail.Message msg, gmail.MessagePart part) async {
    final body = part.body;
    if (body == null) return '';

    if (body.data != null && body.data!.isNotEmpty) {
      return _decodeBase64Url(body.data!);
    }

    if (body.attachmentId != null && msg.id != null && _gmailApi != null) {
      final att = await _gmailApi!.users.messages.attachments.get(
        'me',
        msg.id!,
        body.attachmentId!,
      );
      if (att.data != null && att.data!.isNotEmpty) {
        return _decodeBase64Url(att.data!);
      }
    }

    return '';
  }

  gmail.MessagePart? _findBestHtmlPart(gmail.MessagePart part) {
    if (part.mimeType == 'text/html') return part;
    final parts = part.parts ?? const [];
    for (final p in parts) {
      final found = _findBestHtmlPart(p);
      if (found != null) return found;
    }
    return null;
  }

  gmail.MessagePart? _findBestPlainPart(gmail.MessagePart part) {
    if (part.mimeType == 'text/plain') return part;
    final parts = part.parts ?? const [];
    for (final p in parts) {
      final found = _findBestPlainPart(p);
      if (found != null) return found;
    }
    return null;
  }

  // ✅ FIX 1: Re-fetch full message when Gmail truncates body data
  Future<String> _getMessageHtmlBodyAsync(gmail.Message msg) async {
    final payload = msg.payload;
    if (payload == null) return '';

    final htmlPart = _findBestHtmlPart(payload);
    if (htmlPart != null) {
      final htmlText = await _getPartText(msg, htmlPart);
      if (htmlText.trim().isNotEmpty) return htmlText;

      // Gmail truncated the body — size > 0 but data is empty
      if (htmlPart.body?.size != null && htmlPart.body!.size! > 0) {
        print("⚠️ HTML body truncated (size=${htmlPart.body!.size}), re-fetching...");
        try {
          final fullMsg = await _gmailApi!.users.messages.get(
            'me',
            msg.id!,
            format: 'full',
          );
          final retryPart = _findBestHtmlPart(fullMsg.payload!);
          if (retryPart != null) {
            final retryText = await _getPartText(fullMsg, retryPart);
            if (retryText.trim().isNotEmpty) return retryText;
          }
        } catch (e) {
          print("❌ Re-fetch HTML failed: $e");
        }
      }
    }

    final plainPart = _findBestPlainPart(payload);
    if (plainPart != null) {
      final plain = await _getPartText(msg, plainPart);

      // Gmail truncated plain body — re-fetch
      if (plain.trim().isEmpty &&
          plainPart.body?.size != null &&
          plainPart.body!.size! > 0) {
        print("⚠️ Plain body truncated (size=${plainPart.body!.size}), re-fetching...");
        try {
          final fullMsg = await _gmailApi!.users.messages.get(
            'me',
            msg.id!,
            format: 'full',
          );
          final retryPart = _findBestPlainPart(fullMsg.payload!);
          if (retryPart != null) {
            final retryText = await _getPartText(fullMsg, retryPart);
            if (retryText.trim().isNotEmpty) {
              final escaped = const HtmlEscape(HtmlEscapeMode.element).convert(retryText);
              return '<pre>$escaped</pre>';
            }
          }
        } catch (e) {
          print("❌ Re-fetch plain failed: $e");
        }
      }

      if (plain.trim().isNotEmpty) {
        final escaped = const HtmlEscape(HtmlEscapeMode.element).convert(plain);
        return '<pre>$escaped</pre>';
      }
    }

    return '';
  }

  // ✅ FIX 2: Always re-fetch fresh full message to avoid cached truncated data
  Future<void> _loadSelectedEmailBody(gmail.Message msg) async {
    setState(() {
      _selectedBodyHtml = '';
      _isBodyLoading = true;
    });

    try {
      gmail.Message freshMsg = msg;
      if (_gmailApi != null && msg.id != null) {
        try {
          freshMsg = await _gmailApi!.users.messages.get(
            'me',
            msg.id!,
            format: 'full',
          );
        } catch (e) {
          print("⚠️ Could not re-fetch message, using cached: $e");
        }
      }

      final rawHtml = await _getMessageHtmlBodyAsync(freshMsg);
      final baseHtml = rawHtml.trim().isNotEmpty ? rawHtml : '<p>(no content)</p>';

      final htmlWithCid = await _replaceCidImages(freshMsg, baseHtml);
      final sanitized = _sanitizeEmailHtml(htmlWithCid);
      final finalHtml = _injectResponsiveImageCss(sanitized);

      if (!mounted) return;
      setState(() {
        _selectedBodyHtml = finalHtml;
        _isBodyLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _selectedBodyHtml = '<p>(failed to load content)</p>';
        _isBodyLoading = false;
      });
    }
  }

  String _decodeBase64Url(String input) {
    var normalized = input.replaceAll('-', '+').replaceAll('_', '/');
    switch (normalized.length % 4) {
      case 2:
        normalized += '==';
        break;
      case 3:
        normalized += '=';
        break;
    }
    return utf8.decode(base64.decode(normalized));
  }

  gmail.MessagePart? _findPartByMimeType(
      gmail.MessagePart part,
      String mimeType,
      ) {
    if (part.mimeType == mimeType) return part;
    if (part.parts != null) {
      for (final p in part.parts!) {
        final found = _findPartByMimeType(p, mimeType);
        if (found != null) return found;
      }
    }
    return null;
  }

  String _getMessageHtmlBody(gmail.Message msg) {
    final payload = msg.payload;
    if (payload == null) return '';

    if (payload.mimeType == 'text/html' && payload.body?.data != null) {
      return _decodeBase64Url(payload.body!.data!);
    }

    final htmlPart = _findPartByMimeType(payload, 'text/html');
    if (htmlPart != null && htmlPart.body?.data != null) {
      return _decodeBase64Url(htmlPart.body!.data!);
    }

    gmail.MessagePart? textPart;
    if (payload.mimeType == 'text/plain') {
      textPart = payload;
    } else {
      textPart = _findPartByMimeType(payload, 'text/plain');
    }

    if (textPart != null && textPart.body?.data != null) {
      final plain = _decodeBase64Url(textPart.body!.data!);
      final escaped = const HtmlEscape(HtmlEscapeMode.element).convert(plain);
      return '<pre>$escaped</pre>';
    }

    return '';
  }


  Future<void> _loadArchivedEmails() async {
    if (_gmailApi == null) return;

    try {
      setState(() {
        _isGmailLoading = true;
        _currentLabelId = 'ARCHIVED_VIEW';
        _nextPageToken = null;
        _hasMore = false;
      });

      print("📥 Loading archived emails (-in:inbox -in:trash -in:spam)");

      final response = await _gmailApi!.users.messages.list(
        'me',
        q: '-in:inbox -in:trash -in:spam',
        maxResults: 50,
      );

      final messages = <gmail.Message>[];

      if (response.messages != null) {
        for (final m in response.messages!) {
          final full = await _gmailApi!.users.messages.get(
            'me',
            m.id!,
            format: 'full',
          );
          messages.add(full);
        }
      }

      setState(() {
        _emails = messages;
        _selectedEmail = _emails.isNotEmpty ? _emails.first : null;
        _selectedBodyHtml = '';
      });
    } catch (e) {
      print("❌ Failed to load archived emails: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isGmailLoading = false;
        });
      }
    }
  }


  void _createApiClient() {
    if (_gmailToken == null) {
      print("❌ _gmailToken is null, cannot create GmailApi client.");
      setState(() {
        _isInitializingGmail = false;
      });
      return;
    }

    print("⚙️ Creating GmailApi client with web token...");
    final client = _WebClient(_gmailToken!);
    setState(() {
      _gmailApi = gmail.GmailApi(client);
      _isInitializingGmail = false;
    });

    _loadGmailProfile().then((_) {
      _loadLabel('INBOX').then((_) {
        _maybeStartInboxPolling();
      });
    });
  }


  Future<void> _loadLabel(String labelId) async {
    if (_gmailApi == null) return;

    setState(() {
      _isGmailLoading = true;
      _currentLabelId = labelId;
      _nextPageToken = null;
      _hasMore = true;
    });

    try {
      final res = await _gmailApi!.users.messages.list(
        'me',
        labelIds: [labelId],
        maxResults: 20,
      );

      final List<gmail.Message> loaded = [];

      if (res.messages != null) {
        for (final m in res.messages!) {
          if (m.id == null) continue;
          final full = await _gmailApi!.users.messages.get(
            'me',
            m.id!,
            format: 'full',
          );
          loaded.add(full);
        }
      }

      setState(() {
        _emails = loaded;
        _nextPageToken = res.nextPageToken;
        _hasMore = _nextPageToken != null;

        if (labelId == 'INBOX' && loaded.isNotEmpty) {
          _lastSeenInboxTopId = loaded.first.id;
        }

        if (_selectedEmail != null && loaded.any((e) => e.id == _selectedEmail!.id)) {
          // keep selection
        } else {
          _selectedEmail = null;
          _selectedBodyHtml = '';
        }
      });
    } catch (e) {
      print("❌ Failed to load label $labelId: $e");
    } finally {
      if (mounted) setState(() => _isGmailLoading = false);
    }
  }


  String _getHeader(gmail.Message msg, String name) {
    final headers = msg.payload?.headers ?? [];
    try {
      return headers
          .firstWhere(
            (h) => (h.name ?? '').toLowerCase() == name.toLowerCase(),
        orElse: () => gmail.MessagePartHeader(),
      )
          .value ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _getPlainBody(gmail.Message msg) {
    String? data;

    if (msg.payload?.mimeType == 'text/plain') {
      data = msg.payload?.body?.data;
    } else {
      final parts = msg.payload?.parts ?? [];
      final textPart = parts.firstWhere(
            (p) => p.mimeType == 'text/plain',
        orElse: () => gmail.MessagePart(),
      );
      data = textPart.body?.data;
    }

    if (data == null) return '';

    final normalized = data.replaceAll('-', '+').replaceAll('_', '/');
    try {
      final bytes = base64Decode(normalized);
      final body = utf8.decode(bytes);
      return body;
    } catch (e) {
      print("⚠️ Error decoding email body: $e");
      return '';
    }
  }


  int tabIndex = 0; // 0 = All, 1 = Read, 2 = Unread

  List<gmail.Message> _filterEmails({required bool isInbox}) {
    Iterable<gmail.Message> result = _emails;

    if (isInbox) {
      if (tabIndex == 1) {
        result = result.where((msg) {
          final labels = msg.labelIds ?? const <String>[];
          return !labels.contains('UNREAD');
        });
      } else if (tabIndex == 2) {
        result = result.where((msg) {
          final labels = msg.labelIds ?? const <String>[];
          return labels.contains('UNREAD');
        });
      }
    }

    final q = _searchQuery.trim();
    if (q.isNotEmpty) {
      result = result.where((msg) {
        final subject = _getHeader(msg, 'Subject').toLowerCase();
        final fromName = _extractDisplayName(_getHeader(msg, 'From')).toLowerCase();
        final body = _getPlainBody(msg).toLowerCase();
        return subject.contains(q) || fromName.contains(q) || body.contains(q);
      });
    }

    return result.toList();
  }


  String _sanitizeRawDate(String raw) {
    return raw.split('(').first.trim();
  }

  String _formatListDate(String rawDate, {String? internalDate}) {
    DateTime? dt;

    if (internalDate != null && internalDate.isNotEmpty) {
      try {
        dt = DateTime.fromMillisecondsSinceEpoch(
          int.parse(internalDate),
          isUtc: true,
        ).toLocal();
      } catch (_) {}
    }

    if (dt == null && rawDate.isNotEmpty) {
      final clean = _sanitizeRawDate(rawDate);
      final formats = [
        "EEE, d MMM yyyy HH:mm:ss Z",
        "d MMM yyyy HH:mm:ss Z",
        "EEE, d MMM yyyy HH:mm Z",
        "d MMM yyyy HH:mm Z",
      ];

      for (final f in formats) {
        try {
          dt = DateFormat(f).parseUtc(clean).toLocal();
          break;
        } catch (_) {}
      }
    }

    if (dt == null) return rawDate;
    return DateFormat('MMM d').format(dt);
  }

  String _formatPreviewDate(String rawDate, {String? internalDate}) {
    DateTime? dt;

    if (internalDate != null && internalDate.isNotEmpty) {
      try {
        dt = DateTime.fromMillisecondsSinceEpoch(
          int.parse(internalDate),
          isUtc: true,
        ).toLocal();
      } catch (_) {}
    }

    if (dt == null && rawDate.isNotEmpty) {
      final clean = _sanitizeRawDate(rawDate);
      final formats = [
        "EEE, d MMM yyyy HH:mm:ss Z",
        "d MMM yyyy HH:mm:ss Z",
        "EEE, d MMM yyyy HH:mm Z",
        "d MMM yyyy HH:mm Z",
      ];

      for (final f in formats) {
        try {
          dt = DateFormat(f).parseUtc(clean).toLocal();
          break;
        } catch (_) {}
      }
    }

    if (dt == null) return rawDate;
    return DateFormat('yyyy-MM-dd | hh:mma').format(dt).toLowerCase();
  }


  String _extractDisplayName(String fromFull) {
    final match = RegExp(r'^(.*)<(.*)>$').firstMatch(fromFull);
    if (match != null) {
      final name = (match.group(1) ?? '').trim();
      if (name.isNotEmpty) return name;
    }
    return fromFull;
  }

  bool _isSelectedEmailStarred() {
    return _selectedEmail?.labelIds?.contains('STARRED') ?? false;
  }

  List<EmailAttachment> _getAttachmentsForMessage(gmail.Message msg) {
    final List<EmailAttachment> attachments = [];

    void walkParts(List<gmail.MessagePart>? parts) {
      if (parts == null) return;
      for (final part in parts) {
        final filename = part.filename ?? '';
        final body = part.body;
        if (filename.isNotEmpty && body != null && body.attachmentId != null) {
          attachments.add(
            EmailAttachment(
              fileName: filename,
              sizeBytes: body.size ?? 0,
              attachmentId: body.attachmentId!,
              messageId: msg.id ?? '',
            ),
          );
        }
        if (part.parts != null && part.parts!.isNotEmpty) {
          walkParts(part.parts);
        }
      }
    }

    walkParts(msg.payload?.parts);
    return attachments;
  }


  Future<void> _downloadAttachment(EmailAttachment attachment) async {
    if (_gmailApi == null) {
      showTopRightToast(context, message: "Gmail connection unavailable!", isSuccess: false);
      return;
    }

    try {
      print("⬇️ Downloading attachment: ${attachment.fileName}");

      final att = await _gmailApi!.users.messages.attachments.get(
        'me',
        attachment.messageId,
        attachment.attachmentId,
      );

      final data = att.data;
      if (data == null) throw Exception("Attachment data is null");

      final normalized = data.replaceAll('-', '+').replaceAll('_', '/');
      final bytes = base64Decode(normalized);

      final blob = html_dom.Blob([bytes]);
      final url = html_dom.Url.createObjectUrlFromBlob(blob);

      final anchor = html_dom.AnchorElement(href: url)
        ..download = attachment.fileName
        ..click();

      html_dom.Url.revokeObjectUrl(url);

      print("✅ Attachment downloaded: ${attachment.fileName}");
      showTopRightToast(context, message: "Attachment downloaded", isSuccess: true);
    } catch (e) {
      print("❌ Error downloading attachment: $e");
      showTopRightToast(context, message: "Failed to download attachment", isSuccess: false);
    }
  }


  @override
  void dispose() {
    _stopInboxPolling();
    _emailListController.dispose();
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _maybeStartInboxPolling();
    } else {
      _stopInboxPolling();
    }
  }


  // ------------------ LIVE INBOX POLLING ------------------

  void _maybeStartInboxPolling() {
    if (_gmailApi == null) return;
    if (_currentLabelId != 'INBOX') return;
    if (_isPolling) return;

    _isPolling = true;
    _inboxPollTimer?.cancel();
    _inboxPollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _checkForNewInboxMail();
    });
  }

  void _stopInboxPolling() {
    _isPolling = false;
    _inboxPollTimer?.cancel();
    _inboxPollTimer = null;
  }

  Future<void> _checkForNewInboxMail() async {
    if (!mounted || _gmailApi == null) return;
    if (_currentLabelId != 'INBOX') return;
    if (_pollRequestRunning) return;
    _pollRequestRunning = true;

    try {
      final res = await _gmailApi!.users.messages.list(
        'me',
        labelIds: const ['INBOX'],
        maxResults: 15,
      );

      final ids = res.messages
          ?.map((m) => m.id)
          .whereType<String>()
          .toList() ??
          [];

      if (ids.isEmpty) return;

      if (_lastSeenInboxTopId == null) {
        _lastSeenInboxTopId = ids.first;
        return;
      }

      final oldIndex = ids.indexOf(_lastSeenInboxTopId!);
      if (oldIndex == 0) return;

      final newIds = (oldIndex == -1) ? ids : ids.sublist(0, oldIndex);
      if (newIds.isEmpty) return;

      final List<gmail.Message> newFullMessages = [];
      for (final id in newIds.reversed) {
        final full = await _gmailApi!.users.messages.get('me', id, format: 'full');
        newFullMessages.add(full);
      }

      setState(() {
        final existingIds = _emails.map((e) => e.id).toSet();
        final uniqueNew = newFullMessages.where((m) => !existingIds.contains(m.id)).toList();
        _emails.insertAll(0, uniqueNew);
      });

      _lastSeenInboxTopId = ids.first;

      showTopRightToast(
        context,
        message: "${newIds.length} new email${newIds.length > 1 ? "s" : ""} received",
        isSuccess: true,
      );
    } catch (e) {
      print("❌ Inbox poll error: $e");
    } finally {
      _pollRequestRunning = false;
    }
  }

  // ------------------ PAGINATION LOAD MORE ------------------

  Future<void> _loadMoreEmails() async {
    if (_gmailApi == null) return;
    if (_isLoadingMore) return;
    if (!_hasMore) return;
    if (_nextPageToken == null) return;
    if (_searchQuery.trim().isNotEmpty) return;

    setState(() => _isLoadingMore = true);

    try {
      final res = await _gmailApi!.users.messages.list(
        'me',
        labelIds: [_currentLabelId],
        maxResults: 20,
        pageToken: _nextPageToken,
      );

      final List<gmail.Message> more = [];

      if (res.messages != null) {
        for (final m in res.messages!) {
          if (m.id == null) continue;
          final full = await _gmailApi!.users.messages.get('me', m.id!, format: 'full');
          more.add(full);
        }
      }

      setState(() {
        final existingIds = _emails.map((e) => e.id).toSet();
        final uniqueMore = more.where((m) => !existingIds.contains(m.id)).toList();
        _emails.addAll(uniqueMore);
        _nextPageToken = res.nextPageToken;
        _hasMore = _nextPageToken != null;
      });
    } catch (e) {
      print("❌ load more error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }


  String _buildInitial(String name, String email) {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    if (trimmedName.isNotEmpty) return trimmedName[0].toUpperCase();
    if (trimmedEmail.isNotEmpty) return trimmedEmail[0].toUpperCase();
    return '';
  }


  @override
  Widget build(BuildContext context) {

    final String currentLabel = sidebarItems[selectedIndex]["label"] ?? "Inbox";
    final bool isInbox = currentLabel == "Inbox";
    final bool isArchiveView = currentLabel == "Archive";
    final filteredEmails = _filterEmails(isInbox: isInbox);

    if (_isInitializingGmail) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_gmailApi == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.email_outlined, size: 48),
            const SizedBox(height: 12),
            const Text(
              "Gmail connection required",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "We couldn't connect to Gmail. Please try again.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startWebLogin,
              child: const Text("Retry Gmail Login"),
            ),
          ],
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;

    final selected = _selectedEmail;
    String fromName = '';
    String fromEmail = '';
    String subject = '';
    String date = '';
    List<EmailAttachment> attachments = [];

    if (selected != null) {
      final fromFull = _getHeader(selected, 'From');
      subject = _getHeader(selected, 'Subject');
      final rawDateHeader = _getHeader(selected, 'Date');
      date = _formatPreviewDate(rawDateHeader, internalDate: selected.internalDate);

      final match = RegExp(r'^(.*)<(.*)>$').firstMatch(fromFull);
      if (match != null) {
        fromName = (match.group(1) ?? '').trim();
        fromEmail = (match.group(2) ?? '').trim();
      } else {
        fromName = fromFull;
      }

      if (fromName.isEmpty) fromName = 'No sender';
      if (subject.isEmpty) subject = '(no subject)';
      attachments = _getAttachmentsForMessage(selected);
    }


    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width >= 400 ? AppPadding.p10 : AppPadding.p5,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorManager.bordercolor)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ───────────────── Sidebar ─────────────────
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.only(top: width >= 500 ? 20 : 10),
                color: ColorManager.white,
                child: ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blueGrey.shade100,
                              child: Text(
                                _buildInitial('', _gmailUserEmail ?? ''),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),

                            width >= 900
                                ? const Expanded(child: SizedBox())
                                : const SizedBox(width: 10),

                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 35,
                                width: 120,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    if (_gmailApi == null) {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: Container(
                                            width: 300,
                                            height: 150,
                                            decoration: BoxDecoration(
                                              color: ColorManager.white,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.redAccent.shade100,
                                                    borderRadius: const BorderRadius.only(
                                                      topLeft: Radius.circular(8),
                                                      topRight: Radius.circular(8),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      const Padding(
                                                        padding: EdgeInsets.only(left: 10),
                                                        child: Text(
                                                          "Gmail Not Ready",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () => Navigator.pop(ctx),
                                                        icon: const Icon(Icons.close, color: Colors.white, size: 18),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Spacer(),
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                                  child: Text(
                                                    'Gmail is still connecting.\nPlease wait and try again.',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black87,
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    if (_gmailUserEmail == null || _gmailUserEmail!.isEmpty) {
                                      print("⚠️ Compose tapped but email null — re-fetching profile...");
                                      await _loadGmailProfile();
                                    }

                                    final senderEmail = _gmailUserEmail ?? _user?.email ?? '';
                                    print("✉️ Opening compose dialog... fromEmail = $senderEmail");

                                    if (!mounted) return;

                                    showGeneralDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      barrierLabel: 'New Message',
                                      transitionDuration: const Duration(milliseconds: 200),
                                      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
                                      transitionBuilder: (context, anim1, anim2, child) {
                                        return Align(
                                          alignment: Alignment.bottomRight,
                                          child: Padding(
                                            padding: const EdgeInsets.all(AppPadding.p20),
                                            child: ScaleTransition(
                                              scale: anim1,
                                              child: FadeTransition(
                                                opacity: anim1,
                                                child: Material(
                                                  elevation: 10,
                                                  child: NewMessageContainer(
                                                    gmailApi: _gmailApi!,
                                                    fromEmail: senderEmail,
                                                    fromPhotoUrl: _gmailPhotoUrl,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  icon: SvgPicture.asset("images/communication/compose.svg"),
                                  label: Text(
                                    "COMPOSE",
                                    style: TextStyle(
                                      fontSize: FontSize.s12,
                                      color: ColorManager.greenBright,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: ColorManager.greenBright,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: ColorManager.greenBright,
                                        width: 1.5,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSize.s10),
                        ...List.generate(sidebarItems.length, (index) {
                          final item = sidebarItems[index];
                          final bool selectedItem = selectedIndex == index;
                          return InkWell(
                            onTap: () async {
                              setState(() {
                                selectedIndex = index;
                              });

                              final label = item["label"];
                              String? labelId;

                              switch (label) {
                                case "Inbox":
                                  labelId = 'INBOX';
                                  break;
                                case "Starred":
                                  labelId = 'STARRED';
                                  break;
                                case "Archive":
                                  _stopInboxPolling();
                                  await _loadArchivedEmails();
                                  return;
                                case "Sent":
                                  labelId = 'SENT';
                                  break;
                                case "Drafts":
                                  labelId = 'DRAFT';
                                  break;
                                case "Spam":
                                  labelId = 'SPAM';
                                  break;
                                case "Trash":
                                  labelId = 'TRASH';
                                  break;
                                default:
                                  labelId = 'INBOX';
                              }

                              print("📂 Sidebar tap: $label -> $labelId");
                              if (labelId != null) {
                                await _loadLabel(labelId);
                                if (labelId == 'INBOX') {
                                  _maybeStartInboxPolling();
                                } else {
                                  _stopInboxPolling();
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: AppPadding.p4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppPadding.p8,
                                vertical: AppPadding.p10,
                              ),
                              decoration: BoxDecoration(
                                color: selectedItem
                                    ? ColorManager.greenBright.withOpacity(0.15)
                                    : ColorManager.greenBright.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    item["icon"]!,
                                    height: width >= 900 ? 18 : 12,
                                    width: width >= 900 ? 18 : 12,
                                    color: selectedItem ? Colors.black : Colors.black54,
                                  ),
                                  SizedBox(
                                    width: width >= 900 ? AppSize.s12 : AppSize.s6,
                                  ),
                                  Text(
                                    item["label"]!,
                                    style: TextStyle(
                                      color: selectedItem ? Colors.black : Colors.black87,
                                      fontWeight: selectedItem ? FontWeight.bold : FontWeight.normal,
                                      fontSize: FontSize.s12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppSize.s10),
            VerticalDivider(color: ColorManager.bordercolor, width: 2),

            /// ───────────────── Inbox list (middle column) ─────────────────
            Expanded(
              flex: 2,
              child: Container(
                height: AppSize.s720,
                decoration: BoxDecoration(
                  color: ColorManager.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        width >= 900 ? AppPadding.p16 : AppPadding.p8,
                        AppPadding.p30,
                        width >= 900 ? AppPadding.p16 : AppPadding.p10,
                        AppPadding.p10,
                      ),
                      child: Text(
                        sidebarItems[selectedIndex]["label"] ?? "Inbox",
                        style: const TextStyle(
                          fontSize: FontSize.s16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width >= 900 ? AppPadding.p16 : AppPadding.p8,
                        vertical: AppPadding.p8,
                      ),
                      child: Container(
                        height: AppPadding.p35,
                        padding: const EdgeInsets.symmetric(horizontal: AppPadding.p12),
                        decoration: BoxDecoration(
                          color: ColorManager.fillColor,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: ColorManager.bordercolor, width: 1),
                        ),
                        child: TextField(
                          controller: _searchController,
                          cursorColor: ColorManager.black,
                          style: TextStyle(color: ColorManager.grey, fontSize: 12),
                          decoration: InputDecoration(
                            icon: Icon(Icons.search, color: ColorManager.grey, size: IconSize.I20),
                            hintText: "Search Here",
                            hintStyle: TextStyle(color: ColorManager.grey, fontSize: 12),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(bottom: AppPadding.p15),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                        ),
                      ),
                    ),
                    if (isInbox)
                      Padding(
                        padding: EdgeInsets.only(
                          left: width >= 900 ? AppPadding.p16 : AppPadding.p8,
                          top: AppPadding.p12,
                          bottom: AppPadding.p8,
                        ),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: <Widget>[
                                _buildTab("All", 0),
                                const SizedBox(width: AppSize.s12),
                                _buildTab("Read", 1),
                                const SizedBox(width: AppSize.s12),
                                _buildTab("Unread", 2),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSize.s10),
                    Expanded(
                      child: _isGmailLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ScrollConfiguration(
                        behavior: const ScrollBehavior().copyWith(scrollbars: false),
                        child: ListView.builder(
                          controller: _emailListController,
                          itemCount: filteredEmails.length + 1,
                          itemBuilder: (context, index) {

                            if (index == filteredEmails.length) {
                              if (_isLoadingMore) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              if (!_hasMore) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(child: Text("No more emails")),
                                );
                              }
                              return const SizedBox(height: 30);
                            }

                            final msg = filteredEmails[index];
                            final fromFull = _getHeader(msg, 'From');
                            final fromNameOnly = _extractDisplayName(fromFull);
                            final subject = _getHeader(msg, 'Subject');
                            final rawDateHeader = _getHeader(msg, 'Date');
                            final listDate = _formatListDate(
                              rawDateHeader,
                              internalDate: msg.internalDate,
                            );

                            final isSelected = _selectedEmail?.id == msg.id;
                            final labels = msg.labelIds ?? const <String>[];
                            final isUnread = labels.contains('UNREAD');

                            return InkWell(
                              onTap: () async {
                                print("📨 Selected email index=$index id=${msg.id}");
                                setState(() {
                                  _selectedEmail = msg;
                                  _selectedBodyHtml = '';
                                  _isBodyLoading = true;
                                });
                                await _markAsRead(msg);
                                await _loadSelectedEmailBody(msg);
                              },
                              child: _emailListTile(
                                fromNameOnly,
                                listDate,
                                subject,
                                isSelected,
                                (msg.labelIds ?? const <String>[]).contains('UNREAD'),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            VerticalDivider(color: ColorManager.bordercolor, width: 2),

            /// ───────────────── Email Preview (right column) ─────────────────
            Expanded(
              flex: 5,
              child: _selectedEmail == null
                  ? Container(
                height: AppSize.s660,
                color: ColorManager.white,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mail_outline, size: 40, color: ColorManager.mediumgrey),
                      const SizedBox(height: 8),
                      Text(
                        "Select an email to view",
                        style: TextStyle(
                          fontSize: FontSize.s12,
                          color: ColorManager.mediumgrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : Column(
                children: [
                  // ── Action bar (star, archive, delete) ──
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width >= 900 ? AppPadding.p15 : AppPadding.p8,
                      vertical: AppPadding.p10,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: width >= 1100 ? 6 : 8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: _FunctionalIcon(
                                  assetPath: "images/communication/email/star_filled.svg",
                                  color: _isSelectedEmailStarred() ? Colors.amber : Colors.black,
                                  onTap: _toggleStar,
                                ),
                              ),
                              if (!isArchiveView)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: _FunctionalIcon(
                                    assetPath: "images/communication/email/email_download.svg",
                                    onTap: _onArchivePressed,
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: _FunctionalIcon(
                                  assetPath: "images/communication/email/email_delete.svg",
                                  onTap: _onDeletePressed,
                                ),
                              ),
                              const SizedBox(width: 80),
                            ],
                          ),
                        ),
                        width >= 1100
                            ? const Expanded(flex: 3, child: SizedBox())
                            : const Offstage(),
                        Expanded(
                          flex: width >= 1100 ? 1 : 3,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // ── Email content area ──
                  Container(
                    height: AppSize.s660,
                    color: ColorManager.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Sender header (pinned, does NOT scroll) ──
                        Container(
                          color: ColorManager.fillColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: width >= 1100 ? AppPadding.p20 : AppPadding.p10,
                            vertical: AppPadding.p8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: width >= 1100 ? 20 : 12,
                                    backgroundColor: Colors.blueGrey.shade100,
                                    child: Text(
                                      _buildInitial(fromName, fromEmail),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: width >= 1100 ? 14 : 10,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSize.s10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fromName.isNotEmpty ? fromName : "No sender",
                                        style: TextStyle(
                                          fontSize: width >= 1100 ? FontSize.s12 : FontSize.s10,
                                          fontWeight: FontWeight.w700,
                                          color: ColorManager.black,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        fromEmail,
                                        style: TextStyle(
                                          fontSize: width >= 1100 ? FontSize.s12 : FontSize.s10,
                                          fontWeight: FontWeight.w400,
                                          color: ColorManager.mediumgrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                date,
                                style: TextStyle(
                                  color: ColorManager.mediumgrey,
                                  fontWeight: FontWeight.w500,
                                  fontSize: width >= 1100 ? FontSize.s12 : FontSize.s10,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ✅ FIX 3: SingleChildScrollView + Column replaces
                        // CustomScrollView + SliverChildListDelegate.
                        // flutter_html needs a bounded Column parent to correctly
                        // measure its full intrinsic height. Slivers caused
                        // content to be clipped/cut off for long emails.
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.all(AppPadding.p20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                // Subject
                                const SizedBox(height: AppSize.s8),
                                Text(
                                  subject.isNotEmpty ? subject : "(no subject)",
                                  style: TextStyle(
                                    fontSize: width >= 1100 ? FontSize.s12 : FontSize.s10,
                                    fontWeight: FontWeight.w700,
                                    color: ColorManager.black,
                                  ),
                                ),
                                const SizedBox(height: AppSize.s12),

                                // Body
                                if (_isBodyLoading)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(child: CircularProgressIndicator()),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: html.Html(
                                      data: _selectedBodyHtml.isNotEmpty
                                          ? _selectedBodyHtml
                                          : "<p>(no content)</p>",
                                      style: {
                                        "body": html.Style(
                                          margin: html.Margins.zero,
                                          padding: html.HtmlPaddings.zero,
                                        ),
                                      },
                                    ),
                                  ),

                                // Attachments
                                if (attachments.isNotEmpty) ...[
                                  const SizedBox(height: AppSize.s20),
                                  Row(
                                    children: [
                                      const Icon(Icons.attach_file, size: 18, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${attachments.length} attachment${attachments.length > 1 ? 's' : ''}",
                                        style: TextStyle(
                                          fontSize: width >= 1100 ? FontSize.s12 : FontSize.s10,
                                          fontWeight: FontWeight.w600,
                                          color: ColorManager.mediumgrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSize.s10),
                                  Wrap(
                                    spacing: 15,
                                    runSpacing: 10,
                                    children: attachments.map((a) {
                                      return EmailScreenCommunication._attachmentChip(
                                        fileName: a.fileName,
                                        fileSize: _formatBytes(a.sizeBytes),
                                        onDownload: () => _downloadAttachment(a),
                                      );
                                    }).toList(),
                                  ),
                                ],

                                // Bottom breathing room
                                const SizedBox(height: 60),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }


  Widget _buildTab(String label, int index) {
    final bool isInbox = sidebarItems[selectedIndex]["label"] == "Inbox";
    final bool isActive = tabIndex == index && isInbox;

    return InkWell(
      onTap: () {
        if (!isInbox) return;
        setState(() {
          tabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p20,
          vertical: AppPadding.p8,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.grey[800] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? ColorManager.white : Colors.black54,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }


  Widget _emailListTile(
      String sender,
      String date,
      String subject,
      bool selected,
      bool isUnread,
      ) {
    final width = MediaQuery.of(context).size.width;
    final textSize = width >= 900 ? AppSize.s12 : AppSize.s10;

    final senderStyle = TextStyle(
      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w400,
      fontSize: textSize,
      color: isUnread ? Colors.black : const Color(0xFF777777),
    );

    final subjectStyle = TextStyle(
      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
      fontSize: textSize,
      color: isUnread ? Colors.black : const Color(0xFF999999),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width >= 900 ? AppPadding.p12 : AppPadding.p8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: selected ? ColorManager.greenBright.withOpacity(0.05) : Colors.transparent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: width >= 900 ? 18 : 12,
            backgroundColor: isUnread ? Colors.blue.shade100 : Colors.grey.shade300,
            child: Text(
              sender.isNotEmpty ? sender[0].toUpperCase() : '?',
              style: TextStyle(color: Colors.black, fontSize: textSize),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        sender,
                        style: senderStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      date,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: width >= 600 ? 12 : 10,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: subjectStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}