/// Every signed-in EMR screen and the URL it lives at.
///
/// EMR is served at `/emr/` with real paths — no `#` — so the page is in the
/// address bar, for each of the three role desktops:
///
///   /emr/patients                  (clinician)
///   /emr/qa/my-tasks               (QA Coordinator)
///   /emr/coder/dashboard           (Coder)
///
/// Refreshing, pressing Enter in the address bar and opening a copied link
/// all land on that page. Paths below are relative to the base href.
///
/// The clinician desktop's patient and visit screens (visit details, the
/// patient chart, protocol, alerts, plan of care…) open over the page with
/// the patient or visit picked on it, held in EMRNavigationController. The
/// URL names which of them are open — `/emr/patients/patient/protocol` — so
/// Back closes them one at a time as it always has, but never the patient or
/// visit: that stays in memory, and a refresh while one is open lands back
/// on the page under it.
library;

/// The three role desktops. [prefix] is the path every page of it starts with.
enum EmrDesktop {
  clinician(''),
  qa('/qa'),
  coder('/coder');

  const EmrDesktop(this.prefix);

  final String prefix;
}

/// The pages of a desktop, with the slot each has in its own page state —
/// the clinician PageView (Chat is 4, a panel over it), or QaCoordinator /
/// CoderProvider's pageIdx (Chat is 2).
enum EmrPage {
  dashboard(EmrDesktop.clinician, 'dashboard', 0),
  calendar(EmrDesktop.clinician, 'calendar', 1),
  patients(EmrDesktop.clinician, 'patients', 2),
  timesheet(EmrDesktop.clinician, 'timesheet', 3),
  chat(EmrDesktop.clinician, 'chat', 4),
  qaDashboard(EmrDesktop.qa, 'dashboard', 0),
  qaMyTasks(EmrDesktop.qa, 'my-tasks', 1),
  qaChat(EmrDesktop.qa, 'chat', 2),
  coderDashboard(EmrDesktop.coder, 'dashboard', 0),
  coderMyTasks(EmrDesktop.coder, 'my-tasks', 1),
  coderChat(EmrDesktop.coder, 'chat', 2);

  const EmrPage(this.desktop, this.slug, this.slot);

  final EmrDesktop desktop;
  final String slug;

  /// The page's slot in its desktop's own page state.
  final int slot;

  String get path => '${desktop.prefix}/$slug';

  /// The page of [desktop] in [slot], or its dashboard.
  static EmrPage of(EmrDesktop desktop, int slot) {
    for (final EmrPage page in values) {
      if (page.desktop == desktop && page.slot == slot) return page;
    }
    return homeOf(desktop);
  }

  static EmrPage homeOf(EmrDesktop desktop) => switch (desktop) {
        EmrDesktop.clinician => dashboard,
        EmrDesktop.qa => qaDashboard,
        EmrDesktop.coder => coderDashboard,
      };
}

/// The clinician desktop's patient and visit screens, bottom to top: the
/// order they stack in, and the reverse of the order Back closes them in.
/// Each has a name for the URL and nothing else.
enum EmrOverlay {
  scheduledVisit('scheduled-visit'),
  visit('visit'),
  map('map'),
  patient('patient'),
  planOfCare('plan-of-care'),
  frequency('frequency'),
  alerts('alerts'),
  protocol('protocol');

  const EmrOverlay(this.slug);

  final String slug;

  static EmrOverlay? fromSlug(String slug) {
    for (final EmrOverlay o in values) {
      if (o.slug == slug) return o;
    }
    return null;
  }
}

/// What a URL names: a page and, on the clinician desktop, which patient and
/// visit screens are open over it.
class EmrLocation {
  const EmrLocation(this.page, [this.overlays = const <EmrOverlay>[]]);

  final EmrPage page;

  /// Open patient/visit screens, bottom to top. Names only.
  final List<EmrOverlay> overlays;

  EmrLocation withOverlays(List<EmrOverlay> open) => EmrLocation(page, open);

  @override
  bool operator ==(Object other) =>
      other is EmrLocation &&
      other.page == page &&
      _sameList(other.overlays, overlays);

  @override
  int get hashCode => Object.hash(page, Object.hashAll(overlays));

  static bool _sameList(List<EmrOverlay> a, List<EmrOverlay> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class EmrRoutes {
  EmrRoutes._();

  /// The signed-in user's role, read in main() at boot. It picks the desktop
  /// a URL that names no page opens — `/`, or the login screen's — exactly
  /// as the old route table did; nothing else depends on it.
  static String bootRole = '';

  /// The desktop a page-less URL opens for [role]. QA and Coder have their
  /// own; every other role — Clinical Manager, QA Manager and DME included,
  /// whose desktops are not in this repo — gets the clinician one.
  static EmrDesktop desktopFor(String role) => switch (role) {
        'QA' => EmrDesktop.qa,
        'Coder' => EmrDesktop.coder,
        _ => EmrDesktop.clinician,
      };

  /// Where the module opens: the boot role's dashboard.
  static String get home => EmrPage.homeOf(desktopFor(bootRole)).path;

  /// The clinician dashboard — where `/home`, the old `/emrDesktop` and every
  /// login led, whatever the role.
  static String get clinicianHome => EmrPage.dashboard.path;

  /// Old route names, and where they lead.
  static final Map<String, String> _legacy = <String, String>{
    '/emrDesktop': EmrPage.dashboard.path,
    '/home': EmrPage.dashboard.path,
    '/qaCoordinatorDesktop': EmrPage.qaDashboard.path,
    '/coderDesktop': EmrPage.coderDashboard.path,
  };

  /// The URL of [at].
  static String locationOf(EmrLocation at) {
    if (at.page.desktop != EmrDesktop.clinician || at.overlays.isEmpty) {
      return at.page.path;
    }
    return '${at.page.path}/${at.overlays.map((o) => o.slug).join('/')}';
  }

  /// The page (and open patient screens) [uri] names, or null for none.
  static EmrLocation? parse(Uri uri) {
    final List<String> segments =
        uri.pathSegments.where((String s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return null;

    EmrDesktop desktop = EmrDesktop.clinician;
    int at = 0;
    if (segments[0] == 'qa' || segments[0] == 'coder') {
      desktop = segments[0] == 'qa' ? EmrDesktop.qa : EmrDesktop.coder;
      at = 1;
    }
    if (segments.length <= at) return EmrLocation(EmrPage.homeOf(desktop));

    EmrPage? page;
    for (final EmrPage p in EmrPage.values) {
      if (p.desktop == desktop && p.slug == segments[at]) page = p;
    }
    if (page == null) {
      // `/qa/anything` is still the QA desktop; anything else is no page.
      return desktop == EmrDesktop.clinician
          ? null
          : EmrLocation(EmrPage.homeOf(desktop));
    }

    // Patient/visit screen names: kept while they make a valid stack.
    final List<EmrOverlay> overlays = <EmrOverlay>[];
    if (desktop == EmrDesktop.clinician && page != EmrPage.chat) {
      for (final String slug in segments.skip(at + 1)) {
        final EmrOverlay? o = EmrOverlay.fromSlug(slug);
        if (o == null || (overlays.isNotEmpty && o.index <= overlays.last.index)) {
          break;
        }
        overlays.add(o);
      }
    }
    return EmrLocation(page, overlays);
  }

  /// The exact URL [uri] should be shown at, or null when it already is.
  ///
  /// Old route names go to their desktop; a URL naming no page — the module
  /// root, the login screen's, a stale bookmark — opens the boot role's
  /// dashboard; a desktop without a page gets its dashboard.
  static String? canonical(Uri uri) {
    final String? legacy = _legacy[uri.path];
    if (legacy != null) return legacy;
    final EmrLocation? at = parse(uri);
    final String target = at == null ? home : locationOf(at);
    return target == uri.path ? null : target;
  }
}
