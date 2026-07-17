class RegisterRequestModel {
  final String email;
  final String country;

  const RegisterRequestModel({
    required this.email,
    required this.country,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'country': country,
      };
}