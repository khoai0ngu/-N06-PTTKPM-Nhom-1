import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  final bool showBackButton;

  const AboutScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : null,
        title: const Text(
          'Về chúng tôi',
          style: TextStyle(
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Image.network(
                      'https://i.imgur.com/eSseq0Y.png',
                      height: 150,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ứng dụng quản lý thư viện này được tạo ra để giúp quản lý sách và thành viên dễ dàng hơn.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    const ListTile(
                      leading: Icon(Icons.book, color: Colors.orangeAccent),
                      title: Text(
                        'Quản lý sách',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Thêm, chỉnh sửa và xóa sách dễ dàng.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const ListTile(
                      leading: Icon(Icons.people, color: Colors.orangeAccent),
                      title: Text(
                        'Quản lý thành viên',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Quản lý tư cách thành viên và thông tin thành viên.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const ListTile(
                      leading: Icon(Icons.chat, color: Colors.orangeAccent),
                      title: Text(
                        'Chatbot thông minh',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Sử dụng chatbot của chúng tôi để được trợ giúp nhanh chóng.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
