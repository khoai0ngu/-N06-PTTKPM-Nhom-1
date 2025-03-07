import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'member_detail_screen.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    String errorMessage = '';
    String selectedRole = "User"; // Giá trị mặc định

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Thêm người dùng"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(nameController, "Tên"),
                  _buildTextField(emailController, "Email"),
                  _buildTextField(passwordController, "Mật khẩu",
                      obscureText: true),
                  _buildTextField(
                      confirmPasswordController, "Xác nhận mật khẩu",
                      obscureText: true),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    items: ["Admin", "User"]
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(errorMessage,
                          style: const TextStyle(color: Colors.red)),
                    ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Hủy")),
                ElevatedButton(
                  onPressed: () async {
                    String name = nameController.text.trim();
                    String email = emailController.text.trim();
                    String password = passwordController.text.trim();
                    String confirmPassword =
                        confirmPasswordController.text.trim();

                    if (name.isEmpty ||
                        email.isEmpty ||
                        password.isEmpty ||
                        confirmPassword.isEmpty) {
                      setState(() =>
                          errorMessage = "⚠️ Vui lòng nhập đầy đủ thông tin!");
                      return;
                    }
                    if (password != confirmPassword) {
                      setState(() => errorMessage = "❌ Mật khẩu không khớp!");
                      return;
                    }

                    setState(() => _isLoading = true);

                    try {
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      User? user = userCredential.user;

                      if (user != null) {
                        String avatarUrl =
                            "https://picsum.photos/200?random=${user.uid}";

                        await _firestore.collection('users').doc(user.uid).set({
                          'name': name,
                          'email': email,
                          'avatar': avatarUrl,
                          'role': selectedRole, // Lưu role vào Firestore
                        });
                      }
                      Navigator.pop(context);
                    } catch (e) {
                      setState(() => errorMessage = "❌ Lỗi: ${e.toString()}");
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  },
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Thêm"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        obscureText: obscureText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý người dùng"),
        actions: [
          IconButton(
              icon: const Icon(Icons.add), onPressed: _showAddUserDialog),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          var users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              String name = user['name'];
              String email = user['email'];
              String avatarUrl = user['avatar'];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 300),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          FadeTransition(
                        opacity: animation,
                        child: MemberDetailScreen(
                          userId: user.id,
                          name: name,
                          email: email,
                          avatar: avatarUrl,
                        ),
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                        radius: 30, backgroundImage: NetworkImage(avatarUrl)),
                    title: Text(name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text(email,
                        style: const TextStyle(color: Colors.black54)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
