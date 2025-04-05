class User {
  final int? id;
  final String firstName;
  final String? lastName;
  final String? email;
  final String? avatar;
  final String? job;

  User({
    this.id,
    required this.firstName,
    this.lastName,
    this.email,
    this.avatar,
    this.job,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.tryParse(json['id'].toString()), // Updated to handle string IDs
      firstName: json['first_name'] ?? json['name'] ?? '',
      lastName: json['last_name'],
      email: json['email'],
      avatar: json['avatar'],
      job: json['job'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (email != null) 'email': email,
      if (avatar != null) 'avatar': avatar,
      if (job != null) 'job': job,
    };
  }


  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? avatar,
    String? job,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      job: job ?? this.job,
    );
  }
}