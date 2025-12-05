import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plantify_app/providers/user_provider.dart';
import 'package:plantify_app/database/database_helper.dart';
import 'package:plantify_app/models/tanaman_user.dart';
import 'dart:io'; // Import for File

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<TanamanUser> _tanamanUserList = [];

  @override
  void initState() {
    super.initState();
    _loadUserPlants();
  }

  Future<void> _loadUserPlants() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser != null) {
      final userId = userProvider.currentUser!.id!;
      final plants = await _databaseHelper.getTanamanUserByUserId(userId);
      setState(() {
        _tanamanUserList = plants;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.currentUser == null) {
      // Handle case where user is not logged in (e.g., navigate to login)
      // This should not happen if navigation logic is correct, but as a safeguard
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantify', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF4CAF50)),
            onPressed: () {
              // Navigate to Add Plant screen
              Navigator.pushNamed(context, '/add_plant').then((_) => _loadUserPlants()); // Reload plants after adding
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Jaga tanamanmu tetap bahagia 🌱',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _tanamanUserList.isEmpty
          ? const Center(
              child: Text(
                'Belum ada tanaman. Tambahkan tanaman pertamamu!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.8, // Adjust as needed
              ),
              itemCount: _tanamanUserList.length,
              itemBuilder: (context, index) {
                final plant = _tanamanUserList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/detail_user_tanaman', arguments: plant.id!)
                        .then((_) => _loadUserPlants()); // Reload plants after returning
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Display actual image if fotoPath is available and is a file
                        if (plant.fotoPath != null && plant.fotoPath!.startsWith('/data'))
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(
                              File(plant.fotoPath!),
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          // Fallback to asset image or icon
                          Icon(Icons.eco, size: 60, color: Theme.of(context).primaryColor),
                        const SizedBox(height: 8),
                        Text(
                          plant.namaTanaman,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plant.jadwalSiram ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50), // Primary green
        unselectedItemColor: Colors.grey,
        currentIndex: 0, // Assuming Home is the first item
        onTap: (index) {
          // Handle navigation
          switch (index) {
            case 0:
            // Already on Home
              break;
            case 1:
              Navigator.pushNamed(context, '/gallery');
              break;
            case 2:
              Navigator.pushNamed(context, '/community');
              break;
            case 3:
              Navigator.pushNamed(context, '/challenges');
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Galeri',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Komunitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Tantangan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}