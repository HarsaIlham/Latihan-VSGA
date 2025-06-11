class Senjata {
  final int? id;
  final String nama;
  final int jumlah;

  Senjata({
    this.id,
    required this.nama,
    required this.jumlah,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'jumlah': jumlah,
    };
  }

  factory Senjata.fromMap(Map<String, dynamic> map) {
    return Senjata(
      id: map['id'],
      nama: map['nama'],
      jumlah: map['jumlah'],
    );
  }
}
