class JadwalPenyiraman {
  int? id;
  int tanamanUserId;
  String tanggalSiram;
  String status;

  JadwalPenyiraman({
    this.id,
    required this.tanamanUserId,
    required this.tanggalSiram,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanaman_user_id': tanamanUserId,
      'tanggal_siram': tanggalSiram,
      'status': status,
    };
  }

  factory JadwalPenyiraman.fromMap(Map<String, dynamic> map) {
    return JadwalPenyiraman(
      id: map['id'],
      tanamanUserId: map['tanaman_user_id'],
      tanggalSiram: map['tanggal_siram'],
      status: map['status'],
    );
  }
}