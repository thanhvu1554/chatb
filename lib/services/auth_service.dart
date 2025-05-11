import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import '../utils/api_config.dart';

class AuthService {
  // URL API giống với ứng dụng Kivy
  final String baseUrl = ApiConfig.baseUrl;
  
  // HttpClient với timeout dài hơn
  final httpClient = http.Client();
  
  // Đăng nhập
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final result = await ApiConfig.makeRequest(
        url: '$baseUrl/login',
        method: 'POST',
        bodyJson: {
          'username': username,
          'password': password,
        },
      );
      
      if (result['success']) {
        // Lưu thông tin đăng nhập vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await prefs.setString('password', password);
      }
      
      return result;
    } on SocketException {
      // Xử lý lỗi kết nối mạng
      return {'success': false, 'message': 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối của bạn.'};
    } on TimeoutException {
      // Xử lý lỗi timeout
      return {'success': false, 'message': 'Máy chủ không phản hồi. Vui lòng thử lại sau.'};
    } on FormatException {
      // Xử lý lỗi phân tích JSON
      return {'success': false, 'message': 'Lỗi định dạng phản hồi từ máy chủ.'};
    } catch (e) {
      // Các lỗi khác
      return {'success': false, 'message': 'Đã xảy ra lỗi: $e'};
    }
  }
  
  // Đăng ký
  Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      final result = await ApiConfig.makeRequest(
        url: '$baseUrl/register',
        method: 'POST',
        bodyJson: {
          'username': username,
          'password': password,
        },
      );
      
      return result;
    } on SocketException {
      return {'success': false, 'message': 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối của bạn.'};
    } on TimeoutException {
      return {'success': false, 'message': 'Máy chủ không phản hồi. Vui lòng thử lại sau.'};
    } on FormatException {
      return {'success': false, 'message': 'Lỗi định dạng phản hồi từ máy chủ.'};
    } catch (e) {
      return {'success': false, 'message': 'Đã xảy ra lỗi: $e'};
    }
  }
  
  // Đăng xuất
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
  }
  
  // Kiểm tra đã đăng nhập hay chưa
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('username') && prefs.containsKey('password');
  }
} 