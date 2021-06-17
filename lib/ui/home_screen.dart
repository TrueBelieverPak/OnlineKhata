import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:onlinekhata/ui/ledger_detail.dart';
import 'package:onlinekhata/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DocumentSnapshot> _partiesList = [];
  List<DocumentSnapshot> _searchResult = [];

  bool loading = true;

  int documentLimit = 10000; // documents to be fetched per request
  DocumentSnapshot _lastDocument;
  bool _gettingMoreParties = false;
  bool _morePartiesAvailable = true;

  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    getParties();
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);

    super.initState();
  }

  _scrollListener() {
    double maxScroll = scrollController.position.maxScrollExtent;
    double currentScroll = scrollController.position.pixels;
    double delta = MediaQuery.of(context).size.height * 0.25;
    if (maxScroll - currentScroll <= delta) {
      __getMoreParties();
    }
  }

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
                            getParties();
                          }
                        },
                        onChanged: (v) {
                          if (v.length == 0) {
                            getParties();
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
                        if (searchController.text.toString().length >= 0) {
                          onSearchTextChanged(searchController.text.toString());
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
                        : _partiesList == null
                            ? Center(
                                child: Text('No record found.'),
                              )
                            : _partiesList.length == 0
                                ? Center(
                                    child: Text('No record found.'),
                                  )
                                : _partiesList.length != 0 &&
                                        _searchResult.length == 0
                                    ? new ListView.builder(
                                        controller: scrollController,
                                        itemCount: _partiesList.length,
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
                                                            ID: _partiesList[
                                                                index]['Id'],
                                                            partName:
                                                                _partiesList[
                                                                        index][
                                                                    'PartyName'],
                                                          )));
                                            },
                                            child: new PartiesItem(
                                                _partiesList[index], index),
                                          );
                                        },
                                      )
                                    : _searchResult == null
                                        ? Center(
                                            child: Text('No record found.'),
                                          )
                                        : _searchResult.length == 0
                                            ? Center(
                                                child: Text('No record found.'),
                                              )
                                            : ListView.builder(
                                                controller: scrollController,
                                                itemCount: _searchResult.length,
                                                scrollDirection: Axis.vertical,
                                                shrinkWrap: true,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return new InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  LedgerDetailScreen(
                                                                    ID: _searchResult[
                                                                            index]
                                                                        ['Id'],
                                                                    partName: _searchResult[
                                                                            index]
                                                                        [
                                                                        'PartyName'],
                                                                  )));
                                                    },
                                                    child: new PartiesItem(
                                                        _searchResult[index],
                                                        index),
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

  onSearchTextChanged(String text) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          loading = true;
        });
        setState(() {
          loading = false;
          _searchResult = _partiesList
              .where((s) => s.data['PartyName']
                  .toString()
                  .toLowerCase()
                  .contains(text.toLowerCase()))
              .toList();
          int i = 0;
        });
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

        setState(() {
          loading = false;
          _searchResult.clear();
          _partiesList = querySnapshot.documents;
          //   _searchResult = querySnapshot.documents;
        });

        _lastDocument = querySnapshot.documents.length > 0
            ? querySnapshot.documents[querySnapshot.documents.length - 1]
            : 10000;
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
  final DocumentSnapshot _item;
  final int index;

  //int grossTotal = 0;

  PartiesItem(this._item, this.index);

  @override
  Widget build(BuildContext context) {
    // if (_item.data["Debit"] == null) {
    //   grossTotal = 0 - _item.data["Credit"];
    // } else {
    //   grossTotal = _item.data["Debit"] - _item.data["Credit"];
    // }
    //
    // if (_item.data["Credit"] == null) {
    //   grossTotal = _item.data["Debit"] - 0;
    // } else {
    //   grossTotal = _item.data["Debit"] - _item.data["Debit"];
    // }

    // grossTotal = 0;
    //
    // if (_item.data["Debit"] == null || _item.data["Credit"] == null) {
    //   if (_item.data["Credit"] == null) {
    //     grossTotal = _item.data["Debit"];
    //   } else if (_item.data["Debit"] == null) {
    //     grossTotal = _item.data["Credit"];
    //   }
    // } else {
    //   grossTotal = _item.data["Debit"] - _item.data["Debit"];
    // }
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
                          isKeyNotNull(_item.data["PartyName"])
                              ? Container(
                                  margin:
                                      EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                  child: Text(
                                    _item.data["PartyName"],
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
                              isKeyNotNull(_item.data["Debit"].toString())
                                  ? Container(
                                      margin: EdgeInsets.fromLTRB(
                                          7.0, 3.0, 3.0, 0.0),
                                      child: Text(
                                        'RS ' + _item.data["Debit"].toString(),
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
                              isKeyNotNull(_item.data["Credit"].toString())
                                  ? Container(
                                      margin: EdgeInsets.fromLTRB(
                                          3.0, 3.0, 3.0, 0.0),
                                      child: Text(
                                        'RS ' + _item.data["Credit"].toString(),
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
                      _item.data["Credit"] == null
                          ? Container(
                              margin: EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 0.0),
                              child: Text(
                                'RS ' + _item.data["Debit"].toString(),
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
                          : _item.data["Debit"] == null
                              ? Container(
                                  margin:
                                      EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 0.0),
                                  child: Text(
                                    'RS ' + _item.data["Credit"].toString(),
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
                                        ((int.parse(_item.data["Debit"].toString()) -
                                                        int.parse(_item
                                                            .data["Credit"]
                                                            .toString())) >
                                                    0
                                                ? (int.parse(_item.data["Debit"]
                                                        .toString()) -
                                                    int.parse(_item
                                                        .data["Credit"]
                                                        .toString()))
                                                : (int.parse(_item.data["Debit"]
                                                            .toString()) -
                                                        int.parse(
                                                            _item.data["Credit"].toString()))
                                                    .abs()
                                                    .toString())
                                            .toString(),
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: (int.parse(_item.data["Debit"]
                                                      .toString()) -
                                                  int.parse(_item.data["Debit"]
                                                      .toString())) >
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
