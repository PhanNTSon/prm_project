class ProfileModel {
  final int userId;
  final String username;
  final String? profileName;
  final String email;
  final String? avatarUrl;
  final String? country;
  final String? gender;
  final String? dob;
  final String? summary;
  final String role;
  final int totalGames;
  final int reviewCount;
  final double walletBalance;

  const ProfileModel({
    required this.userId,
    required this.username,
    this.profileName,
    required this.email,
    this.avatarUrl,
    this.country,
    this.gender,
    this.dob,
    this.summary,
    required this.role,
    this.totalGames = 0,
    this.reviewCount = 0,
    this.walletBalance = 0.0,
  });

  String get displayName => profileName?.isNotEmpty == true ? profileName! : username;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['userId'] is int
          ? json['userId']
          : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      username: json['username'] ?? '',
      profileName: json['profileName'],
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      country: json['country'],
      gender: json['gender'],
      dob: json['dob'],
      summary: json['summary'],
      role: json['role'] ?? 'ROLE_USER',
      totalGames: json['totalGames'] ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
      walletBalance: (json['walletBalance'] ?? 0).toDouble(),
    );
  }
}