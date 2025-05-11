import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static final ApiConfig _instance = ApiConfig._internal();
  factory ApiConfig() => _instance;
  ApiConfig._internal();

  // Chỉ sử dụng server production
  static final List<String> _availableServers = [
    'http://51.81.228.215:5000',  // Server production
  ];
  
  // Server đang được sử dụng
  static int _currentServerIndex = 0;
  
  // Lưu trữ server đã chọn
  static Future<void> _saveCurrentServerIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_server_index', _currentServerIndex);
  }
  
  // Đọc server đã lưu
  static Future<void> _loadCurrentServerIndex() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentServerIndex = prefs.getInt('current_server_index') ?? 0;
    } catch (e) {
      print("Lỗi đọc cài đặt server: $e");
      _currentServerIndex = 0;
    }
  }
  
  // Khởi tạo cấu hình với server production
  static Future<void> initialize() async {
    await _loadCurrentServerIndex();
    print("Đang sử dụng máy chủ: ${_availableServers[_currentServerIndex]}");
  }

  // Lấy baseUrl hiện tại (luôn là server production)
  static String get baseUrl {
    return _availableServers[_currentServerIndex];
  }
  
  static const Duration defaultTimeout = Duration(seconds: 15);
  
  // Mô phỏng kiểu cấu trúc HttpRequest của Kivy trong Flutter
  static Future<Map<String, dynamic>> makeRequest({
    required String url,
    required String method,
    Map<String, String>? headers,
    Map<String, dynamic>? bodyJson,
    Duration timeout = defaultTimeout,
    bool autoSwitchServer = true,
  }) async {
    headers ??= {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Connection': 'keep-alive',
    };
    
    try {
      print("API Request: $method $url");
      if (bodyJson != null) {
        print("Request data: ${jsonEncode(bodyJson)}");
      }
      
      http.Response response;
      
      if (method.toUpperCase() == 'GET') {
        response = await http.get(
          Uri.parse(url),
          headers: headers,
        ).timeout(timeout);
      } else if (method.toUpperCase() == 'POST') {
        response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: bodyJson != null ? jsonEncode(bodyJson) : null,
        ).timeout(timeout);
      } else {
        throw Exception('Phương thức không được hỗ trợ: $method');
      }
      
      print("API Response status: ${response.statusCode}");
      
      // Xử lý phản hồi
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          print("Lỗi decode JSON: $e");
          print("Response body: ${response.body}");
          
          // Thử xử lý trường hợp phản hồi trống
          if (response.body.isEmpty) {
            return {
              'success': true,
              'message': 'Thành công (phản hồi trống)',
            };
          }
          
          return {
            'success': false,
            'message': 'Không thể đọc dữ liệu từ máy chủ: $e',
          };
        }
      } else {
        print("Lỗi HTTP: ${response.statusCode} - ${response.body}");
        return {
          'success': false,
          'message': 'Lỗi máy chủ: ${response.statusCode}',
          'status_code': response.statusCode,
          'response_body': response.body,
        };
      }
    } on SocketException catch (e) {
      print("Lỗi Socket: $e");
      return {
        'success': false,
        'message': 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
        'error': e.toString(),
      };
    } on TimeoutException catch (e) {
      print("Lỗi Timeout: $e");
      return {
        'success': false,
        'message': 'Hết thời gian chờ kết nối. Máy chủ không phản hồi.',
        'error': e.toString(),
      };
    } catch (e) {
      print("Lỗi không xác định: $e");
      return {
        'success': false,
        'message': 'Đã xảy ra lỗi: $e',
        'error': e.toString(),
      };
    }
  }
} 