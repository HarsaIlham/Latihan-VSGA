class Transaksi {
  int? id;
  int produkId;
  int jumlah;
  String namaPembeli;
  String lokasiPembeli;

  Transaksi({this.id,required this.produkId,required this.jumlah,required this.namaPembeli,required this.lokasiPembeli,});

  Map<String, dynamic> toMap() {
    return {'produk_id': produkId,'jumlah': jumlah,'nama_pembeli': namaPembeli,'lokasi_pembeli': lokasiPembeli,};
  }

  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(id: map['id'],produkId: map['produk_id'],jumlah: map['jumlah'],namaPembeli: map['nama_pembeli'],lokasiPembeli: map['lokasi_pembeli'],
    );
  }
}
