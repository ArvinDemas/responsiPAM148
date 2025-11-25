import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  void _register() async {
    if (_userController.text.isEmpty || _passController.text.isEmpty) return;

    try {
      await DatabaseHelper.instance.register(_userController.text, _passController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Register Berhasil! Silakan Login'), backgroundColor: Colors.green)
        );
        Navigator.pop(context); // Kembali ke Login
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username sudah ada'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _userController, decoration: const InputDecoration(labelText: 'Username Baru', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: 'Password Baru', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF546EE5)),
                child: const Text('DAFTAR', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}