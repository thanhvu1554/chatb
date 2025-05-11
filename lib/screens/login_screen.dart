import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../main.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String _statusMessage = '';
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang đăng nhập...';
    });
    
    try {
      final result = await _authService.login(
        _usernameController.text.trim(), 
        _passwordController.text.trim()
      );
      
      if (!mounted) return;
      
      if (result['success']) {
        // Cập nhật state user trong Provider
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(UserModel.fromJson(result['user']));
        
        // Chuyển đến màn hình chat
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/chat_list');
        }
      } else {
        String errorMessage = result['message'] ?? 'Đăng nhập thất bại';
        
        // Thêm hướng dẫn chi tiết cho lỗi CORS (chỉ khi chạy trên web)
        if (kIsWeb && (errorMessage.contains("network") || errorMessage.contains("kết nối") || errorMessage.contains("lỗi"))) {
          errorMessage += "\n\nNếu bạn đang chạy ứng dụng trên web, có thể gặp lỗi CORS. Thử các cách sau:\n"
              "1. Cài ứng dụng trên thiết bị di động thật\n"
              "2. Thêm CORS headers vào server backend";
        }
        
        setState(() {
          _statusMessage = errorMessage;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Lỗi kết nối: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _checkServerStatus() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang kiểm tra kết nối đến máy chủ...';
    });
    
    try {
      final response = await http.get(Uri.parse('http://51.81.228.215:5000/'));
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        if (response.statusCode >= 200 && response.statusCode < 300) {
          _statusMessage = 'Kết nối đến máy chủ thành công với status: ${response.statusCode}.\n'
                          'Response: ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}\n\n'
                          'Vấn đề có thể là do CORS. Hãy cài đặt app trên thiết bị thật.';
        } else {
          _statusMessage = 'Máy chủ phản hồi với status: ${response.statusCode}';
        }
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _statusMessage = 'Không thể kết nối đến máy chủ: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Đăng nhập ChatApp',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1877F2),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Tên đăng nhập',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên đăng nhập';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    hintText: 'Mật khẩu',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      )
                    : const Text(
                        'Đăng nhập',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isLoading 
                    ? null
                    : () => Navigator.pushNamed(context, '/register'),
                  child: const Text(
                    'Tạo tài khoản mới',
                    style: TextStyle(
                      color: Color(0xFF1877F2),
                      fontSize: 16,
                    ),
                  ),
                ),
                if (_statusMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _statusMessage,
                      style: TextStyle(
                        color: _statusMessage.contains('Đang')
                            ? Colors.blue
                            : Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                // Thêm nút kiểm tra server khi chạy trên web
                if (kIsWeb && _statusMessage.contains('CORS'))
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextButton(
                      onPressed: _checkServerStatus,
                      child: const Text(
                        'Kiểm tra kết nối server',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 