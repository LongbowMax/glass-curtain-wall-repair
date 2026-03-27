class User {
  final String id;
  final String username;
  final String name;
  final String? phone;
  final String? email;
  final String? company;
  final String? avatar;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  User({
    required this.id,
    required this.username,
    required this.name,
    this.phone,
    this.email,
    this.company,
    this.avatar,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'],
      company: json['company'],
      avatar: json['avatar'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'phone': phone,
      'email': email,
      'company': company,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? name,
    String? phone,
    String? email,
    String? company,
    String? avatar,
  }) {
    return User(
      id: id,
      username: username,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      company: company ?? this.company,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }
}
