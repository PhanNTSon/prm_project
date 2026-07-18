import 'package:flutter/foundation.dart';
import '../models/wallet_transaction_model.dart';
import '../repositories/wallet_repository.dart';

class PaymentProvider extends ChangeNotifier {
  final WalletRepository _repository;
  PaymentProvider(this._repository);

  double _balance = 0.0;
  bool _isLoading = false;
  bool _isTopUpLoading = false;
  String? _errorMessage;
  List<WalletTransactionModel> _transactions = [];

  double get balance => _balance;
  bool get isLoading => _isLoading;
  bool get isTopUpLoading => _isTopUpLoading;
  String? get errorMessage => _errorMessage;
  List<WalletTransactionModel> get transactions => _transactions;

  /// Tải số dư ví hiện tại từ BE.
  Future<void> loadBalance() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _balance = await _repository.getBalance();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tải lịch sử giao dịch (mua game + nạp tiền).
  Future<void> loadTransactions() async {
    try {
      _transactions = await _repository.getTransactions();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Bước 1: tạo yêu cầu thanh toán VNPay, trả về paymentUrl để mở
  /// InAppWebView. Chưa thay đổi số dư ví.
  Future<String?> requestTopUp(double amountUsd) async {
    _isTopUpLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final url = await _repository.createVnpayPayment(amountUsd: amountUsd);
      return url;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isTopUpLoading = false;
      notifyListeners();
    }
  }

  /// Bước 2: sau khi WebView báo vnp_ResponseCode == 00, gọi API cộng tiền
  /// thật vào ví trên BE, đồng thời cập nhật số dư cục bộ.
  Future<bool> confirmTopUp(double amountUsd) async {
    _isTopUpLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _balance = await _repository.addBalance(amountUsd);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isTopUpLoading = false;
      notifyListeners();
    }
  }
}
