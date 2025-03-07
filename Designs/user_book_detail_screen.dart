import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Thêm thư viện để định dạng thời gian

class UserBookDetailScreen extends StatefulWidget {
  final String bookId;

  const UserBookDetailScreen({Key? key, required this.bookId})
      : super(key: key);

  @override
  _UserBookDetailScreenState createState() => _UserBookDetailScreenState();
}

class _UserBookDetailScreenState extends State<UserBookDetailScreen> {
  final Map<String, TextEditingController> _controllers = {};
  double _rating = 3.0;
  bool _hasBorrowed = false;
  @override
  void initState() {
    super.initState();
    _fetchBookData();
  }

  void _fetchBookData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('books')
        .doc(widget.bookId)
        .get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        _controllers['title'] = TextEditingController(text: data['title']);
        _controllers['author'] = TextEditingController(text: data['author']);
        _controllers['language'] =
            TextEditingController(text: data['language']);
        _controllers['publicationInfo'] =
            TextEditingController(text: data['publicationInfo']);
        _controllers['edition'] = TextEditingController(text: data['edition']);
        _controllers['physicalDesc'] =
            TextEditingController(text: data['physicalDesc']);
        _controllers['subject'] = TextEditingController(text: data['subject']);
        _controllers['documentType'] =
            TextEditingController(text: data['documentType']);
        _controllers['imageUrl'] =
            TextEditingController(text: data['imageUrl']);
        _controllers['copies'] =
            TextEditingController(text: data['copies'].toString());
        _controllers['summary'] =
            TextEditingController(text: data['summary'] ?? "");
        _rating = (data['rating'] ?? 3.0).toDouble();
      });
    }

    // Kiểm tra xem người dùng có mượn sách này không
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        List<dynamic> borrowedBooks = List.from(
            (userSnapshot.data() as Map<String, dynamic>)['borrow'] ?? []);

        setState(() {
          _hasBorrowed =
              borrowedBooks.any((book) => book['bookId'] == widget.bookId);
        });
      }
    }
  }

  void _borrowBook() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    // Lấy thông tin người dùng từ Firestore
    DocumentSnapshot userSnapshot = await userRef.get();
    List<dynamic> borrowedBooks = [];

    if (userSnapshot.exists && userSnapshot.data() != null) {
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      borrowedBooks = List.from(userData['borrow'] ?? []);
    }

    // Kiểm tra xem sách đã được mượn chưa
    bool alreadyBorrowed =
        borrowedBooks.any((book) => book['bookId'] == widget.bookId);

    if (alreadyBorrowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Bạn đã mượn sách này rồi!")),
      );
      return;
    }

    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận mượn sách"),
        content: const Text("Bạn có chắc chắn muốn mượn sách này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Mượn", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      DocumentReference bookRef =
          FirebaseFirestore.instance.collection('books').doc(widget.bookId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot bookSnapshot = await transaction.get(bookRef);
        if (bookSnapshot.exists) {
          int currentCopies = bookSnapshot['copies'] ?? 0;

          if (currentCopies > 0) {
            transaction.update(bookRef, {'copies': currentCopies - 1});

            // Lấy thời gian hiện tại và format theo "HH:mm dd/MM/yyyy"
            String borrowDate =
                DateFormat('HH:mm dd/MM/yyyy').format(DateTime.now());

            // Cập nhật danh sách sách đã mượn của user
            transaction.update(userRef, {
              'borrow': FieldValue.arrayUnion([
                {
                  'bookId': widget.bookId,
                  'title': _controllers['title']!.text,
                  'borrowDate': borrowDate, // Thêm thời gian mượn sách
                }
              ])
            });

            setState(() {
              _controllers['copies']!.text = (currentCopies - 1).toString();
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("📚 Đã mượn sách thành công!")),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("⚠️ Sách này đã hết!")),
            );
          }
        }
      });

      _fetchBookData();
    }
  }

  void _returnBook() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    DocumentReference bookRef =
        FirebaseFirestore.instance.collection('books').doc(widget.bookId);

    // Lấy danh sách sách đã mượn của người dùng
    DocumentSnapshot userSnapshot = await userRef.get();
    List<dynamic> borrowedBooks = [];

    if (userSnapshot.exists && userSnapshot.data() != null) {
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      borrowedBooks = List.from(userData['borrow'] ?? []);
    }

    // Kiểm tra xem sách này có trong danh sách mượn không
    bool hasBorrowed =
        borrowedBooks.any((book) => book['bookId'] == widget.bookId);

    if (!hasBorrowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Bạn chưa mượn sách này!")),
      );
      return;
    }

    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận trả sách"),
        content: const Text("Bạn có chắc chắn muốn trả sách này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Trả sách", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot bookSnapshot = await transaction.get(bookRef);
        if (bookSnapshot.exists) {
          int currentCopies = bookSnapshot['copies'] ?? 0;
          transaction.update(bookRef, {'copies': currentCopies + 1});

          // Xóa sách khỏi danh sách borrow của người dùng
          transaction.update(userRef, {
            'borrow': FieldValue.arrayRemove([
              {
                'bookId': widget.bookId,
                'title': _controllers['title']!.text,
                'borrowDate': borrowedBooks.firstWhere(
                    (book) => book['bookId'] == widget.bookId)['borrowDate'],
              }
            ])
          });

          setState(() {
            _controllers['copies']!.text = (currentCopies + 1).toString();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Trả sách thành công!")),
          );
        }
      });

      _fetchBookData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chi tiết sách")),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: _buildPreview(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.book, color: Colors.white),
                    label: const Text("Mượn sách",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _borrowBook,
                  ),
                ),
                const SizedBox(width: 10), // Khoảng cách giữa hai nút
                if (_hasBorrowed)
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.assignment_return,
                          color: Colors.white),
                      label: const Text("Trả sách",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _returnBook,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookImage(),
            ..._buildDetailList(),
            const SizedBox(height: 10),
            _buildRating(readOnly: true),
          ],
        ),
      ),
    );
  }

  Widget _buildBookImage() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _controllers['imageUrl']?.text.isNotEmpty == true
            ? Image.network(_controllers['imageUrl']!.text, height: 200)
            : const Icon(Icons.image_not_supported, size: 100),
      ),
    );
  }

  List<Widget> _buildDetailList() {
    return [
      _buildDetailTile(Icons.book, "Tiêu đề", _controllers['title']?.text),
      _buildDetailTile(Icons.person, "Tác giả", _controllers['author']?.text),
      _buildDetailTile(
          Icons.language, "Ngôn ngữ", _controllers['language']?.text),
      _buildDetailTile(Icons.apartment, "Thông tin xuất bản",
          _controllers['publicationInfo']?.text),
      _buildDetailTile(Icons.edit, "Phiên bản", _controllers['edition']?.text),
      _buildDetailTile(Icons.description, "Mô tả vật lý",
          _controllers['physicalDesc']?.text),
      _buildDetailTile(Icons.label, "Chủ đề", _controllers['subject']?.text),
      _buildDetailTile(
          Icons.category, "Loại tài liệu", _controllers['documentType']?.text),
      _buildDetailTile(
          Icons.inventory, "Số lượng", _controllers['copies']?.text),
      _buildExpandableDetailTile(
          Icons.notes, "Tóm tắt", _controllers['summary']?.text),
    ];
  }

  Widget _buildExpandableDetailTile(
      IconData icon, String label, String? value) {
    return ExpansionTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(value?.isNotEmpty == true ? value! : 'Không có dữ liệu'),
        ),
      ],
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String? value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value?.isNotEmpty == true ? value! : 'Không có dữ liệu'),
    );
  }

  Widget _buildRating({required bool readOnly}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("⭐ Đánh giá:", style: TextStyle(fontSize: 16)),
        RatingBar.builder(
          initialRating: _rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 30.0,
          itemBuilder: (context, _) =>
              const Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: (rating) {},
          ignoreGestures: true,
        ),
      ],
    );
  }
}
