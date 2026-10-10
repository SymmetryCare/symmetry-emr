import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:symmetry_emr/presentation/screens/login_module/login/login_screen.dart';

/// Whether EMR is showing its signed-in screens or its login flow.
///
/// The two are separate apps (see `main.dart`): the login screens are
/// Navigator 1.0 code that `pushNamed` each other, while the signed-in screens
/// live on go_router with one URL per page. This is the switch between them —
/// the same split RIS and Establishment make.
///
/// A singleton, because session expiry is noticed in `Api`'s interceptor,
/// which has no widget tree to look a provider up in.
class AppSession extends ChangeNotifier {
  AppSession._();

  static final AppSession instance = AppSession._();

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  /// The login flow finished and wrote the token, or the app booted with one.
  void start() {
    if (_isSignedIn) return;
    _isSignedIn = true;
    notifyListeners();
  }

  /// The session is over (sign-out or expiry); the token is already cleared.
  ///
  /// Returns whether this swapped the signed-in screens for the login flow.
  /// When it returns false the login flow is already up, and the caller
  /// navigates within it the way it always has.
  bool end() {
    if (!_isSignedIn) return false;
    _isSignedIn = false;
    notifyListeners();
    return true;
  }

  /// Leave for the login screen once the token is cleared — what a sign-out
  /// button used to do with `pushNamedAndRemoveUntil(LoginScreen.routeName)`.
  ///
  /// Signed in, that is ending the session: main.dart swaps the signed-in
  /// screens for the login flow, which hands over to the shell's login when
  /// this build is hosted behind it. The go_router screens have no named
  /// routes to push.
  static void signedOut(BuildContext context) {
    if (instance.end()) return;
    // Already ended — AuthManager.logOutuserByToken does it on success,
    // before the button's own call — so the login flow is on its way and
    // this screen is going.
    if (!context.mounted || GoRouter.maybeOf(context) != null) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginScreen.routeName,
      (Route<dynamic> route) => false,
    );
  }
}
