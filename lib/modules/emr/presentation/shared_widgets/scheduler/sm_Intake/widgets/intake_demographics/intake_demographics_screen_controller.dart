import 'package:flutter/widgets.dart';

import 'package:symmetry_emr/modules/emr/data/api/managers/sm_intake_manager/intake_demographics/intake_demographic_dropdown_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/sm_data/scheduler_create_data/create_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/scheduler/widgets/constant_widgets/pdf_viewer.dart'; // Pure Dart text extraction

/// Combines the three fetch-once API calls that
/// [SmIntakeDemographicsScreen] needs into one widget-scoped
/// `ChangeNotifierProvider`, so the screen's body no longer needs
/// `late Future<T>` fields (re)assigned inside `build()`.
///
/// - [pdfText] is re-fetched whenever the referral link (`isLinkeOpen` from
///   `SmIntakeProviderManager`) changes, via [reloadPdfText].
/// - [stateDropDown] / [countryDropDown] are fetched once via [load].
class SmIntakeDemographicsController extends ChangeNotifier {
  String? pdfText;
  bool isPdfTextLoading = true;
  Object? pdfTextError;
  String? pdfTextLinkKey;

  List<StateData>? stateDropDown;
  bool isStateDropDownLoading = true;
  Object? stateDropDownError;

  List<CountryData>? countryDropDown;
  bool isCountryDropDownLoading = true;
  Object? countryDropDownError;

  bool _disposed = false;

  /// Initial load: fetches the pdf text for [initialLinkKey] plus both
  /// dropdown lists.
  Future<void> load(BuildContext context, String initialLinkKey) async {
    await Future.wait([
      reloadPdfText(initialLinkKey),
      _loadStateDropDown(context),
      _loadCountryDropDown(context),
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

  Future<void> _loadStateDropDown(BuildContext context) async {
    isStateDropDownLoading = true;
    notifyListeners();
    try {
      final result = await getStateDropDown(context);
      if (_disposed) return;
      stateDropDown = result;
    } catch (e) {
      if (_disposed) return;
      stateDropDownError = e;
    } finally {
      if (!_disposed) {
        isStateDropDownLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadCountryDropDown(BuildContext context) async {
    isCountryDropDownLoading = true;
    notifyListeners();
    try {
      final result = await getCountryDropDown(context);
      if (_disposed) return;
      countryDropDown = result;
    } catch (e) {
      if (_disposed) return;
      countryDropDownError = e;
    } finally {
      if (!_disposed) {
        isCountryDropDownLoading = false;
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
