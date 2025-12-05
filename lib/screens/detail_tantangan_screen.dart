import 'package:flutter/material.dart';
import 'package:plantify_app/database/database_helper.dart';
import 'package:plantify_app/models/tantangan.dart';

class DetailTantanganScreen extends StatefulWidget {
  final int challengeId;

  const DetailTantanganScreen({super.key, required this.challengeId});

  @override
  State<DetailTantanganScreen> createState() => _DetailTantanganScreenState();
}

class _DetailTantanganScreenState extends State<DetailTantanganScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  Tantangan? _challenge;

  @override
  void initState() {
    super.initState();
    _loadChallengeDetails();
  }

  Future<void> _loadChallengeDetails() async {
    final challenge = await _databaseHelper.getTantanganById(widget.challengeId);
    setState(() {
      _challenge = challenge;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_challenge == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Tantangan')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    double progress = _challenge!.target > 0 ? (_challenge!.progressSaatIni / _challenge!.target) : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFC8E6C9), // Soft green background
      appBar: AppBar(
        title: const Text('Tantangan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      _challenge!.icon ?? '🏆',
                      style: const TextStyle(fontSize: 60),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _challenge!.namaTantangan,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _challenge!.deskripsi ?? '',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade300,
                      color: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Progress: ${_challenge!.progressSaatIni}/${_challenge!.target}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.badge, color: Colors.orange, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Lencana Pro', // Hardcoded badge name
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_challenge!.totalPeserta} Total Peserta',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Aktivitas Terkini',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityItem('Pengguna 1', 'Menyelesaikan hari ke-3'),
            _buildActivityItem('Pengguna 2', 'Menyelesaikan hari ke-2'),
            _buildActivityItem('Pengguna 3', 'Menyelesaikan hari ke-1'),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String userName, String activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.person_outline, color: Color(0xFF4CAF50)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  Text(
                    activity,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
          ],
        ),
      ),
    );
  }
}