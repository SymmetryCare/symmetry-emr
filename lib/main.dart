import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:symmetry_emr/app/services/title/app_title.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:symmetry_emr/app/resources/provider/em_provider/em_main_provider.dart';
import 'package:symmetry_emr/app/resources/provider/navigation_provider.dart';
import 'package:symmetry_emr/app/resources/provider/office_location.dart';
import 'package:symmetry_emr/app/resources/provider/sm_provider/sm_slider_provider.dart';
import 'package:symmetry_emr/app/resources/provider/version_provider.dart';
import 'package:symmetry_emr/app/resources/screen_route_name.dart';
import 'package:symmetry_emr/app/services/config/error_surface.dart';
import 'package:symmetry_emr/app/services/config/frontend_config_boot.dart';
import 'package:symmetry_emr/app/services/shell/shell_link.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/data/navigator_arguments/screen_arguments.dart';
import 'package:symmetry_emr/firebase_options.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/provider/form_builder_provider.dart';
import 'package:symmetry_emr/modules/emr/oasis_form_builder/side_drawer/side_drawer_provider.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/patients_tab_emr/widgets/patient_chart_tabs/widget/const_form_tap.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/responsive_screen/responsive_screen_emr.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/coder/responsive_screen/coder_responsive.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/responsive_screen/qa_responsive.dart';
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
import 'package:symmetry_emr/presentation/screens/login_module/email_verification/email_verification.dart';
import 'package:symmetry_emr/presentation/screens/login_module/forget_pass_verification/forget_pass_verification.dart';
import 'package:symmetry_emr/presentation/screens/login_module/forget_password/forget_password_screen.dart';
import 'package:symmetry_emr/presentation/screens/login_module/login/login_screen.dart';

/// Global navigator key. The post-first-frame frontend-config refresh needs a
/// `BuildContext` that outlives any one screen.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Carried over from the monolith's `lib/main.dart`, where it is declared and
/// read by `oasis_form_builder/constants/responsive.dart` but never attached to
/// a navigator — so its `currentContext` is always null and `Responsive` falls
/// back to the context it was given. Kept unattached here so the OASIS forms
/// size themselves exactly as they do in the monolith.
GlobalKey<NavigatorState> navigationKeyOasis = GlobalKey();

Future<void> main() async {
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
  final bool signedIn = accessToken.isNotEmpty;
  // Only meaningful when signed in -- an anonymous boot goes to the login
  // screen regardless of whatever role a stale localStorage entry names.
  final String role = signedIn ? await TokenManager.getRole() : '';
  EmrApplication.markSession(signedIn);
  runApp(EmrApplication(isSignedIn: signedIn, role: role));
}

/// EMR runs in the same two shapes HR, Establishment and RIS do — standalone
/// at the site root with its own login screen, or hosted behind symmetry-shell
/// at `/emr/` on one origin, where the session written by the shell's login is
/// already in `localStorage` and this boots straight to the module. Which one
/// is decided at build time by `--dart-define=SHELL_PATH=/`; see
/// `app/services/shell/shell_link.dart`.
class EmrApplication extends StatelessWidget {
  const EmrApplication({super.key, required this.isSignedIn, required this.role});

  final bool isSignedIn;

  /// The signed-in user's role, as `TokenManager.getRole()` returns it --
  /// empty when signed out. Read once at boot to pick [_initialRouteFor];
  /// nothing here re-reads it after that; a role change takes effect on the
  /// next sign-in, same as it always has.
  final String role;

  /// Whether a session exists *now*, as opposed to at boot.
  ///
  /// [isSignedIn] is a snapshot taken in `main()`, before the first frame. It
  /// is the right thing for `initialRoute`, but wrong for the fallback in
  /// [_generateRoute]: after a successful login it still says `false`, so any
  /// route this table does not name would send a signed-in user back to the
  /// login screen. `onGenerateRoute` is synchronous and cannot re-read the
  /// async token store, so the login hand-off flips this instead.
  static bool _hasSession = false;

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
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: AppTitle.value,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xff50B5E5),
          ),
          fontFamily: GoogleFonts.firaSans().fontFamily,
          useMaterial3: false,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute:
            isSignedIn ? _initialRouteFor(role) : LoginScreen.routeName,
        onGenerateRoute: _generateRoute,
        builder: (BuildContext context, Widget? child) {
          // Replace the cached/default config with the live one once there is
          // a context to make the call with.
          FrontendConfigBoot.refreshInBackground(navigatorKey);
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }

  /// Record whether a session exists. Called from `main()` with the boot
  /// snapshot, and again when the login flow hands off to the module.
  static void markSession(bool value) => _hasSession = value;

  /// Where a freshly booted, signed-in session lands.
  ///
  /// The monolith's home menu sent QA and Coder to their own desktops
  /// (`/qaCoordinatorDesktop`, `/coderDesktop`) rather than the clinician
  /// dashboard every other role opens. Those two screens made the trip in
  /// this repo's extraction from the monolith -- see CONTEXT.md -- and are
  /// otherwise unreachable now that the shell can no longer push a route
  /// into this app directly: opening EMR from the picker is a full page
  /// navigation to a separate bundle, not `Navigator.pushNamed` inside one.
  /// Role has to be resolved in here instead, from the same localStorage
  /// entry the shell already wrote at login.
  ///
  /// QA Manager, Clinical Manager and DME are deliberately not routed here.
  /// CONTEXT.md says plainly that their desktop screens are **not** part of
  /// this repo -- only a handful of their widgets came along as transitive
  /// dependencies of the OASIS form mapper, not the screens themselves. There
  /// is nothing real to send them to, so they fall back to the general EMR
  /// desktop like Clinical and Assistant do, rather than to a route that
  /// would render blank.
  static String _initialRouteFor(String role) {
    switch (role) {
      case 'QA':
        return RouteStrings.qaDesktop;
      case 'Coder':
        return RouteStrings.coderDesktop;
      default:
        return RouteStrings.emrDesktop;
    }
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    final Widget page;

    switch (settings.name) {
      // Reaching the module means the login flow completed (or the app booted
      // with a session), so the token is written by now.
      case RouteStrings.emrDesktop:
      case RouteStrings.home:
        _hasSession = true;
        page = const ResponsiveScreenEMR();
        break;
      case RouteStrings.qaDesktop:
        _hasSession = true;
        page = const ResponsiveScreenQA();
        break;
      case RouteStrings.coderDesktop:
        _hasSession = true;
        page = const ResponsiveScreenCoder();
        break;
      case LoginScreen.routeName:
        // Logout and session-expiry both land here; the session is gone.
        _hasSession = false;
        page = _loginOrShell();
        break;
      case EmailVerification.routeName:
        final email = _emailFrom(settings.arguments);
        page =
            email == null ? _loginOrShell() : EmailVerification(email: email);
        break;
      case ForgetPassword.routeName:
        page = const ForgetPassword();
        break;
      case VerifyPassword.routeName:
        final email = _emailFrom(settings.arguments);
        page = email == null ? _loginOrShell() : VerifyPassword(email: email);
        break;
      default:
        page = _hasSession ? const ResponsiveScreenEMR() : _loginOrShell();
        break;
    }

    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }

  /// This app's own login screen, or a redirect to the shell's when hosted.
  ///
  /// Every route above that would otherwise render a login form goes through
  /// here, so a shell-hosted build never shows a second login form on the same
  /// origin. The redirect is synchronous, so the empty widget is on screen
  /// only until the browser navigates.
  Widget _loginOrShell() {
    if (ShellLink.signOutToShell()) return const SizedBox.shrink();
    return const LoginScreen();
  }

  String? _emailFrom(Object? arguments) {
    if (arguments is ScreenArguments) {
      final email = arguments.title?.trim();
      return email == null || email.isEmpty ? null : email;
    }
    return null;
  }
}
