import 'package:flutter/material.dart';

import 'bnss_form_pdf_base.dart';

Future<void> previewJuvenileSocialReportPdf(
  BuildContext context,
  Map<String, dynamic> doc,
) =>
    previewBnssFormPdf(
      context,
      doc,
      filePrefix: 'Juvenile_Social_Report',
      titleEn: 'Juvenile Social Background Report',
      titleMr: 'बालगुन्हेगार सामाजिक अहवाल',
      sections: const [
        BnssPdfSection(id: 'Juvenile Social Part I', headingEn: 'Part I — Personal', headingMr: 'भाग १'),
        BnssPdfSection(id: 'Juvenile Social Part II', headingEn: 'Part II — Family', headingMr: 'भाग २'),
        BnssPdfSection(id: 'Juvenile Social Part III', headingEn: 'Part III — Social', headingMr: 'भाग ३'),
        BnssPdfSection(id: 'Juvenile Social Part IV', headingEn: 'Part IV — Reports', headingMr: 'भाग ४'),
        BnssPdfSection(id: 'Juvenile Social Part V', headingEn: 'Part V — Signatures', headingMr: 'भाग ५'),
      ],
    );
