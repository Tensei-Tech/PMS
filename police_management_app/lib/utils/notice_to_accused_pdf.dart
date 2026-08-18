import 'package:flutter/material.dart';

import 'bnss_form_pdf_base.dart';

Future<void> previewNoticeToAccusedPdf(
  BuildContext context,
  Map<String, dynamic> doc,
) =>
    previewMinimalMarathiFormPdf(
      context,
      doc,
      filePrefix: 'Notice_to_Accused',
      titleMr: 'आरोपीस सूचनापत्र',
      titleEn: 'Notice to Accused',
      fieldKeys: [
        'outwardNo', 'policeStation', 'noticeDate', 'accusedNameAddress',
        'crNo', 'subject', 'noticeBody', 'accusedSig', 'ioName',
      ],
    );
