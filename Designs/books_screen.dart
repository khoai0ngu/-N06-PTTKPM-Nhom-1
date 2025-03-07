import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'book_detail_screen.dart';

class BookScreen extends StatefulWidget {
  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  void _addBook() {
    final _formKey = GlobalKey<FormState>();
    final Map<String, TextEditingController> controllers = {
      'title': TextEditingController(),
      'author': TextEditingController(),
      'language': TextEditingController(),
      'publicationInfo': TextEditingController(),
      'edition': TextEditingController(),
      'physicalDesc': TextEditingController(),
      'subject': TextEditingController(),
      'documentType': TextEditingController(),
      'imageUrl': TextEditingController(),
      'copies': TextEditingController(),
      'summary': TextEditingController(), // Thêm tóm tắt sách
    };
    double rating = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Thêm Sách Mới',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...controllers.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: TextFormField(
                        controller: entry.value,
                        decoration: InputDecoration(
                          labelText: entry.key == 'summary'
                              ? 'Tóm tắt sách'
                              : entry.key,
                          border: OutlineInputBorder(),
                        ),
                        maxLines: entry.key == 'summary'
                            ? 3
                            : 1, // Tóm tắt sách có nhiều dòng
                        validator: (value) => value == null || value.isEmpty
                            ? 'Không được để trống'
                            : null,
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 10),
                  Text("Đánh giá:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 30.0,
                    itemBuilder: (context, _) =>
                        Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (newRating) => rating = newRating,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  FirebaseFirestore.instance.collection('books').add({
                    'title': controllers['title']!.text,
                    'author': controllers['author']!.text,
                    'language': controllers['language']!.text,
                    'publicationInfo': controllers['publicationInfo']!.text,
                    'edition': controllers['edition']!.text,
                    'physicalDesc': controllers['physicalDesc']!.text,
                    'subject': controllers['subject']!.text,
                    'documentType': controllers['documentType']!.text,
                    'imageUrl': controllers['imageUrl']!.text,
                    'copies': int.tryParse(controllers['copies']!.text) ?? 1,
                    'summary': controllers['summary']!.text, // Lưu tóm tắt
                    'rating': rating,
                  }).then((_) => Navigator.of(context).pop());
                }
              },
              child: Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Quản Lý Sách', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _addBook),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sách...',
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                }
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          var books = snapshot.data!.docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return data['title'].toLowerCase().contains(searchQuery) ||
                data['author'].toLowerCase().contains(searchQuery);
          }).toList();

          return GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Hiển thị 2 cột
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              var book = books[index];
              var data = book.data() as Map<String, dynamic>;

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => BookDetailScreen(bookId: book.id)),
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Hero(
                          tag: book.id,
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(10)),
                            child: Image.network(
                              data['imageUrl'],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.image_not_supported, size: 80),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(data['title'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            SizedBox(height: 5),
                            Text('Tác giả: ${data['author']}',
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            SizedBox(height: 5),
                            RatingBarIndicator(
                              rating: (data['rating'] ?? 0.0).toDouble(),
                              itemBuilder: (context, _) =>
                                  Icon(Icons.star, color: Colors.amber),
                              itemCount: 5,
                              itemSize: 18.0,
                            ),
                          ],
                        ),
                      ),
                    ],
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
