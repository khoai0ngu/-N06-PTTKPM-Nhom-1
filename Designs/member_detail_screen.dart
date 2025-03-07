import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_detail_screen.dart';

class MemberDetailScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String email;
  final String avatar;

  const MemberDetailScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
    required this.avatar,
  });

  @override
  _MemberDetailScreenState createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _avatarController;
  String? selectedRole;
  bool _isEditing = false;
  List<Map<String, dynamic>> borrowedBooks = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _avatarController = TextEditingController(text: widget.avatar);
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userDoc.exists && userDoc.data() != null) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      setState(() {
        selectedRole = userData['role'] ?? 'user';
        borrowedBooks =
            List<Map<String, dynamic>>.from(userData['borrow'] ?? []);
      });
    }
  }

  Future<void> _updateUserInfo() async {
    String newName = _nameController.text.trim();
    String newAvatar = _avatarController.text.trim();

    if (newName.isEmpty || newAvatar.isEmpty || selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Vui lòng nhập đầy đủ thông tin!")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({
      'name': newName,
      'avatar': newAvatar,
      'role': selectedRole, // Cập nhật role
    });

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Cập nhật thành công!")),
    );
  }

  Future<void> _deleteUser() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: const Text("Bạn có chắc chắn muốn xóa người dùng này?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Hủy")),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Xóa", style: TextStyle(color: Colors.red))),
          ],
        );
      },
    );
    if (confirmDelete == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .delete();
      Navigator.pop(context);
    }
  }

  Future<void> _resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: widget.email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📩 Email đặt lại mật khẩu đã được gửi!")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi: ${error.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết thành viên"),
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteUser),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildUserInfoCard(),
              const SizedBox(height: 20),
              _buildBorrowedBooksList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                if (_isEditing) _changeAvatar();
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(_avatarController.text),
              ),
            ),
            const SizedBox(height: 10),
            Text(widget.email,
                style: const TextStyle(fontSize: 18, color: Colors.black54)),
            const SizedBox(height: 10),

            // Hiển thị tên và dropdown chọn Role
            _isEditing
                ? Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: "Tên"),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: ['admin', 'user']
                            .map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value;
                          });
                        },
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Text(_nameController.text,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Role: ${selectedRole?.toUpperCase()}",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.blueAccent)),
                    ],
                  ),

            const SizedBox(height: 20),

            // Nút Chỉnh sửa / Lưu
            ElevatedButton(
              onPressed: () {
                if (_isEditing) {
                  _updateUserInfo();
                } else {
                  setState(() => _isEditing = true);
                }
              },
              child: Text(_isEditing ? "Lưu" : "Chỉnh sửa"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _resetPassword,
              child: const Text("🔑 Đặt lại mật khẩu"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBorrowedBooksList() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("📚 Sách đã mượn",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            borrowedBooks.isEmpty
                ? const Text("📚 Chưa có sách nào được mượn",
                    style: TextStyle(fontSize: 16, color: Colors.black54))
                : Column(
                    children: borrowedBooks
                        .map((book) => _buildBookTile(book))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookTile(Map<String, dynamic> book) {
    return ListTile(
      leading: const Icon(Icons.book, color: Colors.blueAccent),
      title: Text(book['title'],
          style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailScreen(bookId: book['bookId']),
          ),
        );
      },
    );
  }

  void _changeAvatar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Thay đổi ảnh đại diện"),
          content: TextField(
            controller: _avatarController,
            decoration: const InputDecoration(hintText: "Nhập URL ảnh mới"),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy")),
            TextButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text("Xác nhận"),
            ),
          ],
        );
      },
    );
  }
}
