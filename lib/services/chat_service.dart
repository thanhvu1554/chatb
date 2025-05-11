import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import '../utils/api_config.dart';

class ChatService {
  final String baseUrl = ApiConfig.baseUrl;
  
  // Lấy danh sách bạn bè
  Future<List<String>> getFriends(String username) async {
    try {
      final result = await ApiConfig.makeRequest(
        url: '$baseUrl/friends/$username',
        method: 'GET',
      );
      
      if (result['success']) {
        return List<String>.from(result['friends']);
      } else {
        return [];
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
      return [];
    }
  }
  
  // Gửi yêu cầu kết bạn
  Future<Map<String, dynamic>> sendFriendRequest(String user, String friend) async {
    try {
      return await ApiConfig.makeRequest(
        url: '$baseUrl/add_friend',
        method: 'POST',
        bodyJson: {
          'user1': user,
          'user2': friend,
        },
      );
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
  
  // Lấy danh sách yêu cầu kết bạn
  Future<List<String>> getFriendRequests(String username) async {
    try {
      final result = await ApiConfig.makeRequest(
        url: '$baseUrl/friend_requests/$username',
        method: 'GET',
      );
      
      if (result['success']) {
        return List<String>.from(result['friend_requests']);
      } else {
        return [];
      }
    } catch (e) {
      print("Lỗi lấy yêu cầu kết bạn: $e");
      return [];
    }
  }
  
  // Chấp nhận yêu cầu kết bạn
  Future<Map<String, dynamic>> acceptFriendRequest(String user, String friend) async {
    try {
      return await ApiConfig.makeRequest(
        url: '$baseUrl/accept_friend',
        method: 'POST',
        bodyJson: {
          'user': user,
          'friend': friend,
        },
      );
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
  
  // Từ chối yêu cầu kết bạn
  Future<Map<String, dynamic>> rejectFriendRequest(String user, String friend) async {
    try {
      return await ApiConfig.makeRequest(
        url: '$baseUrl/reject_friend',
        method: 'POST',
        bodyJson: {
          'user': user,
          'friend': friend,
        },
      );
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
  
  // Lấy lịch sử tin nhắn
  Future<List<Map<String, dynamic>>> getMessageHistory(String sender, String recipient) async {
    try {
      String url = '$baseUrl/message_history?sender=$sender&recipient=$recipient';
      
      final result = await ApiConfig.makeRequest(
        url: url,
        method: 'GET',
      );
      
      if (result['success']) {
        return List<Map<String, dynamic>>.from(result['history']);
      } else {
        return [];
      }
    } catch (e) {
      print("Lỗi lấy lịch sử tin nhắn: $e");
      return [];
    }
  }
  
  // Gửi tin nhắn
  Future<Map<String, dynamic>> sendMessage(String from, String to, String message) async {
    try {
      return await ApiConfig.makeRequest(
        url: '$baseUrl/send_message',
        method: 'POST',
        bodyJson: {
          'from': from,
          'to': to,
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      return {'success': false, 'message': 'Lỗi gửi tin nhắn: $e'};
    }
  }
} 