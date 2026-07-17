class ResetPasswordModel {
  final String email;
  final String otp;
  final String newPassword;

  const ResetPasswordModel({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      };
}