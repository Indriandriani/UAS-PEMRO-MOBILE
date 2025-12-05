import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate some loading and then navigate
    Future.delayed(const Duration(seconds: 3), () {
      // Navigate to Login/Register screen
      // For now, let's navigate to a dummy screen or directly to login if implemented
      Navigator.pushReplacementNamed(context, '/login'); // This path will be defined later
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Allow tapping to skip the delay if desired
          Navigator.pushReplacementNamed(context, '/login');
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFC8E6C9), Colors.white], // Soft green gradient
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Placeholder for plant logo
                Image.asset(
                  'assets/plant_logo.png', // We will add this asset later
                  height: 150,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Plantify',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32), // Dark green text
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Pendamping Perawatan Tanamanmu',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF2E7D32),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                const Text(
                  'Ketuk di mana saja untuk Melanjutkan',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2E7D32),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
