import 'package:flutter/material.dart';

import 'bnss_form_pdf_base.dart';

Future<void> previewOrderSection4748Pdf(
  BuildContext context,
  Map<String, dynamic> doc,
) =>
    previewBnssFormPdf(
      context,
      doc,
      filePrefix: 'Order_Section_47_48',
      titleEn: 'ORDER — Sections 47 & 48 BNSS',
      titleMr: 'आदेश — कलम ४७ व ४८',
      sections: const [
        BnssPdfSection(
          id: 'Order Main',
          headingEn: 'Administrative Order',
          headingMr: 'प्रशासकीय आदेश',
        ),
        BnssPdfSection(
          id: 'Notice BNSS 47(1)',
          headingEn: 'Notice 47(1)',
          headingMr: 'सूचना ४७(१)',
        ),
        BnssPdfSection(
          id: 'Notice BNSS 48',
          headingEn: 'Notice 48',
          headingMr: 'सूचना ४८',
        ),
      ],
    );
