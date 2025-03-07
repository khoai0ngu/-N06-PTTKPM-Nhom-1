import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool passwordVisible = false;
  String errorMessage = '';
  String successMessage = '';
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc['name'] ?? '';
        });
      }
    } catch (e) {
      setState(() => errorMessage = "❌ Lỗi khi lấy dữ liệu từ Firestore!");
    }
  }

  Future<void> _updateName() async {
    String newName = _nameController.text.trim();
    if (newName.isEmpty) {
      setState(() => errorMessage = "⚠️ Tên không được để trống!");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'name': newName});
      setState(() {
        successMessage = "✅ Cập nhật tên thành công!";
        errorMessage = '';
      });
    } catch (e) {
      setState(() {
        errorMessage = "❌ Lỗi khi cập nhật tên!";
        successMessage = '';
      });
    }
  }

  Future<void> _changePassword() async {
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() => errorMessage = "⚠️ Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    if (newPassword.length < 6) {
      setState(() => errorMessage = "❌ Mật khẩu phải có ít nhất 6 ký tự!");
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() => errorMessage = "❌ Mật khẩu xác nhận không khớp!");
      return;
    }

    try {
      await user?.updatePassword(newPassword);
      setState(() {
        successMessage = "✅ Đổi mật khẩu thành công!";
        errorMessage = '';
      });
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      setState(() {
        errorMessage = "❌ Lỗi khi đổi mật khẩu. Hãy đăng nhập lại!";
        successMessage = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, // Màu nền trắng
        elevation: 0, // Xóa bóng
        title: const Text(
          "Tài khoản",
          style: TextStyle(
            color: Colors.orange, // Màu cam
            fontWeight: FontWeight.bold, // Chữ đậm
          ),
        ),
      ),
      body: Column(
        children: [
          // Thêm Divider ngay dưới AppBar
          const Divider(height: 1, thickness: 2, color: Colors.grey),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Cập nhật thông tin",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Tên hiển thị",
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateName,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Cập nhật tên",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  const Divider(height: 30, thickness: 2),
                  const Text(
                    "Thay đổi mật khẩu",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: !passwordVisible,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu mới",
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () =>
                            setState(() => passwordVisible = !passwordVisible),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: !passwordVisible,
                    decoration: InputDecoration(
                      labelText: "Xác nhận mật khẩu mới",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () =>
                            setState(() => passwordVisible = !passwordVisible),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Đổi mật khẩu",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (successMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        successMessage,
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
