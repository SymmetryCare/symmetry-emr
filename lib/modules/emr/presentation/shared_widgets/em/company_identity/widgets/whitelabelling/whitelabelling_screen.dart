import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:open_file/open_file.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/common_resources/common_theme_const.dart';
import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establishment_string_manager.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/google_aotopromt_api_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/establishment_manager/whitelabelling_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/widgets/text_form_field_const.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/hr/manage/widgets/custom_icon_button_constant.dart';

import 'package:symmetry_emr/modules/emr/resources/establishment_resources/establish_theme_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/establishment_data/whitelabelling_modal/whitelabelling_modal_.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/widgets/custom_scrollbar.dart';

// 🔑 Adjust this import path to wherever CompanyLogoService actually lives
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/legacy/company_logo_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
/// Immutable snapshot of everything the logo panel needs to render.
/// Kept completely separate from [_whitelabelFuture] (company details) so
/// that uploading a new logo never touches the rest of the screen.
// ─────────────────────────────────────────────────────────────────────────────
class _LogoSectionState {
  final bool isInitialLoading; // first fetch, on screen open
  final bool isUploading;      // PATCH/POST in flight
  final Uint8List? previewBytes; // locally picked file, shown before server confirms
  final int? logoId;
  final String? logoUrl;
  final String? error;
  final int retryCount; // retries of Image.network load right after upload

  const _LogoSectionState({
    this.isInitialLoading = true,
    this.isUploading = false,
    this.previewBytes,
    this.logoId,
    this.logoUrl,
    this.error,
    this.retryCount = 0,
  });

  bool get hasLogo => logoId != null;

  _LogoSectionState copyWith({
    bool? isInitialLoading,
    bool? isUploading,
    Uint8List? previewBytes,
    bool clearPreview = false,
    int? logoId,
    String? logoUrl,
    String? error,
    bool clearError = false,
    int? retryCount,
  }) {
    return _LogoSectionState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isUploading: isUploading ?? this.isUploading,
      previewBytes: clearPreview ? null : (previewBytes ?? this.previewBytes),
      logoId: logoId ?? this.logoId,
      logoUrl: logoUrl ?? this.logoUrl,
      error: clearError ? null : (error ?? this.error),
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

class WhitelabellingScreen extends StatefulWidget {
  final String officeId;
  final VoidCallback backButtonCallback;

  const WhitelabellingScreen(
      {super.key, required this.officeId, required this.backButtonCallback});

  @override
  State<WhitelabellingScreen> createState() => _WhitelabellingScreenState();
}

class _WhitelabellingScreenState extends State<WhitelabellingScreen> {
  // ── Form controllers ──────────────────────────────────────────────────────────
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController secNumberController = TextEditingController();
  TextEditingController primNumController = TextEditingController();
  TextEditingController altNumController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController hcoNumController = TextEditingController();
  TextEditingController medicareController = TextEditingController();
  TextEditingController npiNumController = TextEditingController();
  TextEditingController faxController = TextEditingController();

  TextEditingController addressCtlr = TextEditingController();
  TextEditingController nameCtlr = TextEditingController();
  TextEditingController secNumberCtlr = TextEditingController();
  TextEditingController primNumCtlr = TextEditingController();
  TextEditingController altNumCtlr = TextEditingController();
  TextEditingController emailCtlr = TextEditingController();
  TextEditingController hcoNumCtlr = TextEditingController();
  TextEditingController medicareCtlr = TextEditingController();
  TextEditingController npiNumCtlr = TextEditingController();
  TextEditingController faxCtlr = TextEditingController();

  // ── Stream controllers ────────────────────────────────────────────────────────
  final StreamController<List<PlatformFile>> _mobileFilesStreamController =
  StreamController<List<PlatformFile>>.broadcast();
  final StreamController<List<PlatformFile>> _webFilesStreamController =
  StreamController<List<PlatformFile>>.broadcast();
  final StreamController<List<WhiteLabellingCompanyDetailModal>> _controller =
  StreamController<List<WhiteLabellingCompanyDetailModal>>();

  bool showManageScreen = false;
  bool showWhitelabellingScreen = true;
  final ScrollController _horizontalScrollController = ScrollController();

  List<PlatformFile>? pickedMobileFiles;
  List<PlatformFile>? pickedWebFiles;

  /// Company details only (name/address/phones/etc). NEVER reassigned by the
  /// logo upload flow — that's the whole point of the split below.
  late Future<WhiteLabellingCompanyDetailModal> _whitelabelFuture;

  /// Logo panel's own state. Uploading a new logo only ever updates this
  /// notifier, so only the widgets listening to it rebuild — the details
  /// form, top bar, etc. are completely untouched.
  final ValueNotifier<_LogoSectionState> _logoNotifier =
  ValueNotifier(const _LogoSectionState());

  // ── Address autocomplete ──────────────────────────────────────────────────────
  ValueNotifier<List<String>> _suggestionsNotifier = ValueNotifier([]);

  var maskFormatter = MaskTextInputFormatter(
      mask: '+# (###) ###-##-##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  bool _isEditing = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _whitelabelFuture = getWhiteLabellingData(context);

    // Seed the logo panel from the same initial fetch (one API call covers
    // both details + logo on first load), but store it separately so future
    // logo updates never touch _whitelabelFuture.
    _whitelabelFuture.then((data) {
      if (!mounted) return;
      final hasLogo = data.logos.isNotEmpty;
      _logoNotifier.value = _logoNotifier.value.copyWith(
        isInitialLoading: false,
        logoId: hasLogo ? data.logos[0].companyLogoId : null,
        logoUrl: hasLogo ? data.logos[0].url : null,
      );
    }).catchError((e) {
      if (!mounted) return;
      _logoNotifier.value = _logoNotifier.value.copyWith(
        isInitialLoading: false,
        error: e.toString(),
      );
    });

    addressController.addListener(_onAddressChanged);
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _mobileFilesStreamController.close();
    _webFilesStreamController.close();
    _controller.close();
    addressController.removeListener(_onAddressChanged);
    nameController.dispose();
    addressController.dispose();
    secNumberController.dispose();
    primNumController.dispose();
    altNumController.dispose();
    emailController.dispose();
    faxController.dispose();
    _logoNotifier.dispose();
    super.dispose();
  }

  void _onAddressChanged() async {
    if (addressController.text.isEmpty) {
      _suggestionsNotifier.value = [];
      return;
    }
    final suggestions = await fetchSuggestions(addressController.text);
    _suggestionsNotifier.value = suggestions;
  }

  // ── Pick file → upload immediately ───────────────────────────────────────────
  /// Opens the file picker. On selection it:
  ///   1. Shows an immediate local preview (Image.memory) — logo section only.
  ///   2. Calls PATCH if a logo already exists, otherwise POST.
  ///   3. On success: updates _logoNotifier (NOT _whitelabelFuture) and tells
  ///      the app-wide CompanyLogoService to refresh, so app bars elsewhere
  ///      update too. On failure: rolls back the preview.
  ///
  /// Nothing here calls setState() on the screen itself — every state change
  /// flows through _logoNotifier, so only the logo panel repaints.
  Future<void> _pickAndUploadLogo({
    required bool hasExistingLogo,
    int? existingLogoId,
  }) async {
    // Guard: don't open picker while another upload is running
    if (_logoNotifier.value.isUploading) return;

    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', ],
    );

    if (result == null) return; // user cancelled

    final bytes = result.files.first.bytes;
    final name = result.files.first.name;

    if (bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not read file bytes. Please try again.')),
        );
      }
      return;
    }

    // Show preview + spinner immediately — logo panel only
    _logoNotifier.value = _logoNotifier.value.copyWith(
      previewBytes: bytes,
      isUploading: true,
      clearError: true,
    );

    try {
      final response = hasExistingLogo && existingLogoId != null
          ? await patchWebAndAppLogo(
        context: context,
        type: "web",
        documentFile: bytes,
        companyLogoId: existingLogoId,
        documentName: name,
      )
          : await uploadWebAndAppLogo(
        context: context,
        type: "web",
        documentFile: bytes,
        documentName: name,
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _applyUploadSuccess();
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => EditSuccessPopup(
            message: hasExistingLogo
                ? 'Logo updated successfully'
                : 'Logo uploaded successfully',
          ),
        );
      } else {
        _logoNotifier.value = _logoNotifier.value.copyWith(
          isUploading: false,
          clearPreview: true,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text(response.message ?? 'Upload failed. Try again.')),
        );
      }
    } catch (e) {
      if (mounted) {
        _logoNotifier.value = _logoNotifier.value.copyWith(
          isUploading: false,
          clearPreview: true,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Try again.')),
        );
      }
    }
  }

  /// Re-fetches just enough to know the new logo id/url and pushes it into
  /// _logoNotifier. Also nudges the app-wide CompanyLogoService so every
  /// CompanyLogoWidget in other app bars updates too.
  ///
  /// NOTE: if patchWebAndAppLogo/uploadWebAndAppLogo's response already
  /// includes the new logo url + id, skip this re-fetch entirely and just
  /// call _logoNotifier.value = ...copyWith(logoId: response.data.id,
  /// logoUrl: response.data.url) directly — it's faster and avoids a race
  /// if the server hasn't finished processing the file yet.
  Future<void> _applyUploadSuccess() async {
    // Force-evict whatever was showing before this upload, so there's no
    // chance of the old bytes lingering in Flutter's ImageCache — belt and
    // suspenders alongside the ValueKey + cache-bust below.
    final previousUrl = _logoNotifier.value.logoUrl;
    if (previousUrl != null) {
      await NetworkImage(previousUrl).evict();
    }

    final data = await getWhiteLabellingData(context);
    if (!mounted) return;

    final hasLogo = data.logos.isNotEmpty;
    final rawUrl = hasLogo ? data.logos[0].url : null;

    // 🔑 FIX: rawUrl can already carry its own query string (e.g. signed
    // URLs like "...?token=abc"). Blindly appending "?v=..." produced
    // "...?token=abc?v=123", which the CDN/storage 404'd on — that 404 is
    // exactly what was rendering as the broken-image icon after upload.
    final bustedUrl = rawUrl == null
        ? null
        : '$rawUrl${rawUrl.contains('?') ? '&' : '?'}v=${DateTime.now().millisecondsSinceEpoch}';

    _logoNotifier.value = _logoNotifier.value.copyWith(
      isUploading: false,
      clearPreview: true,
      logoId: hasLogo ? data.logos[0].companyLogoId : null,
      logoUrl: bustedUrl,
      retryCount: 0, // fresh URL gets a clean set of retry attempts
    );

    // Tell every CompanyLogoWidget elsewhere in the app (other screens'
    // app bars) to refresh too.
    if (bustedUrl != null) {
      CompanyLogoService.instance.updateLogoUrl(bustedUrl);
    } else {
      CompanyLogoService.instance.refresh(context);
    }
  }

  /// Called from the network Image's errorBuilder. Right after upload, the
  /// CDN/storage can take a moment to finish propagating the new file, so
  /// the very first Image.network load can 404 even though the upload
  /// itself succeeded (see the comment in _applyUploadSuccess). Re-bust the
  /// URL and retry a few times before giving up and showing the fallback icon.
  void _scheduleLogoRetry() {
    final current = _logoNotifier.value;
    if (current.logoUrl == null || current.retryCount >= 3) return;
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final base = current.logoUrl!.split('?').first;
      _logoNotifier.value = _logoNotifier.value.copyWith(
        logoUrl: '$base?v=${DateTime.now().millisecondsSinceEpoch}',
        retryCount: current.retryCount + 1,
      );
    });
  }

  // ── Logo container with overlaid pencil button ────────────────────────────────
  Widget _buildLogoPanel(_LogoSectionState state) {
    return Stack(
      children: [
        // ── Main bordered box ─────────────────────────────────────────────────
        Container(
          height: 320,
          decoration: BoxDecoration(
            border: Border.all(color: ColorManager.blueprime),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Center(
            child: _buildLogoContent(state),
          ),
        ),

        // ── Pencil / add button pinned to bottom-right ────────────────────────
        // Hidden while the initial fetch is loading; shows spinner while upload runs.
        if (!state.isInitialLoading)
          Positioned(
            top: 10,
            right: 10,
            child: state.isUploading
                ? _circleWidget(
              child: const Padding(padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
            )
                : Tooltip(
              message: state.hasLogo ? 'Change logo' : 'Add logo',
              child: InkWell(
                onTap: () => _pickAndUploadLogo(
                  hasExistingLogo: state.hasLogo,
                  existingLogoId: state.logoId,
                ),
                borderRadius: BorderRadius.circular(20),
                child: _circleWidget(
                  child: Icon(
                    state.hasLogo
                        ? Icons.edit_outlined
                        : Icons.add_photo_alternate_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Shared styled circle container for the action button
  Widget _circleWidget({required Widget child}) {
    return Container(
      height: 25,
      width: 25,
      decoration: BoxDecoration(
        color: ColorManager.blueprime,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _fallbackLogoImage() {
    return Icon(
      Icons.image_not_supported,
      size: 48,
      color: ColorManager.mediumgrey,
    );
  }

  /// Pure display logic for what goes inside the bordered box.
  /// 🔑 FIX: both the preview and network branches now size the image off
  /// the box's real constraints via LayoutBuilder instead of a hardcoded
  /// AppSize.s300, which was overflowing the 320px container by 4px once
  /// the "Preview"/"Uploading…" label was added below it.
  Widget _buildLogoContent(_LogoSectionState state) {
    // 1. Initial API loading
    if (state.isInitialLoading) {
      return const CircularProgressIndicator();
    }

    // 2. Local bytes ready — show preview (+ "Uploading…" label while in-flight)
    if (state.previewBytes != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final maxH = constraints.maxHeight.isFinite ? constraints.maxHeight : 320.0;
          final imageHeight = (maxH - 32).clamp(0.0, maxH);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.memory(
                state.previewBytes!,
                height: imageHeight,
                width: AppSize.s300,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _fallbackLogoImage(),
              ),
              const SizedBox(height: 8),
              Text(
                state.isUploading ? 'Uploading…' : 'Preview',
                style: TextStyle(
                  fontSize: FontSize.s12,
                  color: ColorManager.mediumgrey,
                ),
              ),
            ],
          );
        },
      );
    }

    // 3. Logo fetched from server
    if (state.hasLogo && state.logoUrl != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final maxH = constraints.maxHeight.isFinite ? constraints.maxHeight : 320.0;
          return Image.network(
            state.logoUrl!,
            // 🔑 Keying by URL forces Flutter to fully remount this Image every
            // time the URL changes (even if only the cache-bust query differs),
            // instead of reusing the previous widget/render object. That's what
            // guarantees a real reload — with loadingBuilder firing again —
            // on every single upload, not just the first one.
            key: ValueKey(state.logoUrl),
            height: maxH,
            width: AppSize.s300,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return const SizedBox(
                height: AppSize.s25,
                width: AppSize.s25,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            },
            errorBuilder: (_, __, ___) {
              // 🔑 FIX: right after upload the CDN can 404 briefly before the
              // file finishes propagating. Retry a few times (spaced 800ms
              // apart) instead of dropping straight to the broken-image icon.
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _scheduleLogoRetry());
              return state.retryCount < 3
                  ? const SizedBox(
                height: AppSize.s25,
                width: AppSize.s25,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : _fallbackLogoImage();
            },
          );
        },
      );
    }

    // 4. Empty state
    return Text(
      'No available logo!',
      style: AllNoDataAvailable.customTextStyle(context),
    );
  }

  // ── Details Save (form) ───────────────────────────────────────────────────────
  Future<void> _onSaveDetails() async {
    // Wire up your details update API call here
  }

  // ── Main build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: LayoutBuilder(builder: (context, constraints) {
        const double minContentWidth = 1200;
        final double contentWidth = constraints.maxWidth > minContentWidth
            ? constraints.maxWidth
            : minContentWidth;
        return CustomScrollbar(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppPadding.p10),
              child: SizedBox(
                width: contentWidth,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizeConst.A40),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSize.s10),
                        // ── Top bar ────────────────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: AppPadding.p15),
                              child: InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                onTap: widget.backButtonCallback,
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  color: ColorManager.mediumgrey,
                                  size: IconSize.I16,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: AppPadding.p15,top: AppPadding.p16),
                              child: Text(
                                AppStringEM.logos,
                                style: TextStyle(
                                  fontSize: FontSize.s14,
                                  fontWeight: FontWeight.w600,
                                  color: ColorManager.mediumgrey,
                                ),
                              ),
                            ),
                            SizedBox(width: contentWidth / 3.55),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top:AppPadding.p15),
                                child: Text(
                                  AppStringEM.details,
                                  style: TextStyle(
                                    fontSize: FontSize.s14,
                                    fontWeight: FontWeight.w600,
                                    color: ColorManager.mediumgrey,
                                  ),
                                ),
                              ),
                            ),
                            // Details Save button (form only, not logo)
                            SizedBox(
                              height: AppSize.s30,
                              width: AppSize.s90,
                              child: CustomButton(
                                borderRadius: 12,
                                style: BlueButtonTextConst.customTextStyle(
                                    context),
                                text: AppStringEM.save,
                                onPressed: _onSaveDetails,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizeConst.A20),
                        // ── Logo + Details row ─────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: ValueListenableBuilder<_LogoSectionState>(
                                valueListenable: _logoNotifier,
                                builder: (context, logoState, _) =>
                                    _buildLogoPanel(logoState),
                              ),
                            ),

                            const SizedBox(width: AppSize.s35),

                            // ── Details panel ──────────────────────────────────
                            Expanded(
                              flex: 6,
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: ColorManager.blueprime),
                                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                                    ),
                                    height: 320,
                                    width: 1100,
                                    child: FutureBuilder<WhiteLabellingCompanyDetailModal>(
                                      future: _whitelabelFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                              CircularProgressIndicator());
                                        }
                                        if (snapshot.hasData) {
                                          final data = snapshot.data!;
                                          nameController = TextEditingController(
                                              text: data
                                                  .companyDetail.name);
                                          secNumberController.text = data.contactDetail.secondaryPhone;
                                          faxController.text = data.contactDetail.primaryFax;
                                          addressController.text = data.companyDetail.address;
                                          primNumController.text = data.contactDetail.primaryPhone;
                                          altNumController.text = data.contactDetail.alternativePhone;
                                          emailController.text = data.contactDetail.email;

                                          return Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  EditTextField(
                                                    enabled: _isEditing,
                                                    controller:
                                                    nameController,
                                                    keyboardType:
                                                    TextInputType.text,
                                                    text: AppStringEM
                                                        .companyName,
                                                  ),
                                                  const SizedBox(height: AppSizeConst.A20),
                                                  EditTextFieldPhone(
                                                    controller:
                                                    secNumberController,
                                                    keyboardType:
                                                    TextInputType.number,
                                                    text: AppStringEM.secNum,
                                                    enabled: _isEditing,
                                                  ),
                                                  const SizedBox(height: AppSizeConst.A20),
                                                  EditTextField(
                                                    controller:
                                                    faxController,
                                                    keyboardType:
                                                    TextInputType.text,
                                                    text: AppStringEM.fax,
                                                    enabled: _isEditing,
                                                  ),
                                                  const SizedBox(height: AppSizeConst.A20),
                                                  EditTextField(
                                                    controller:
                                                    emailController,
                                                    keyboardType:
                                                    TextInputType.text,
                                                    text: AppStringEM
                                                        .primarymail,
                                                    enabled: _isEditing,
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  EditTextFieldPhone(
                                                    controller:
                                                    primNumController,
                                                    keyboardType:
                                                    TextInputType.number,
                                                    text: AppStringEM.primNum,
                                                    enabled: _isEditing,
                                                  ),
                                                  const SizedBox(height: AppSizeConst.A20),
                                                  EditTextFieldPhone(
                                                    controller:
                                                    altNumController,
                                                    keyboardType:
                                                    TextInputType.number,
                                                    text: AppStringEM
                                                        .alternatephone,
                                                    enabled: _isEditing,
                                                  ),
                                                  const SizedBox(height: AppSizeConst.A20),
                                                  EditTextField(
                                                    controller:
                                                    addressController,
                                                    keyboardType:
                                                    TextInputType.text,
                                                    text: "Street Address",
                                                    enabled: _isEditing,
                                                  ),
                                                  SizedBox(
                                                    height: AppSize.s72,
                                                    width: MediaQuery.of(context).size.width / 5,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}