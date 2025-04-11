class User {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.profileImage,
  });

  // Create a copy of the user with updated properties
  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? profileImage,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  // Sample user for testing
  static User getSampleUser() {
    return User(
      id: '1',
      name: 'Abebe Kebede',
      phone: '+251 911 123 456',
      email: 'abebe@example.com',
    );
  }
}
