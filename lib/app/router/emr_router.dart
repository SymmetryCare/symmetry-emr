import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:symmetry_emr/app/router/emr_routes.dart';
import 'package:symmetry_emr/app/services/session/app_session.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/responsive_screen/responsive_screen_emr.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/coder/responsive_screen/coder_responsive.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/responsive_screen/qa_responsive.dart';

/// The signed-in screens' router: one URL per page of each role desktop, see
/// [EmrRoutes]. The login flow is not on it — it is its own app, see
/// main.dart.
///
/// Every URL of a desktop shows that desktop under one Navigator page key,
/// so a URL change updates it in place instead of rebuilding it; it then
/// moves to the page (and patient screens) the URL names. Its pages used to
/// swap inside a PageView, and still do.
///
/// Back and Forward walk the pages visited, and close and reopen the
/// clinician's patient screens, like any website.
class EmrRouter {
  EmrRouter._();

  static GoRouter? _router;

  /// Whether a router was made earlier in this page load.
  static bool _madeOne = false;

  /// One router per signed-in session, dropped when the session ends.
  /// [navigatorKey]'s context is what main.dart's start-up work (frontend
  /// config) runs its API call with.
  ///
  /// The first opens on the URL the page was loaded with — a deep link, a
  /// refresh. One made after signing in again opens on the clinician
  /// dashboard, where a login always led; a router kept from the last
  /// session would show its last page while the address bar still said where
  /// the login flow left it.
  static GoRouter router(GlobalKey<NavigatorState> navigatorKey) {
    if (_router != null) return _router!;
    final bool afterSignIn = _madeOne;
    _madeOne = true;
    AppSession.instance.addListener(_dropOnSignOut);
    return _router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation:
          afterSignIn ? EmrRoutes.clinicianHome : EmrRoutes.home,
      overridePlatformDefaultLocation: afterSignIn,
      redirect: (BuildContext context, GoRouterState state) =>
          EmrRoutes.canonical(state.uri),
      onException: (BuildContext context, GoRouterState state,
              GoRouter router) =>
          router.go(EmrRoutes.home),
      // Which paths are pages is EmrRoutes' call (the redirect above); these
      // only have to match every shape a page URL takes — a page, plus up to
      // one name per patient screen open over it.
      routes: <RouteBase>[
        for (int depth = 1; depth <= 2 + EmrOverlay.values.length; depth++)
          GoRoute(
            path: List<String>.generate(depth, (int i) => '/:s$i').join(),
            pageBuilder: _page,
          ),
      ],
    );
  }

  static void _dropOnSignOut() {
    if (AppSession.instance.isSignedIn) return;
    AppSession.instance.removeListener(_dropOnSignOut);
    _router = null;
  }

  /// One key per desktop, so a URL change within it updates it in place. No
  /// transition: pages used to swap inside a PageView, not slide in.
  static Page<void> _page(BuildContext context, GoRouterState state) {
    final EmrLocation at = EmrRoutes.parse(state.uri) ??
        const EmrLocation(EmrPage.dashboard);
    final Widget child = switch (at.page.desktop) {
      EmrDesktop.clinician => ResponsiveScreenEMR(location: at),
      EmrDesktop.qa => ResponsiveScreenQA(page: at.page),
      EmrDesktop.coder => ResponsiveScreenCoder(page: at.page),
    };
    return NoTransitionPage<void>(
      key: ValueKey<String>('emr-${at.page.desktop.name}'),
      child: child,
    );
  }

  /// Go to [at], as a new Back step.
  static void open(BuildContext context, EmrLocation at) {
    GoRouter.of(context).go(EmrRoutes.locationOf(at));
  }

  /// Show [at] in the address bar without adding a Back step.
  static void replace(BuildContext context, EmrLocation at) {
    Router.neglect(
      context,
      () => GoRouter.of(context).go(EmrRoutes.locationOf(at)),
    );
  }
}
