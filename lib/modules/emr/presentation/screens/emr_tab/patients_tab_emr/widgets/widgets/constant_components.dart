import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';
import 'package:symmetry_emr/app/resources/value_manager.dart';

// ── Shared enum ───────────────────────────────────────────────────────────────
enum NoteStatus { completed, pending }

// ── Status Badge ─────────────────────────────────────────────────────────────
class StatusBadgeEMR extends StatelessWidget {
  final NoteStatus status;
  const StatusBadgeEMR({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = status == NoteStatus.completed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? ColorManager.greenbg : ColorManager.redbgd,
        borderRadius: BorderRadius.circular(AppSize.s4),
      ),
      child: Text(
        isCompleted ? 'Completed' : 'Pending',
        style: TextStyle(
          fontSize: FontSize.s11,
          fontWeight: FontWeight.w600,
          color: isCompleted ? ColorManager.greenDark : ColorManager.redDark,
        ),
      ),
    );
  }
}

// ── QA Badge ──────────────────────────────────────────────────────────────────
class QaBadgeEMR extends StatelessWidget {
  final NoteStatus status;
  const QaBadgeEMR({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = status == NoteStatus.completed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? ColorManager.greenbg : ColorManager.redbg,
        borderRadius: BorderRadius.circular(AppSize.s4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'QA',
            style: TextStyle(
              fontSize: FontSize.s11,
              fontWeight: FontWeight.w600,
              color: isCompleted ? ColorManager.greenDark : ColorManager.redDark,
            ),
          ),
          const SizedBox(width: AppSize.s4),
          Icon(Icons.check, size: AppSize.s16,
              color: isCompleted ? ColorManager.greenDark : ColorManager.redDark),
        ],
      ),
    );
  }
}

// ── Delete Button ─────────────────────────────────────────────────────────────
class DeleteButtonEMR extends StatelessWidget {
  final VoidCallback? onTap;
  const DeleteButtonEMR({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(Icons.delete_outline, size: AppSize.s16, color: ColorManager.redDark),
    );
  }
}

// ── List View Container ───────────────────────────────────────────────────────
class ListViewContainerConstantEMR extends StatelessWidget {
  final Widget child;
  final double? paddingTop;
  final double? paddingBottom;
  final double? paddingLeft;
  final double? paddingRight;
  final double? marginRight;

  const ListViewContainerConstantEMR({super.key, required this.child,
    this.paddingTop,this.paddingBottom, this.paddingLeft, this.marginRight, this.paddingRight
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSize.s8,right: marginRight ?? 0),
      padding: EdgeInsets.only(top: paddingTop ?? 0,bottom: paddingBottom ?? 0,
          left: paddingLeft ?? 0,right: paddingRight ?? 0,),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}

// ── Circle Avatar List View Data ──────────────────────────────────────────────
class CircleAvatarListViewData extends StatelessWidget {
  final String name;
  final String bgColor;
  final String abrivation;
   const CircleAvatarListViewData({super.key, required this.name, required this.bgColor, required this.abrivation});

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSize.s35,
      height: AppSize.s28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: AppSize.s14,
            backgroundColor: const Color(0xFF4CAF50),
            child: Text(
              _initials,
              style: const TextStyle(
                fontSize: FontSize.s11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 15,
            bottom: -5,
            right: -5,
            child: Container(
              width: AppSize.s25,
              height: AppSize.s15,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Color(int.parse('0xFF$bgColor')),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(4),
              ),
                  child: Center(
  child: Text(
    abrivation,
    style: const TextStyle(
      fontSize: FontSize.s7,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
),
            ),
          ),
        ],
      ),
    );
  }
}