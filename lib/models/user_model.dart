class UserModel {
  final String username;
  final Map<String, dynamic>? additionalData;

  UserModel({
    required this.username,
    this.additionalData,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Tách username từ JSON
    final username = json['username'] as String;
    
    // Tạo một bản sao của map dữ liệu
    final Map<String, dynamic> additionalData = Map.from(json);
    // Xóa username vì đã có biến riêng
    additionalData.remove('username');
    
    return UserModel(
      username: username,
      additionalData: additionalData.isEmpty ? null : additionalData,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
    };
    
    if (additionalData != null) {
      data.addAll(additionalData!);
    }
    
    return data;
  }
} 