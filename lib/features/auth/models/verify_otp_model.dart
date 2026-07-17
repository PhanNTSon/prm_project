class VerifyOtpModel {
  final String email;
  final String otp;

  const VerifyOtpModel({
    required this.email,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'otp': otp,
      };
}