import 'package:flutter/material.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/qa_coordinator/qa_dashboard/widget/rating_dialog.dart';

import 'package:symmetry_emr/app/resources/color.dart';

class ConstQaCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  final VoidCallback onTap;

  const ConstQaCard({
    super.key,
    required this.title,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 70,
              width: constraints.maxWidth == double.infinity
                  ? double.infinity
                  : constraints.maxWidth,
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.only(left: 10, right: 10, top: 16, bottom: 10),
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  top: BorderSide(color: color, width: 3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.granitegray,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    count,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}










///coder
class ConstCoderCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  final VoidCallback onTap;

  const ConstCoderCard({
    super.key,
    required this.title,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 70,
              width: constraints.maxWidth == double.infinity
                  ? double.infinity
                  : constraints.maxWidth,
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.only(left: 10, right: 10, top: 16, bottom: 10),
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  top: BorderSide(color: color, width: 3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.granitegray,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    count,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}




class ConstCoderInfoCard extends StatelessWidget {
  final String title;
  final String subTitle;
  final Color color;
  bool? isStarShow;
  final VoidCallback onTap;

  ConstCoderInfoCard({
    super.key,
    this.isStarShow = false,
    required this.title,
    required this.subTitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: InkWell(
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 70,
              width: constraints.maxWidth == double.infinity
                  ? double.infinity
                  : constraints.maxWidth,
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 5),
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  top: BorderSide(color: color, width: 3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.granitegray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  isStarShow! ? const StarRow(filled: 3, total: 3,)
                      : Text(
                    subTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}







class ConstCoderInfoCardWithPercent extends StatelessWidget {
  final String title;
  final String leftPercentage;
  final String leftString;
  final String rightPercentage;
  final String rightString;
  final Color color;
  final VoidCallback onTap;

  const ConstCoderInfoCardWithPercent({
    super.key,
    required this.title,
    required this.color,
    required this.onTap,
    required this.leftPercentage,
    required this.leftString,
    required this.rightPercentage,
    required this.rightString,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            constraints: const BoxConstraints(minHeight: 70), // ← grows if needed
            width: 190,
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
            decoration: BoxDecoration(
              color: ColorManager.white,
              borderRadius: BorderRadius.circular(8),
              border: Border(
                top: BorderSide(color: color, width: 3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,       // ← shrink to content
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.granitegray,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(                        // ← fixes horizontal overflow
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            leftPercentage,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: color),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            leftString,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ColorManager.granitegray),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(                        // ← fixes horizontal overflow
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rightPercentage,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: color),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            rightString,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ColorManager.granitegray),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}