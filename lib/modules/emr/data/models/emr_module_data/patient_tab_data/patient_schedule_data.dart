// ── Episode Chart Dropdown ────────────────────────────────────────────────────
class EpisodeChartDropdownData {
  final int ptEpisodeId;
  final int episodeId;
  final int chartId;
  final String label;
  final String episodeFrom;
  final String episodeTo;

  EpisodeChartDropdownData({
    required this.ptEpisodeId,
    required this.episodeId,
    required this.chartId,
    required this.label,
    required this.episodeFrom,
    required this.episodeTo,
  });
}

// ── LUPA ──────────────────────────────────────────────────────────────────────
class LupaData {
  final LupaEpisodeData episode;
  final LupaPeriodData first30;
  final LupaPeriodData second30;

  LupaData({
    required this.episode,
    required this.first30,
    required this.second30,
  });
}

class LupaEpisodeData {
  final int ptEpisodeId;
  final String episodeFrom;
  final String episodeTo;

  LupaEpisodeData({
    required this.ptEpisodeId,
    required this.episodeFrom,
    required this.episodeTo,
  });
}

class LupaPeriodData {
  final String dateFrom;
  final String dateTo;
  final int completedVisits;
  final int totalVisits;

  LupaPeriodData({
    required this.dateFrom,
    required this.dateTo,
    required this.completedVisits,
    required this.totalVisits,
  });
}

// ── Patient Daily Visit ───────────────────────────────────────────────────────
class PatientDailyVisitData {
  final int visitId;
  final String timeFrom;
  final String timeTo;
  final String status;
  final String visitTypeName;
  final DailyVisitDisciplineData discipline;
  final DailyVisitClinicianData clinician;

  PatientDailyVisitData({
    required this.visitId,
    required this.timeFrom,
    required this.timeTo,
    required this.status,
    required this.visitTypeName,
    required this.discipline,
    required this.clinician,
  });
}

class DailyVisitDisciplineData {
  final int employeeTypeId;
  final String name;
  final String abbreviation;
  final String color;

  DailyVisitDisciplineData({
    required this.employeeTypeId,
    required this.name,
    required this.abbreviation,
    required this.color,
  });
}

class DailyVisitClinicianData {
  final int employeeId;
  final String name;
  final String? imgUrl;

  DailyVisitClinicianData({
    required this.employeeId,
    required this.name,
    this.imgUrl,
  });
}

// ── Patient Schedule ──────────────────────────────────────────────────────────
class PatientScheduleData {
  final PatientScheduleEpisodeData episode;
  final List<PatientScheduleVisitData> visits;

  PatientScheduleData({
    required this.episode,
    required this.visits,
  });
}

class PatientScheduleEpisodeData {
  final int ptEpisodeId;
  final int ptId;
  final int chartId;
  final int episodeId;
  final String episodeFrom;
  final String episodeTo;
  final String mid30DayDate;

  PatientScheduleEpisodeData({
    required this.ptEpisodeId,
    required this.ptId,
    required this.chartId,
    required this.episodeId,
    required this.episodeFrom,
    required this.episodeTo,
    required this.mid30DayDate,
  });
}

class PatientScheduleVisitData {
  final int visitId;
  final String visitDate;
  final String timeFrom;
  final String timeTo;
  final String status;
  final String visitTypeName;
  final PatientScheduleDisciplineData discipline;
  final PatientScheduleClinicianData clinician;
  final bool isEpisodeStart;
  final bool is2nd30DayStart;

  PatientScheduleVisitData({
    required this.visitId,
    required this.visitDate,
    required this.timeFrom,
    required this.timeTo,
    required this.status,
    required this.visitTypeName,
    required this.discipline,
    required this.clinician,
    required this.isEpisodeStart,
    required this.is2nd30DayStart,
  });
}

class PatientScheduleDisciplineData {
  final int employeeTypeId;
  final String name;
  final String abbreviation;
  final String color;

  PatientScheduleDisciplineData({
    required this.employeeTypeId,
    required this.name,
    required this.abbreviation,
    required this.color,
  });
}

class PatientScheduleClinicianData {
  final int employeeId;
  final String name;
  final String? imgUrl;

  PatientScheduleClinicianData({
    required this.employeeId,
    required this.name,
    this.imgUrl,
  });
}