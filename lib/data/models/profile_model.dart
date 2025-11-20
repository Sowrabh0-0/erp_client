class ProfileModel {
  final String id;
  final String email;
  final String role;

  ProfileModel({required this.id, required this.email, required this.role});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      email: json['email'],
      role: json['role'],
    );
  }
}
