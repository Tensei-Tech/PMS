import 'package:flutter/material.dart';

import 'bnss_form_pdf_base.dart';

Future<void> previewPanchanamaContinuationPdf(
  BuildContext context,
  Map<String, dynamic> doc,
) =>
    previewMinimalMarathiFormPdf(
      context,
      doc,
      filePrefix: 'Panchanama_Continuation',
      titleMr: 'पंचनाम्याचा पुढील भाग',
      titleEn: 'Further Panchanama',
      fieldKeys: [
        'dist', 'ps', 'firNo', 'headerDate', 'furtherPanchanama',
        'furtherDate', 'ioName', 'ioRank', 'ioPosting',
      ],
    );
