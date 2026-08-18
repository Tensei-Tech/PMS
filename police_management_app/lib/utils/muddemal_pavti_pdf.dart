import 'package:flutter/material.dart';

import 'bnss_form_pdf_base.dart';

Future<void> previewMuddemalPavtiPdf(
  BuildContext context,
  Map<String, dynamic> doc,
) =>
    previewMinimalMarathiFormPdf(
      context,
      doc,
      filePrefix: 'Muddemal_Pavti',
      titleMr: 'मुद्देमाल पावती',
      titleEn: 'Muddemal Pavti',
      fieldKeys: [
        'receiptNo', 'date', 'policeStation', 'crNo', 'accusedName',
        'propertyDescription', 'propertyValue', 'receiverName', 'ioName',
      ],
    );
