import 'package:flutter/material.dart';

import 'bnss_form_pdf_base.dart';

Future<void> previewMedicalExamS51Pdf(
  BuildContext context,
  Map<String, dynamic> doc,
) =>
    previewMinimalMarathiFormPdf(
      context,
      doc,
      filePrefix: 'Medical_Exam_S51',
      titleMr: 'वैद्यकीय तपासणी विनंती — कलम ५१',
      titleEn: 'Medical Exam Request — Section 51',
      fieldKeys: [
        'letterNo', 'date', 'policeStation', 'crNo', 'toHospital',
        'accusedName', 'requestBody', 'ioName',
      ],
    );
