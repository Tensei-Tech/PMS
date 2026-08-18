import 'package:flutter/material.dart';

import 'bnss_form_pdf_base.dart';

Future<void> previewMobileSealLabelPdf(
  BuildContext context,
  Map<String, dynamic> doc,
) =>
    previewMinimalMarathiFormPdf(
      context,
      doc,
      filePrefix: 'Mobile_Seal_Label',
      titleMr: 'मोबाईल शिक्का लेबल',
      titleEn: 'Mobile Seal Label',
      fieldKeys: [
        'labelNo', 'date', 'policeStation', 'crNo', 'mobileMake',
        'mobileModel', 'imei1', 'imei2', 'simNo', 'seizedFrom', 'ioName',
      ],
    );
