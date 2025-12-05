class TanamanUser {
  int? id;
  int userId;
  String namaTanaman;
  String? jenisTanaman;
  String? jadwalSiram;
  String? terakhirDisiram;
  String? fotoPath;
  String? createdAt;

  TanamanUser({
    this.id,
    required this.userId,
    required this.namaTanaman,
    this.jenisTanaman,
    this.jadwalSiram,
    this.terakhirDisiram,
    this.fotoPath,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'nama_tanaman': namaTanaman,
      'jenis_tanaman': jenisTanaman,
      'jadwal_siram': jadwalSiram,
      'terakhir_disiram': terakhirDisiram,
      'foto_path': fotoPath,
      'created_at': createdAt,
    };
  }

  factory TanamanUser.fromMap(Map<String, dynamic> map) {
    return TanamanUser(
      id: map['id'],
      userId: map['user_id'],
      namaTanaman: map['nama_tanaman'],
      jenisTanaman: map['jenis_tanaman'],
      jadwalSiram: map['jadwal_siram'],
      terakhirDisiram: map['terakhir_disiram'],
      fotoPath: map['foto_path'],
      createdAt: map['created_at'],
    );
  }
}