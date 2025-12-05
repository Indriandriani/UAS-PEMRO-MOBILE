class Lencana {
  int? id;
  int userId;
  String namaLencana;
  String? deskripsi;
  String? icon;
  String? tanggalDiperoleh;

  Lencana({
    this.id,
    required this.userId,
    required this.namaLencana,
    this.deskripsi,
    this.icon,
    this.tanggalDiperoleh,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'nama_lencana': namaLencana,
      'deskripsi': deskripsi,
      'icon': icon,
      'tanggal_diperoleh': tanggalDiperoleh,
    };
  }

  factory Lencana.fromMap(Map<String, dynamic> map) {
    return Lencana(
      id: map['id'],
      userId: map['user_id'],
      namaLencana: map['nama_lencana'],
      deskripsi: map['deskripsi'],
      icon: map['icon'],
      tanggalDiperoleh: map['tanggal_diperoleh'],
    );
  }
}