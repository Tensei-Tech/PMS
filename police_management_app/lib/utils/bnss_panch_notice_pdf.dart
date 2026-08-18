import 'package:flutter/material.dart';

import 'bnss_form_pdf_base.dart';

Future<void> previewBnssPanchNoticePdf(
  BuildContext context,
  Map<String, dynamic> doc,
) =>
    previewMinimalMarathiFormPdf(
      context,
      doc,
      filePrefix: 'BNSS_Panch_Notice',
      titleMr: 'पंच सूचनापत्र',
      titleEn: 'Panch Notice BNSS',
      fieldKeys: [
        'noticeType', 'outwardNo', 'policeStation', 'noticeDate',
        'toNameAddress', 'crNo', 'noticeBody', 'ioName', 'receiptName',
      ],
    );
