class LotterModel {
  String number;
  String nama;

  LotterModel({required this.number, required this.nama});
}

class ListLotterModel {
  String namaSheet;
  List<LotterModel> listLottery;

  ListLotterModel({required this.namaSheet, required this.listLottery});
}
