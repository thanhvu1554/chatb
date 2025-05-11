import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  
  List<String> _friends = [];
  List<String> _friendRequests = [];
  bool _isLoading = true;
  bool _hasNewRequests = false;
  Timer? _checkRequestsTimer;
  
  @override
  void initState() {
    super.initState();
    _loadData();
    
    // Kiểm tra yêu cầu kết bạn mỗi 30 giây
    _checkRequestsTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkFriendRequests();
    });
  }
  
  @override
  void dispose() {
    _checkRequestsTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (userProvider.user != null) {
      try {
        final friends = await _chatService.getFriends(userProvider.user!.username);
        final requests = await _chatService.getFriendRequests(userProvider.user!.username);
        
        if (mounted) {
          setState(() {
            _friends = friends;
            _friendRequests = requests;
            _hasNewRequests = requests.isNotEmpty;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _checkFriendRequests() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (userProvider.user != null) {
      try {
        final requests = await _chatService.getFriendRequests(userProvider.user!.username);
        
        if (mounted && requests.isNotEmpty && !_hasNewRequests) {
          setState(() {
            _friendRequests = requests;
            _hasNewRequests = true;
          });
        }
      } catch (e) {
        // Bỏ qua lỗi kiểm tra yêu cầu tự động
      }
    }
  }
  
  void _logout() async {
    await _authService.logout();
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.logout();
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
  
  void _showAddFriendDialog() {
    final TextEditingController friendController = TextEditingController();
    String statusMessage = '';
    bool isLoading = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Thêm bạn mới'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: friendController,
                decoration: const InputDecoration(
                  hintText: 'Tên bạn bè',
                ),
              ),
              if (statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    statusMessage,
                    style: TextStyle(
                      color: statusMessage.contains('thành công') 
                          ? Colors.green 
                          : Colors.red,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: isLoading 
                ? null 
                : () async {
                    final friendUsername = friendController.text.trim();
                    if (friendUsername.isEmpty) {
                      setDialogState(() {
                        statusMessage = 'Tên không hợp lệ';
                      });
                      return;
                    }
                    
                    final userProvider = Provider.of<UserProvider>(context, listen: false);
                    if (friendUsername == userProvider.user!.username) {
                      setDialogState(() {
                        statusMessage = 'Không thể tự kết bạn';
                      });
                      return;
                    }
                    
                    setDialogState(() {
                      isLoading = true;
                      statusMessage = 'Đang gửi...';
                    });
                    
                    try {
                      final result = await _chatService.sendFriendRequest(
                        userProvider.user!.username, 
                        friendUsername
                      );
                      
                      setDialogState(() {
                        statusMessage = result['message'] ?? 'Đã gửi yêu cầu';
                        isLoading = false;
                      });
                      
                      if (result['success']) {
                        Future.delayed(const Duration(seconds: 1), () {
                          Navigator.pop(context);
                        });
                      }
                    } catch (e) {
                      setDialogState(() {
                        statusMessage = 'Lỗi: $e';
                        isLoading = false;
                      });
                    }
                  },
              child: isLoading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Gửi yêu cầu'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showFriendRequestsDialog() {
    setState(() {
      _hasNewRequests = false;
    });
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Yêu cầu kết bạn'),
          content: SizedBox(
            width: double.maxFinite,
            child: _friendRequests.isEmpty
              ? const Center(child: Text('Không có yêu cầu mới'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _friendRequests.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_friendRequests[index]),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () async {
                              final userProvider = Provider.of<UserProvider>(context, listen: false);
                              try {
                                await _chatService.acceptFriendRequest(
                                  userProvider.user!.username,
                                  _friendRequests[index]
                                );
                                
                                setDialogState(() {
                                  _friendRequests.removeAt(index);
                                });
                                
                                _loadData(); // Làm mới danh sách bạn bè
                                
                                if (_friendRequests.isEmpty) {
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lỗi: $e')),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () async {
                              final userProvider = Provider.of<UserProvider>(context, listen: false);
                              try {
                                await _chatService.rejectFriendRequest(
                                  userProvider.user!.username,
                                  _friendRequests[index]
                                );
                                
                                setDialogState(() {
                                  _friendRequests.removeAt(index);
                                });
                                
                                if (_friendRequests.isEmpty) {
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lỗi: $e')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    if (userProvider.user == null) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: const Text('Đăng nhập'),
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Xin chào, ${userProvider.user!.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: ElevatedButton(
              onPressed: _loadData,
              child: const Text('Làm mới DS Bạn'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showAddFriendDialog,
                    child: const Text('Thêm bạn'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showFriendRequestsDialog,
                    style: _hasNewRequests
                      ? ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                        )
                      : null,
                    child: Text(
                      _hasNewRequests 
                          ? 'Yêu cầu kết bạn (Mới!)'
                          : 'Yêu cầu kết bạn',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Bạn bè:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _friends.isEmpty
                    ? const Center(child: Text('(Chưa có bạn bè)'))
                    : ListView.builder(
                        itemCount: _friends.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_friends[index]),
                            tileColor: const Color(0xFFE4E6EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/conversation',
                                arguments: {
                                  'friendUsername': _friends[index],
                                },
                              );
                            },
                          );
                        },
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
          ),
        ],
      ),
    );
  }
} 