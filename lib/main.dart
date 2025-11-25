import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Responsi Movie App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D), // Hitam Pekat sesuai desain
        primaryColor: const Color(0xFF546EE5),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Manrope'), // Simulasi font Manrope
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // Transparan agar menyatu dengan background
          elevation: 0,
        ),
      ),
      home: const SplashCheck(),
    );
  }
}

class SplashCheck extends StatefulWidget {
  const SplashCheck({super.key});
  @override
  State<SplashCheck> createState() => _SplashCheckState();
}

class _SplashCheckState extends State<SplashCheck> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLogin = prefs.getBool('isLogin') ?? false;
    await Future.delayed(const Duration(seconds: 1)); 

    if (mounted) {
      if (isLogin) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}