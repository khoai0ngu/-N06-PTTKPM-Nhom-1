import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard.dart';
import 'register_screen.dart';
import 'reset_password_screen.dart';
import 'user_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool passwordVisible = false;
  bool isLoading = false;
  String errorMessage = '';

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = "⚠️ Vui lòng nhập đầy đủ email và mật khẩu!";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Lấy role từ Firestore
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          String role = userDoc['role'] ?? 'user';

          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const MyHomePage()), // Màn hình admin
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => UserDashBoard()), // Màn hình user
            );
          }
        } else {
          setState(() {
            errorMessage = "⚠️ Không tìm thấy thông tin tài khoản!";
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = "❌ Đăng nhập thất bại: ${e.message}";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network('https://i.imgur.com/eSseq0Y.png', height: 150),
                const SizedBox(height: 20),
                const Text(
                  "Chào mừng đến với Thư viện",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange),
                ),
                const SizedBox(height: 10),
                const Text("Vui lòng đăng nhập để tiếp tục",
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 30),

                // Email input
                TextField(
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                // Password input
                TextField(
                  controller: _passwordController,
                  obscureText: !passwordVisible,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    labelText: "Mật khẩu",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() => passwordVisible = !passwordVisible);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Hiển thị lỗi
                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 20),

                // Button Login
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("🔑 Đăng Nhập",
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),

                // Go to Register
                TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterScreen())),
                  child: const Text("📌 Chưa có tài khoản? Đăng ký ngay"),
                ),

                // Forgot Password (Tự động quay lại màn hình đăng nhập sau khi đặt lại mật khẩu)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ResetPasswordScreen(
                                onResetSuccess: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "✅ Kiểm tra email để đặt lại mật khẩu!")),
                                  );
                                  Navigator.pop(
                                      context); // Quay lại màn hình đăng nhập
                                },
                              )),
                    );
                  },
                  child: const Text("🔒 Quên mật khẩu?"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
