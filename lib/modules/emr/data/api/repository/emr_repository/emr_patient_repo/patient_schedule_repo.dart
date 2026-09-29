class PatientScheduleModuleRepository {
  static String _patientVisits = '/patient-visits';
  static String _episodes      = '/episodes';

  // ── Patient Daily Visit List ────────────────────────────────────────────────
  static String dailyList({required int ptId, required String date}) {
    return '$_patientVisits/daily-list/$ptId/$date';
  }

  // ── LUPA ───────────────────────────────────────────────────────────────────
  static String lupa({required int ptId, required int ptEpisodeId}) {
    return '$_patientVisits/lupa/$ptId/$ptEpisodeId';
  }

  // ── Patient Schedule ───────────────────────────────────────────────────────
  static String patientSchedule({required int ptId, required int ptEpisodeId}) {
    return '$_patientVisits/patient-schedule/$ptId/$ptEpisodeId';
  }

  // ── Episode Chart Dropdown ─────────────────────────────────────────────────
  static String chartDropdown({required int ptId}) {
    return '$_episodes/patient/$ptId/chart-dropdown';
  }
}