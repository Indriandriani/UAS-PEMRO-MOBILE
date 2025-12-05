class GaleriTanaman {
  int? id;
  String nama;
  String? kategori;
  String? statusDisiram;
  String? deskripsi;

  GaleriTanaman({
    this.id,
    required this.nama,
    this.kategori,
    this.statusDisiram,
    this.deskripsi,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'kategori': kategori,
      'status_disiram': statusDisiram,
      'deskripsi': deskripsi,
    };
  }

  factory GaleriTanaman.fromMap(Map<String, dynamic> map) {
    return GaleriTanaman(
      id: map['id'],
      nama: map['nama'],
      kategori: map['kategori'],
      statusDisiram: map['status_disiram'],
      deskripsi: map['deskripsi'],
    );
  }
}