import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plantify_app/database/database_helper.dart';
import 'package:plantify_app/models/user.dart';
import 'package:plantify_app/providers/user_provider.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    _currentUser = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (_currentUser != null) {
      _usernameController.text = _currentUser!.username;
      _emailController.text = _currentUser!.email;
      _passwordController.text = _currentUser!.password; // Pre-fill with current password
    }
  }

  Future<void> _updateProfile() async {
    if (_currentUser == null) {
      _showSnackBar('User not logged in.', Colors.red);
      return;
    }

    final String newUsername = _usernameController.text;
    final String newEmail = _emailController.text;
    final String newPassword = _passwordController.text;

    if (newUsername.isEmpty || newEmail.isEmpty || newPassword.isEmpty) {
      _showSnackBar('All fields must be filled.', Colors.red);
      return;
    }

    // Check if new email already exists and is different from current user's email
    if (newEmail != _currentUser!.email) {
      User? existingUser = await _databaseHelper.getUserByEmail(newEmail);
      if (existingUser != null && existingUser.id != _currentUser!.id) {
        _showSnackBar('Email already taken by another user.', Colors.red);
        return;
      }
    }

    final updatedUser = User(
      id: _currentUser!.id,
      username: newUsername,
      email: newEmail,
      password: newPassword,
      hariBeruntun: _currentUser!.hariBeruntun,
      totalLencana: _currentUser!.totalLencana,
      createdAt: _currentUser!.createdAt,
    );

    int result = await _databaseHelper.updateUser(updatedUser);

    if (result > 0) {
      Provider.of<UserProvider>(context, listen: false).setUser(updatedUser);
      _showSnackBar('Profil berhasil diperbarui!', Colors.green);
      Navigator.pop(context); // Go back to profile screen
    } else {
      _showSnackBar('Gagal memperbarui profil. Silakan coba lagi.', Colors.red);
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
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Plant logo
              Image.asset(
                'assets/plant_logo.png', // Ensure this asset exists
                height: 100,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MY PROFILE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: 'Enter your username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Kata sandi',
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateProfile,
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