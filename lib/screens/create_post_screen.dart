import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:plantify_app/providers/user_provider.dart';
import 'package:plantify_app/database/database_helper.dart';
import 'package:plantify_app/models/postingan.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  File? _imageFile;
  bool _isLoading = false;
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _createPost() async {
    if (_isLoading) return; // ignore double taps
    setState(() {
      _isLoading = true;
    });
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser == null) {
      _showSnackBar('User not logged in.', Colors.red);
      return;
    }

    if (_imageFile == null) {
      _showSnackBar('Please select an image for your post.', Colors.orange);
      return;
    }

    if (_captionController.text.isEmpty) {
      _showSnackBar('Caption cannot be empty.', Colors.orange);
      return;
    }

    final Postingan newPost = Postingan(
      userId: userProvider.currentUser!.id!,
      imageUrl: _imageFile!.path,
      caption: _captionController.text,
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      int result = await _databaseHelper.insertPostingan(newPost);

      if (result > 0) {
        if (!mounted) return;
        _showSnackBar('Postingan berhasil dibuat!', Colors.green);
        Navigator.pop(context); // Go back to Komunitas screen
      } else {
        if (!mounted) return;
        _showSnackBar('Gagal membuat postingan. Silakan coba lagi.', Colors.red);
      }
    } catch (e, st) {
      // show a helpful message for unexpected errors so user doesn't see 'no response'
      debugPrint('Error creating post: $e\n$st');
      if (mounted) {
        _showSnackBar('Terjadi kesalahan saat membuat postingan: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC8E6C9), // Soft green background
      appBar: AppBar(
        title: const Text('Buat Postingan Baru', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('Ketuk untuk memilih gambar', style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14.0),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _captionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Caption',
                hintText: 'Tulis caption Anda di sini...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _createPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50), // Green button
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
