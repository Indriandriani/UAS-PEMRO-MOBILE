import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plantify_app/database/database_helper.dart';
import 'package:plantify_app/models/tanaman_user.dart';
import 'package:plantify_app/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io'; // Import dart:io for File
import 'package:intl/intl.dart';

class TambahTanamanScreen extends StatefulWidget {
  const TambahTanamanScreen({super.key});

  @override
  State<TambahTanamanScreen> createState() => _TambahTanamanScreenState();
}

class _TambahTanamanScreenState extends State<TambahTanamanScreen> {
  final TextEditingController _namaTanamanController = TextEditingController();
  String? _selectedJenisTanaman;
  File? _fotoFile; // Change to File? to store the image file

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  final List<String> _jenisTanamanOptions = [
    'Tropis',
    'Sub tropis',
    'Kering',
    'Stepa',
    'Sedang',
    'Dingin',
  ];

  Future<void> _saveTanaman() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser == null) {
      _showSnackBar('User not logged in.', Colors.red);
      return;
    }

    final String namaTanaman = _namaTanamanController.text;
    if (namaTanaman.isEmpty || _selectedJenisTanaman == null) {
      _showSnackBar('Nama Tanaman and Jenis Tanaman are required.', Colors.red);
      return;
    }

    final TanamanUser newPlant = TanamanUser(
      userId: userProvider.currentUser!.id!,
      namaTanaman: namaTanaman,
      jenisTanaman: _selectedJenisTanaman,
      // For simplicity, hardcode a watering schedule for now
      jadwalSiram: 'Setiap 7 hari', // Example: "Setiap 7 hari"
      terakhirDisiram: DateTime.now().toIso8601String(), // Last watered now
      fotoPath: _fotoFile?.path, // Store the actual file path
      createdAt: DateTime.now().toIso8601String(),
    );

    int result = await _databaseHelper.insertTanamanUser(newPlant);

    if (result > 0) {
      _showSnackBar('Tanaman berhasil ditambahkan!', Colors.green);
      Navigator.pop(context); // Go back to previous screen (Home)
    } else {
      _showSnackBar('Gagal menambahkan tanaman. Silakan coba lagi.', Colors.red);
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

  Future<void> _uploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _fotoFile = File(image.path);
      });
    } else {
      _showSnackBar('Tidak ada gambar yang dipilih.', Colors.orange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC8E6C9), // Soft green background
      appBar: AppBar(
        title: const Text('Tambah Tanaman'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Plant logo (similar to Login/Register)
              Image.asset(
                'assets/plant_logo.png', // Ensure this asset exists
                height: 250,
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _namaTanamanController,
                      decoration: InputDecoration(
                        labelText: 'Nama Tanaman',
                        hintText: 'Masukkan nama tanaman',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        prefixIcon: const Icon(Icons.grass),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedJenisTanaman,
                      decoration: InputDecoration(
                        labelText: 'Jenis Tanaman',
                        hintText: 'Pilih jenis tanaman',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        prefixIcon: const Icon(Icons.category),
                      ),
                      items: _jenisTanamanOptions.map((String jenis) {
                        return DropdownMenuItem<String>(
                          value: jenis,
                          child: Text(jenis),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedJenisTanaman = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    // Photo Upload (Placeholder)
                    OutlinedButton.icon(
                      onPressed: _uploadImage,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Foto Tanaman'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        side: const BorderSide(color: Color(0xFF4CAF50)),
                        foregroundColor: const Color(0xFF4CAF50),
                      ),
                    ),
                    if (_fotoFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Image.file(
                          _fotoFile!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveTanaman,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50), // Green button
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}