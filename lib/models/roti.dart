class Roti {
  final int? id;
  final String nama;
  final int harga;

  Roti({this.id,required this.nama,required this.harga,});

  Map<String, dynamic> toMap() {
    return {'id': id,'nama': nama,'harga': harga,};
  }

  factory Roti.fromMap(Map<String, dynamic> map) {
    return Roti(id: map['id'],nama: map['nama'],harga: map['harga'],);
  }
}
