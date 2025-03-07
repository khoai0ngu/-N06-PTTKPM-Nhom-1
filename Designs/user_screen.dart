import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'about_screen.dart';
import 'chatbot_screen.dart';
import 'auth_gate.dart';
import 'user_home_screen.dart';
import 'user_book_screen.dart';
import 'person_screen.dart';

class UserDashBoard extends StatefulWidget {
  const UserDashBoard({super.key});

  @override
  State<UserDashBoard> createState() => _UserDashBoardState();
}

class _UserDashBoardState extends State<UserDashBoard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  User? _user;
  String _name = 'Người dùng';
  String _avatarUrl = 'https://via.placeholder.com/150';

  @override
  void initState() {
    super.initState();
    _fetchUser();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() => _user = user);
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
          _name = userDoc['name'] ?? 'Người dùng';
          _avatarUrl = userDoc['avatar'] ?? 'https://via.placeholder.com/150';
        });
      }
    }
  }

  Future<void> _updateAvatar() async {
    TextEditingController urlController =
        TextEditingController(text: _avatarUrl);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cập nhật ảnh đại diện'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              hintText: "Nhập URL ảnh mới",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                String newUrl = urlController.text.trim();
                if (newUrl.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(_user?.uid)
                      .update({'avatar': newUrl});
                  setState(() => _avatarUrl = newUrl);
                }
                Navigator.pop(context);
              },
              child: const Text('Lưu', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const UserHomeScreen(),
    UserBookScreen(),
    const PersonScreen(),
    const chatbotScreen(),
    const AboutScreen(showBackButton: false),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _scaffoldKey.currentState?.closeDrawer();
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          _widgetOptions.elementAt(_selectedIndex),
          Positioned(
            top: 5,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.menu, size: 30, color: Colors.black),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.greenAccent),
            accountName: Text(
              _name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            accountEmail: Text(
              _user?.email ?? 'Chưa có email',
              style: const TextStyle(fontSize: 16),
            ),
            currentAccountPicture: GestureDetector(
              onTap: _updateAvatar,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(_avatarUrl),
                radius: 40,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(Icons.home, "Trang chủ", 0),
                _buildMenuItem(Icons.book, "Sách", 1),
                _buildMenuItem(Icons.people, "Cá nhân", 2),
                _buildMenuItem(Icons.chat, "Chatbot", 3),
                _buildMenuItem(Icons.info, "Về chúng tôi", 4),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Đăng xuất',
                      style: TextStyle(color: Colors.red)),
                  onTap: _logout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon,
          color: _selectedIndex == index ? Colors.greenAccent : Colors.black54),
      title: Text(title,
          style: TextStyle(
              color: _selectedIndex == index
                  ? Colors.greenAccent
                  : Colors.black87)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () => _onItemTapped(index),
    );
  }
}
