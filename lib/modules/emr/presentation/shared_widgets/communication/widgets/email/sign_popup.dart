import 'package:flutter/material.dart';

import 'package:symmetry_emr/modules/emr/data/api/managers/communication_manger/email_manager.dart';

// adjust path (for getEmployeeSignature)

class SignatureDialog extends StatefulWidget {
  final void Function(EmployeeSignatureModel selected) onSubmit;

  const SignatureDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<SignatureDialog> createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<SignatureDialog> {
  EmployeeSignatureModel? _signature;
  bool _isLoadingSignature = false;
  String? _signatureError;
  int? selectedEmployeeId;

  @override
  void initState() {
    super.initState();
    _loadSignature(); // 🔥 API call happens when popup opens
  }

  Future<void> _loadSignature() async {
    setState(() {
      _isLoadingSignature = true;
      _signatureError = null;
    });

    try {
      final sig = await getEmployeeSignature(context: context);
      setState(() {
        _signature = sig;
        selectedEmployeeId = sig?.employeeId; // auto-select if not null
      });
    } catch (e) {
      setState(() {
        _signatureError = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingSignature = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Choose middle content based on loading / error / data
    Widget middleContent;

    if (_isLoadingSignature) {
      middleContent = const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_signatureError != null || _signature == null) {
      middleContent = Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Failed to load signature',
                style: TextStyle(fontSize: 14, color: Colors.red),
              ),
              if (_signatureError != null) ...[
                const SizedBox(height: 4),
                Text(
                  _signatureError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loadSignature,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    } else {
      final sig = _signature!;
      middleContent = Expanded(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Signature image
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color:const Color(0xffF3F3F3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:const Color(0xffF3F3F3) ,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        sig.signatureUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) =>
                        const Icon(Icons.image),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Name
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sig.fullName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 2),

                      // Designation (placeholder)
                      const Text(
                        'Designation',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Radio
                      Theme(
                        data: Theme.of(context).copyWith(
                          radioTheme: RadioThemeData(
                            fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                              if (states.contains(MaterialState.selected)) {
                                return Colors.greenAccent; // 🔥 selected color
                              }
                              return Colors.grey; // unselected radio border color
                            }),
                          ),
                        ),
                        child: Radio<int>(
                          splashRadius: 0,
                          hoverColor: Colors.transparent,
                          value: sig.employeeId,
                          groupValue: selectedEmployeeId,
                          onChanged: (value) {
                            setState(() {
                              selectedEmployeeId = value;
                            });
                          },
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 400,
          minWidth: 320,
          maxWidth: 420,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Text(
                          'E-mail signature',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select your signature',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),
            const Divider(thickness: 2),


            middleContent,

            const SizedBox(height: 12),
            // Bottom buttons
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // CANCEL BUTTON (OutlinedButton)
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffF3F3F3),  // light gray background
                        foregroundColor: Colors.black,             // text color
                        // side: const BorderSide(color: Colors.grey),// border
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),

                  // SUBMIT BUTTON (ElevatedButton)
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,  // custom green
                        foregroundColor: Colors.white,        // text color
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                      ),
                      onPressed: (!_isLoadingSignature &&
                          _signature != null &&
                          selectedEmployeeId != null)
                          ? () {
                        final sig = _signature!;
                        widget.onSubmit(sig);
                        Navigator.of(context).pop();
                      }
                          : null,
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}
