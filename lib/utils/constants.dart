import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


Firestore databaseReference = Firestore.instance;

String getDateTimeFormat(String date) {
  final DateTime now = DateTime.parse(date);
  // final DateFormat formatter = DateFormat('dd MMM yyyy h:mm a');
  final DateFormat formatter = DateFormat('dd MMM yyyy');
  final String formatted = formatter.format(now);

  return formatted;
}


bool isKeyNotNull(Object param1) {
  if (param1 != null)
    return true;
  else
    return false;
}