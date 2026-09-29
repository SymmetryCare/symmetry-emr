import 'package:flutter/material.dart';

import 'package:symmetry_emr/modules/emr/presentation/shared_widgets/communication/widgets/e_fax/widgets/sent_fax_list.dart';

// ── Received List ─────────────────────────────────────────────────────────────
class ReceivedFaxList extends StatelessWidget {
  final bool scrollable;
  const ReceivedFaxList({super.key, this.scrollable = false});

  @override
  Widget build(BuildContext context) {
    const items = [
      FaxRowData('eFax received from Dr. Miller. No document attached.', '05/08/24 | 9:05AM'),
      FaxRowData('eFax received from Clinic B. Prescription attached.', '05/07/24 | 1:30PM'),
      FaxRowData('eFax received from Warren. Lab results attached.', '05/06/24 | 10:00AM'),
      FaxRowData('eFax received from Dr. Smith. Referral form attached.', '05/05/24 | 8:45AM'),
      FaxRowData('eFax received from Clinic A. No document attached.', '05/04/24 | 3:20PM'),
      FaxRowData('eFax received from Dr. Miller. Patient summary attached.', '05/03/24 | 5:40PM'),
    ];

    if (scrollable) {
      return ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(scrollbars: false),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => FaxRowTile(data: items[i],),
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
          itemBuilder: (_, i) => FaxRowTile(data: items[i], ),
        ),
      ),
    );
  }
}