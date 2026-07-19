class RegisterDetailsModel {
  final String email;
  final String username;
  final String password;

  const RegisterDetailsModel({
    required this.email,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'username': username,
        'password': password,
      };
}