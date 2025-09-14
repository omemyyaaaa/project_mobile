import 'dart:convert';
import 'package:flutter/material.dart';
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

          // ✅ เก็บ userId ลง SharedPreferences
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "อีเมล"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "รหัสผ่าน"),
            ),
            SizedBox(height: 24),
            ElevatedButton(onPressed: login, child: Text("เข้าสู่ระบบ")),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotpassScreen()),
                );
              },
              child: Text("ลืมรหัสผ่าน?"),
            ),
          ],
        ),
      ),
    );
  }
}
