import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'api_config.dart';

class NetworkInterceptor {
  // Singleton pattern
  static final NetworkInterceptor _instance = NetworkInterceptor._internal();
  factory NetworkInterceptor() => _instance;
  NetworkInterceptor._internal();

  // Phát hiện trạng thái kết nối mạng
  bool _isNetworkAvailable = true;
  bool get isNetworkAvailable => _isNetworkAvailable;

  // Xác định trạng thái kết nối server
  bool _isServerReachable = true;
  bool get isServerReachable => _isServerReachable;

  // Kiểm tra kết nối
  Future<bool> checkConnection(String url) async {
    try {
      print("Đang kiểm tra kết nối đến: $url");
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        }
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => http.Response('{"success":false,"message":"Timeout"}', 408),
      );
      
      print("Mã trạng thái: ${response.statusCode}");
      print("Nội dung phản hồi: ${response.body}");
      
      // Kiểm tra mã trạng thái HTTP
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Xử lý trường hợp phản hồi trống
        if (response.body.isEmpty) {
          print("Phản hồi trống nhưng mã trạng thái OK");
          _isServerReachable = true;
          _isNetworkAvailable = true;
          return true;
        }
        
        try {
          // Thử phân tích JSON
          final data = jsonDecode(response.body);
          print("Phân tích JSON thành công: $data");
          _isServerReachable = true;
          _isNetworkAvailable = true;
          return true;
        } catch (jsonError) {
          // Lỗi phân tích JSON nhưng vẫn có kết nối
          print("Lỗi phân tích JSON: $jsonError, nhưng mã trạng thái OK");
          _isServerReachable = true;
          _isNetworkAvailable = true;
          return true;
        }
      } else {
        print("Máy chủ trả về mã lỗi: ${response.statusCode}");
        _isNetworkAvailable = true;
        _isServerReachable = false;
        return false;
      }
    } catch (e) {
      print("Lỗi kết nối chi tiết: $e");
      _isNetworkAvailable = false;
      _isServerReachable = false;
      return false;
    }
  }

  // Hiển thị thông báo lỗi kết nối
  void showNetworkError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Thử lại',
          textColor: Colors.white,
          onPressed: () async {
            // Thử kết nối lại
            checkConnection('${ApiConfig.baseUrl}/ping');
          },
        ),
      ),
    );
  }

  // Tự động thử kết nối lại
  Future<bool> retryConnection(int maxRetries, {required String url}) async {
    int retries = 0;
    bool success = false;
    
    while (retries < maxRetries && !success) {
      print("Lần thử kết nối thứ ${retries + 1}/$maxRetries");
      success = await checkConnection(url);
      if (success) {
        print("Kết nối thành công sau ${retries + 1} lần thử");
        return true;
      }
      
      // Đợi trước khi thử lại
      int waitTime = 2 * (retries + 1);
      print("Đợi $waitTime giây trước khi thử lại...");
      await Future.delayed(Duration(seconds: waitTime));
      retries++;
    }
    
    if (!success) {
      print("Đã thử kết nối $maxRetries lần nhưng không thành công");
    }
    
    return success;
  }
} 