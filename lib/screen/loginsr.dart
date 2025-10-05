import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/myhome.dart';
import 'package:flutter_application_1/screen/forgotpasswordsr.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _secureStorage = const FlutterSecureStorage();
  bool _isLoading = false;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    print("Logging in with:");
    print("Email: $email");
    print("Password: $password");

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:3000/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"]) {
          print("Login successful!");
          final int userId = data["user"]["id"];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt("userId", userId);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHome()),
          );
        } else {
          print("Login failed: ${data["message"]}");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(data["message"])));
        }
      } else {
        print("Server error: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Login exception: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("เข้าสู่ระบบ")),
      body: Stack(
        // ✨ ใช้ Stack เพื่อแสดง Loading Indicator
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // จัดให้อยู่กลางจอ
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "อีเมล"),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "รหัสผ่าน"),
                ),
                const SizedBox(height: 24),
                // ✨ แก้ไขปุ่มเดิมให้ disable ตอน loading
                ElevatedButton(
                  onPressed: _isLoading ? null : login,
                  child: const Text("เข้าสู่ระบบ"),
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotpassScreen(),
                            ),
                          );
                        },
                  child: const Text("ลืมรหัสผ่าน?"),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
