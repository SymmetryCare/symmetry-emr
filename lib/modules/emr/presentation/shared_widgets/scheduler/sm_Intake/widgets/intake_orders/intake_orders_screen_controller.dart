import 'package:flutter/widgets.dart';

import 'package:symmetry_emr/modules/emr/data/api/managers/refferals_manager/refferals_patient_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/referral_service_data.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/sm_model_data/sm_patient_refferal_data.dart';
import 'package:symmetry_emr/data/appconfige_data/app_confige_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/pdf_viewer.dart';

/// Combines the several fetch-once API calls that [SMIntakeOrdersScreen]
/// needs into one widget-scoped `ChangeNotifierProvider`, so the screen's
/// body no longer needs several `late Future<T>` fields (re)assigned inside
/// `build()`.
///
/// - [pdfText] is re-fetched whenever the referral link (`isLinkeOpen` from
///   `SmIntakeProviderManager`) changes, via [reloadPdfText].
/// - [employeeClinical] / [marketer] / [referralSource] / [specialOrder] are
///   each fetched once via [load].
///
/// The patient orders fetch used to prefill this screen is intentionally
/// NOT part of this controller — it stays as its own independent
/// `AsyncDataController<List<PatientOrderData>>` in the screen widget, since
/// the screen's `_prefillData()` also makes its own separate call to the
/// same endpoint to populate several `TextEditingController`s, and merging
/// the two risks changing that existing behavior/timing.
class IntakeOrdersScreenController extends ChangeNotifier {
  String? pdfText;
  bool isPdfTextLoading = true;
  Object? pdfTextError;
  String? pdfTextLinkKey;

  List<EmployeeClinicalData>? employeeClinical;
  bool isEmployeeClinicalLoading = true;
  Object? employeeClinicalError;

  List<PatientMarketerData>? marketer;
  bool isMarketerLoading = true;
  Object? marketerError;

  List<ReferralSourcesData>? referralSource;
  bool isReferralSourceLoading = true;
  Object? referralSourceError;

  List<SpacialOrderData>? specialOrder;
  bool isSpecialOrderLoading = true;
  Object? specialOrderError;

  bool _disposed = false;

  /// Initial load: fetches the pdf text for [initialLinkKey] plus the four
  /// independent dropdown/checkbox datasets.
  Future<void> load(BuildContext context, String initialLinkKey) async {
    await Future.wait([
      reloadPdfText(initialLinkKey),
      _loadEmployeeClinical(context),
      _loadMarketer(context),
      _loadReferralSource(context),
      _loadSpecialOrder(context),
    ]);
  }

  /// Re-fetches the pdf text for [linkKey]. Safe to call again whenever the
  /// referral link changes.
  Future<void> reloadPdfText(String linkKey) async {
    pdfTextLinkKey = linkKey;
    isPdfTextLoading = true;
    pdfTextError = null;
    notifyListeners();
    try {
      final result = await extractTextFromPdf(linkKey);
      if (_disposed) return;
      pdfText = result;
    } catch (e) {
      if (_disposed) return;
      pdfTextError = e;
    } finally {
      if (!_disposed) {
        isPdfTextLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadEmployeeClinical(BuildContext context) async {
    isEmployeeClinicalLoading = true;
    notifyListeners();
    try {
      final result = await getEmployeeClinicalInReffreals(context: context);
      if (_disposed) return;
      employeeClinical = result;
    } catch (e) {
      if (_disposed) return;
      employeeClinicalError = e;
    } finally {
      if (!_disposed) {
        isEmployeeClinicalLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadMarketer(BuildContext context) async {
    isMarketerLoading = true;
    notifyListeners();
    try {
      final result = await getMarketerWithDeptId(context: context, deptId: FrontendConfigStore.data!.config.salesId);
      if (_disposed) return;
      marketer = result;
    } catch (e) {
      if (_disposed) return;
      marketerError = e;
    } finally {
      if (!_disposed) {
        isMarketerLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadReferralSource(BuildContext context) async {
    isReferralSourceLoading = true;
    notifyListeners();
    try {
      final result = await getReferalSourceDD(context: context);
      if (_disposed) return;
      referralSource = result;
    } catch (e) {
      if (_disposed) return;
      referralSourceError = e;
    } finally {
      if (!_disposed) {
        isReferralSourceLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadSpecialOrder(BuildContext context) async {
    isSpecialOrderLoading = true;
    notifyListeners();
    try {
      final result = await getSpecialOrder(context: context);
      if (_disposed) return;
      specialOrder = result;
    } catch (e) {
      if (_disposed) return;
      specialOrderError = e;
    } finally {
      if (!_disposed) {
        isSpecialOrderLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
