import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_book_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _borrowedBooks = [];

  @override
  void initState() {
    super.initState();
    _fetchBorrowHistory();
  }

  void _fetchBorrowHistory() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists && userSnapshot.data() != null) {
      List<dynamic> borrowList =
          (userSnapshot.data() as Map<String, dynamic>)['borrow'] ?? [];

      List<Map<String, dynamic>> booksWithImages = [];

      for (var book in borrowList) {
        String bookId = book['bookId'];
        String borrowDate = book['borrowDate'];
        String title = book['title'];

        DocumentSnapshot bookSnapshot = await FirebaseFirestore.instance
            .collection('books')
            .doc(bookId)
            .get();

        if (bookSnapshot.exists) {
          Map<String, dynamic> bookData =
              bookSnapshot.data() as Map<String, dynamic>;
          booksWithImages.add({
            'bookId': bookId,
            'title': title,
            'borrowDate': borrowDate,
            'imageUrl': bookData['imageUrl'] ?? '',
          });
        }
      }

      setState(() {
        _borrowedBooks = booksWithImages;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch sử mượn sách")),
      body: _borrowedBooks.isEmpty
          ? const Center(
              child: Text("📚 Bạn chưa mượn sách nào!",
                  style: TextStyle(fontSize: 23)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _borrowedBooks.length,
              itemBuilder: (context, index) {
                var book = _borrowedBooks[index];
                return _buildBookCard(book);
              },
            ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  UserBookDetailScreen(bookId: book['bookId']),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildBookImage(book['imageUrl']),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book['title'] ?? 'Không có tiêu đề',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Ngày mượn: ${book['borrowDate']}",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookImage(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(imageUrl, width: 60, height: 80, fit: BoxFit.cover)
          : Container(
              width: 60,
              height: 80,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
    );
  }
}
