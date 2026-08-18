import 'package:flutter/material.dart';

import 'bnss_form_pdf_base.dart';

Future<void> previewWitnessNoticePdf(
  BuildContext context,
  Map<String, dynamic> doc,
) =>
    previewMinimalMarathiFormPdf(
      context,
      doc,
      filePrefix: 'Witness_Notice',
      titleMr: 'साक्षीदार सूचनापत्र',
      titleEn: 'Witness Notice',
      fieldKeys: [
        'outwardNo', 'policeStation', 'noticeDate', 'witnessNameAddress',
        'crNo', 'noticeBody', 'appearanceDate', 'witnessSig', 'ioName',
      ],
    );
