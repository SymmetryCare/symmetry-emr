import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/color.dart'; // update path

// ── Helper ────────────────────────────────────────────────────────────────────

void showOrderSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const OrderSuccessDialog(),
  );
}

// ── Dialog ────────────────────────────────────────────────────────────────────

class OrderSuccessDialog extends StatelessWidget {
  const OrderSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
      child: Container(
        width: 340,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Checkmark circle ─────────────────────────
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(
                  color: ColorManager.blueprime,
                  width: 5,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.check_rounded,
                  size: 62,
                  color: ColorManager.blueprime,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Title ────────────────────────────────────
            const Text(
              'Successfully',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 10),

            // ── Subtitle ─────────────────────────────────
            Text(
              'Your order has been created successfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            // ── Continue button ───────────────────────────
            SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: navigate to orders list if needed
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.blueprime,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'CONTINUE',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}