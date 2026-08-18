import 'package:flutter/material.dart';

import 'bnss_form_pdf_base.dart';

Future<void> previewNilHouseSearchPdf(
  BuildContext context,
  Map<String, dynamic> doc,
) =>
    previewMinimalMarathiFormPdf(
      context,
      doc,
      filePrefix: 'Nil_House_Search',
      titleMr: 'घर शोध पंचनामा — निरर्थक',
      titleEn: 'Nil House Search Panchanama',
      fieldKeys: [
        'campNo', 'date', 'policeStation', 'crNo', 'searchAddress',
        'ownerName', 'searchBody', 'ioName',
      ],
    );
