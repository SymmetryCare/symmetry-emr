import 'package:flutter/material.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/app/resources/font_manager.dart';

class HeaderDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 60,
    margin: const EdgeInsets.symmetric(horizontal: 12),
    color: Colors.grey.shade200,
  );
}

class HeaderColumn extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<HeaderRow> rows;
  const HeaderColumn(
      {required this.title, required this.icon, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: ColorManager.blueprime),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: FontSize.s10,
                fontWeight: FontWeight.w700,
                color: ColorManager.blueprime,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...rows,
      ],
    );
  }
}

class HeaderRow extends StatelessWidget {
  final String label;
  final String value;
  const HeaderRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: FontSize.s10,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: FontSize.s10,
                fontWeight: FontWeight.w400,
                color: ColorManager.darkgrey,
                decoration: TextDecoration.none,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
