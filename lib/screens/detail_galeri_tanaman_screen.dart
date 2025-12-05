import 'package:flutter/material.dart';
import 'package:plantify_app/database/database_helper.dart';
import 'package:plantify_app/models/galeri_tanaman.dart';
import 'package:intl/intl.dart';

class DetailGaleriTanamanScreen extends StatefulWidget {
  final int plantId;

  const DetailGaleriTanamanScreen({super.key, required this.plantId});

  @override
  State<DetailGaleriTanamanScreen> createState() => _DetailGaleriTanamanScreenState();
}

class _DetailGaleriTanamanScreenState extends State<DetailGaleriTanamanScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  GaleriTanaman? _plant;

  @override
  void initState() {
    super.initState();
    _loadPlantDetails();
  }

  Future<void> _loadPlantDetails() async {
    final plant = await _databaseHelper.getGaleriTanamanById(widget.plantId);
    setState(() {
      _plant = plant;
    });
  }

  // Helper to calculate next watering date based on a simple hardcoded schedule
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
        appBar: AppBar(title: const Text('Detail Tanaman')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // For GaleriTanaman, we are using its status_disiram and a dummy date for calculation
    // In a real app, this would be more complex for user's actual plants
    const String dummyLastWatered = "2025-10-14T10:00:00.000"; // Example ISO format date

    return Scaffold(
      backgroundColor: const Color(0xFFC8E6C9), // Soft green background
      appBar: AppBar(
        title: Text(_plant!.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Large plant icon
            Icon(Icons.spa, size: 120, color: Theme.of(context).primaryColor),
            const SizedBox(height: 20),
            Text(
              _plant!.nama,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _plant!.kategori ?? 'Kategori tidak diketahui',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            // "Sudah Disiram" checklist display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _plant!.statusDisiram == 'Sudah Disiram' ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _plant!.statusDisiram == 'Sudah Disiram' ? Icons.check_circle : Icons.warning,
                    color: _plant!.statusDisiram == 'Sudah Disiram' ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _plant!.statusDisiram ?? 'Status tidak diketahui',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _plant!.statusDisiram == 'Sudah Disiram' ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                ],
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
                      'Setiap 7 hari', // Hardcoded as per spec for GaleriTanaman
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
                      DateFormat('dd/MM/yyyy').format(DateTime.parse(dummyLastWatered)),
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
                      _getNextWateringInfo(dummyLastWatered, 'Setiap 7 hari'),
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
            const SizedBox(height: 20),
            Text(
              _plant!.deskripsi ?? 'Tidak ada deskripsi tersedia.',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}