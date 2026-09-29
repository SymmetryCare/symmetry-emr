class CliniciansChatRepository {
  // ── Base path segments ─────────────────────────────────────────────────────
  static String _patientGroup     = '/patient-group';
  static String _careTeamChat     = '/care-team-chat';
  static String _patientGroupChat = '/patient-group-chat';
  static String _chatScreen       = '/chat-screen';
  static String _cliniciansChat   = '/clinicians_chat';
  static String _attachment       = '/attachment';
  static String _voiceNote        = '/voice-note';

  // ── GET paths ──────────────────────────────────────────────────────────────
  static String getCareTeamChat({required int ptId}) {
    return '$_patientGroup$_careTeamChat/$ptId';
  }

  static String getChatScreen({
    required int ptGroupId,
    required int pageNbr,
    required int nbrOfRows,
  }) {
    return '$_patientGroupChat$_chatScreen/$ptGroupId/$pageNbr/$nbrOfRows';
  }

  // ── POST paths ─────────────────────────────────────────────────────────────
  static String sendChat({required bool isGroup}) {
    return '$_cliniciansChat/${isGroup.toString()}';
  }

  static String sendAttachment({required bool isGroup, required int chatId}) {
    return '$_cliniciansChat/${isGroup.toString()}/$chatId$_attachment';
  }

  static String sendVoiceNote({required bool isGroup, required int chatId}) {
    return '$_cliniciansChat/${isGroup.toString()}/$chatId$_voiceNote';
  }
}