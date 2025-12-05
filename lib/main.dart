import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plantify_app/providers/user_provider.dart';
import 'package:plantify_app/screens/login_screen.dart';
import 'package:plantify_app/screens/splash_screen.dart';
import 'package:plantify_app/screens/register_screen.dart';
import 'package:plantify_app/screens/home_screen.dart';
import 'package:plantify_app/screens/tambah_tanaman_screen.dart';
import 'package:plantify_app/screens/galeri_screen.dart';
import 'package:plantify_app/screens/detail_galeri_tanaman_screen.dart';
import 'package:plantify_app/screens/komunitas_screen.dart';
import 'package:plantify_app/screens/postingan_detail_screen.dart';
import 'package:plantify_app/screens/tantangan_screen.dart';
import 'package:plantify_app/screens/detail_tantangan_screen.dart';
import 'package:plantify_app/screens/profil_screen.dart';
import 'package:plantify_app/screens/edit_profil_screen.dart';
import 'package:plantify_app/screens/detail_user_tanaman_screen.dart';
import 'package:plantify_app/screens/create_post_screen.dart'; // Import CreatePostScreen

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plantify',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
            .copyWith(background: const Color(0xFFC8E6C9)),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/add_plant': (context) => const TambahTanamanScreen(),
        '/gallery': (context) => const GaleriScreen(),
        '/detail_galeri_tanaman': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as int;
          return DetailGaleriTanamanScreen(plantId: args);
        },
        '/community': (context) => const KomunitasScreen(),
        '/post_detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as int;
          return PostinganDetailScreen(postId: args);
        },
        '/challenges': (context) => const TantanganScreen(),
        '/detail_tantangan': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as int;
          return DetailTantanganScreen(challengeId: args);
        },
        '/profile': (context) => const ProfilScreen(),
        '/edit_profile': (context) => const EditProfilScreen(),
        '/detail_user_tanaman': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as int;
          return DetailUserTanamanScreen(plantId: args);
        },
        '/create_post': (context) => const CreatePostScreen(), // Add CreatePostScreen route
        // Define other routes here later
      },
    );
  }
}