class Postingan {
  int? id;
  int userId;
  String? imageUrl;
  String caption;
  String createdAt;

  Postingan({
    this.id,
    required this.userId,
    this.imageUrl,
    required this.caption,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'image_url': imageUrl,
      'caption': caption,
      'created_at': createdAt,
    };
  }

  factory Postingan.fromMap(Map<String, dynamic> map) {
    return Postingan(
      id: map['id'],
      userId: map['user_id'],
      imageUrl: map['image_url'],
      caption: map['caption'],
      createdAt: map['created_at'],
    );
  }
}
