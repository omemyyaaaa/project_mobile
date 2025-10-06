import 'dart:convert'; // สำหรับ jsonEncode, jsonDecode
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screen/reset_password_screen.dart';
import 'package:http/http.dart' as http; // สำหรับเรียก API
import 'package:pinput/pinput.dart'; // import หน้าที่สร้างขึ้นมาใหม่

class ForgotpassScreen extends StatefulWidget {
  const ForgotpassScreen({super.key});

  @override
  State<ForgotpassScreen> createState() => _ForgotpassScreenState();
}

class _ForgotpassScreenState extends State<ForgotpassScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final FocusNode otpFocusNode = FocusNode();

  bool _isOtpSent = false;
  bool _isLoading = false; // state สำหรับ loading

  // *** URL ของ Backend (สำหรับ Android Emulator ใช้ 10.153.27.172 เพื่อชี้มาที่ localhost ของคอม) ***
  final String _baseUrl = 'http://10.153.27.172:3000';

  // --- แก้ไขฟังก์ชันนี้ ---
  Future<void> _sendOtp() async {
    final email = emailController.text;
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกอีเมลให้ถูกต้อง')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('$_baseUrl/api/auth/request-otp'); // Endpoint ที่สร้างไว้
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _isOtpSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ส่ง OTP ไปที่ $email สำเร็จแล้ว')),
        );
      } else {
        final body = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${body['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('การเชื่อมต่อล้มเหลว: $e')),
      );
    } finally {
       if (mounted) {
         setState(() {
          _isLoading = false;
        });
       }
    }
  }

  // --- แก้ไขฟังก์ชันนี้ ---
  Future<void> _verifyOtp() async {
    final otp = otpController.text;
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอก OTP ให้ครบ 6 หลัก')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('$_baseUrl/api/auth/verify-otp');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': emailController.text, 'otp': otp}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // ถ้า OTP ถูกต้อง ให้ไปหน้าตั้งรหัสผ่านใหม่
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              email: emailController.text,
              otp: otp, // ส่ง OTP ไปด้วย
            ),
          ),
        );
      } else {
         final body = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP ไม่ถูกต้อง: ${body['message']}')),
        );
      }

    } catch(e) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('การเชื่อมต่อล้มเหลว: $e')),
      );
    } finally {
      if(mounted){
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ลืมรหัสผ่าน")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _isOtpSent ? _buildOtpScreen() : _buildRequestForm(),
      ),
    );
  }

  Widget _buildRequestForm() {
    return Column(
      // ... UI ส่วนนี้เหมือนเดิม แต่เพิ่ม Loading ที่ปุ่ม ...
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        //... Text Widgets ...
        const Text(
         "กรุณากรอกอีเมลของคุณ",
         style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
         textAlign: TextAlign.center,
       ),
       const SizedBox(height: 12),
       Text(
         "เราจะส่งรหัสยืนยัน (OTP) ไปยังอีเมลของคุณ",
         style: TextStyle(fontSize: 16, color: Colors.grey[600]),
         textAlign: TextAlign.center,
       ),
       const SizedBox(height: 32),
       TextField(
         controller: emailController,
         keyboardType: TextInputType.emailAddress,
         decoration: InputDecoration(
           labelText: "อีเมล",
           prefixIcon: const Icon(Icons.email_outlined),
           border: OutlineInputBorder(
             borderRadius: BorderRadius.circular(16.0),
           ),
         ),
       ),
       const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _sendOtp,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          child: _isLoading
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
              : const Text("ขอรหัส OTP", style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildOtpScreen() {
    // ... UI ส่วนนี้เหมือนเดิม แต่เพิ่ม Loading ที่ปุ่ม ...
    final defaultPinTheme = PinTheme(
     width: 56,
     height: 60,
     textStyle: const TextStyle(
       fontSize: 22,
       color: Color.fromRGBO(30, 60, 87, 1),
     ),
     decoration: BoxDecoration(
       color: Colors.grey[200],
       borderRadius: BorderRadius.circular(8),
       border: Border.all(color: Colors.transparent),
     ),
   );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "ยืนยันรหัส OTP",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          "กรุณากรอกรหัส 6 หลักที่ส่งไปยัง ${emailController.text}",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Pinput(
          length: 6,
          controller: otpController,
          focusNode: otpFocusNode,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: defaultPinTheme.copyWith(
            decoration: defaultPinTheme.decoration!.copyWith(
              border: Border.all(color: Theme.of(context).primaryColor),
            ),
          ),
          onCompleted: (pin) => _verifyOtp(),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyOtp,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          child: _isLoading
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
              : const Text("ยืนยัน", style: TextStyle(fontSize: 18)),
        ),
        // ... TextButton ...
      ],
    );
  }
}