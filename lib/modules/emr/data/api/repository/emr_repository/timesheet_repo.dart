class TimesheetRepo {
  // ── Monthly Calendar ──────────────────────────────────────────────
  static const String _monthlyCalendarBase =
      "/patient-visits/clinician/monthly-calendar";

  static String getClinicianMonthlyCalendar({
    required int year,
    required int month,
  }) {
    return "$_monthlyCalendarBase/$year/$month";
  }

  // ── Payroll Period ────────────────────────────────────────────────
  static const String getPayrollPeriodCurrent = "/payroll-period/current";

  // ── Clinician Event ───────────────────────────────────────────────
  static const String postClinicianEvent = "/clinician-event";
  static const String getSupervisors = "/clinician-event/supervisors";

  // ── Clinician Event List ──────────────────────────────────────────
  static const String getClinicianEventList = "/clinician-event/list";

  static String getClinicianEventListByDate({required String date}) {
    return "$getClinicianEventList/$date";
  }

  // ── Todays Visit ──────────────────────────────────────────────────
  static const String _todaysVisitBase = "/patient-visits/todaysVisitData";

  static String getTodaysVisitData({required String clinicianId}) {
    return "$_todaysVisitBase/$clinicianId";
  }

  // ── Visit Range ───────────────────────────────────────────────────
  static const String _visitRangeBase = "/patient-visits/range";

  static String getVisitRangeList({
    required String dateFrom,
    required String dateTo,
  }) {
    return "$_visitRangeBase/$dateFrom/$dateTo/list";
  }

  // ── Daily Summary ─────────────────────────────────────────────────
  static const String _dailySummary = '/patient-visits/clinician/daily-summary';

  static String getDailySummaryByDate({required String date}) {
    return '$_dailySummary/$date';
  }

  // ── Scheduled Visits Popup ────────────────────────────────────────
  static const String _scheduledVisits = '/patient-visits/popup/scheduled-visits';

  static String getScheduledVisitsByDate({required String date}) {
    return '$_scheduledVisits/$date';
  }



  //--------------
// ── Pending Visits Popup ──────────────────────────────────────────────
  static const String _pendingVisits = '/patient-visits/popup/pending-visits';

  static String getPendingVisitsByDate({required String date}) {
    return '$_pendingVisits/$date';
  }
}



class CompletedVisitsPopupRepository {
  static String _patientVisits = '/patient-visits';
  static String _popup = '/popup';
  static String _completedVisits = '/completed-visits';

  static String getCompletedVisits({required String date}) {
    return '$_patientVisits$_popup$_completedVisits/$date';
  }
}