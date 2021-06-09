import 'package:mongo_dart/mongo_dart.dart';
import 'dart:io' show Platform;

class MongoDBConnection  {
  Db db ;

  Future<Db> getConnection() async{
    if (db == null){
      try {
        db = Db(_getConnectionString());
        await db.open();
      } catch(e){
        print(e);
      }
    }
    return db;
  }

  _getConnectionString(){
    return "mongodb+srv://asif:cosoftcon123>@cluster0.k6lme.mongodb.net/imran?retryWrites=true&w=majority";
  }
  void getPartiesFromMongoServer() async {
    try {



      var collection = db.collection('Party');

      await collection.find().forEach((v) {
        print(v);

      });
    } catch (e) {
      var i = 0;
    }
  }

  closeConnection() {
    db.close();
  }
}
