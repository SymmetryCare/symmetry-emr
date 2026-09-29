import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:symmetry_emr/app/services/token/token_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_right_widget_components/widgets/widgets/widgets/order_success_popup_const.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/data/api/managers/emr_module_manager/emr_dash_manager/emr_dashboard_manager.dart';
import 'package:symmetry_emr/modules/emr/data/models/emr_module_data/emr_dash_data/reminder_model.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/em/company_identity/widgets/whitelabelling/success_popup.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/emr_dashbord/dashboard_right_widget_components/widgets/common_components.dart';

void showCreateNewOrderDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.3),
    builder: (_) => const PatientsOrderDialog(),
  );
}

// ── Item Entry Model ──────────────────────────────────────────────────────────

class _ItemEntry {
  String? imageName;
  Uint8List? imageBytes;
  final TextEditingController skuController = TextEditingController();
  int quantity = 1;

  InventorySupplyData? selectedInventory;
  List<InventorySupplyData> searchResults = [];
  bool isSearching = false;
  bool showOverlay = false;
  bool isConfirmed = false;

  // ── Validation state ──────────────────────────────────────────────────────
  String? skuError;

  // ── Stock validation ──────────────────────────────────────────────────────
  /// true when quantity > selectedInventory.qty
  bool get isOverStock =>
      selectedInventory != null && quantity > selectedInventory!.qty;

  void dispose() => skuController.dispose();
}

// ── Main Dialog ───────────────────────────────────────────────────────────────

class PatientsOrderDialog extends StatefulWidget {
  const PatientsOrderDialog({super.key});

  @override
  State<PatientsOrderDialog> createState() => _PatientsOrderDialogState();
}

class _PatientsOrderDialogState extends State<PatientsOrderDialog> {
  int _currentStep = 1;

  final TextEditingController _patientController = TextEditingController();

  // ── Patient search state ──────────────────────────────────────────────────
  List<PatientNameDetails> _patientSearchResults = [];
  bool _patientSearching = false;
  bool _patientShowOverlay = false;
  SupplyOrderPatientDetails? _patientDetails;
  int? _selectedPatientId;

  // ── Category state ────────────────────────────────────────────────────────
  List<String> _selectedCategories = [];
  List<String> _categories = [];
  List<SupplyOrderCategoryData> _categoryData = [];
  bool _categoriesLoading = false;

  final List<_ItemEntry> _items = [_ItemEntry()];

  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  static const List<String> _patientOrderSteps = [
    'Select Patient',
    'Choose Item',
    'Configure Item',
    'Address Info',
  ];

  // ── Field-level validation errors ─────────────────────────────────────────
  String? _patientError;
  String? _categoryError;
  String? _itemStepError;
  String? _supplyMethodError;
  String? _addressError;
  String? _deliveryError;

  // ── Stock validation helper ───────────────────────────────────────────────
  /// Returns true if any item's quantity exceeds its current stock
  bool get _hasStockViolation => _items.any((e) => e.isOverStock);

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadCategories();

    // ── Clear the address error as soon as the user types something ──
    _addressController.addListener(() {
      if (_addressError != null && _addressController.text.trim().isNotEmpty) {
        setState(() => _addressError = null);
      }
    });
  }

  Future<void> _loadCategories() async {
    setState(() => _categoriesLoading = true);
    final result = await getSupplyOrderCategory(context: context);
    if (mounted) {
      setState(() {
        _categoryData = result;
        _categories = result.map((e) => e.categoryName).toList();
        _categoriesLoading = false;
      });
    }
  }

  int get _selectedCategoryId {
    if (_selectedCategories.isEmpty) return 0;
    final match = _categoryData.firstWhere(
          (e) => e.categoryName == _selectedCategories.first,
      orElse: () => SupplyOrderCategoryData(categoryId: 0, categoryName: ''),
    );
    return match.categoryId;
  }

  @override
  void dispose() {
    _patientController.dispose();
    _notesController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────

  /// Validates all fields that belong to [step]. Sets the relevant error
  /// messages via setState and returns true only when every field on that
  /// step is valid.
  bool _validateStep(int step) {
    switch (step) {
      case 1:
        setState(() {
          _patientError =
          _selectedPatientId == null ? 'Please select a patient.' : null;
          _categoryError = _selectedCategories.isEmpty
              ? 'Please select at least one category.'
              : null;
        });
        return _patientError == null && _categoryError == null;

      case 2:
      // Validate every confirmed item plus the currently active one.
        String? firstError;
        setState(() {
          for (final entry in _items) {
            // ── FIX: a typed/selected name satisfies the row — we no ──
            // ── longer hard-require `selectedInventory` to be set. ──
            final hasName = entry.skuController.text.trim().isNotEmpty;
            if (!hasName) {
              entry.skuError = 'Please select a supply item.';
              firstError ??= 'Please select a supply item for every row.';
            } else if (entry.selectedInventory != null &&
                entry.isOverStock) {
              entry.skuError =
              'Quantity exceeds available stock (${entry.selectedInventory!.qty}).';
              firstError ??=
              'One or more items have a quantity greater than the current stock.';
            } else if (entry.quantity < 1) {
              entry.skuError = 'Quantity must be at least 1.';
              firstError ??= 'Quantity must be at least 1 for every item.';
            } else {
              entry.skuError = null;
            }
          }
          _itemStepError = firstError;
        });
        return _itemStepError == null;

      case 3:
        setState(() {
          _supplyMethodError =
          _supplyMethod == null ? 'Please select a supply method.' : null;
        });
        return _supplyMethodError == null;

      case 4:
        setState(() {
          _addressError = _addressController.text.trim().isEmpty
              ? 'Please enter a delivery address.'
              : null;
          _deliveryError = _deliveryMethod == null
              ? 'Please select a delivery method.'
              : null;
        });
        return _addressError == null && _deliveryError == null;

      default:
        return true;
    }
  }

  /// Small reusable inline error message, shown under a field.
  Widget _errorText(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 12, color: Colors.red.shade500),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                fontSize: 10,
                color: Colors.red.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: Container(
        width: 520,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StepperWidgetWithHead(
              title: 'Create New Order',
              stepLabels: _patientOrderSteps,
              currentStep: _currentStep,
              onStepTapped: (step) => setState(() => _currentStep = step),
              onClose: () => Navigator.pop(context),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.52,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: KeyedSubtree(
                    key: ValueKey(_currentStep),
                    child: switch (_currentStep) {
                      1 => _selectPatientTab(),
                      2 => chooseItemTab(),
                      3 => _buildStep3(),
                      4 => _buildStep4(),
                      _ => const SizedBox.shrink(),
                    },
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ── STEP 1 : Select Patient ───────────────────────────────────────────────

  Future<void> _searchPatient(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _patientSearchResults = [];
        _patientShowOverlay = false;
        _patientSearching = false;
      });
      return;
    }
    setState(() {
      _patientSearching = true;
      _patientShowOverlay = true;
    });
    final results = await getSupplyPatientByName(
      context: context,
      patientName: query,
    );
    if (mounted) {
      setState(() {
        _patientSearchResults = results;
        _patientSearching = false;
      });
    }
  }

  Future<void> _loadPatientDetails(int patientId) async {
    setState(() {
      _selectedPatientId = patientId;
      _patientDetails = null;
      _patientError = null; // ── clear error once a patient is chosen ──
    });
    try {
      final details = await getSupplyPatientDeatils(
        context: context,
        patientId: patientId,
      );
      if (mounted) {
        setState(() {
          if (details != null) {
            _patientDetails = details;
            // ── Pre-fill address from patient details ──────
            final String addr = details.address?.toString() ?? '';
            if (addr.isNotEmpty) {
              _addressController.text = addr;
            }
          }
        });
      }
    } catch (e) {
      debugPrint('_loadPatientDetails error: $e');
    }
  }

  Widget _selectPatientTab() {
    return ScrollConfiguration(
      behavior: ScrollBehavior().copyWith(scrollbars: false),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            fieldLabel(context,'Patient Name'),
            const SizedBox(height: AppSize.s6),
            _buildPatientSearchField(),
            _errorText(_patientError),

            if (_patientDetails != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "PATIENT'S DETAILS",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _patientDetailRow('Patient ID:', _patientDetails!.patientId?.toString() ?? '—'),
                    _patientDetailRow('Name:', _patientDetails!.name?.toString() ?? '—'),
                    _patientDetailRow('Age:', _patientDetails!.age?.toString() ?? '—'),
                    _patientDetailRow('Last Order Date:', _patientDetails!.lastSupplyOrderDate?.toString() ?? '—'),
                    _patientDetailRow('Address:', _patientDetails!.address?.toString() ?? '—'),
                  ],
                ),
              ),
            ] else if (_selectedPatientId != null && _patientDetails == null) ...[
              const SizedBox(height: 8),
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSize.s25),

            fieldLabel(context,'Select Category'),
            const SizedBox(height: AppSize.s6),
            _categoriesLoading
                ? const SizedBox(
              height: 38,
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
                : MultiSelectDropdown(
              options: _categories,
              selected: _selectedCategories,
              hint: 'Select',
              maxOverlayHeight: 90,
              onChanged: (vals) => setState(() {
                _selectedCategories = vals;
                // ── clear error once a category is chosen ──
                if (_selectedCategories.isNotEmpty) _categoryError = null;
              }),
            ),
            _errorText(_categoryError),

            const SizedBox(height: AppSize.s40),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(
              color: _patientShowOverlay && _patientSearchResults.isNotEmpty
                  ? Colors.grey.shade400
                  : Colors.grey.shade300,
            ),
            borderRadius:
            _patientShowOverlay && _patientSearchResults.isNotEmpty
                ? const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            )
                : BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: TextField(
                    controller: _patientController,
                    style: const TextStyle(fontSize: 12),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Search patient by name',
                      hintStyle:
                      TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12,vertical: 5),
                      isCollapsed: true,
                      border: InputBorder.none,
                    ),
                    onChanged: (val) => _searchPatient(val),
                    onTap: () {
                      if (_patientSearchResults.isNotEmpty) {
                        setState(() => _patientShowOverlay = true);
                      }
                    },
                  ),
                ),
              ),
              if (_patientSearching)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      color: Colors.grey.shade400,
                    ),
                  ),
                )
              else if (_selectedPatientId != null)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPatientId = null;
                      _patientDetails = null;
                      _patientController.clear();
                      _patientSearchResults = [];
                      _patientShowOverlay = false;
                      _addressController.clear(); // ── clear pre-filled address
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(Icons.close,
                        size: 16, color: Colors.grey.shade400),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.search,
                      size: 16, color: Colors.grey.shade400),
                ),
            ],
          ),
        ),

        if (_patientShowOverlay && _patientSearchResults.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: Colors.grey.shade400),
                right: BorderSide(color: Colors.grey.shade400),
                bottom: BorderSide(color: Colors.grey.shade400),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _patientSearchResults.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, i) {
                final patient = _patientSearchResults[i];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _patientController.text = patient.name;
                      _patientShowOverlay = false;
                      _patientSearchResults = [];
                    });
                    _loadPatientDetails(patient.patientId);
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: ColorManager.blueprime.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person_outline,
                              size: 15, color: ColorManager.blueprime),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            patient.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          'ID: ${patient.patientId}',
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        else if (_patientShowOverlay &&
            !_patientSearching &&
            _patientController.text.isNotEmpty &&
            _patientSearchResults.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Center(
              child: Text('No patients found',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade400)),
            ),
          ),
      ],
    );
  }

  Widget _patientDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          text: '$label ',
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Colors.black54),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  // ── STEP 2 : Choose Item ──────────────────────────────────────────────────

  Widget chooseItemTab() {
    return ScrollConfiguration(
      behavior: ScrollBehavior().copyWith(scrollbars: false),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_itemStepError != null) ...[
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 13, color: Colors.red.shade500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _itemStepError!,
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            ..._items
                .asMap()
                .entries
                .where((e) => e.value.isConfirmed)
                .map((e) => _buildConfirmedItemCard(e.key, e.value)),

            Builder(builder: (_) {
              final activeEntry = _items.last;
              final activeIndex = _items.length - 1;
              return _buildActiveItemEntry(activeIndex, activeEntry);
            }),

            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  final activeEntry = _items.last;
                  // ── FIX: require a name (typed or selected) — no longer ──
                  // ── forces a dropdown selection before letting the user ──
                  // ── move on to the next item row. ──────────────────────
                  if (activeEntry.skuController.text.trim().isEmpty) {
                    setState(() =>
                    activeEntry.skuError = 'Please select a supply item.');
                    return;
                  }
                  if (activeEntry.selectedInventory != null &&
                      activeEntry.isOverStock) {
                    setState(() => activeEntry.skuError =
                    'Quantity exceeds available stock (${activeEntry.selectedInventory!.qty}).');
                    return;
                  }
                  setState(() {
                    _items.last.isConfirmed = true;
                    _items.add(_ItemEntry());
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    '+ Add Another Item',
                    style: TextStyle(
                      fontSize: 11,
                      color: ColorManager.blueprime,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmedItemCard(int index, _ItemEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Details of Item${index + 1} added by you',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _items.removeAt(index)),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Remove Item ${index + 1} ×',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.imageBytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(entry.imageBytes!,
                        width: 64, height: 64, fit: BoxFit.cover),
                  )
                else
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.image_outlined,
                        color: Colors.grey.shade400, size: 28),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow('SKU/Supply Item Name:',
                          entry.skuController.text),
                      _detailRow('Added Quantity:', '${entry.quantity}'),
                      if (entry.selectedInventory != null) ...[
                        _detailRow('Price per 1 unit:',
                            '\$${entry.selectedInventory!.price}'),
                        _detailRow('SKU ID:', entry.selectedInventory!.sku),
                        _detailRow('Description:',
                            entry.selectedInventory!.description),
                        _detailRow(
                            'Expiry Date:', entry.selectedInventory!.expiryDate),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: RichText(
        text: TextSpan(
          text: '$label ',
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black54),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveItemEntry(int index, _ItemEntry entry) {
    final bool overStock = entry.isOverStock;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Upload Image ────────────────────────────────
        fieldLabel(context,'Add Image'),
        const SizedBox(height: 6),
        Row(
          children: [
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final XFile? picked = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                );
                if (picked != null) {
                  final bytes = await picked.readAsBytes();
                  setState(() {
                    entry.imageName = picked.name;
                    entry.imageBytes = bytes;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: ColorManager.blueprime,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.file_upload_outlined,
                        color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('Upload Image',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: FontSize.s12,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  entry.imageName ?? 'No file chosen',
                  style: TextStyle(
                      fontSize: 11,
                      color: entry.imageName != null
                          ? Colors.black87
                          : Colors.grey.shade400),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(child: Container()),
          ],
        ),

        if (entry.imageBytes != null) ...[
          const SizedBox(height: 10),
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.memory(entry.imageBytes!,
                    width: 72, height: 72, fit: BoxFit.cover),
              ),
              Positioned(
                top: -5,
                right: -5,
                child: GestureDetector(
                  onTap: () => setState(() {
                    entry.imageName = null;
                    entry.imageBytes = null;
                  }),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 11),
                  ),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: AppSize.s25),

        // ── SKU / Supply Item Name ────────────────────────
        fieldLabel(context,'SKU/Supply Item Name'),
        const SizedBox(height: AppSize.s6),
        _buildSkuSearchField(entry),
        _errorText(entry.skuError),

        // ── SKU Detail Card ───────────────────────────────
        if (entry.selectedInventory != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SKU DETAILS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 6),
                _detailRow('SKU ID:', entry.selectedInventory!.sku),
                _detailRow('Item Name:', entry.selectedInventory!.name),
                _detailRow('Description:', entry.selectedInventory!.description),
                // ── Current stock — highlighted in red when over-stock ──
                _stockDetailRow(
                  'Current Stock:',
                  '${entry.selectedInventory!.qty}',
                  isWarning: overStock,
                ),
                _detailRow('Expiry Date:', entry.selectedInventory!.expiryDate),
                _detailRow('Price:', '\$${entry.selectedInventory!.price}'),
                _detailRow('Added Quantity:', '${entry.quantity}'),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSize.s25),

        // ── Select Quantity ───────────────────────────────
        fieldLabel(context,'Select Quantity'),
        const SizedBox(height: AppSize.s6),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            // ── Red border when over-stock ──────────────
            border: Border.all(
              color: overStock ? Colors.red.shade400 : Colors.grey.shade300,
              width: overStock ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (entry.quantity > 1) {
                    setState(() {
                      entry.quantity--;
                      if (!entry.isOverStock) entry.skuError = null;
                    });
                  }
                },
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: ColorManager.containerColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.remove,
                      size: 16, color: Colors.black54),
                ),
              ),
              Expanded(
                child: Text(
                  '${entry.quantity}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    // ── Red text when over-stock ──────────
                    color: overStock ? Colors.red.shade600 : Colors.black87,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => entry.quantity++),
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: ColorManager.containerColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add,
                      size: 16, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),

        // ── Inline stock validation message ──────────────
        if (overStock) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 13, color: Colors.red.shade500),
              const SizedBox(width: 4),
              Text(
                'Selected quantity must be less than or equal to current stock (${entry.selectedInventory!.qty})',
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.red.shade500,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],

        const SizedBox(height: AppSize.s25),
      ],
    );
  }

  /// Detail row with optional red warning colour for stock field
  Widget _stockDetailRow(String label, String value,
      {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: RichText(
        text: TextSpan(
          text: '$label ',
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black54),
          children: [
            TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isWarning ? Colors.red.shade600 : Colors.black87,
              ),
            ),
            if (isWarning)
              TextSpan(
                text: '  ⚠ Low',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade500),
              ),
          ],
        ),
      ),
    );
  }

  // ── SKU Search Field with overlay ────────────────────────────────────────

  Future<void> _searchSku(_ItemEntry entry, String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        entry.searchResults = [];
        entry.showOverlay = false;
        entry.isSearching = false;
      });
      return;
    }
    setState(() {
      entry.isSearching = true;
      entry.showOverlay = true;
    });
    final results = await getInventorySupplyData(
      context: context,
      searchQuery: query,
    );
    if (mounted) {
      setState(() {
        entry.searchResults = results;
        entry.isSearching = false;
      });
    }
  }

  Widget _buildSkuSearchField(_ItemEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(
              color: entry.showOverlay && entry.searchResults.isNotEmpty
                  ? Colors.grey.shade400
                  : Colors.grey.shade300,
            ),
            borderRadius: entry.showOverlay && entry.searchResults.isNotEmpty
                ? const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            )
                : BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: TextField(
                    controller: entry.skuController,
                    style: const TextStyle(fontSize: 12),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Search supply item by name / ID',
                      hintStyle: TextStyle(
                          fontSize: 12, color: Colors.grey.shade400),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12,vertical: 5),
                      isCollapsed: true,
                      border: InputBorder.none,
                    ),
                    // ── FIX: typing a name is now enough — clear the ──
                    // ── row error and the top-level banner live as ──
                    // ── soon as text is present, and drop any stale ──
                    // ── `selectedInventory` if the text no longer ──
                    // ── matches it, so state stays honest. ────────
                    onChanged: (val) {
                      _searchSku(entry, val);
                      setState(() {
                        if (val.trim().isNotEmpty) {
                          entry.skuError = null;
                          _itemStepError = null;
                        }
                        if (entry.selectedInventory != null &&
                            val != entry.selectedInventory!.name) {
                          entry.selectedInventory = null;
                        }
                      });
                    },
                    onTap: () {
                      if (entry.searchResults.isNotEmpty) {
                        setState(() => entry.showOverlay = true);
                      }
                    },
                  ),
                ),
              ),
              if (entry.isSearching)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      color: Colors.grey.shade400,
                    ),
                  ),
                )
              else if (entry.selectedInventory != null)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      entry.selectedInventory = null;
                      entry.skuController.clear();
                      entry.searchResults = [];
                      entry.showOverlay = false;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(Icons.close,
                        size: 16, color: Colors.grey.shade400),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.search,
                      size: 16, color: Colors.grey.shade400),
                ),
            ],
          ),
        ),

        if (entry.showOverlay && entry.searchResults.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: Colors.grey.shade400),
                right: BorderSide(color: Colors.grey.shade400),
                bottom: BorderSide(color: Colors.grey.shade400),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: entry.searchResults.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, i) {
                final item = entry.searchResults[i];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      entry.selectedInventory = item;
                      entry.skuController.text = item.name;
                      entry.showOverlay = false;
                      entry.searchResults = [];
                      // Reset quantity to 1 on new selection
                      entry.quantity = 1;
                      // ── clear error once an item is chosen ──
                      entry.skuError = null;
                      // ── FIX: also clear the top-level banner so it ──
                      // ── doesn't stay stuck showing a stale error ──
                      // ── after the row becomes valid. ────────────────
                      _itemStepError = null;
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              if (item.sku.isNotEmpty)
                                Text(
                                  'SKU: ${item.sku}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // ── Show stock badge in overlay ───
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${item.price}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: ColorManager.blueprime,
                              ),
                            ),
                            Text(
                              'Stock: ${item.qty}',
                              style: TextStyle(
                                fontSize: 10,
                                color: item.qty > 0
                                    ? Colors.green.shade600
                                    : Colors.red.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        else if (entry.showOverlay &&
            !entry.isSearching &&
            entry.skuController.text.isNotEmpty &&
            entry.searchResults.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Center(
              child: Text('No items found',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade400)),
            ),
          ),
      ],
    );
  }

  // ── STEP 3 : Configure Item ───────────────────────────────────────────────

  String? _supplyMethod;
  bool _supplyDropdownOpen = false;

  Widget _buildStep3() {
    final activeItems =
    _items.where((e) => e.selectedInventory != null).toList();

    final double total = activeItems.fold(
      0,
          (sum, e) => sum + (e.selectedInventory!.price * e.quantity),
    );

    if (activeItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'No items added yet.\nGo back to Step 2 and select supply items.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ),
      );
    }

    return ScrollConfiguration(
      behavior: ScrollBehavior().copyWith(scrollbars: false),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order Details (total ${activeItems.length} items)',
                        style: TextStyle(
                          fontSize: FontSize.s12,
                          fontWeight: FontWeight.w500,
                          color: ColorManager.mediumgrey,
                        ),
                      ),
                      Text(
                        'Order total: \$${total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: FontSize.s12,
                          fontWeight: FontWeight.w600,
                          color: ColorManager.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: activeItems.asMap().entries.map((e) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildOrderItemCard(e.key, e.value),
                          const SizedBox(height: 15),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            fieldLabel(context,'Supply Method'),
            const SizedBox(height: 6),
            _buildSupplyMethodDropdown(),
            _errorText(_supplyMethodError),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemCard(int index, _ItemEntry entry) {
    final inv = entry.selectedInventory!;
    final bool overStock = entry.isOverStock;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0XFFF4F4F4),
        borderRadius: BorderRadius.circular(8),
        // ── Red outline when over-stock ─────────────────
        border: overStock
            ? Border.all(color: Colors.red.shade300, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: entry.imageBytes != null
                        ? Image.memory(entry.imageBytes!,
                        width: 65, height: 65, fit: BoxFit.cover)
                        : Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border:
                        Border.all(color: Colors.grey.shade200),
                      ),
                      child: Icon(Icons.inventory_2_outlined,
                          size: 26, color: Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (entry.quantity > 1) {
                            setState(() => entry.quantity--);
                          }
                        },
                        child: Container(
                          width: 20,
                          height: 22,
                          decoration: BoxDecoration(
                              color: ColorManager.white,
                              shape: BoxShape.circle),
                          child: const Center(
                            child: Icon(Icons.remove,
                                size: 12, color: Colors.black54),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${entry.quantity}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: overStock
                                ? Colors.red.shade600
                                : Colors.black87,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => entry.quantity++),
                        child: Container(
                          width: 20,
                          height: 22,
                          decoration: BoxDecoration(
                              color: ColorManager.white,
                              shape: BoxShape.circle),
                          child: const Center(
                            child: Icon(Icons.add,
                                size: 12, color: Colors.black54),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${inv.sku}',
                        style: const TextStyle(
                            fontSize: 9, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(inv.name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    const SizedBox(height: 2),
                    Text(inv.description,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    // ── Stock display in card ─────────────
                    Row(
                      children: [
                        Text(
                          'Stock: ${inv.qty}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: overStock
                                ? Colors.red.shade500
                                : Colors.green.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•  Exp: ${inv.expiryDate}',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '\$${inv.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.blueprime,
                ),
              ),
            ],
          ),
          // ── Inline warning inside card ──────────────────
          if (overStock) ...[
            const SizedBox(height: 8),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 13, color: Colors.red.shade500),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Selected quantity (${entry.quantity}) exceeds current stock (${inv.qty}). Please reduce the quantity.',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSupplyMethodDropdown() {
    final options = ['Self Issued', 'Clinician Issued'];
    return Column(
      children: [
        GestureDetector(
          onTap: () =>
              setState(() => _supplyDropdownOpen = !_supplyDropdownOpen),
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: _supplyDropdownOpen
                  ? const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              )
                  : BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _supplyMethod ?? 'Select',
                    style: TextStyle(
                        fontSize: 12,
                        color: _supplyMethod != null
                            ? Colors.black87
                            : Colors.grey.shade400),
                  ),
                ),
                Icon(
                  _supplyDropdownOpen
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down,
                  color: Colors.grey.shade500,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (_supplyDropdownOpen)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((opt) {
                final isSelected = _supplyMethod == opt;
                return GestureDetector(
                  onTap: () => setState(() {
                    _supplyMethod = opt;
                    _supplyDropdownOpen = false;
                    _supplyMethodError = null; // ── clear once chosen ──
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(color: Colors.grey.shade100)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(opt,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? ColorManager.blueprime
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              )),
                        ),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? ColorManager.blueprime
                                  : Colors.grey.shade400,
                              width: 1.8,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorManager.blueprime,
                              ),
                            ),
                          )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  // ── STEP 4 : Address Info ─────────────────────────────────────────────────

  String? _deliveryMethod;
  bool _deliveryDropdownOpen = false;
  final List<String> _deliveryOptions = ['Home Delivery'];

  Widget _buildStep4() {
    final activeItems =
    _items.where((e) => e.selectedInventory != null).toList();
    final double total = activeItems.fold(
      0,
          (sum, e) => sum + (e.selectedInventory!.price * e.quantity),
    );

    return ScrollConfiguration(
      behavior: ScrollBehavior().copyWith(scrollbars: false),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ORDER SUMMARY',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _summaryRow('Patient Name:',
                      _patientDetails?.name?.toString() ?? '—'),
                  _summaryRow('Patient ID:',
                      '${_selectedPatientId ?? '—'}'),
                  _summaryRow('Total Items:', '${activeItems.length}'),
                  _summaryRow(
                      'Order Total:', '\$${total.toStringAsFixed(2)}'),
                ],
              ),
            ),
            fieldLabel(context,'Address'),
            const SizedBox(height: 6),
            // ── Address pre-filled from patient details; user can edit ──
            inputField(
              controller: _addressController,
              hint: 'Auto-filled with patient address, editable',
            ),
            _errorText(_addressError),
            const SizedBox(height: 16),
            fieldLabel(context,'Delivery Method'),
            const SizedBox(height: 6),
            _buildDeliveryDropdown(),
            _errorText(_deliveryError),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54)),
          const SizedBox(width: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildDeliveryDropdown() {
    return Column(
      children: [
        GestureDetector(
          onTap: () =>
              setState(() => _deliveryDropdownOpen = !_deliveryDropdownOpen),
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: _deliveryDropdownOpen
                  ? const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              )
                  : BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _deliveryMethod ?? 'Select',
                    style: TextStyle(
                        fontSize: 12,
                        color: _deliveryMethod != null
                            ? Colors.black87
                            : Colors.grey.shade400),
                  ),
                ),
                Icon(
                  _deliveryDropdownOpen
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down,
                  color: Colors.grey.shade500,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (_deliveryDropdownOpen)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _deliveryOptions.map((opt) {
                final isSelected = _deliveryMethod == opt;
                return GestureDetector(
                  onTap: () => setState(() {
                    _deliveryMethod = opt;
                    _deliveryDropdownOpen = false;
                    _deliveryError = null; // ── clear once chosen ──
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(color: Colors.grey.shade100)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(opt,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? ColorManager.blueprime
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              )),
                        ),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? ColorManager.blueprime
                                  : Colors.grey.shade400,
                              width: 1.8,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorManager.blueprime,
                              ),
                            ),
                          )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  // ── Submit Order ──────────────────────────────────────────────────────────

  bool _isSubmitting = false;

  Future<void> _submitOrder() async {
    // ── Guard: block submit if any item exceeds stock ─────
    if (_hasStockViolation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.white, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Selected quantity must be less than or equal to current stock. Please review your items.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade500,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final orderResult = await addOrderSupply(
        context: context,
        orderType: 'Patient',
        patientId: _selectedPatientId ?? 0,
        employeeId: 0,
        categoryId: _selectedCategoryId,
        items: _items.map((e) => {
          'inventoryId': e.selectedInventory?.inventoryId ?? 0,
          'quantity': e.quantity,
          'unitPrice': e.selectedInventory?.price ?? 0,
          'imageUrl': '',
        }).toList(),
        supplyMethod: _supplyMethod ?? '',
        address: _addressController.text.trim(),
        deliveryMethod: _deliveryMethod ?? '',
      );

      if (!orderResult.success) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return  AddErrorPopup(
                message: orderResult.message,
              );
            },
          );
        }
        return;
      }

      final List<int> supplyOrderItemIds = orderResult.supplyOrderItemId ?? [];

      for (int i = 0; i < _items.length; i++) {
        final item = _items[i];
        if (item.imageBytes != null) {
          final int supplyOrderItemId =
          i < supplyOrderItemIds.length ? supplyOrderItemIds[i] : 0;

          if (supplyOrderItemId == 0) {
            debugPrint('No supplyOrderItemId found for item at index $i');
            continue;
          }

          final String base64Image = base64Encode(item.imageBytes!);
          final String documentName = item.imageName ?? 'supply_image';
          final uploadResult = await uploadOrderSupplyDoc(
            context: context,
            supplyOrderItemId: supplyOrderItemId,
            base64: base64Image,
            documentName: documentName,
          );
          if (!uploadResult.success) {
            debugPrint('Image upload failed for item: $documentName');
          }
        }
      }

      if (mounted) {
        final navigator = Navigator.of(context);
        navigator.pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showOrderSuccessDialog(navigator.context);
        });
      }
    } catch (e) {
      debugPrint('_submitOrder error: $e');
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 10),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancel',
                style: TextStyle(
                    fontSize: FontSize.s12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 12),

          ElevatedButton(
            // ── Validate the current step before advancing / submitting ──
            onPressed: _isSubmitting
                ? null
                : () {
              if (_currentStep < 4) {
                if (_validateStep(_currentStep)) {
                  setState(() => _currentStep++);
                }
              } else {
                if (_validateStep(4)) {
                  _submitOrder();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.blueprime,
              disabledBackgroundColor: const Color(0xFFBFBFBF),
              disabledForegroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 22, vertical: 10),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: _isSubmitting && _currentStep == 4
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
                : Text(
              _currentStep < 4 ? 'Next' : 'Create Order',
              style: const TextStyle(
                  fontSize: FontSize.s12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}