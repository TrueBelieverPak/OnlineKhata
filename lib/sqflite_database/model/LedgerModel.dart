class LedgerModel {
  String partyID_FK;
  String vocNo;
  String tType;
  String description;
  String date;
  String debit;
  String credit;
  String totalBalance;

  LedgerModel(
      {this.partyID_FK,
      this.vocNo,
      this.tType,
      this.description,
      this.date,
      this.debit,
      this.credit,
      this.totalBalance});

  Map<String, dynamic> toMap() {
    // used when inserting data to the database
    return <String, dynamic>{
      "partyID_FK": partyID_FK,
      "vocNo": vocNo,
      "tType": tType,
      "description": description,
      "date": date,
      "debit": debit,
      "credit": credit,
      "totalBalance": totalBalance,
    };
  }
}
