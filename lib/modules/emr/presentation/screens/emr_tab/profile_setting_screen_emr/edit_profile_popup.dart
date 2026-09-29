import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/setting_profile_manager/emr_profile_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/hr_module_manager/manage_emp/employeement_manager.dart';
import 'package:symmetry_emr/data/api_data/api_data.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_const/sucess_failed_popup_const.dart';

// TODO: adjust this import to wherever `uploadphoto()` actually lives
// (e.g. a manage_module_manager / document manager file).
// import '../../../../../app/services/api/managers/.../manage_module_manager.dart';

/// Formats digits into a US-style phone number: (777) 777-7777
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly =
    newValue.text.replaceAll(RegExp(r'\D'), '').substring(
        0, newValue.text.replaceAll(RegExp(r'\D'), '').length > 10
        ? 10
        : newValue.text.replaceAll(RegExp(r'\D'), '').length);

    final buffer = StringBuffer();

    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 0) buffer.write('(');
      buffer.write(digitsOnly[i]);
      if (i == 2) buffer.write(') ');
      if (i == 5) buffer.write('-');
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// "Edit Profile" popup dialog wired up to call `updateEmployee` on Save
/// and `uploadphoto` when the user picks a new profile photo.
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   barrierColor: Colors.black54,
///   builder: (context) => EditProfilePopup(
///     employeeId: 123,
///     userId: 45,
///     avatarUrl: 'https://example.com/avatar.jpg',
///     firstNameController: firstNameController,
///     lastNameController: lastNameController,
///     phoneController: phoneController,
///     emailController: emailController,
///     onUpdated: () {
///       // e.g. refresh profile data on the parent screen
///     },
///   ),
/// );
/// ```
class EditProfilePopup extends StatefulWidget {
  const EditProfilePopup({
    super.key,
    required this.employeeId,
    required this.userId, // ✅ passed from ProfileDetailScreen (originated in EmrAppBar)
    required this.avatarUrl,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.emailController,
    this.onUpdated,
  });

  final int employeeId;
  final int userId; // ✅ NEW
  final String avatarUrl;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;

  /// Called after a successful save or photo upload.
  /// Use this to refresh the parent screen's data.
  final VoidCallback? onUpdated;

  @override
  State<EditProfilePopup> createState() => _EditProfilePopupState();
}

class _EditProfilePopupState extends State<EditProfilePopup> {
  static const Color _fieldFill = Color(0xFFF4F5F7);
  static const Color _hintColor = Color(0xFF9AA0A6);
  static const Color _accentBlue = Color(0xFF4FA8DA);

  bool _isSaving = false;
  bool _isUploadingPhoto = false;

  // Locally picked image bytes, shown as a preview immediately after
  // picking, before/while the upload request completes.
  Uint8List? _pickedImageBytes;

  Future<void> _handlePickAndUploadPhoto() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return; // user cancelled the picker

    final bytes = await picked.readAsBytes();

    setState(() {
      _pickedImageBytes = bytes; // show preview right away
      _isUploadingPhoto = true;
    });

    // NOTE: replace `uploadphoto` below with the correct import/reference
    // for wherever that function actually lives in your project.
    final ApiData result = await uploadphoto(
      context: context,
      employeeid: widget.employeeId,
      documentFile: bytes,
      documentName: picked.name,
    );

    if (!mounted) return;

    setState(() => _isUploadingPhoto = false);

    if (result.success) {
      widget.onUpdated?.call();
    } else {
      // Revert preview if upload failed.
      setState(() => _pickedImageBytes = null);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddErrorPopup(message: result.message);
        },
      );
    }
  }

  Future<void> _handleSave() async {
    final firstName = widget.firstNameController.text.trim();
    final lastName = widget.lastNameController.text.trim();
    final phone = widget.phoneController.text.trim();
    final email = widget.emailController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("First name and last name are required")),
      );
      return;
    }

    setState(() => _isSaving = true);

    final ApiData result = await updateEmployee(
      context: context,
      employeeId: widget.employeeId,
      userId: widget.userId, // ✅ fixed — was `userId: null`
      firstName: firstName,
      lastName: lastName,
      primaryPhoneNbr: phone,
      personalEmail: email,
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (result.success) {
      await showDialog(
        context: context,
        builder: (_) => const EMRSuccessPopup(
          title: 'Success',
          message: 'Profile updated\nsuccessfully.',
        ),
      );
      widget.onUpdated?.call();
      Navigator.of(context).pop();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddErrorPopup(
            message: result.message,
          );
        },
      );
    }
  }

  bool get _isBusy => _isSaving || _isUploadingPhoto;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: title + close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: _isBusy ? null : () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.redAccent,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Avatar with edit icon
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: _fieldFill,
                      backgroundImage: _pickedImageBytes != null
                          ? MemoryImage(_pickedImageBytes!)
                          : (widget.avatarUrl.isNotEmpty
                          ? NetworkImage(widget.avatarUrl)
                          : null) as ImageProvider?,
                      child: _pickedImageBytes == null &&
                          widget.avatarUrl.isEmpty
                          ? const Icon(Icons.person,
                          size: 40, color: _hintColor)
                          : null,
                    ),
                    if (_isUploadingPhoto)
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black38,
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _isBusy ? null : _handlePickAndUploadPhoto,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black12),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Section label
              const Text(
                'Your Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              _ProfileTextField(
                hint: 'First Name',
                controller: widget.firstNameController,
                enabled: !_isBusy,
              ),
              const SizedBox(height: 12),
              _ProfileTextField(
                hint: 'Last Name',
                controller: widget.lastNameController,
                enabled: !_isBusy,
              ),
              const SizedBox(height: 12),
              _ProfileTextField(
                hint: 'Phone Number',
                controller: widget.phoneController,
                keyboardType: TextInputType.phone,
                enabled: !_isBusy,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _PhoneNumberFormatter(),
                ],
              ),
              const SizedBox(height: 12),
              _ProfileTextField(
                hint: 'Email Address',
                controller: widget.emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_isBusy,
              ),
              const SizedBox(height: 30),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isBusy ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFBFBFBF),
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable, uniformly styled text field used inside the popup.
class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.hint,
    this.controller,
    this.keyboardType,
    this.enabled = true,
    this.inputFormatters,
  });

  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  static const Color _fieldFill = Color(0xFFF4F5F7);
  static const Color _hintColor = Color(0xFF9AA0A6);
  static const Color _accentBlue = Color(0xFF4FA8DA);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: _hintColor,
          fontSize: 14,
        ),
        filled: true,
        fillColor: _fieldFill,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: _accentBlue,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}