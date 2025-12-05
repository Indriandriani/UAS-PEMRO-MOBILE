class Tantangan {
  int? id;
  int userId;
  String namaTantangan;
  String? deskripsi;
  int progressSaatIni;
  int target;
  int totalPeserta;
  String status;
  String? icon;
  String? lastReset;

  Tantangan({
    this.id,
    required this.userId,
    required this.namaTantangan,
    this.deskripsi,
    this.progressSaatIni = 0,
    required this.target,
    this.totalPeserta = 0,
    required this.status,
    this.icon,
    this.lastReset,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'nama_tantangan': namaTantangan,
      'deskripsi': deskripsi,
      'progress_saat_ini': progressSaatIni,
      'target': target,
      'total_peserta': totalPeserta,
      'status': status,
      'icon': icon,
      'last_reset': lastReset,
    };
  }

  factory Tantangan.fromMap(Map<String, dynamic> map) {
    return Tantangan(
      id: map['id'],
      userId: map['user_id'],
      namaTantangan: map['nama_tantangan'],
      deskripsi: map['deskripsi'],
      progressSaatIni: map['progress_saat_ini'],
      target: map['target'],
      totalPeserta: map['total_peserta'],
      status: map['status'],
      icon: map['icon'],
      lastReset: map['last_reset'],
    );
  }
}