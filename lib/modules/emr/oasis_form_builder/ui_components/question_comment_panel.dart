import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/model/question_comment_model.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/services/api/managers/comment_manager.dart';

class QuestionCommentPanel extends StatefulWidget {
  final int patientFormId;
  final int questionId;
  final String questionTitle;
  final VoidCallback onClose;
  final void Function(int questionId, String comment, int index)? onCommentAdded;
  final List<Map<String, dynamic>> initialComments;
  final void Function(int questionId, int listIndex)? onCommentResolved;
  final void Function(int questionId, int listIndex)? onCommentDeleted;
  final Map<String, dynamic> commentUsers;
  // Bumped by the parent whenever it reloads subform data from the server
  // (e.g. after a successful Save). Lets this panel tell a real reload
  // apart from an unrelated parent rebuild, so it only drops its optimistic
  // "Unsaved" local echo when the server data has actually changed.
  final int reloadToken;

  const QuestionCommentPanel({
    super.key,
    required this.patientFormId,
    required this.questionId,
    required this.questionTitle,
    required this.onClose,
    this.onCommentAdded,
    this.initialComments = const [],
    this.onCommentResolved,
    this.onCommentDeleted,
    this.commentUsers = const {},
    this.reloadToken = 0,
  });

  @override
  State<QuestionCommentPanel> createState() => _QuestionCommentPanelState();
}

class _QuestionCommentPanelState extends State<QuestionCommentPanel> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  List<QuestionCommentModel> _comments = [];
  List<String> _pendingLocalComments = [];
  bool _isLoading = true;
  bool _showInput = false;
  bool _isSending = false;
  int _currentUserId = 0;

  @override
  void initState() {
    super.initState();
    _loadComments();
    TokenManager.getuserId().then((id) {
      if (mounted) setState(() => _currentUserId = id);
    });
  }

  @override
  void didUpdateWidget(covariant QuestionCommentPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questionId != widget.questionId) {
      _pendingLocalComments = [];
      _loadComments();
    } else if (oldWidget.reloadToken != widget.reloadToken) {
      // Parent just reloaded from the server — its initialComments now
      // includes what we optimistically echoed locally, so drop the local
      // echo to avoid showing the same comment twice.
      setState(() {
        _pendingLocalComments = [];
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final comments = await CommentManager().getComments(
      context,
      patientFormId: widget.patientFormId,
      questionId: widget.questionId,
    );
    if (!mounted) return;
    setState(() {
      _comments = comments;
      _isLoading = false;
    });
  }

  Future<void> _resolveComment(int commentId) async {
    await CommentManager().resolveComment(context, commentId: commentId);
    if (!mounted) return;
    await _loadComments();
  }

  Future<void> _deleteComment(int commentId) async {
    await CommentManager().deleteComment(context, commentId: commentId);
    if (!mounted) return;
    await _loadComments();
  }

  int _nextIndex() {
    int maxIndex = -1;
    for (final c in widget.initialComments) {
      final idx = c['index'] as int? ?? -1;
      if (idx > maxIndex) maxIndex = idx;
    }
    for (final c in _comments) {
      if (c.index > maxIndex) maxIndex = c.index;
    }
    return maxIndex + 1;
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    widget.onCommentAdded?.call(widget.questionId, text, _nextIndex());
    setState(() {
      _pendingLocalComments.add(text);
      _commentController.clear();
      _showInput = false;
    });
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('EEE dd MMM yyyy, h:mm a').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF5C6BC0),
      Color(0xFF26A69A),
      Color(0xFFEF5350),
      Color(0xFFAB47BC),
      Color(0xFF42A5F5),
      Color(0xFFFF7043),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (_showInput) _buildInputArea(),
          Expanded(
            child: Stack(
              children: [
                _buildCommentList(),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Column(
                    children: [
                      _scrollButton(
                        icon: Icons.keyboard_arrow_up,
                        onTap: () => _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _scrollButton(
                        icon: Icons.keyboard_arrow_down,
                        onTap: () => _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
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
    );
  }

  Widget _scrollButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: ColorManager.blueprime,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        spacing: 12,
        children: [
          Row(
            children: [
              const Text(
                'Comments:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const Spacer(),
              InkWell(
                onTap: widget.onClose,
                child: Icon(Icons.close, size: 18, color: Colors.grey.shade600),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Add Comment',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ColorManager.granitegray,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => setState(() => _showInput = !_showInput),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: ColorManager.blueprime,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              maxLines: 3,
              minLines: 1,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Type your comment...',
                hintStyle:
                    TextStyle(fontSize: 12, color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ColorManager.blueprime),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _isSending ? null : _addComment,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isSending
                    ? Colors.grey.shade400
                    : ColorManager.blueprime,
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    final hasAny = _comments.isNotEmpty ||
        _pendingLocalComments.isNotEmpty ||
        widget.initialComments.isNotEmpty;
    if (!hasAny) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 32, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              'No comments yet',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ],
        ),
      );
    }
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        ...widget.initialComments.asMap().entries.map(
              (e) => _buildInitialComment(e.key, e.value),
            ),
        ..._comments.map((c) => _buildApiComment(c)),
        ..._pendingLocalComments.map((text) => _buildCommentCard(
              authorName: 'You',
              initials: 'Y',
              avatarColor: ColorManager.blueprime,
              createdAt: '',
              text: text,
              showUnsaved: true,
            )),
      ],
    );
  }

  Widget _buildInitialComment(int listIndex, Map<String, dynamic> c) {
    final rawUserId = c['user_id'];
    final userIdKey = rawUserId?.toString() ?? '0';
    final text = c['comment'] as String? ?? '';
    final createdAt = c['created_at'] as String? ?? '';
    final isResolved = c['resolution_status'] as bool? ?? false;

    final userInfo = widget.commentUsers[userIdKey] as Map<String, dynamic>?;
    final authorName = userInfo?['name'] as String? ?? 'User #$userIdKey';
    final imgUrl = userInfo?['imgurl'] as String?;

    final parts = authorName.trim().split(' ');
    final initials = parts.isEmpty || parts[0].isEmpty
        ? '?'
        : parts.length == 1
            ? parts[0][0].toUpperCase()
            : '${parts[0][0]}${parts[1][0]}'.toUpperCase();

    return _buildCommentCard(
      authorName: authorName,
      initials: initials,
      avatarColor: _avatarColor(authorName),
      imageUrl: imgUrl,
      createdAt: createdAt,
      text: text,
      isResolved: isResolved,
      onResolve: !isResolved
          ? () => widget.onCommentResolved?.call(widget.questionId, listIndex)
          : null,
      onDelete: !isResolved
          ? () => widget.onCommentDeleted?.call(widget.questionId, listIndex)
          : null,
    );
  }

  Widget _buildApiComment(QuestionCommentModel comment) {
    final author = comment.createdBy;
    final Color avatarBg = author.color != null
        ? Color(
            int.tryParse(
                    author.color!.replaceFirst('#', '').padLeft(8, 'FF')) ??
                0xFF5C6BC0)
        : _avatarColor(author.name);

    return _buildCommentCard(
      authorName: author.name,
      initials: author.initials,
      avatarColor: avatarBg,
      createdAt: comment.createdAt,
      text: comment.comment,
      isResolved: comment.isResolved,
      onResolve:
          !comment.isResolved ? () => _resolveComment(comment.id) : null,
      onDelete:
          !comment.isResolved ? () => _deleteComment(comment.id) : null,
    );
  }

  Widget _buildCommentCard({
    required String authorName,
    required String initials,
    required Color avatarColor,
    required String createdAt,
    required String text,
    String? imageUrl,
    bool isResolved = false,
    bool showUnsaved = false,
    VoidCallback? onResolve,
    VoidCallback? onDelete,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: avatarColor,
                    backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : null,
                    child: imageUrl == null || imageUrl.isEmpty
                        ? Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (createdAt.isNotEmpty)
                    Text(
                      _formatDate(createdAt),
                      style: TextStyle(
                          fontSize: 9, color: Colors.grey.shade500),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                              height: 1.4),
                        ),
                        if (showUnsaved) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color:
                                      Colors.orange.withValues(alpha: 0.4)),
                            ),
                            child: const Text(
                              'Unsaved',
                              style: TextStyle(
                                  fontSize: 9, color: Colors.orange),
                            ),
                          ),
                        ],
                        if (isResolved) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.check_circle,
                                  size: 11, color: Colors.green.shade600),
                              const SizedBox(width: 3),
                              Text(
                                'Resolved',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.green.shade600),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onDelete != null || onResolve != null) ...[
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onDelete != null)
                          _actionIcon(
                            icon: Icons.close,
                            color: Colors.red,
                            onTap: onDelete,
                          ),
                        if (onResolve != null) ...[
                          const SizedBox(width: 6),
                          _actionIcon(
                            icon: Icons.check,
                            color: Colors.green,
                            onTap: onResolve,
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
      ],
    );
  }

  Widget _actionIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, size: 13, color: color),
      ),
    );
  }
}
