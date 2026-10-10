import 'package:flutter/widgets.dart';
import 'package:symmetry_emr/app/router/emr_router.dart';
import 'package:symmetry_emr/app/router/emr_routes.dart';

/// Keeps a QA or Coder desktop on the page its URL names, and its URL on the
/// page it is on.
///
/// Those desktops keep their page in an app-wide provider (QaCoordinator /
/// CoderProvider) and change it with `jumpTo` from their own tab buttons and
/// dashboard cards. This sits between that provider and the URL:
///
/// * the URL changes (refresh, a link, Back/Forward) → `jumpTo` that page;
/// * the provider moves to another page (a tab or card tap) → go to its URL,
///   a Back step like any website.
///
/// Each direction leaves the other already agreeing, so neither loops.
class RolePageSync extends StatefulWidget {
  const RolePageSync({
    super.key,
    required this.page,
    required this.listenable,
    required this.current,
    required this.jumpTo,
    required this.child,
  });

  /// The page the URL names.
  final EmrPage page;

  /// The provider that holds the desktop's page, and how to read and set it.
  final Listenable listenable;
  final int Function() current;
  final ValueChanged<int> jumpTo;

  final Widget child;

  @override
  State<RolePageSync> createState() => _RolePageSyncState();
}

class _RolePageSyncState extends State<RolePageSync> {
  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_onPageChanged);
    // After the first frame, once the desktop's PageView is attached. Always:
    // jumpTo also sets the tab highlight, which may be left from before.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.jumpTo(widget.page.slot);
    });
  }

  @override
  void didUpdateWidget(covariant RolePageSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_onPageChanged);
      widget.listenable.addListener(_onPageChanged);
    }
    if (widget.page == oldWidget.page) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.current() != widget.page.slot) {
        widget.jumpTo(widget.page.slot);
      }
    });
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_onPageChanged);
    super.dispose();
  }

  void _onPageChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final int now = widget.current();
      if (now == widget.page.slot) return;
      EmrRouter.open(
        context,
        EmrLocation(EmrPage.of(widget.page.desktop, now)),
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
