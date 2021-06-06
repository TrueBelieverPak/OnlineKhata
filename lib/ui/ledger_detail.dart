import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:onlinekhata/ui/pdf_viewer/report_pdf.dart';
import 'package:onlinekhata/utils/constants.dart';
import 'package:permission_handler/permission_handler.dart';

class LedgerDetailScreen extends StatefulWidget {
  static String id = 'ledger_detail_screen';

  final int ID;
  final String partName;

  const LedgerDetailScreen({Key key, this.ID, this.partName}) : super(key: key);

  @override
  _LedgerDetailScreenState createState() =>
      _LedgerDetailScreenState(ID: this.ID, partName: this.partName);
}

int totalDebit = 0;
int totalCredit = 0;
int totalBalance=0;

class _LedgerDetailScreenState extends State<LedgerDetailScreen> {
  int ID;
  String partName;

  List<DocumentSnapshot> _ledgerList = [];
  bool loading = true;
List<dynamic> dateStart =["2021-04-27 19:02:51.000Z"];
List<dynamic> dateEnd =["2021-05-25 19:02:51.000Z"];


  // int documentLimit = 10; // documents to be fetched per request
  // DocumentSnapshot _lastDocument;
  // bool _gettingMoreParties = false;
  // bool _morePartiesAvailable = true;

  //ScrollController scrollController = ScrollController();

  _LedgerDetailScreenState({this.ID, this.partName});

  @override
  void dispose() {
    // TODO: implement dispose
    totalDebit = 0;
    totalCredit = 0;
    totalBalance=0;

    super.dispose();
  }

  @override
  void initState() {

   getLedger(widget.ID);
   //  getLedgerByDateWise(widget.ID);
     super.initState();
  }

  // _scrollListener() {
  //   double maxScroll = scrollController.position.maxScrollExtent;
  //   double currentScroll = scrollController.position.pixels;
  //   double delta = MediaQuery.of(context).size.height * 0.25;
  //   if (maxScroll - currentScroll <= delta) {
  //   //  __getMoreLedger(widget.ID);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return SafeArea(
      child: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: loading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 60,
                margin: EdgeInsets.fromLTRB(0.0, 0, 0.0, 0.0),
                width: MediaQuery.of(context).size.width - 1,
                color: Colors.blue,
                child: Container(
                  margin: EdgeInsets.fromLTRB(0.0, 0, 0.0, 0.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.fromLTRB(5.0, 0, 0.0, 0.0),
                        child: new IconButton(
                          icon: Image.asset(
                            'assets/ic_back.png',
                            width: 40,
                            height: 40,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Container(
                        width: width * 0.7,
                        margin: EdgeInsets.fromLTRB(10.0, 0, 0.0, 0.0),
                        child: new Text(
                          partName,
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 19,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      Container(
                        width: 30,
                        height: 30,
                        margin: EdgeInsets.fromLTRB(5.0, 0, 0.0, 0.0),
                        child: Image.asset("assets/ic_calendar.png")
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(15.0, 15.0, 12.0, 10.0),
                color: Colors.black12,
                height: 39,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(4.0, 0.0, 0.0, 0.0),
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Text(
                        "Ledger Detail",
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Text(
                              "Will Receive",
                              maxLines: 2,
                              softWrap: true,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _ledgerList == null || _ledgerList.length == 0
                              ? Container()
                              : Container(
                                  child: Text(
                                   "RS "+ totalCredit.toString(),
                                    maxLines: 2,
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Text(
                              "You Gave",
                              maxLines: 2,
                              softWrap: true,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _ledgerList == null || _ledgerList.length == 0
                              ? Container()
                              : Container(
                                  child: Text(
                                    "RS "+ totalDebit.toString(),
                                    maxLines: 2,
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: loading == true
                    ? Container()
                    : _ledgerList == null
                        ? Center(
                            child: Text('No record found.'),
                          )
                        : _ledgerList.length == 0
                            ? Center(
                                child: Text('No record found.'),
                              )
                            : new ListView.builder(
                                //  controller: scrollController,
                                itemCount: _ledgerList.length,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return new InkWell(
//                      onTap: () {
//                        Navigator.push(
//                            context,
//                            MaterialPageRoute(
//                                builder: (context) =>
//                                    FormSubmitDetails(
//                                        submitFormDetails:
//                                        formList[index]
//                                        ['fields'],
//                                        formType: formList[index]
//                                        ['form_type'])));
//                      },
                                    child: new LedgerItem(
                                        _ledgerList[index], index),
                                  );
                                },
                              ),
              ),
              _ledgerList != null && _ledgerList.length > 0
                  ? Container(
                margin: EdgeInsets.fromLTRB(0.0, 0, 0.0, 5.0),

                child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            var status = await Permission.storage.status;
                            try {
                              if (await Permission.storage.request().isGranted) {
                                generatePdfReport(context, widget.partName, _ledgerList,"from_view");
                              } else {
                                if (status.isPermanentlyDenied) {
                                  // The user opted to never again see the permission request dialog for this
                                  // app. The only way to change the permission's status now is to let the
                                  // user manually enable it in the system settings.
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: new Text("Alert"),
                                          content: new Text(
                                              "Please grant Storage permission from settings."),
                                          actions: <Widget>[
                                            new FlatButton(
                                              child: new Text('OK'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                openAppSettings();
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                }
                                // You can can also directly ask the permission about its status.
                                else if (status.isRestricted) {
                                  // The OS restricts access, for example because of parental controls.
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: new Text("Alert"),
                                          content: new Text(
                                              "Please grant Storage  permission from settings."),
                                          actions: <Widget>[
                                            new FlatButton(
                                              child: new Text('OK'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                } else if (status.isDenied) {
                                  // The OS restricts access, for example because of parental controls.
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: new Text("Alert"),
                                          content: new Text(
                                              "Please grant Storage permission from settings."),
                                          actions: <Widget>[
                                            new FlatButton(
                                              child: new Text('OK'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                } else if (e
                                    .toString()
                                    .contains('The getter \'path\' was called on null')) {
                                  return;
                                } else {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: new Text("Alert"),
                                          content: new Text(
                                              "Please grant Storage  permission from settings."),
                                          actions: <Widget>[
                                            new FlatButton(
                                              child: new Text('OK'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                }
                              }
                            } catch (e) {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: new Text("Alert"),
                                      content: new Text(
                                          "Please grant Storage  permission from settings."),
                                      actions: <Widget>[
                                        new FlatButton(
                                          child: new Text('OK'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            }
                          },

                          child: Container(  width:width*0.45,
                            height: 35,
                              margin: const EdgeInsets.all(5.0),
                              padding: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blueAccent),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("assets/ic_view.png",
                                      width: 18,
                                      height: 18,
                                      color: Colors.blueAccent),
                                  Container(
                                      margin: EdgeInsets.fromLTRB(5.0, 0, 0.0, 0.0),
                                      child: Text(
                                        'View PDF',
                                        style: TextStyle(color: Colors.blueAccent),
                                      )),
                                ],
                              ),
                            ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            var status = await Permission.storage.status;
                            try {
                              if (await Permission.storage.request().isGranted) {
                                generatePdfReport(context, widget.partName, _ledgerList,"from_share");
                              } else {
                                if (status.isPermanentlyDenied) {
                                  // The user opted to never again see the permission request dialog for this
                                  // app. The only way to change the permission's status now is to let the
                                  // user manually enable it in the system settings.
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: new Text("Alert"),
                                          content: new Text(
                                              "Please grant Storage permission from settings."),
                                          actions: <Widget>[
                                            new FlatButton(
                                              child: new Text('OK'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                openAppSettings();
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                }
                                // You can can also directly ask the permission about its status.
                                else if (status.isRestricted) {
                                  // The OS restricts access, for example because of parental controls.
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: new Text("Alert"),
                                          content: new Text(
                                              "Please grant Storage  permission from settings."),
                                          actions: <Widget>[
                                            new FlatButton(
                                              child: new Text('OK'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                } else if (status.isDenied) {
                                  // The OS restricts access, for example because of parental controls.
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: new Text("Alert"),
                                          content: new Text(
                                              "Please grant Storage permission from settings."),
                                          actions: <Widget>[
                                            new FlatButton(
                                              child: new Text('OK'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                } else if (e
                                    .toString()
                                    .contains('The getter \'path\' was called on null')) {
                                  return;
                                } else {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: new Text("Alert"),
                                          content: new Text(
                                              "Please grant Storage  permission from settings."),
                                          actions: <Widget>[
                                            new FlatButton(
                                              child: new Text('OK'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                }
                              }
                            } catch (e) {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: new Text("Alert"),
                                      content: new Text(
                                          "Please grant Storage  permission from settings."),
                                      actions: <Widget>[
                                        new FlatButton(
                                          child: new Text('OK'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            }
                          },

                          child: Container(
                            width:width*0.45,
                            height: 35,
                            margin: const EdgeInsets.all(5.0),
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset("assets/ic_share.png",
                                    width: 18,
                                    height: 18,
                                    color: Colors.blueAccent),
                                Container(
                                    margin: EdgeInsets.fromLTRB(5.0, 0, 0.0, 0.0),
                                    child: Text(
                                      'Share',
                                      style: TextStyle(color: Colors.blueAccent),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  getLedger(int ID) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          loading = true;
        });

        Query q = databaseReference
            .collection('Ledger')
            .where('PartyID', isEqualTo: ID)
        .orderBy('Date',descending: true);

        QuerySnapshot querySnapshot = await q.getDocuments();

        setState(() {
          loading = false;
          _ledgerList = querySnapshot.documents;

          for (int i = 0; i < _ledgerList.length; i++) {
            if (isKeyNotNull(_ledgerList[i].data["Debit"])) {
              totalDebit = totalDebit + _ledgerList[i].data["Debit"];
            }
            if (isKeyNotNull(_ledgerList[i].data["Credit"])) {
              totalCredit = totalCredit + _ledgerList[i].data["Credit"];
            }
          }
        });
        // _lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
      }
    } on SocketException catch (_) {
      setState(() {
        loading = false;
      });
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("No Network Connection"),
              content: new Text("Please connect to an Internet connection"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
    }
  }


  getLedgerByDateWise(int ID) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          loading = true;
        });
        DateTime _now = DateTime.now();


        Query q = databaseReference
            .collection('Ledger')
            .where('PartyID', isEqualTo: ID)
        .where("Date",isGreaterThanOrEqualTo:_now,isLessThanOrEqualTo: _now);
        //.orderBy('Date',descending: true);
        // .limit(documentLimit);

        // .orderBy('name');

        QuerySnapshot querySnapshot = await q.getDocuments();

        setState(() {
          loading = false;
          _ledgerList = querySnapshot.documents;

          for (int i = 0; i < _ledgerList.length; i++) {
            if (isKeyNotNull(_ledgerList[i].data["Debit"])) {
              totalDebit = totalDebit + _ledgerList[i].data["Debit"];
            }
            if (isKeyNotNull(_ledgerList[i].data["Credit"])) {
              totalCredit = totalCredit + _ledgerList[i].data["Credit"];
            }
          }
        });
        // _lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
      }
    } on SocketException catch (_) {
      setState(() {
        loading = false;
      });
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("No Network Connection"),
              content: new Text("Please connect to an Internet connection"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
    }
  }
//
// __getMoreLedger(int ID) async {
//   try {
//     if (_morePartiesAvailable == false) {
//       return;
//     }
//     if (_gettingMoreParties == true) {
//       return;
//     }
//     _gettingMoreParties = true;
//     Query q = databaseReference
//         .collection('Ledger')
//         .where('PartyID', isEqualTo: ID)
//       // .orderBy('Date')
//         .startAfter([_lastDocument.data['PartyID']]).limit(documentLimit);
//
//     QuerySnapshot querySnapshot = await q.getDocuments();
//     if (querySnapshot.documents.length < documentLimit) {
//       _morePartiesAvailable = false;
//     }
//     _lastDocument =
//         querySnapshot.documents[querySnapshot.documents.length - 1];
//     setState(() {
//       _ledgerList.addAll(querySnapshot.documents);
//     });
//
//     setState(() {});
//
//     _gettingMoreParties = false;
//   } on SocketException catch (_) {
//     setState(() {
//       loading = false;
//     });
//     showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: new Text("No Network Connection"),
//             content: new Text("Please connect to an Internet connection"),
//             actions: <Widget>[
//               new FlatButton(
//                 child: new Text('OK'),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           );
//         });
//   }
// }
}

class LedgerItem extends StatelessWidget {
  final DocumentSnapshot _item;
  final int index;

  LedgerItem(this._item, this.index);

  @override
  Widget build(BuildContext context) {
    Timestamp t = _item.data["Date"];
    DateTime d = t.toDate();

    totalBalance =    _item.data["Debit"] != null ? totalBalance + _item.data["Debit"]  : totalBalance;
    totalBalance =    _item.data["Credit"] != null ? totalBalance - _item.data["Credit"]  : totalBalance;

    return new Container(
      color: Colors.white,
      height: 135,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Divider(
            height: 2.0,
            color: Colors.grey,
          ),
          Container(
              margin: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(12.0, 0.0, 0.0, 0.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.47,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              isKeyNotNull(_item.data["VocNo"])
                                  ? Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.fromLTRB(
                                                0.0, 0.0, 0.0, 0.0),
                                            child: Text(
                                              'VocNo:',
                                              maxLines: 3,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.fromLTRB(
                                                2.0, 0.0, 0.0, 0.0),
                                            child: Text(
                                              _item.data["VocNo"].toString(),
                                              maxLines: 1,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),

                              isKeyNotNull(_item.data["TType"])
                                  ? Container(
                                width: MediaQuery.of(context).size.width *
                                    0.5,
                                child: Row(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.fromLTRB(
                                          0.0, 2.0, 0.0, 0.0),
                                      child: Text(
                                        'TType:',
                                        maxLines: 1,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(
                                          2.0, 2.0, 0.0, 0.0),
                                      child: Text(
                                        _item.data["TType"].toString(),
                                        maxLines: 3,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  : Container(),


                              Container(

                                width: MediaQuery.of(context).size.width *
                                    0.5,
                                child: Row(
                                  children: [
                                    Container(
                                      color: Color(0xffDCDCDC),

                                      margin: EdgeInsets.fromLTRB(
                                          0.0, 2.0, 0.0, 0.0),
                                      child: Text(
                                        'Balance:  ',
                                        maxLines: 1,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),

                                    Container(
                                      color: Color(0xffDCDCDC),
                                      margin: EdgeInsets.fromLTRB(
                                          0.0, 2.0, 0.0, 0.0),
                                      child: Text(
                                       "RS "+ totalBalance.abs().toString(),
                                        maxLines: 2,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,

                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  ,

                              isKeyNotNull(_item.data["Description"])
                                  ? Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      margin: EdgeInsets.fromLTRB(
                                          0.0, 2.0, 0.0, 0.0),
                                      child: Text(
                                        _item.data["Description"]
                                            .toString()
                                            .replaceAll("\n", " "),

                                        //  "ddfdf ddfd fdf ",
                                        maxLines: 3,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    )
                                  : Container(),
                              isKeyNotNull(_item.data["Date"].toString())
                                  ? Container(
                                      margin: EdgeInsets.fromLTRB(
                                          0.0, 2.0, 0.0, 0.0),
                                      child: Text(
                                        getDateTimeFormat(d.toString()),
                                        //   DateTime.fromMillisecondsSinceEpoch(_item.data["Date"] ).toString(),

                                        textAlign: TextAlign.right,
                                        maxLines: 1,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black38,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                        isKeyNotNull(_item.data["Credit"]) &&
                                _item.data["Credit"] != 0
                            ? Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                margin: EdgeInsets.fromLTRB(12.0, 1.0, .0, 0.0),
                                child: Text(
                                  _item.data["Credit"].toString(),
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Text(
                                  "",
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                        isKeyNotNull(_item.data["Debit"]) &&
                                _item.data["Debit"] != 0
                            ? Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Text(
                                  _item.data["Debit"].toString(),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Text(
                                  "",
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }



  bool isKeyNotNull(Object param1) {


    if (param1 != null)
      return true;
    else
      return false;
  }
}
