import 'dart:convert';
import 'dart:io';
import 'package:birth_picker/birth_picker.dart' show BirthPicker;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_application_1/screen/loginsr.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  File? _profileImage;
  String? _stickerPath;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null && mounted) {
      setState(() {
        _profileImage = File(image.path);
        _stickerPath = null;
      });
    }
  }

  void pickSticker(String assetPath) {
    setState(() {
      _stickerPath = assetPath;
      _profileImage = null;
    });
  }

  void pickProfileImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("เลือกรูปโปรไฟล์"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("ถ่ายรูป"),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text("เลือกจาก Gallery"),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.emoji_emotions),
              title: Text("เลือกสติกเกอร์"),
              onTap: () {
                Navigator.pop(context);
                showStickerPicker();
              },
            ),
          ],
        ),
      ),
    );
  }

  void showStickerPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("เลือกสติกเกอร์"),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            children: [
              GestureDetector(
                onTap: () {
                  pickSticker("assets/images/sticker1.png");
                  Navigator.pop(context);
                },
                child: Image.asset("assets/images/sticker1.png"),
              ),
              GestureDetector(
                onTap: () {
                  pickSticker("assets/images/sticker2.png");
                  Navigator.pop(context);
                },
                child: Image.asset("assets/images/sticker2.png"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> registerUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("รหัสผ่านไม่ตรงกัน")));
      return;
    }

    var uri = Uri.parse("http://10.0.2.2:3000/register");
    var request = http.MultipartRequest('POST', uri);

    request.fields['email'] = emailController.text;
    request.fields['password'] = passwordController.text;
    request.fields['firstname'] = firstNameController.text;
    request.fields['lastname'] = lastNameController.text;
    request.fields['phone_number'] = phoneController.text;
    request.fields['birthday'] = dobController.text;

    if (_profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profile', _profileImage!.path),
      );
    } else if (_stickerPath != null) {
      final byteData = await rootBundle.load(_stickerPath!);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/sticker.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      request.files.add(
        await http.MultipartFile.fromPath('profile', file.path),
      );
    }

    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    final data = jsonDecode(respStr);

    if (response.statusCode == 200 && data["success"]) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("สมัครสมาชิกสำเร็จ")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "เกิดข้อผิดพลาด")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("สร้างบัญชี")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 16),

            // รูปโปรไฟล์
            GestureDetector(
              onTap: pickProfileImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : _stickerPath != null
                    ? AssetImage(_stickerPath!) as ImageProvider
                    : null,
                child: (_profileImage == null && _stickerPath == null)
                    ? Icon(Icons.add_a_photo, size: 40, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "อีเมล", // ตัวหนังสืออยู่ด้านบน
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // ทำให้โค้งมน
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "รหัสผ่าน",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "ยืนยันรหัสผ่าน",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: "ชื่อ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: "นามสกุล",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "เบอร์โทร",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: dobController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "วันเกิด",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onTap: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (_) => Container(
                    height: 250,
                    color: Colors.white,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: DateTime(2000, 1, 1),
                            minimumDate: DateTime(1900, 1, 1),
                            maximumDate: DateTime.now(),
                            onDateTimeChanged: (DateTime date) {
                              dobController.text = date.toIso8601String().split(
                                'T',
                              )[0];
                            },
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("ยืนยัน"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: registerUser,
                child: Text("สร้างบัญชี", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
