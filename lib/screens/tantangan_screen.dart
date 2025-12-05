import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plantify_app/database/database_helper.dart';
import 'package:plantify_app/models/tantangan.dart';
import 'package:plantify_app/providers/user_provider.dart';

class TantanganScreen extends StatefulWidget {
  const TantanganScreen({super.key});

  @override
  State<TantanganScreen> createState() => _TantanganScreenState();
}

class _TantanganScreenState extends State<TantanganScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Tantangan> _userChallenges = [];

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser == null) return;
    
    final userId = userProvider.currentUser!.id!;
    await _databaseHelper.checkAndResetChallenges(userId);
    
    final challenges = await _databaseHelper.getTantanganByUserId(userId);
    
    for (var challenge in challenges) {
      int progress = 0;
      if (challenge.namaTantangan == 'Tantangan Hijau 20 Hari') {
        progress = await _databaseHelper.getWateringChallengeProgress(userId);
      } else if (challenge.namaTantangan == 'Orang Tua Tanaman Pro') {
        progress = await _databaseHelper.getPlantChallengeProgress(userId);
      } else if (challenge.namaTantangan == 'Penolong Komunitas') {
        progress = await _databaseHelper.getCommunityChallengeProgress(userId);
      }
      challenge.progressSaatIni = progress;
      await _databaseHelper.updateTantangan(challenge);
    }

    final updatedChallenges = await _databaseHelper.getTantanganByUserId(userId);

    setState(() {
      _userChallenges = updatedChallenges;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tantangan', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: const Color(0xFF4CAF50),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Selesaikan tantangan 🏆',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              color: const Color(0xFFE8F5E9), // Light green background
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, size: 40, color: Colors.amber),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Tantangan Bulanan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          Text(
                            'Selesaikan untuk dapatkan lencana!',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        Icon(Icons.star_half, color: Colors.amber, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tantangan Aktif',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _userChallenges.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada tantangan aktif saat ini.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _userChallenges.length,
                    itemBuilder: (context, index) {
                      final challenge = _userChallenges[index];
                      double progress = challenge.target > 0 ? (challenge.progressSaatIni / challenge.target) : 0;
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/detail_tantangan', arguments: challenge.id);
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      challenge.icon ?? '🏆',
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        challenge.namaTantangan,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${challenge.progressSaatIni}/${challenge.target}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4CAF50),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  challenge.deskripsi ?? '',
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 12),
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey.shade300,
                                  color: const Color(0xFF4CAF50),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    '${challenge.totalPeserta} peserta',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50), // Primary green
        unselectedItemColor: Colors.grey,
        currentIndex: 3, // Tantangan is the fourth item (index 3)
        onTap: (index) {
          // Handle navigation
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
            // Already on Tantangan
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/profile');
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