import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/e_fax/widgets/sent_fax_list.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/e_fax/widgets/received_fax_list.dart';

class EFaxScreenCommmunication extends StatefulWidget {
  const EFaxScreenCommmunication({super.key});

  static Color amber = ColorManager.tangerine;
  static const Color amberLight = Color(0xFFFFF8E6);
  static const Color border = Color(0xFFE6E8EC);
  static final Color label = ColorManager.lightGrey;
  static const Color text = Color(0xFF2E3138);
  static const Color muted = Color(0xFF9AA0AA);

  @override
  State<EFaxScreenCommmunication> createState() =>
      _EFaxScreenCommmunicationState();
}

class _EFaxScreenCommmunicationState extends State<EFaxScreenCommmunication> {
  bool _logEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorManager.greyShade200,width: 2)
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.2),
        //     blurRadius: 10,
        //     offset: const Offset(0, 5),
        //   ),
        // ],
      ),
     child:  SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 900;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _LeftPanel(
                      logEnabled: _logEnabled,
                      onLogToggle: (v) => setState(() => _logEnabled = v),
                    ),
                  ),
                  Container(width: 1, color: EFaxScreenCommmunication.border),
                  const Expanded(flex: 6, child: _RightPanel(scrollable: false)),
                ],
              );
            }

            return ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(scrollbars: false),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _LeftPanel(
                      logEnabled: _logEnabled,
                      onLogToggle: (v) => setState(() => _logEnabled = v),
                      scrollable: true,
                    ),
                    const Divider(height: 1, color: EFaxScreenCommmunication.border),
                    const _RightPanel(scrollable: true),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
// ---------------- LEFT PANEL ----------------

class _LeftPanel extends StatefulWidget {
  final bool logEnabled;
  final ValueChanged<bool> onLogToggle;
  final bool scrollable;
  const _LeftPanel({required this.logEnabled, required this.onLogToggle, this.scrollable = false});

  @override
  State<_LeftPanel> createState() => _LeftPanelState();
}

class _LeftPanelState extends State<_LeftPanel> {
  static final Color _label = EFaxScreenCommmunication.label;
  static final Color _text = EFaxScreenCommmunication.text;
  static final Color _border = EFaxScreenCommmunication.border;

  List<PlatformFile> _uploadedFiles = [];

  final TextEditingController _recipientController =
      TextEditingController(text: 'Cistrofer I Dias | Washington DC');
  final TextEditingController _faxController =
      TextEditingController(text: '(366) 456 55 Nastive');
  final TextEditingController _textForNamesController = TextEditingController();
  final TextEditingController _coverPageController = TextEditingController(
      text: 'Lorem ipsum is simply dummy text of the printing and '
          'typasetzimg industry, Lorem ax inum… Lorem ipsum is simply '
          'dummy text of the printing and typasetzimg industry, '
          'Lorem ax inum…');

  void _newCase() {
    setState(() {
      _recipientController.clear();
      _faxController.clear();
      _textForNamesController.clear();
      _coverPageController.clear();
      _uploadedFiles.clear();
    });
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _faxController.dispose();
    _textForNamesController.dispose();
    _coverPageController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
    );
    if (!mounted || result == null) return;
    setState(() => _uploadedFiles.addAll(result.files));
  }

  /* _showIncludedFiles — commented out (Included Files button removed)
  void _showIncludedFiles() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SizedBox(
              width: 420,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          'images/communication/efax/included_files.svg',
                          width: 18,
                          height: 18,
                          colorFilter: ColorFilter.mode(
                            EFaxScreenCommmunication.text,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Included Files',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: EFaxScreenCommmunication.text,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 18),
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: EFaxScreenCommmunication.border),
                    const SizedBox(height: 12),
                    if (_uploadedFiles.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No files attached.',
                            style: TextStyle(
                              fontSize: 13,
                              color: EFaxScreenCommmunication.muted,
                            ),
                          ),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 320),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _uploadedFiles.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            color: EFaxScreenCommmunication.border,
                          ),
                          itemBuilder: (_, i) {
                            final file = _uploadedFiles[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: EFaxScreenCommmunication.amberLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: SvgPicture.asset(
                                      'images/communication/efax/cloude_uploaded.svg',
                                      width: 14,
                                      height: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          file.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: EFaxScreenCommmunication.text,
                                          ),
                                        ),
                                        Text(
                                          _formatSize(file.size),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: EFaxScreenCommmunication.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() => _uploadedFiles.removeAt(i));
                                      setDialogState(() {});
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: Colors.redAccent,
                                    ),
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    tooltip: 'Remove',
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  */

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} kb';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} mb';
  }

  @override
  Widget build(BuildContext context) {
    final bool scrollable = widget.scrollable;
    final bool logEnabled = widget.logEnabled;
    final ValueChanged<bool> onLogToggle = widget.onLogToggle;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'E - Fax',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _text,
                ),
              ),
              InkWell(
                onTap: _newCase,
                borderRadius: BorderRadius.circular(8),
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorManager.tangerine),
                  ),
                  child: Icon(Icons.add, color: ColorManager.tangerine, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSize.s30),
          if (scrollable)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Recipient
              _fieldLabel('Recipient'),
              const SizedBox(height: 8),
              _boxField(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _recipientController,
                        style: TextStyle(color: _text, fontSize: 14),
                        decoration: const InputDecoration.collapsed(hintText: 'Recipient'),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: ColorManager.mediumgrey),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Fax Number + Text for names
              LayoutBuilder(
                builder: (context, c) {
                  final twoCol = c.maxWidth >= 360;
                  if (twoCol) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _faxNumberField()),
                        const SizedBox(width: 16),
                        Expanded(child: _textForNamesField()),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _faxNumberField(),
                      const SizedBox(height: 25),
                      _textForNamesField(),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Text cover page
              _fieldLabel('Text cover page'),
              const SizedBox(height: 8),
              _boxField(
                height: 120,
                alignTop: true,
                child: TextField(
                  controller: _coverPageController,
                  maxLines: null,
                  style: TextStyle(color: _text, fontSize: 13, height: 1.5),
                  decoration: const InputDecoration.collapsed(hintText: 'Enter cover page text'),
                ),
              ),
              const SizedBox(height: 16),

              // Attachments
              if (_uploadedFiles.isNotEmpty)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(_uploadedFiles.length, (i) =>
                    _AttachmentChip(
                      name: _uploadedFiles[i].name,
                      size: _formatSize(_uploadedFiles[i].size),
                      onRemove: () => setState(() => _uploadedFiles.removeAt(i)),
                    ),
                  ),
                ),
              const SizedBox(height: AppSize.s100),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // _iconBtn('images/communication/efax/new_case.svg', 'New case', onPressed: _newCase),
                      _iconBtn('images/communication/efax/upload.svg', 'Upload', onPressed: _pickFile),
                      // _iconBtn('images/communication/efax/included_files.svg', 'Included Files', onPressed: _showIncludedFiles),
                      const SizedBox(width: 12),
                      _LogEnablePill(value: logEnabled, onChanged: onLogToggle),
                    ],
                  ),
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: ColorManager.tangerine,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.send, color: Colors.white, size: 14),
                          SizedBox(width: 8),
                          Text('Send', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ],
            )
          else
            Expanded(
              child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Recipient'),
                      const SizedBox(height: 8),
                      _boxField(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _recipientController,
                                style: TextStyle(color: _text, fontSize: 14),
                                decoration: const InputDecoration.collapsed(hintText: 'Recipient'),
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down, color: _label),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      LayoutBuilder(
                        builder: (context, c) {
                          final twoCol = c.maxWidth >= 360;
                          if (twoCol) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _faxNumberField()),
                                const SizedBox(width: 16),
                                Expanded(child: _textForNamesField()),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              _faxNumberField(),
                              const SizedBox(height: 25),
                              _textForNamesField(),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _fieldLabel('Text cover page'),
                      const SizedBox(height: 8),
                      _boxField(
                        height: 120,
                        alignTop: true,
                        child: TextField(
                          controller: _coverPageController,
                          maxLines: null,
                          style: TextStyle(color: _text, fontSize: 13, height: 1.5),
                          decoration: const InputDecoration.collapsed(hintText: 'Enter cover page text'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_uploadedFiles.isNotEmpty)
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: List.generate(_uploadedFiles.length, (i) =>
                            _AttachmentChip(
                              name: _uploadedFiles[i].name,
                              size: _formatSize(_uploadedFiles[i].size),
                              onRemove: () => setState(() => _uploadedFiles.removeAt(i)),
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSize.s100),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // _iconBtn('images/communication/efax/new_case.svg', 'New case', onPressed: _newCase),
                              _iconBtn('images/communication/efax/upload.svg', 'Upload', onPressed: _pickFile),
                              // _iconBtn('images/communication/efax/included_files.svg', 'Included Files', onPressed: _showIncludedFiles),
                              const SizedBox(width: 12),
                              _LogEnablePill(value: logEnabled, onChanged: onLogToggle),
                            ],
                          ),
                          InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(8),
                            splashColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: ColorManager.yellowBright,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset("images/communication/efax/send.svg",height: 15,width: 15,),
                                  const SizedBox(width: 8),
                                  const Text('Send', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _faxNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Fax Number'),
        const SizedBox(height: 8),
        _boxField(
          child: TextField(
            controller: _faxController,
            style: TextStyle(color: _text, fontSize: 14),
            decoration: const InputDecoration.collapsed(hintText: 'Enter fax number'),
          ),
        ),
      ],
    );
  }

  Widget _textForNamesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Text for names  ',
                style: TextStyle(color: _label, fontSize: 12, fontWeight: FontWeight.w500)),
            Text('TMashville',
                style: TextStyle(
                    color: ColorManager.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 8),
        _boxField(
          child: TextField(
            controller: _textForNamesController,
            style: TextStyle(color: _text, fontSize: 14),
            decoration: const InputDecoration.collapsed(hintText: 'Enter Here'),
          ),
        ),
      ],
    );
  }
  static Widget _fieldLabel(String text) => Text(text,
      style: TextStyle(color: _label, fontSize: 12,fontWeight: FontWeight.w500));
  static Widget _boxField({
    required Widget child,
    double? height,
    bool alignTop = false,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      alignment: alignTop ? Alignment.topLeft : Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  Widget _iconBtn(String svgPath, String label, {VoidCallback? onPressed}) {
    return OutlinedButton.icon(
      onPressed: onPressed ?? () {},
      icon: SvgPicture.asset(svgPath, width: 15, height: 15),
      label: Text(label, style: const TextStyle( fontSize: 12,
        fontWeight: FontWeight.w600,
        color: EFaxScreenCommmunication.text,)),
      style: OutlinedButton.styleFrom(
        foregroundColor: _text,
        side: BorderSide(color: _border),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  final String name;
  final String size;
  final VoidCallback? onRemove;
  const _AttachmentChip({required this.name, required this.size, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorManager.whiteGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorManager.white,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset("images/communication/efax/cloude_uploaded.svg", width: 15, height: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: EFaxScreenCommmunication.text),
                ),
                const SizedBox(height: 2),
                Text(size,
                    style: const TextStyle(
                        fontSize: 11,
                        color: EFaxScreenCommmunication.muted)),
              ],
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 14, color: EFaxScreenCommmunication.muted),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------- RIGHT PANEL ----------------

class _RightPanel extends StatefulWidget {
  final bool scrollable;
  const _RightPanel({this.scrollable = false});

  @override
  State<_RightPanel> createState() => _RightPanelState();
}

class _RightPanelState extends State<_RightPanel> {
  int _selectedTab = 0; // 0 = Sent, 1 = Received
  DateTime _selectedDate = DateTime(2025, 5, 16);

  static Color _amber = EFaxScreenCommmunication.amber;
  static const Color _amberLight = EFaxScreenCommmunication.amberLight;
  static const Color _border = EFaxScreenCommmunication.border;
  static const Color _text = EFaxScreenCommmunication.text;

  String get _formattedDate {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[_selectedDate.month - 1]} ${_selectedDate.day} , ${_selectedDate.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs
          Row(
            children: [
              _tab('Sent', 'images/communication/efax/sent.svg', index: 0),
              const SizedBox(width: 28),
              _tab('Received', 'images/communication/efax/received.svg', index: 1),
            ],
          ),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 20),

          // Date navigator
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: _amberLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: _text),
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () => setState(() =>
                            _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
                      ),
                      Text(
                        _formattedDate,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _text),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: _text),
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () => setState(() =>
                            _selectedDate = _selectedDate.add(const Duration(days: 1))),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _amberLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SvgPicture.asset('images/communication/efax/calendar_fax.svg',),
                  // child: const Icon(Icons.calendar_today_outlined,
                  //     color: _text, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // List
          if (_selectedTab == 0)
            SentFaxList(scrollable: widget.scrollable)
          else
            ReceivedFaxList(scrollable: widget.scrollable),
        ],
      ),
    );
  }

  Widget _tab(String label, String svgPath, {required int index}) {
    final bool selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    svgPath,
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      selected ? _amber : _LeftPanelState._label,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? _amber : _LeftPanelState._label,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 4,
              color: selected ? _amber : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}


class _LogEnablePill extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _LogEnablePill({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: EFaxScreenCommmunication.amberLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset("images/communication/efax/log_enable.svg",  width: 15, height: 15),
          const SizedBox(width: 8),
          const Text(
            'Log Enable',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: EFaxScreenCommmunication.text,
            ),
          ),
          const SizedBox(width: 12),
          FlutterSwitch(
            width: 30.0,
            height: 15.0,
            toggleSize: 12.0,
            value: value,
            borderRadius: 20.0,
            padding: 2.0,
            activeColor: ColorManager.white,
            inactiveColor: ColorManager.white,
            toggleColor: ColorManager.tangerine,
            onToggle: onChanged,
          ),
        ],
      ),
    );
  }
}