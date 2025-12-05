import 'package:flutter/material.dart';
import 'package:plantify_app/database/database_helper.dart';
import 'package:plantify_app/models/tanaman_user.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:plantify_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class DetailUserTanamanScreen extends StatefulWidget {
  final int plantId;

  const DetailUserTanamanScreen({super.key, required this.plantId});

  @override
  State<DetailUserTanamanScreen> createState() => _DetailUserTanamanScreenState();
}

class _DetailUserTanamanScreenState extends State<DetailUserTanamanScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  TanamanUser? _plant;

  @override
  void initState() {
    super.initState();
    _loadPlantDetails();
  }

  Future<void> _loadPlantDetails() async {
    final plant = await _databaseHelper.getTanamanUserById(widget.plantId);
    setState(() {
      _plant = plant;
    });
  }

  Future<void> _waterPlant() async {
    if (_plant == null) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    if (user == null) return;

    final updatedPlant = _plant!.copyWith(
      terakhirDisiram: DateTime.now().toIso8601String(),
    );

    int result = await _databaseHelper.updateTanamanUser(updatedPlant);

    if (result > 0) {
      await _databaseHelper.addWateringLog(user.id!, _plant!.id!);
      _showSnackBar('Tanaman berhasil disiram!', Colors.green);
      _loadPlantDetails(); // Reload details to update UI
    } else {
      _showSnackBar('Gagal menyiram tanaman. Silakan coba lagi.', Colors.red);
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

  // Helper to calculate next watering date based on watering schedule
  String _getNextWateringInfo(String? lastWateredDate, String? wateringSchedule) {
    if (lastWateredDate == null || wateringSchedule == null) return 'N/A';

    try {
      // Example: "Setiap 7 hari"
      final parts = wateringSchedule.split(' ');
      if (parts.length < 2) return 'N/A';
      final intervalDays = int.parse(parts[1]);

      final lastWatered = DateTime.parse(lastWateredDate);
      DateTime nextWatering = lastWatered.add(Duration(days: intervalDays));

      final today = DateTime.now();
      final difference = nextWatering.difference(today);

      if (difference.isNegative) {
        return 'Terlewat ${difference.inDays.abs()} hari';
      } else if (difference.inDays == 0) {
        return 'Hari ini';
      } else {
        return 'Dalam ${difference.inDays + 1} hari';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_plant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Tanaman Saya')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFC8E6C9), // Soft green background
      appBar: AppBar(
        title: Text(_plant!.namaTanaman, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Plant Image/Icon
            if (_plant!.fotoPath != null && _plant!.fotoPath!.startsWith('/data')) // Check if it's a file path
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.file(
                  File(_plant!.fotoPath!),
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              )
            else
              // Fallback to asset image or icon
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(
                  _plant!.fotoPath ?? 'assets/placeholder_plant.png', // Fallback to placeholder if path is null or not a file
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              _plant!.namaTanaman,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _plant!.jenisTanaman ?? 'Jenis tidak diketahui',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            // Info Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jadwal Penyiraman:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _plant!.jadwalSiram ?? 'Tidak Ada',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const Divider(height: 30),
                    Text(
                      'Terakhir Disiram:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _plant!.terakhirDisiram != null &&
                              DateFormat('dd/MM/yyyy').format(DateTime.parse(_plant!.terakhirDisiram!)) ==
                                  DateFormat('dd/MM/yyyy').format(DateTime.now())
                          ? 'Sudah Disiram Hari Ini!'
                          : _plant!.terakhirDisiram != null
                              ? DateFormat('dd/MM/yyyy').format(DateTime.parse(_plant!.terakhirDisiram!))
                              : 'Belum pernah',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const Divider(height: 30),
                    Text(
                      'Penyiraman Berikutnya:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _getNextWateringInfo(_plant!.terakhirDisiram, _plant!.jadwalSiram),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _waterPlant,
                icon: const Icon(Icons.water_drop, color: Colors.white),
                label: const Text(
                  'Siram Tanaman',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // Green button
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
extension on TanamanUser {
  TanamanUser copyWith({
    int? id,
    int? userId,
    String? namaTanaman,
    String? jenisTanaman,
    String? jadwalSiram,
    String? terakhirDisiram,
    String? fotoPath,
    String? createdAt,
  }) {
    return TanamanUser(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      namaTanaman: namaTanaman ?? this.namaTanaman,
      jenisTanaman: jenisTanaman ?? this.jenisTanaman,
      jadwalSiram: jadwalSiram ?? this.jadwalSiram,
      terakhirDisiram: terakhirDisiram ?? this.terakhirDisiram,
      fotoPath: fotoPath ?? this.fotoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
