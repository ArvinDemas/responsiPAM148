import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_helper.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  void _login() async {
    String user = _userController.text;
    String pass = _passController.text;

    if (user.isEmpty || pass.isEmpty) return;

    bool isValid = await DatabaseHelper.instance.login(user, pass);

    if (isValid) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLogin', true);
      await prefs.setString('username', user);

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Gagal')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("LOGIN MOVIE", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(controller: _userController, decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF546EE5)),
                child: const Text('MASUK', style: TextStyle(color: Colors.white)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
              child: const Text("Belum punya akun? Register"),
            )
          ],
        ),
      ),
    );
  }
}