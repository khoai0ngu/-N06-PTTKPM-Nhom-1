import 'package:flutter/material.dart';
import 'about_screen.dart';
import 'chatbot_screen.dart';
import 'user_book_screen.dart';
import 'person_screen.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orangeAccent, Colors.greenAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Hero(
                    tag: 'library_logo',
                    child: Image.network('https://i.imgur.com/eSseq0Y.png',
                        width: 200, height: 200),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Chào mừng đến với Thư viện',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Khám phá bộ sưu tập sách và tham gia cộng đồng của chúng tôi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 30),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildFeatureCard(
                        icon: Icons.book,
                        title: 'Sách',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserBookScreen()),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.people,
                        title: 'Cá nhân',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PersonScreen()),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.chat,
                        title: 'Chatbot',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const chatbotScreen()),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.info,
                        title: 'Về chúng tôi',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AboutScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Ưu điểm của thư viện chúng tôi:',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const ListTile(
                    leading: Icon(Icons.wifi, color: Colors.white),
                    title: Text(
                      'Truy cập vào nhiều nguồn tài nguyên khác nhau',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const ListTile(
                    leading: Icon(Icons.group_work, color: Colors.white),
                    title: Text(
                      'Không gian làm việc cộng tác',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const ListTile(
                    leading: Icon(Icons.event, color: Colors.white),
                    title: Text(
                      'Chương trình giáo dục và sự kiện cộng đồng',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.deepOrangeAccent),
              const SizedBox(height: 10),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
