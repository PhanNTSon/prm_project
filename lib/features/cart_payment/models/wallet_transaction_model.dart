class WalletTransactionModel {
  final int transactionId;
  final DateTime? dateCreated;
  final String type;
  final int? gameId;
  final String? gameName;
  final double? price;

  const WalletTransactionModel({
    required this.transactionId,
    required this.dateCreated,
    required this.type,
    this.gameId,
    this.gameName,
    this.price,
  });

  bool get isTopUp => gameId == null;

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      transactionId: json['transactionId'] as int,
      dateCreated: _parseDate(json['dateCreated']),
      type: json['type'] as String? ?? 'Unknown',
      gameId: json['gameId'] as int?,
      gameName: json['gameName'] as String?,
      price: (json['price'] as num?)?.toDouble(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      if (value is String) return DateTime.parse(value);
      if (value is List && value.length >= 3) {
        return DateTime(value[0] as int, value[1] as int, value[2] as int);
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
