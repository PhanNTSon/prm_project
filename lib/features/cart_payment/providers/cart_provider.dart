import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../repositories/cart_repository.dart';

enum CheckoutResult { success, insufficientBalance, error }

class CartProvider extends ChangeNotifier {
  final CartRepository _repository;
  CartProvider(this._repository);

  List<CartItemModel> _items = [];
  bool _isLoading = false;
  bool _isCheckingOut = false;
  String? _errorMessage;

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  bool get isCheckingOut => _isCheckingOut;
  String? get errorMessage => _errorMessage;

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.price);

  Future<void> loadCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _repository.getCart();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeItem(int gameId) async {
    try {
      await _repository.removeFromCart(gameId);
      _items.removeWhere((item) => item.gameId == gameId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<CheckoutResult> checkout() async {
    _isCheckingOut = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.checkout();
      _items = [];
      _isCheckingOut = false;
      notifyListeners();
      return CheckoutResult.success;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      _isCheckingOut = false;
      if (msg.contains('insufficient') ||
          msg.contains('balance') ||
          msg.contains('không đủ')) {
        _errorMessage = e.toString();
        notifyListeners();
        return CheckoutResult.insufficientBalance;
      }
      _errorMessage = e.toString();
      notifyListeners();
      return CheckoutResult.error;
    }
  }
}