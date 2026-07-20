import 'package:dio/dio.dart';


String extractErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is String && data.isNotEmpty) {
      return data;
    }
    // Không có response (mất mạng, timeout...) -> dùng message của Dio
    return error.message ?? error.toString();
  }
  return error.toString();
}