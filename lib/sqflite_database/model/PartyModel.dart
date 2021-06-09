class PartyModel {
  String partyID;
  String partyName;
  String debit;
  String credit;
  String total;

  PartyModel(
      {this.partyID,
      this.partyName,
        this.debit,
      this.credit,this.total});

  Map<String, dynamic> toMap() {
    // used when inserting data to the database
    return <String, dynamic>{
      "partyID": partyID,
      "partyName": partyName,
      "debit": debit,
      "credit": credit,
      "total": total,
    };
  }
}
