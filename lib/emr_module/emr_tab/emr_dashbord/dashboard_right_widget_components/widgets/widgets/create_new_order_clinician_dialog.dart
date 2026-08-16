import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prohealth/presentation/screens/emr_module/emr_tab/emr_dashbord/dashboard_right_widget_components/widgets/widgets/widgets/order_success_popup_const.dart';
import '../../../../../../../../app/resources/color.dart';
import '../../../../../../../../app/resources/font_manager.dart';
import '../../../../../../../../app/resources/value_manager.dart';
import '../../../../../../../../app/services/api/managers/emr_module_manager/emr_dash_manager/emr_dashboard_manager.dart';
import '../../../../../../../../data/api_data/emr_module_data/emr_dash_data/reminder_model.dart';
import '../../../../../../em_module/company_identity/widgets/whitelabelling/success_popup.dart';
import '../common_components.dart';

void showClinicianOrderDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.3),
    builder: (_) => const ClinicianOrderDialog(),
  );
}

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

  // ── Stock validation ────────────────────────────────────────────────────
  /// true when quantity > selectedInventory.qty
  bool get isOverStock =>
      selectedInventory != null && quantity > selectedInventory!.qty;

  void dispose() => skuController.dispose();
}

class ClinicianOrderDialog extends StatefulWidget {
  const ClinicianOrderDialog({super.key});

  @override
  State<ClinicianOrderDialog> createState() => _ClinicianOrderDialogState();
}

class _ClinicianOrderDialogState extends State<ClinicianOrderDialog> {
  static const List<String> _patientOrderSteps = [
    'Select Clinician',
    'Choose Item',
    'Configure Item',
    'Address Info',
  ];

  int _currentStep = 1;
  final TextEditingController _clinicianController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  List<SupplyOrderClinicalDetails> _clinicianSearchResults = [];
  bool _clinicianSearching = false;
  bool _clinicianShowOverlay = false;
  SupplyOrderClinicalDetails? _clinicianDetails;
  int? _selectedClinicianId;

  List<String> _selectedCategories = [];
  List<String> _categories = [];
  List<SupplyOrderCategoryData> _categoryData = [];
  bool _categoriesLoading = false;

  final List<_ItemEntry> _items = [_ItemEntry()];

  // ── Stock validation helper ─────────────────────────────────────────────
  /// Returns true if any item's quantity exceeds its current stock
  bool get _hasStockViolation => _items.any((e) => e.isOverStock);

  @override
  void initState() {
    super.initState();
    _loadCategories();
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
    _clinicianController.dispose();
    _addressController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

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
                      1 => _selectClinicianTab(),
                      2 => _chooseItemTab(),
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

  // ── STEP 1 ────────────────────────────────────────────────────────────────

  Future<void> _searchClinician(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _clinicianSearchResults = [];
        _clinicianShowOverlay = false;
        _clinicianSearching = false;
      });
      return;
    }
    setState(() {
      _clinicianSearching = true;
      _clinicianShowOverlay = true;
    });
    final results = await getSupplyClinicalByName(
      context: context,
      searchName: query,
    );
    if (mounted) {
      setState(() {
        _clinicianSearchResults = results;
        _clinicianSearching = false;
      });
    }
  }

  // ── FIX: assign address from the selected clinician ───────────────────────
  void _selectClinician(SupplyOrderClinicalDetails clinician) {
    setState(() {
      _clinicianController.text = clinician.name;
      _clinicianDetails = clinician;
      _selectedClinicianId = clinician.clinicianId;
      _clinicianShowOverlay = false;
      _clinicianSearchResults = [];
      // Pre-fill address from the selected clinician
      _addressController.text = clinician.address;
    });
  }

  Widget _selectClinicianTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          fieldLabel('Clinician Name'),
          const SizedBox(height: AppSize.s6),
          _buildClinicianSearchField(),

          if (_clinicianDetails != null) ...[
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
                    "CLINICIAN'S DETAILS",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _clinicianDetailRow('Clinician ID:', '${_clinicianDetails!.clinicianId}'),
                  _clinicianDetailRow('Name:', _clinicianDetails!.name),
                  _clinicianDetailRow('Gender:', _clinicianDetails!.gender),
                  _clinicianDetailRow('Employee Type:', _clinicianDetails!.employeeType),
                  _clinicianDetailRow('Address:', _clinicianDetails!.address),
                  _clinicianDetailRow('Last Order Date:', _clinicianDetails!.lastSupplyOrderDate),
                ],
              ),
            ),
          ] else if (_clinicianSearching && _clinicianController.text.isNotEmpty) ...[
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

          fieldLabel('Select Category'),
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
            onChanged: (vals) =>
                setState(() => _selectedCategories = vals),
          ),

          const SizedBox(height: AppSize.s40),
        ],
      ),
    );
  }

  Widget _buildClinicianSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _clinicianShowOverlay && _clinicianSearchResults.isNotEmpty
                  ? Colors.grey.shade400
                  : Colors.grey.shade300,
            ),
            borderRadius:
            _clinicianShowOverlay && _clinicianSearchResults.isNotEmpty
                ? const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            )
                : BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _clinicianController,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Search clinician by name',
                    hintStyle: TextStyle(
                        fontSize: 12, color: Colors.grey.shade400),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: InputBorder.none,
                  ),
                  onChanged: (val) => _searchClinician(val),
                  // ── FIX: only re-open overlay, never assign address here ──
                  onTap: () {
                    if (_clinicianSearchResults.isNotEmpty) {
                      setState(() => _clinicianShowOverlay = true);
                    }
                  },
                ),
              ),
              if (_clinicianSearching)
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
              else if (_selectedClinicianId != null)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedClinicianId = null;
                      _clinicianDetails = null;
                      _clinicianController.clear();
                      _clinicianSearchResults = [];
                      _clinicianShowOverlay = false;
                      _addressController.clear();
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

        if (_clinicianShowOverlay && _clinicianSearchResults.isNotEmpty)
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
              itemCount: _clinicianSearchResults.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, i) {
                final clinician = _clinicianSearchResults[i];
                return GestureDetector(
                  onTap: () => _selectClinician(clinician),
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
                            color: clinician.colorCode.isNotEmpty
                                ? Color(int.tryParse(clinician.colorCode
                                .replaceAll('#', '0xFF')) ??
                                0xFF2196F3)
                                .withOpacity(0.15)
                                : ColorManager.bluebottom.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: clinician.photo.isNotEmpty
                              ? ClipOval(
                            child: Image.network(
                              clinician.photo,
                              width: 28,
                              height: 28,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.person_outline,
                                size: 15,
                                color: ColorManager.bluebottom,
                              ),
                            ),
                          )
                              : Icon(
                            Icons.person_outline,
                            size: 15,
                            color: ColorManager.bluebottom,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clinician.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              if (clinician.employeeType.isNotEmpty)
                                Text(
                                  clinician.employeeType,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          'ID: ${clinician.clinicianId}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        else if (_clinicianShowOverlay &&
            !_clinicianSearching &&
            _clinicianController.text.isNotEmpty &&
            _clinicianSearchResults.isEmpty)
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
              child: Text(
                'No clinicians found',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ),
          ),
      ],
    );
  }

  Widget _clinicianDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          text: '$label ',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
          ),
          children: [
            TextSpan(
              text: value.isNotEmpty ? value : '—',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── STEP 2 ────────────────────────────────────────────────────────────────

  Widget _chooseItemTab() {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    color: ColorManager.bluebottom,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
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
                    child: Image.memory(
                      entry.imageBytes!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
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
                      _detailRow('SKU/Supply Item Name:', entry.skuController.text),
                      _detailRow('Added Quantity:', '${entry.quantity}'),
                      if (entry.selectedInventory != null) ...[
                        _detailRow('Price per 1 unit:', '\$${entry.selectedInventory!.price}'),
                        _detailRow('SKU ID:', entry.selectedInventory!.sku),
                        _detailRow('Description:', entry.selectedInventory!.description),
                        _detailRow('Expiry Date:', entry.selectedInventory!.expiryDate),
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
        fieldLabel('Add Image'),
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
                  color: ColorManager.bluebottom,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.file_upload_outlined,
                        color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Upload Image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: FontSize.s12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
                child: Image.memory(
                  entry.imageBytes!,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
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
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 11),
                  ),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: AppSize.s25),

        fieldLabel('SKU/Supply Item Name'),
        const SizedBox(height: AppSize.s6),
        _buildSkuSearchField(entry),

        if (entry.selectedInventory != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                // ── Current stock highlighted red when over-stock ──────────
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

        fieldLabel('Select Quantity'),
        const SizedBox(height: AppSize.s6),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            // ── Red border when over-stock ──────────────────────────────
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
                  if (entry.quantity > 1) setState(() => entry.quantity--);
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
                    // ── Red text when over-stock ──────────────────────────
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

        // ── Inline stock validation message ───────────────────────────────
        if (overStock) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 13, color: Colors.red.shade500),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Selected quantity must be less than or equal to current stock (${entry.selectedInventory!.qty})',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.red.shade500,
                      fontWeight: FontWeight.w500),
                ),
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

  // ── SKU Search ────────────────────────────────────────────────────────────

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
                child: TextField(
                  controller: entry.skuController,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Search supply item by name / ID',
                    hintStyle: TextStyle(
                        fontSize: 12, color: Colors.grey.shade400),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: InputBorder.none,
                  ),
                  onChanged: (val) => _searchSku(entry, val),
                  onTap: () {
                    if (entry.searchResults.isNotEmpty) {
                      setState(() => entry.showOverlay = true);
                    }
                  },
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
                        // ── Stock badge in overlay ──────────────────────
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${item.price}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: ColorManager.bluebottom,
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
              child: Text(
                'No items found',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ),
          ),
      ],
    );
  }

  // ── STEP 3 ────────────────────────────────────────────────────────────────

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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
          fieldLabel('Supply Method'),
          const SizedBox(height: 6),
          _buildSupplyMethodDropdown(),
          const SizedBox(height: 20),
        ],
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
                        border: Border.all(color: Colors.grey.shade200),
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
                          if (entry.quantity > 1) setState(() => entry.quantity--);
                        },
                        child: Container(
                          width: 20,
                          height: 22,
                          decoration: BoxDecoration(
                              color: ColorManager.white, shape: BoxShape.circle),
                          child: const Center(
                            child: Icon(Icons.remove, size: 12, color: Colors.black54),
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
                            color: overStock ? Colors.red.shade600 : Colors.black87,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => entry.quantity++),
                        child: Container(
                          width: 20,
                          height: 22,
                          decoration: BoxDecoration(
                              color: ColorManager.white, shape: BoxShape.circle),
                          child: const Center(
                            child: Icon(Icons.add, size: 12, color: Colors.black54),
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
                        style: const TextStyle(fontSize: 9, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(inv.name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    const SizedBox(height: 2),
                    Text(inv.description,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
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
                          '\u2022  Exp: ${inv.expiryDate}',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
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
                  color: ColorManager.bluebottom,
                ),
              ),
            ],
          ),
          if (overStock) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
                                    ? ColorManager.bluebottom
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
                                  ? ColorManager.bluebottom
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
                                color: ColorManager.bluebottom,
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

  // ── STEP 4 ────────────────────────────────────────────────────────────────

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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                _summaryRow('Clinician Name:', _clinicianDetails?.name ?? '—'),
                _summaryRow('Clinician ID:', '${_selectedClinicianId ?? '—'}'),
                _summaryRow('Total Items:', '${activeItems.length}'),
                _summaryRow('Order Total:', '\$${total.toStringAsFixed(2)}'),
              ],
            ),
          ),
          fieldLabel('Address'),
          const SizedBox(height: 6),
          inputField(
            controller: _addressController,
            hint: 'Auto-filled with clinician default, editable',
          ),
          const SizedBox(height: 16),
          fieldLabel('Delivery method'),
          const SizedBox(height: 6),
          _buildDeliveryDropdown(),
          const SizedBox(height: 20),
        ],
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
                                    ? ColorManager.bluebottom
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
                                  ? ColorManager.bluebottom
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
                                color: ColorManager.bluebottom,
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

  // ── Submit ────────────────────────────────────────────────────────────────

  bool _isSubmitting = false;

  Future<void> _submitOrder() async {
    // ── Guard: block submit if any item exceeds stock ─────────────────────
    if (_hasStockViolation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.white, size: 16),
              const SizedBox(width: 8),
              const Expanded(
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
        orderType: 'Clinician',
        patientId: 0,
        employeeId: _selectedClinicianId ?? 0,
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
              return const AddErrorPopup(
                message: 'Something went wrong!',
              );
            },
          );
        }
        return;
      }

      final int supplyOrderItemId = orderResult.supplyOrderItemId ?? 0;
      for (final item in _items) {
        if (item.imageBytes != null) {
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    // ── Disable Next on step 2 if stock violated ──────────────────────────
    final bool blockNext = _currentStep == 2 && _hasStockViolation;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
          if (_currentStep == 4) ...[
            OutlinedButton(
              onPressed: _isSubmitting ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save Draft',
                  style: TextStyle(
                      fontSize: FontSize.s12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500)),
            ),
            const SizedBox(width: 12),
          ],
          ElevatedButton(
            onPressed: (_isSubmitting || blockNext)
                ? null
                : () {
              if (_currentStep < 4) {
                setState(() => _currentStep++);
              } else {
                _submitOrder();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
              blockNext ? Colors.grey.shade300 : ColorManager.bluebottom,
              padding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: _isSubmitting && _currentStep == 4
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
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