import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'settings_screen.dart';
import 'person_borrow_book.dart';

class PersonScreen extends StatefulWidget {
  const PersonScreen({Key? key}) : super(key: key);

  @override
  _PersonScreenState createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen> {
  String avatarUrl = "";
  String name = "Tên người dùng";
  String email = "Email chưa cập nhật";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          name = userDoc['name'] ?? "Tên người dùng";
          email = userDoc['email'] ?? "Email chưa cập nhật";
          avatarUrl = userDoc['avatar'] ?? "";
        });
      }
    } catch (e) {
      print("Lỗi tải dữ liệu người dùng: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Tài khoản"),
        backgroundColor: Colors.greenAccent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 10),
          Expanded(child: _buildMenuList(context)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(45),
              child: avatarUrl.isNotEmpty
                  ? Image.network(avatarUrl,
                      width: 90, height: 90, fit: BoxFit.cover)
                  : Image.asset("assets/default_avatar.png",
                      width: 90, height: 90, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              Text(
                email,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildMenuItem(
          Icons.person,
          "Thông tin tài khoản",
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsScreen()),
          ),
        ),
        _buildMenuItem(
          Icons.menu_book,
          "Lịch sử mượn",
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HistoryScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            leading: Icon(icon, color: Colors.greenAccent),
            title: Text(title, style: const TextStyle(fontSize: 16)),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 18, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
