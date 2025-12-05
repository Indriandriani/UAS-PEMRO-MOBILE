import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plantify_app/database/database_helper.dart';
import 'package:plantify_app/providers/user_provider.dart';
import 'package:plantify_app/models/user.dart';
import 'package:plantify_app/models/lencana.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  User? _currentUser;
  int _totalPlants = 0;
  List<Lencana> _userBadges = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _currentUser = userProvider.currentUser;
    });

    if (_currentUser != null) {
      // Load total plants
      final plants = await _databaseHelper.getTanamanUserByUserId(_currentUser!.id!);
      setState(() {
        _totalPlants = plants.length;
      });

      // Load user badges
      final badges = await _databaseHelper.getLencanaByUserId(_currentUser!.id!);
      setState(() {
        _userBadges = badges;
      });
    }
  }

  Future<void> _logout() async {
    Provider.of<UserProvider>(context, listen: false).clearUser();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: const Color(0xFF4CAF50),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Perjalanan tanamanmu 🌱',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFFC8E6C9),
              child: Icon(Icons.person_4, size: 80, color: Color(0xFF4CAF50)),
            ),
            const SizedBox(height: 16),
            Text(
              _currentUser?.username ?? 'Pecinta Tanaman',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Penggemar Tanaman 🌱',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            // Stats Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Total Tanaman', _totalPlants.toString()),
                    _buildStatItem('Hari Beruntun', _currentUser?.hariBeruntun.toString() ?? '0'),
                    _buildStatItem('Lencana', _userBadges.length.toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Lencana Saya',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _userBadges.isEmpty
                ? const Text('Belum ada lencana.', style: TextStyle(color: Colors.grey))
                : Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _userBadges.map((badge) => _buildBadge(badge)).toList(),
                  ),
            const SizedBox(height: 30),
            // Menu List
            _buildMenuItem(context, Icons.settings, 'Edit Profil', '/edit_profile'),
            _buildMenuItem(context, Icons.notifications, 'Notifikasi', '/notifications'), // Placeholder
            _buildMenuItem(context, Icons.emoji_events, 'Pencapaian', '/achievements'), // Placeholder
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B9D), // Pink color
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
                child: const Text(
                  'Keluar',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50), // Primary green
        unselectedItemColor: Colors.grey,
        currentIndex: 4, // Profil is the fifth item (index 4)
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/gallery');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/community');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/challenges');
              break;
            case 4:
            // Already on Profil
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

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildBadge(Lencana lencana) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(lencana.icon ?? '✨', style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(height: 4),
        Text(
          lencana.namaLencana,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String route) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4CAF50)),
        title: Text(title, style: const TextStyle(color: Color(0xFF2E7D32))),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }
}