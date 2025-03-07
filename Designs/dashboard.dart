import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'books_screen.dart';
import 'members_screen.dart';
import 'about_screen.dart';
import 'chatbot_screen.dart';
import 'auth_gate.dart';
import 'settings_screen.dart'; // Import trang cài đặt

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  User? _user;
  String _name = 'Người dùng';
  String _avatarUrl = 'https://via.placeholder.com/150';

  @override
  void initState() {
    super.initState();
    _fetchUser(); // Lấy thông tin người dùng khi khởi động
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user; // Cập nhật khi có thay đổi đăng nhập/đăng xuất
      });
      _fetchUser();
    });
  }

  Future<void> _fetchUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _user = user;
          _name = userDoc['name'] ?? 'Người dùng';
          _avatarUrl = userDoc['avatar'] ?? 'https://via.placeholder.com/150';
        });
      }
    }
  }

  static List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    BookScreen(),
    const MembersScreen(),
    const chatbotScreen(),
    const AboutScreen(showBackButton: false),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child:
                  const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
    _fetchUser(); // Cập nhật lại tên sau khi quay về
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý thư viện'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.orange),
              accountName: Text(
                _name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              accountEmail: Text(
                _user?.email ?? 'Chưa có email',
                style: const TextStyle(fontSize: 16),
              ),
              currentAccountPicture: GestureDetector(
                onTap: _navigateToSettings,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(_avatarUrl),
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home),
              trailing: const Icon(Icons.arrow_forward),
              title: const Text('Trang chủ'),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              trailing: const Icon(Icons.arrow_forward),
              title: const Text('Quản lý sách'),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              trailing: const Icon(Icons.arrow_forward),
              title: const Text('Quản lý người dùng'),
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              trailing: const Icon(Icons.arrow_forward),
              title: const Text('Chatbot'),
              onTap: () => _onItemTapped(3),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              trailing: const Icon(Icons.arrow_forward),
              title: const Text('Về chúng tôi'),
              onTap: () => _onItemTapped(4),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt'),
              onTap: _navigateToSettings,
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title:
                  const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}
