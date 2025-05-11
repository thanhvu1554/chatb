import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/conversation_screen.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'utils/network_interceptor.dart';
import 'utils/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print("==== KHỞI ĐỘNG ỨNG DỤNG BELUGA CHAT ====");
  
  // Khởi tạo cấu hình API với server production
  await ApiConfig.initialize();
  print("Đã khởi tạo API Config: ${ApiConfig.baseUrl}");
  
  // Khởi tạo shared preferences để lưu session
  final prefs = await SharedPreferences.getInstance();
  final authService = AuthService();
  
  // Kiểm tra kết nối máy chủ
  print("Đang kiểm tra kết nối đến máy chủ...");
  final networkInterceptor = NetworkInterceptor();
  bool isServerReachable = await networkInterceptor.checkConnection('${ApiConfig.baseUrl}/ping');
  print('Trạng thái máy chủ: ${isServerReachable ? "HOẠT ĐỘNG" : "KHÔNG KẾT NỐI ĐƯỢC"}');
  
  // Thử lại nếu không kết nối được
  if (!isServerReachable) {
    print("Lần đầu không kết nối được, thử lại...");
    isServerReachable = await networkInterceptor.retryConnection(1, url: '${ApiConfig.baseUrl}/ping');
  }
  
  // Kiểm tra session đã lưu
  final savedUsername = prefs.getString('username');
  final savedPassword = prefs.getString('password');
  
  UserModel? initialUser;
  if (savedUsername != null && savedPassword != null && isServerReachable) {
    try {
      print("Thử đăng nhập tự động với user: $savedUsername");
      final loginResult = await authService.login(savedUsername, savedPassword);
      if (loginResult['success']) {
        initialUser = UserModel.fromJson(loginResult['user']);
        print("Đăng nhập tự động thành công");
      } else {
        print("Đăng nhập tự động thất bại: ${loginResult['message']}");
      }
    } catch (e) {
      print('Lỗi đăng nhập tự động: $e');
    }
  }
  
  print("Khởi động giao diện người dùng...");
  runApp(BelugaChat(
    initialUser: initialUser,
    isServerReachable: isServerReachable,
  ));
}

class BelugaChat extends StatelessWidget {
  final UserModel? initialUser;
  final bool isServerReachable;
  
  const BelugaChat({
    super.key, 
    this.initialUser,
    this.isServerReachable = true,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(initialUser),
      child: MaterialApp(
        title: 'Beluga Chat',
        theme: ThemeData(
          primaryColor: const Color(0xFF1877F2),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1877F2),
            background: const Color(0xFFF0F2F5),
          ),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1877F2),
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1877F2),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, 
              vertical: 14
            ),
          ),
        ),
        initialRoute: initialUser != null ? '/chat_list' : '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/chat_list': (context) => const ChatListScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/conversation') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ConversationScreen(
                friendUsername: args['friendUsername'],
              ),
            );
          }
          return null;
        },
        builder: (context, child) {
          // Hiển thị thông báo lỗi kết nối nếu không thể kết nối đến máy chủ
          if (!isServerReachable) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_off,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Không thể kết nối đến máy chủ',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Vui lòng kiểm tra kết nối mạng và thử lại sau',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          print("Đang thử kết nối lại...");
                          // Thử kết nối lại server production
                          final success = await NetworkInterceptor().retryConnection(3, url: '${ApiConfig.baseUrl}/ping');
                          if (success) {
                            print("Kết nối lại thành công, khởi động lại ứng dụng");
                            // Khởi động lại ứng dụng
                            runApp(BelugaChat(
                              initialUser: null,
                              isServerReachable: true,
                            ));
                          } else {
                            print("Không thể kết nối lại sau nhiều lần thử");
                          }
                        },
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return child!;
        },
      ),
    );
  }
}

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  
  UserProvider(this._user);
  
  UserModel? get user => _user;
  
  void setUser(UserModel? user) {
    _user = user;
    notifyListeners();
  }
  
  bool get isLoggedIn => _user != null;
  
  void logout() {
    _user = null;
    notifyListeners();
  }
}