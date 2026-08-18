import 'package:flutter/material.dart';

import 'bnss_form_pdf_base.dart';

Future<void> previewInjuryCertificatePdf(
  BuildContext context,
  Map<String, dynamic> doc,
) =>
    previewMinimalMarathiFormPdf(
      context,
      doc,
      filePrefix: 'Injury_Certificate',
      titleMr: 'जखम प्रमाणपत्र',
      titleEn: 'Injury Certificate',
      fieldKeys: [
        'certificateNo', 'date', 'hospital', 'patientName', 'patientAge',
        'injuryDescription', 'opinion', 'moName', 'moDesignation', 'moHospital',
      ],
    );
