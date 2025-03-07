import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen(
      {super.key, required Null Function() onResetSuccess});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  String _statusMessage = "";
  bool isLoading = false;

  /// Kiểm tra email và gửi link đặt lại mật khẩu
  Future<void> checkEmailExists() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _statusMessage = "⚠️ Vui lòng nhập email.");
      return;
    }

    setState(() {
      isLoading = true;
      _statusMessage = "";
    });

    try {
      // Thử tạo tài khoản giả với email
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: "dummy_password",
      );

      // Nếu tạo thành công => Email chưa tồn tại -> Xóa tài khoản ngay
      await userCredential.user!.delete();
      setState(() => _statusMessage = "❌ Tài khoản không tồn tại!");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Nếu email tồn tại -> Gửi email đặt lại mật khẩu
        await _auth.sendPasswordResetEmail(email: email);
        setState(
            () => _statusMessage = "✅ Email đặt lại mật khẩu đã được gửi!");

        // Chờ 3 giây rồi tự động quay về màn hình đăng nhập
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        setState(() => _statusMessage = "⚠️ Lỗi: ${e.message}");
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/forgot_password.png', height: 120),
                const SizedBox(height: 20),
                const Text(
                  "Quên Mật Khẩu?",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text("Nhập email để nhận hướng dẫn đặt lại mật khẩu",
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 30),

                // TextField nhập email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Hiển thị thông báo
                if (_statusMessage.isNotEmpty)
                  Text(
                    _statusMessage,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _statusMessage.contains("✅")
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                const SizedBox(height: 20),

                // Nút gửi yêu cầu đặt lại mật khẩu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : checkEmailExists,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Gửi Email",
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Quay lại đăng nhập",
                      style: TextStyle(fontSize: 16, color: Colors.orange)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
