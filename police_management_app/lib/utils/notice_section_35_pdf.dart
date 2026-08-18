import 'package:flutter/material.dart';

import 'bnss_form_pdf_base.dart';

Future<void> previewNoticeSection35Pdf(
  BuildContext context,
  Map<String, dynamic> doc,
) =>
    previewBnssFormPdf(
      context,
      doc,
      filePrefix: 'Notice_Section_35',
      titleEn: 'NOTICE — Section 35(3) BNSS',
      titleMr: 'सूचनापत्र — कलम ३५(३)',
      sections: const [
        BnssPdfSection(
          id: 'Notice Section 35 Main',
          headingEn: 'Notice main',
          headingMr: 'सूचना मुख्य',
        ),
        BnssPdfSection(
          id: 'Notice Section 35 Continuation',
          headingEn: 'Rights & signatures',
          headingMr: 'हक्क व सही',
        ),
      ],
    );
