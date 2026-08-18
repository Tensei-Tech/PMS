import 'package:flutter/material.dart';

import 'bnss_form_pdf_base.dart';

Future<void> previewCheharePattiPdf(
  BuildContext context,
  Map<String, dynamic> doc,
) =>
    previewMinimalMarathiFormPdf(
      context,
      doc,
      filePrefix: 'Chehare_Patti',
      titleMr: 'चेहरे पट्टी',
      titleEn: 'Chehare Patti / Identification Parade',
      fieldKeys: [
        'campNo', 'date', 'policeStation', 'crNo', 'identifyingWitness',
        'suspectName', 'paradeBody', 'witnessSig', 'ioName',
      ],
    );
