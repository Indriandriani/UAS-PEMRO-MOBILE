class User {
  int? id;
  String username;
  String email;
  String password;
  int hariBeruntun;
  int totalLencana;
  String? createdAt;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.hariBeruntun = 0,
    this.totalLencana = 0,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'hari_beruntun': hariBeruntun,
      'total_lencana': totalLencana,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      hariBeruntun: map['hari_beruntun'],
      totalLencana: map['total_lencana'],
      createdAt: map['created_at'],
    );
  }
}