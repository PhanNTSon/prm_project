import '../../../../core/network/dio_client.dart';
import '../models/cart_item_model.dart';

class CartRepository {
  final DioClient _dioClient;
  CartRepository(this._dioClient);

  /// GET /user/cart
  Future<List<CartItemModel>> getCart() async {
    try {
      final response = await _dioClient.get('/user/cart');
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load cart: ${e.toString()}');
    }
  }

  /// POST /user/cart/add?gameId=
  Future<void> addToCart(int gameId) async {
    try {
      await _dioClient.post(
        '/user/cart/add',
        queryParameters: {'gameId': gameId},
      );
    } catch (e) {
      throw Exception('Failed to add to cart: ${e.toString()}');
    }
  }

  /// DELETE /user/cart/remove?gameId=
  Future<void> removeFromCart(int gameId) async {
    try {
      await _dioClient.delete(
        '/user/cart/remove',
        queryParameters: {'gameId': gameId},
      );
    } catch (e) {
      throw Exception('Failed to remove from cart: ${e.toString()}');
    }
  }

  /// POST /user/cart/checkout
  Future<void> checkout() async {
    try {
      await _dioClient.post('/user/cart/checkout');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}