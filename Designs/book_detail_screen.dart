import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({Key? key, required this.bookId}) : super(key: key);

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isEditing = false;
  double _rating = 3.0;

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
  }

  void _toggleEditMode() {
    setState(() => _isEditing = !_isEditing);
  }

  void _saveBookData() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.bookId)
          .update({
        'title': _controllers['title']!.text,
        'author': _controllers['author']!.text,
        'language': _controllers['language']!.text,
        'publicationInfo': _controllers['publicationInfo']!.text,
        'edition': _controllers['edition']!.text,
        'physicalDesc': _controllers['physicalDesc']!.text,
        'subject': _controllers['subject']!.text,
        'documentType': _controllers['documentType']!.text,
        'imageUrl': _controllers['imageUrl']!.text,
        'copies': int.tryParse(_controllers['copies']!.text) ?? 0,
        'rating': _rating,
      });
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật thành công!")),
      );
    }
  }

  void _deleteBook() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa sách này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.bookId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xóa sách thành công!")),
      );

      Navigator.pop(context); // Quay lại màn hình trước
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết sách"),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveBookData : _toggleEditMode,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: _isEditing ? _buildEditForm() : _buildPreview(),
              ),
            ),
          ),
          Visibility(
            visible: _isEditing, // Chỉ hiển thị khi chế độ chỉnh sửa bật
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text("Xóa sách",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _deleteBook,
              ),
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

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children:
            _controllers.keys.map((key) => _buildTextField(key)).toList() +
                [
                  _buildRating(readOnly: false),
                ],
      ),
    );
  }

  Widget _buildTextField(String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: _controllers[key],
        decoration:
            InputDecoration(labelText: key, border: const OutlineInputBorder()),
        validator: (value) =>
            value == null || value.isEmpty ? "Không được để trống" : null,
      ),
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
          onRatingUpdate: readOnly
              ? (rating) {}
              : (rating) => setState(() => _rating = rating),
          ignoreGestures: readOnly, // Không cho phép chỉnh sửa khi là preview
        ),
      ],
    );
  }
}
