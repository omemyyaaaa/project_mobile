import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/myhome.dart';
import 'package:flutter_application_1/screen/forgotpasswordsr.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ✅ 1. แก้ไขฟังก์ชัน login ให้ถูกต้องและใช้ QuickAlert
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'ข้อมูลไม่ครบถ้วน',
        text: 'กรุณากรอกอีเมลและรหัสผ่าน',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:3000/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"]) {
        final int userId = data["user"]["id"];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt("userId", userId);
        
        // --- กรณี Login สำเร็จ ---
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'เข้าสู่ระบบสำเร็จ',
          text: 'ยินดีต้อนรับ!',
          barrierDismissible: false,
          confirmBtnText: 'ตกลง',
          onConfirmBtnTap: () {
            // ปิด Dialog และนำทางไปหน้า Home
            // ใช้ rootNavigator: true เพื่อปิด Dialog ก่อน
            Navigator.of(context, rootNavigator: true).pop(); 
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyHome()),
            );
          }
        );

      } else {
        // --- กรณี Login ไม่สำเร็จ (รหัสผิด, ไม่มี user) ---
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'เข้าสู่ระบบไม่สำเร็จ',
          text: data["message"] ?? 'อีเมลหรือรหัสผ่านไม่ถูกต้อง',
        );
      }
    } catch (e) {
      if (!mounted) return;
      // --- กรณีเชื่อมต่อไม่ได้ หรือ Error อื่นๆ ---
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'การเชื่อมต่อผิดพลาด',
        text: 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาลองใหม่',
      );
      print("Login exception: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("เข้าสู่ระบบ")),
      body: Center( // ✅ 2. ใช้ Center เพื่อจัดกลางหน้าจอ
        child: SingleChildScrollView( // ✅ 3. ใช้ SingleChildScrollView ป้องกันคีย์บอร์ดดัน UI
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // เพิ่ม Logo หรือ Title ของแอปตรงนี้ได้
              Text(
                'ยินดีต้อนรับ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "อีเมล",
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "รหัสผ่าน",
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
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
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )
                ),
                child: _isLoading 
                    ? const SizedBox(
                        width: 24, 
                        height: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      ) 
                    : const Text("เข้าสู่ระบบ", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}