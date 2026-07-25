import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/order.dart';

class ApiService {
  static String get baseUrl {
    return 'https://backendlibrarium-production.up.railway.app/v1';
  }

  static String getFullImageUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    if (url.startsWith('/')) {
      return baseUrl.replaceAll('/v1', '') + url;
    }
    return baseUrl.replaceAll('/v1', '') + '/' + url;
  }
  
  late final Dio _dio;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        final token = response.data['data']['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> loginWithGoogle(String idToken) async {
    try {
      final response = await _dio.post('/auth/google', data: {
        'id_token': idToken,
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        final token = response.data['data']['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        return true;
      }
      return false;
    } catch (e) {
      print('Google Login error: $e');
      return false;
    }
  }

  Future<String?> register(String email, String password, String fullName) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': 'customer',
      });
      if (response.statusCode == 201) return null; // null means success
      return 'Unknown error: ${response.statusCode}';
    } on DioException catch (e) {
      print('DioError: ${e.message}');
      if (e.response != null && e.response?.data != null) {
        try {
          // If it's a validation or custom error from FastAPI
          if (e.response!.data is Map) {
             final data = e.response!.data as Map;
             if (data['detail'] is Map && data['detail']['message'] != null) {
               return data['detail']['message'];
             } else if (data['detail'] is List) {
               return data['detail'].toString(); // validation errors
             } else if (data['error'] != null) {
               return data['error'].toString();
             }
          }
          return e.response!.data.toString();
        } catch (_) {
          return e.response!.data.toString();
        }
      }
      return e.message; // Connection timeout, etc.
    } catch (e) {
      print('Register error: $e');
      return e.toString();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  Future<List<dynamic>> getComments(String bookId) async {
    try {
      final response = await _dio.get('/comments/$bookId');
      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  Future<dynamic> postComment(String bookId, String text, {String? parentId}) async {
    try {
      final response = await _dio.post('/comments/', data: {
        'book_id': bookId,
        'text': text,
        'parent_id': parentId,
      });
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error posting comment: $e');
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('access_token');
  }

  Future<List<Book>> getBooks() async {
    try {
      final response = await _dio.get('/books/');
      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((json) => Book.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching books: $e');
      return [];
    }
  }

  Future<Order?> createOrder(Order order) async {
    try {
      final response = await _dio.post(
        '/orders/',
        data: order.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Order.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  Future<bool> payOrder(String orderId, String method) async {
    try {
      final response = await _dio.put('/orders/$orderId/pay?payment_method=$method');
      return response.statusCode == 200;
    } catch (e) {
      print('Error paying order: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await _dio.get('/auth/me');
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/auth/me', data: data);
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  Future<List<Order>> getMyOrders() async {
    try {
      final response = await _dio.get('/orders/me');
      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching my orders: $e');
      return [];
    }
  }

  Future<String?> uploadAvatar(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath),
      });
      final response = await _dio.post('/auth/upload_avatar', data: formData);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['avatar_url'];
      }
      return null;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }
}
