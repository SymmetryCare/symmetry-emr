import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:symmetry_emr/app/resources/color.dart';
import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/e_fax/e_fax_screen.dart';

// ── Shared data model ─────────────────────────────────────────────────────────
class FaxRowData {
  final String message;
  final String time;
  const FaxRowData(this.message, this.time);
}

// ── Shared row tile ───────────────────────────────────────────────────────────
class FaxRowTile extends StatelessWidget {
  final FaxRowData data;
  const FaxRowTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: EFaxScreenCommmunication.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SvgPicture.asset("images/communication/efax/files.svg",height: 18,width: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              data.message,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12, color: EFaxScreenCommmunication.text),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            data.time,
            style: const TextStyle(
                fontSize: 12, color: EFaxScreenCommmunication.muted),
          ),
        ],
      ),
    );
  }
}

// ── Sent List ─────────────────────────────────────────────────────────────────
class SentFaxList extends StatelessWidget {
  final bool scrollable;
  const SentFaxList({super.key, this.scrollable = false});

  @override
  Widget build(BuildContext context) {
    const items = [
      FaxRowData('eFax sent by Warren. No document attached.', '05/08/24 | 8:17PM'),
      FaxRowData('eFax sent to Dr. Miller. Invoice attached.', '05/07/24 | 3:45PM'),
      FaxRowData('eFax sent by Warren. Lab results attached.', '05/06/24 | 11:20AM'),
      FaxRowData('eFax sent to Clinic A. Referral form attached.', '05/05/24 | 9:00AM'),
      FaxRowData('eFax sent by Warren. No document attached.', '05/04/24 | 2:10PM'),
      FaxRowData('eFax sent to Dr. Smith. Patient summary attached.', '05/03/24 | 4:55PM'),
    ];

    if (scrollable) {
      return ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(scrollbars: false),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => FaxRowTile(data: items[i]),
        ),
      );
    }
    return Expanded(
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(scrollbars: false),
        child: ListView.separated(
          itemCount: items.length,
          physics: const ClampingScrollPhysics(),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => FaxRowTile(data: items[i],),
        ),
      ),
    );
  }
}