import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:onlinekhata/mongo_db/db_connection.dart';
import 'package:onlinekhata/sqflite_database/DbProvider.dart';
import 'package:onlinekhata/sqflite_database/model/PartyModel.dart';
import 'package:onlinekhata/ui/ledger_detail.dart';
import 'package:onlinekhata/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DocumentSnapshot> _partiesList = [];

  bool loading = true;

  int documentLimit = 30; // documents to be fetched per request
  DocumentSnapshot _lastDocument;
  bool _gettingMoreParties = false;
  bool _morePartiesAvailable = true;

  // ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  DbProvider dbProvider = DbProvider();
  List<PartyModel> partyModelList = List();

  @override
  void initState() {
    // getLocalDb().then((value) {
    //   if (value != null && value == true) {
    //     getDateFromLocalDB();
    //   } else {
    //     getParties();
    //   }
    // });


    MongoDBConnection().getConnection().then((value) {

      MongoDBConnection().getPartiesFromMongoServer();
    });


    // scrollController = ScrollController();
    // scrollController.addListener(_scrollListener);

    super.initState();
  }

  // _scrollListener() {
  //   double maxScroll = scrollController.position.maxScrollExtent;
  //   double currentScroll = scrollController.position.pixels;
  //   double delta = MediaQuery.of(context).size.height * 0.25;
  //   if (maxScroll - currentScroll <= delta) {
  //     __getMoreParties();
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
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  color: Colors.blue,
                  width: MediaQuery.of(context).size.width - 1,
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(0.0, 0, 0.0, 0.0),
                        child: Container(
                          height: 40,
                          margin: EdgeInsets.fromLTRB(20.0, 15, 0.0, 0.0),
                          child: new Text(
                            'Online Khata',
                            style: TextStyle(
                                fontSize: 21,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.3),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0.0, 0, 10.0, 0.0),
                        child: Image.asset(
                          'assets/splash_logo.png',
                          width: 40,
                          height: 40,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      width: width * 0.83,
                      height: 37,
                      margin: EdgeInsets.fromLTRB(12.0, 20.0, 5, 25.0),
                      child: TextField(
                        cursorColor: Colors.blue,
                        style: new TextStyle(
                          fontSize: 14.0,
                        ),
                        controller: searchController,
                        autofocus: false,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (v) {
                          if (v.length == 0) {
                            // getParties();
                          }
                        },
                        onChanged: (v) {
                          if (v.length == 0) {
                            // getParties();
                          }
                        },
                        decoration: InputDecoration(
                            labelStyle: new TextStyle(color: Colors.grey),
                            border: new UnderlineInputBorder(
                                borderSide: new BorderSide(color: Colors.blue)),
                            contentPadding: const EdgeInsets.fromLTRB(
                                12.0, 2.0, 12.0, 10.0),
                            filled: true,
                            hintText: "Search",
                            hintStyle: new TextStyle(
                              color: Colors.blue,
                              fontSize: 14.0,
                            ),
                            fillColor: Colors.white70),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (searchController.text.toString().length > 0) {
                          // onSearchTextChanged(searchController.text.toString());
                          setState(() {
                            loading = true;
                          });
                          dbProvider
                              .fetchPartyByPartName(searchController.text
                                  .toLowerCase()
                                  .toString())
                              .then((value) {
                            partyModelList = value;

                            setState(() {
                              partyModelList;
                              loading = false;
                            });
                          });
                        } else {
                          setState(() {
                            loading = true;
                          });
                          dbProvider
                              .fetchParties()
                              .then((value) {
                            partyModelList = value;

                            setState(() {
                              partyModelList;
                              loading = false;
                            });
                          });
                        }
                      },
                      child: Icon(
                        Icons.search_rounded,
                        color: Colors.blue,
                        size: 26,
                      ),
                    ),
                  ],
                ),
                Expanded(
                    child: loading == true
                        ? Container()
                        : partyModelList == null
                            ? Center(
                                child: Text('No record found.'),
                              )
                            : partyModelList.length == 0
                                ? Center(
                                    child: Text('No record found.'),
                                  )
                                : new ListView.builder(
                                    //      controller: scrollController,
                                    itemCount: partyModelList.length,
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return new InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LedgerDetailScreen(
                                                        ID: int.parse(partyModelList[index].partyID),
                                                        partName:
                                                            partyModelList[
                                                                    index]
                                                                .partyName,
                                                      )));
                                        },
                                        child: new PartiesItem(
                                            partyModelList[index], index),
                                      );
                                    },
                                  )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // onSearchTextChanged(String text) async {
  //   _searchResult.clear();
  //   if (text.isEmpty) {
  //     setState(() {});
  //     return;
  //   }
  //
  //   _partiesList.forEach((userDetail) {
  //     if (userDetail.data.containsValue(text) || userDetail.data.containsValue(text))
  //       _searchResult.add(userDetail);
  //   });
  //
  //   setState(() {});
  // }

  // onSearchTextChanged(String text) async {
  //   try {
  //     final result = await InternetAddress.lookup('google.com');
  //     if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
  //       setState(() {
  //         loading = true;
  //       });
  //       setState(() {
  //         loading = false;
  //         _searchResult = _partiesList
  //             .where((s) => s.data['PartyName']
  //                 .toString()
  //                 .toLowerCase()
  //                 .contains(text.toLowerCase()))
  //             .toList();
  //         int i = 0;
  //       });
  //     }
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

  getParties() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          loading = true;
        });

        Query q = databaseReference
            .collection('Party')
            //  .where("PartyName",isEqualTo: "AA FABRICS")
            .orderBy('PartyName')
            .limit(documentLimit);

        QuerySnapshot querySnapshot = await q.getDocuments();

        _partiesList = querySnapshot.documents;

        for (int i = 0; i < _partiesList.length; i++) {
          final partyModel = PartyModel(
            partyID: _partiesList[i].data['Id'].toString(),
            partyName: _partiesList[i].data['PartyName'].toString(),
            debit: _partiesList[i].data['Debit'].toString(),
            credit: _partiesList[i].data['Credit'].toString(),
            total: _partiesList[i].data["Credit"] == null
                ? 'RS ' + _partiesList[i].data["Debit"].toString()
                : _partiesList[i].data["Debit"] == null
                    ? 'RS ' + _partiesList[i].data["Credit"].toString()
                    : 'RS ' + ((int.parse(_partiesList[i].data["Debit"].toString()) -
                                    int.parse(_partiesList[i]
                                        .data["Credit"]
                                        .toString())) >
                                0
                            ? (int.parse(
                                    _partiesList[i].data["Debit"].toString()) -
                                int.parse(
                                    _partiesList[i].data["Credit"].toString()))
                            : (int.parse(_partiesList[i]
                                        .data["Debit"]
                                        .toString()) -
                                    int.parse(_partiesList[i]
                                        .data["Credit"]
                                        .toString()))
                                .abs()
                                .toString()).toString(),
          );
          partyModelList.add(partyModel);
          await dbProvider.addPartyItem(partyModel);
        }

        setLocalDb(true);

        setState(() {
          partyModelList;
          loading = false;
          //   _searchResult = querySnapshot.documents;
        });
        //  _lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
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

  getDateFromLocalDB() async {
    dbProvider.fetchParties().then((value) {

      partyModelList = value;

      setState(() {
        partyModelList;
        loading = false;
      });
    });
  }

  __getMoreParties() async {
    try {
      if (_morePartiesAvailable == false) {
        return;
      }
      if (_gettingMoreParties == true) {
        return;
      }
      _gettingMoreParties = true;
      Query q = databaseReference
          .collection('Party')
          .orderBy('PartyName')
          .startAfter([_lastDocument.data['PartyName']]).limit(documentLimit);

      QuerySnapshot querySnapshot = await q.getDocuments();
      if (querySnapshot.documents.length < documentLimit) {
        _morePartiesAvailable = false;
      }
      _lastDocument =
          querySnapshot.documents[querySnapshot.documents.length - 1];
      setState(() {
        _partiesList.addAll(querySnapshot.documents);
      });

      setState(() {});

      _gettingMoreParties = false;
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
}

class PartiesItem extends StatelessWidget {
  final PartyModel _item;
  final int index;

  //int grossTotal = 0;

  PartiesItem(this._item, this.index);

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      height: 67,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Divider(
            height: 3.0,
            color: Colors.grey,
          ),
          Container(
              margin: EdgeInsets.fromLTRB(2.0, 2.0, 13.0, 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(30.0),
                  //   child: Image.asset(
                  //     "assets/placeh_image.jpg",
                  //     width: 40,
                  //     height: 40,
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          isKeyNotNull(_item.partyName)
                              ? Container(
                                  margin:
                                      EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                  child: Text(
                                    _item.partyName,
                                    maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                )
                              : Container(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(0.0, 3.0, 3.0, 0.0),
                                child: Text(
                                  'Pending:',
                                  textAlign: TextAlign.right,
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              isKeyNotNull(_item.debit.toString())
                                  ? Container(
                                      margin: EdgeInsets.fromLTRB(
                                          7.0, 3.0, 3.0, 0.0),
                                      child: Text(
                                        'RS ' + _item.debit.toString(),
                                        textAlign: TextAlign.right,
                                        maxLines: 1,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(0.0, 3.0, 3.0, 0.0),
                                child: Text(
                                  'Received:',
                                  textAlign: TextAlign.right,
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              isKeyNotNull(_item.credit.toString())
                                  ? Container(
                                      margin: EdgeInsets.fromLTRB(
                                          3.0, 3.0, 3.0, 0.0),
                                      child: Text(
                                        'RS ' + _item.credit.toString(),
                                        textAlign: TextAlign.right,
                                        maxLines: 1,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _item.credit == null
                          ? Container(
                              margin: EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 0.0),
                              child: Text(
                                'RS ' + _item.debit.toString(),
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : _item.debit == null
                              ? Container(
                                  margin:
                                      EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 0.0),
                                  child: Text(
                                    'RS ' + _item.credit.toString(),
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : Container(
                                  margin:
                                      EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 0.0),
                                  child: Text(
                                    'RS ' +
                                        ((int.parse(_item.debit.toString()) -
                                                        int.parse(_item.credit
                                                            .toString())) >
                                                    0
                                                ? (int.parse(_item.debit
                                                        .toString()) -
                                                    int.parse(_item.credit
                                                        .toString()))
                                                : (int.parse(_item.debit
                                                            .toString()) -
                                                        int.parse(_item.credit
                                                            .toString()))
                                                    .abs()
                                                    .toString())
                                            .toString(),
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: (int.parse(
                                                      _item.debit.toString()) -
                                                  int.parse(
                                                      _item.debit.toString())) >
                                              0
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0.0, 2.0, 3.0, 0.0),
                        child: Text(
                          'Total',
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                    ],
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
