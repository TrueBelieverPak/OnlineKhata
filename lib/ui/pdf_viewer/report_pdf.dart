import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:intl/intl.dart';
import 'package:onlinekhata/model/report_model.dart';
import 'package:onlinekhata/ui/pdf_viewer/pdf_viewer_page.dart';
import 'package:onlinekhata/utils/constants.dart';
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart' as material;
import 'package:pdf/widgets.dart';
import 'package:share/share.dart';
import 'dart:io' as Io;

generatePdfReport(context, String partName, List<DocumentSnapshot> list,
    String viewOrDownload) async {
  final Document pdf = Document();
  final baseColor = PdfColors.cyan;
  const tableHeaders = [
    'VocNo',
    'TType',
    'Date',
    'Detail',
    'Debit',
    'Credit',
    'Total Balance'
  ];
  int totalBalance = 0, totalDebit = 0, totalCredit = 0;
  List<ReportModel> ledgerList = [];

  ledgerList.clear();

  Timestamp t;
  DateTime d;

  for (int i = list.length - 1; i >= 0; i--) {
    if (isKeyNotNull(list[i].data["Date"])) {
      t = list[i].data["Date"];
      d = t.toDate();
    }

    totalDebit = list[i].data["Debit"] != null
        ? totalDebit + list[i].data["Debit"]
        : totalDebit;
    totalCredit = list[i].data["Credit"] != null
        ? totalCredit + list[i].data["Credit"]
        : totalCredit;

    totalBalance = list[i].data["Debit"] != null
        ? totalBalance + list[i].data["Debit"]
        : totalBalance;
    totalBalance = list[i].data["Credit"] != null
        ? totalBalance - list[i].data["Credit"]
        : totalBalance;

    ledgerList.add(new ReportModel(
        list[i].data["VocNo"] != null ? list[i].data["VocNo"] : "",
        list[i].data["TType"] != null ? list[i].data["TType"] : "",
        d != null ? getDateTimeFormat(d.toString()) : "",
        list[i].data["Description"] != null ? list[i].data["Description"] : "",
        list[i].data["Debit"] != null ? list[i].data["Debit"] : 0,
        list[i].data["Credit"] != null ? list[i].data["Credit"] : 0,
        totalBalance));
  }

  // pdf.addPage(pw.Page(
  //     pageFormat: PdfPageFormat.a4,
  //
  //     build: (pw.Context context) {
  //       return  pw.Text("Hello World"); // Center
  //     })); // Page

  // Data table
  final table = pw.Table.fromTextArray(
    border: null,
    headers: tableHeaders,
    data: List<List<dynamic>>.generate(
      ledgerList.length,
      (index) => <dynamic>[
        ledgerList[index].vocNo,
        ledgerList[index].date,
        ledgerList[index].desc,
        ledgerList[index].debit,
        ledgerList[index].credit,
        ledgerList[index].totalBalance < 0
            ? ledgerList[index].totalBalance.abs()
            : ledgerList[index].totalBalance
      ],
    ),
    headerStyle: pw.TextStyle(
      color: PdfColors.white,
      fontWeight: pw.FontWeight.bold,
    ),
    headerDecoration: pw.BoxDecoration(
      color: baseColor,
    ),
    rowDecoration: pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(
          color: baseColor,
          width: .3,
        ),
      ),
    ),
    cellAlignment: pw.Alignment.center,
    // defaultColumnWidth: FixedColumnWidth(400.0),
    columnWidths: {
      0: FlexColumnWidth(3),
      1: FlexColumnWidth(3),
      2: FlexColumnWidth(4.6),
      3: FlexColumnWidth(7),
      4: FlexColumnWidth(4),
      5: FlexColumnWidth(4),
      6: FlexColumnWidth(4),
    },

    cellAlignments: {0: pw.Alignment.centerLeft},
  );

  pdf.addPage(MultiPage(
      // pageFormat: PdfPageFormat.a4,
      pageFormat:
          PdfPageFormat.a4.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
      crossAxisAlignment: CrossAxisAlignment.start,
      header: (Context context) {
        if (context.pageNumber == 1) {
          return null;
        }
        return Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            // decoration: const BoxDecoration(
            //     border: BoxBorder(bottom: true, width: 0.5, color: PdfColors.grey)),
            child: Text('Ledger Report',
                style: Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.black)));
      },
      footer: (Context context) {
        return Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: Text('Page ${context.pageNumber} of ${context.pagesCount}',
                style: Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)));
      },
      build: (Context context) => <Widget>[
            Header(
                level: 0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Online Khata',
                          textScaleFactor: 2,
                          style: Theme.of(context)
                              .defaultTextStyle
                              .copyWith(color: PdfColors.blue)),
                      // PdfLogo(),
                    ])),
            Header(
                level: 4,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Ledger Report Detail',
                      style: Theme.of(context).defaultTextStyle.copyWith(
                          color: PdfColors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold))
                ])),

            Header(
                level: 4,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Container(
                      margin: EdgeInsets.fromLTRB(0.0, 25, 0.0, 0.0),
                      child: Text('Customer Name',
                          style: Theme.of(context).defaultTextStyle.copyWith(
                              color: PdfColors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.bold))),
                  Container(
                      margin: EdgeInsets.fromLTRB(10.0, 25, 0.0, 0.0),
                      child: Text(partName,
                          style: Theme.of(context).defaultTextStyle.copyWith(
                              color: PdfColors.grey900, fontSize: 13)))
                ])),

            Header(
                level: 4,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text('Total Debit(-):',
                      style: Theme.of(context).defaultTextStyle.copyWith(
                          color: PdfColors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  Container(
                      margin: EdgeInsets.fromLTRB(10.0, 0, 0.0, 0.0),
                      child: Text(totalDebit.toString(),
                          style: Theme.of(context).defaultTextStyle.copyWith(
                              color: PdfColors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)))
                ])),

            Header(
                level: 4,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text('Total Credit(+):',
                      style: Theme.of(context).defaultTextStyle.copyWith(
                          color: PdfColors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  Container(
                      margin: EdgeInsets.fromLTRB(10.0, 0, 0.0, 0.0),
                      child: Text(totalCredit.toString(),
                          style: Theme.of(context).defaultTextStyle.copyWith(
                              color: PdfColors.green,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)))
                ])),

            Container(
                margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 25.0),
                child: Header(
                    level: 4,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Total Amount:',
                              style: Theme.of(context)
                                  .defaultTextStyle
                                  .copyWith(
                                      color: PdfColors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                          Container(
                              margin: EdgeInsets.fromLTRB(10.0, 0, 0.0, 0.0),
                              child: Text(
                                  totalBalance < 0
                                      ? totalBalance.abs().toString()
                                      : totalBalance.toString(),
                                  style: Theme.of(context)
                                      .defaultTextStyle
                                      .copyWith(
                                          color: totalBalance < 0
                                              ? PdfColors.red
                                              : PdfColors.green,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)))
                        ]))),

            // Table.fromTextArray(context: context, data: const <List<String>>[
            //   <String>['Year', 'Ipsum', 'Lorem'],
            //   <String>['2000', 'Ipsum 1.0', 'Lorem 1'],
            //   <String>['2001', 'Ipsum 1.1', 'Lorem 2'],
            //   <String>['2002', 'Ipsum 1.2', 'Lorem 3'],
            //   <String>['2003', 'Ipsum 1.3', 'Lorem 4'],
            //   <String>['2004', 'Ipsum 1.4', 'Lorem 5'],
            //   <String>['2004', 'Ipsum 1.5', 'Lorem 6'],
            //   <String>['2006', 'Ipsum 1.6', 'Lorem 7'],
            //   <String>['2007', 'Ipsum 1.7', 'Lorem 8'],
            //   <String>['2008', 'Ipsum 1.7', 'Lorem 9'],
            // ]),

            table
          ]));

  //save PDF
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);
  var dir = (await getExternalStorageDirectory());
  var createReportDir = await new Directory('${dir.path}/Online khata Reports')
      .create(recursive: true);

  final String path = '${createReportDir.path}/Report_$formattedDate.pdf';
  final File file = File(path);

  await file.writeAsBytes(pdf.save()).then((value) {
    if (viewOrDownload == "from_share") {
      // List<int> imageBytes = file.readAsBytesSync();
      // print(imageBytes);

      // final bytes = Io.File(path).readAsBytesSync();
      //
      // String base64Image = base64Encode(bytes);




      // FlutterShareMe().shareToWhatsApp(base64Image:"data:image/jpeg;base64,"+ base64Image, msg: "Share Ledger Report");
      Share.shareFiles(['${createReportDir.path}/Report_$formattedDate.pdf'], text: '' );

    } else {
      material.Navigator.of(context).push(
        material.MaterialPageRoute(
          builder: (_) => PdfViewerPage(path: path),
        ),
      );
    }
  });
}
