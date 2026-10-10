import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:symmetry_emr/app/services/title/app_title.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/login_flow_app.dart';
import 'package:symmetry_emr/app/resources/provider/em_provider/em_main_provider.dart';
import 'package:symmetry_emr/app/resources/provider/navigation_provider.dart';
import 'package:symmetry_emr/app/resources/provider/office_location.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/provider/version_provider.dart';
import 'package:symmetry_emr/app/router/emr_router.dart';
import 'package:symmetry_emr/app/router/emr_routes.dart';
import 'package:symmetry_emr/app/services/config/error_surface.dart';
import 'package:symmetry_emr/app/services/config/frontend_config_boot.dart';
import 'package:symmetry_emr/app/services/session/app_session.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/firebase_options.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/provider/form_builder_provider.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/side_drawer/side_drawer_provider.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/widget/const_form_tap.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/coder/coder_provider/coder_myTask_provider.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/coder/coder_provider/coder_provider.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_provider/qa_dashboard_provider.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_provider/qa_my_task_provider.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_demographics/widgets/patients_related_party/intake_patients_related_party.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_orders/intake_orders_screen.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_Intake/widgets/intake_update_schedular/information_update.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/sm_refferal/widgets/refferal_pending_widgets/r_p_eye_pageview_screen.dart';
import 'package:symmetry_emr/modules/emr/providers/emr_provider/emr_patient_provider.dart';
import 'package:symmetry_emr/modules/emr/providers/hh_emr/visit_details_provider.dart';

/// The signed-in app's root navigator (the router's). The post-first-frame
/// frontend-config refresh needs a `BuildContext` that outlives any one screen.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// The login flow's navigator. Its own key: the signed-in app's router owns
/// [navigatorKey], and one GlobalKey cannot sit on two navigators.
final GlobalKey<NavigatorState> loginNavigatorKey = GlobalKey<NavigatorState>();

/// Carried over from the monolith's `lib/main.dart`, where it is declared and
/// read by `oasis_form_builder/constants/responsive.dart` but never attached to
/// a navigator — so its `currentContext` is always null and `Responsive` falls
/// back to the context it was given. Kept unattached here so the OASIS forms
/// size themselves exactly as they do in the monolith.
GlobalKey<NavigatorState> navigationKeyOasis = GlobalKey();

Future<void> main() async {
  // Real paths in the address bar — /emr/patients, not /emr/#/emrDesktop — so
  // every page has a URL that behaves like any website's: refresh and Enter
  // in the address bar reload that page, and a copied link opens it. Must run
  // before the first frame.
  //
  // The server has to answer every path under /emr/ with /emr/index.html (see
  // README.md, "Deploy"), or a refresh on any page but the first is a 404.
  // Old #/ links are rewritten in web/index.html.
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  // No-op unless built with --dart-define=DEBUG_ERRORS=true.
  ErrorSurface.install();
  await dotenv.load(fileName: 'config/emr.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Must complete before the first frame: the EMR screens read
  // `FrontendConfigStore.data!` directly, so a null store is a white screen
  // rather than a degraded one. See FrontendConfigBoot.
  await FrontendConfigBoot.ensureLoaded();

  final accessToken = await TokenManager.getAccessToken();
  if (accessToken.isNotEmpty) {
    // Picks the desktop a URL naming no page opens (`/`): QA and Coder have
    // their own. Only read signed in — an anonymous boot goes to the login
    // screen whatever role a stale localStorage entry names.
    EmrRoutes.bootRole = await TokenManager.getRole();
    AppSession.instance.start();
  }
  runApp(const EmrApplication());
}

/// EMR runs in the same two shapes HR, Establishment and RIS do — standalone
/// at the site root with its own login screen, or hosted behind symmetry-shell
/// at `/emr/` on one origin, where the session written by the shell's login is
/// already in `localStorage` and this boots straight to the module. Which one
/// is decided at build time by `--dart-define=SHELL_PATH=/`; see
/// `app/services/shell/shell_link.dart`.
///
/// Signed out, it shows the login flow ([LoginFlowApp]); signed in, the EMR
/// role desktops on go_router ([EmrRouter]), one URL per page. [AppSession]
/// decides which, and switches on login, sign-out and expiry. Every provider
/// sits above both, so neither swap loses app-wide state.
class EmrApplication extends StatelessWidget {
  const EmrApplication({super.key});

  static final ThemeData _theme = ThemeData(
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: const Color(0xff50B5E5),
    ),
    fontFamily: GoogleFonts.firaSans().fontFamily,
    useMaterial3: false,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  /// Replace the cached/default config with the live one once there is a
  /// context — [key]'s navigator's — to make the call with.
  static TransitionBuilder _startUpWork(GlobalKey<NavigatorState> key) {
    return (BuildContext context, Widget? child) {
      FrontendConfigBoot.refreshInBackground(key);
      return child ?? const SizedBox.shrink();
    };
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VersionProviderManager()),
        ChangeNotifierProvider(create: (_) => RouteProvider()),

        // The module's own app-wide state. In the monolith all of these are
        // registered in the root `main.dart` and consumed many levels down, so
        // a `Consumer<T>` with no provider above it throws
        // ProviderNotFoundException and takes the whole screen down the first
        // time that tab is opened.
        //
        // This list is the result of auditing every Consumer/Consumer2/
        // Selector, context.watch/read/select and Provider.of in this repo
        // against every place a provider is created, and matching the misses
        // to what the monolith's root main.dart registers.
        //
        // EMR itself: EMRNavigationController drives the dashboard overlays
        // (visit details, patient detail, protocols, alerts, plan of care);
        // FilterDrawerProvider the insurance filter; EmrPatientProvider the
        // selected patient; PatienFormTapping opens a chart form.
        ChangeNotifierProvider(create: (_) => EMRNavigationController()),
        ChangeNotifierProvider(create: (_) => FilterDrawerProvider()),
        ChangeNotifierProvider(create: (_) => EmrPatientProvider()),
        ChangeNotifierProvider(create: (_) => PatienFormTapping()),

        // The OASIS form builder the chart and Start Visit open.
        ChangeNotifierProvider(create: (_) => FormBuilderProvider()),
        ChangeNotifierProvider(create: (_) => SideDrawerProvider()),

        // The Patient Profile tab is built from the Intake (RIS) widgets, and
        // reads the same providers they do.
        ChangeNotifierProvider(create: (_) => SmIntakeProviderManager()),
        ChangeNotifierProvider(create: (_) => DiagnosisProvider()),
        ChangeNotifierProvider(create: (_) => PriDiagnosisProvider()),
        ChangeNotifierProvider(create: (_) => EmergencyContactProvider()),

        // Screens the OASIS form mapper reaches for the QA and Coder roles,
        // and the Company Identity / map widgets the app bar and address
        // pickers come in with.
        ChangeNotifierProvider(create: (_) => QaDashboardProvider()),
        ChangeNotifierProvider(create: (_) => QaCoordinatorProvider()),
        ChangeNotifierProvider(create: (_) => QaMyTaskProvider()),
        ChangeNotifierProvider(create: (_) => CoderMyTaskProvider()),
        ChangeNotifierProvider(create: (_) => CoderDashboardProvider()),
        ChangeNotifierProvider(create: (_) => CoderProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => EmMainProvider()),

        // The two callbacks are the monolith's host navigation, and are empty
        // there too — `lib/main.dart` passes `() {}` and `(_) {}`.
        ChangeNotifierProvider(
          create: (_) => InformationUpdateProvider(
            onUpdateButtonPressed: () {},
            onPatientIdReceived: (_) {},
          ),
        ),
      ],
      child: ListenableBuilder(
        listenable: AppSession.instance,
        builder: (BuildContext context, Widget? _) {
          if (!AppSession.instance.isSignedIn) {
            return LoginFlowApp(
              navigatorKey: loginNavigatorKey,
              title: AppTitle.value,
              theme: _theme,
              builder: _startUpWork(loginNavigatorKey),
            );
          }
          return MaterialApp.router(
            title: AppTitle.value,
            debugShowCheckedModeBanner: false,
            theme: _theme,
            routerConfig: EmrRouter.router(navigatorKey),
            builder: _startUpWork(navigatorKey),
          );
        },
      ),
    );
  }
}
