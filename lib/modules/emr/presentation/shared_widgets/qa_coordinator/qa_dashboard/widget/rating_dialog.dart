import 'package:flutter/material.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';
import 'package:symmetry_emr/modules/emr/presentation/screens/emr_tab/popup_const_emr.dart';

import 'package:symmetry_emr/app/resources/color.dart';

class RatingDialogInfo extends StatelessWidget {
  const RatingDialogInfo({super.key});

  static const double _kDesignWidth = 855;
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < _kDesignWidth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
    return DialogueTemplateNoButtons(
      width: AppSize.s450,
      height: AppSize.s580,
      title: "Star Ratings",
      body: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Overall ──
              Row(
                children: [
                   Text(
                    "OVERALL:",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: ColorManager.granitegray,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const StarRow(filled: 3, total: 3),
                ],
              ),
              const SizedBox(height: 10),

              // ── Section 1 ──
              const _SectionHeader(title: "Managing Daily Activities"),
              const _SectionDivider(),
              const _RatingRow(label: "Ambulation", filled: 1, total: 5),
              const _RatingRow(label: "Bed Transferring", filled: 1, total: 5),
              const _RatingRow(label: "Bathing", filled: 1, total: 5),
              const SizedBox(height: 10),

              // ── Section 2 ──
              const _SectionHeader(title: "Treating Symptoms"),
              const _SectionDivider(),
              const _RatingRow(label: "Dyspnea", filled: 1, total: 5),
              const SizedBox(height: 10),

              // ── Section 3 ──
              const _SectionHeader(title: "Preventing Harm"),
              const _SectionDivider(),
              const _RatingRow(label: "Timely Initiation of Care", filled: 4, total: 5),
              const _RatingRow(label: "Management of Oral Medications", filled: 1, total: 5),
              const SizedBox(height: 10),

              // ── Section 4 ──
              const _SectionHeader(title: "Preventing Harm"),
              const _SectionDivider(),
              const _RatingRow(label: "PPH Stay (CMS)", filled: 5, total: 5),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Section Header ──────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style:  TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color:ColorManager.granitegray,
        ),
      ),
    );
  }
}

// ── Divider ─────────────────────────────────────────────────────────────────
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: Color(0xFFDDDDDD),
      thickness: 1,
      height: 8,
    );
  }
}

// ── Rating Row ───────────────────────────────────────────────────────────────
class _RatingRow extends StatelessWidget {
  final String label;
  final int filled;
  final int total;

  const _RatingRow({
    required this.label,
    required this.filled,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Color(0xFF555555),
            ),
          ),
          StarRow(filled: filled, total: total),
        ],
      ),
    );
  }
}

// ── Star Row ─────────────────────────────────────────────────────────────────
class StarRow extends StatelessWidget {
  final int filled;
  final int total;

  const StarRow({required this.filled, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (index) {
        final isFilled = index < filled;
        return Icon(
          isFilled ? Icons.star : Icons.star_half,
          color: const Color(0xFFFFC107),
          size: 20,
        );
      }),
    );
  }
}