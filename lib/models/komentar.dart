class Komentar {
  int? id;
  int? postinganId;
  int? userId;
  String isiKomentar;
  String createdAt;
  String? username;

  Komentar({
    this.id,
    this.postinganId,
    this.userId,
    required this.isiKomentar,
    required this.createdAt,
    this.username,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postingan_id': postinganId,
      'user_id': userId,
      'isi_komentar': isiKomentar,
      'created_at': createdAt,
    };
  }

  factory Komentar.fromMap(Map<String, dynamic> map) {
    return Komentar(
      id: map['id'],
      postinganId: map['postingan_id'],
      userId: map['user_id'],
      isiKomentar: map['isi_komentar'],
      createdAt: map['created_at'],
      username: map['username'],
    );
  }
}
