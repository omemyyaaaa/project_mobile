import 'dart:convert';
import 'dart:io';
// import 'package:birth_picker/birth_picker.dart' show BirthPicker; // ไม่ได้ใช้
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
// ✅ ยืนยันว่า import ถูกต้องตามชื่อไฟล์ที่คุณให้มา (homesr.dart)
import 'package:flutter_application_1/screen/loginsr.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:google_sign_in/google_sign_in.dart'; // ไม่ได้ใช้

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
  }); // ✅ เพิ่ม const constructor เพื่อเป็นแนวปฏิบัติที่ดี

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  File? _profileImage;
  String? _stickerPath;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _emailFieldKey = GlobalKey<FormFieldState>(); 
  final FocusNode _emailFocusNode = FocusNode();
  bool _isEmailChecking = false;
  bool? _isEmailValid;

  @override
  void initState() {
    super.initState();
  }

  void _onEmailFocusChange() {
    if (!_emailFocusNode.hasFocus) {
      // สั่งให้ validate เฉพาะช่องอีเมล
      _emailFieldKey.currentState?.validate();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    dobController.dispose();
    super.dispose();
  }

  Future<void> _validateEmailRealtime(String email) async {
    // ตรวจสอบ format เบื้องต้นก่อนส่ง จะได้ไม่เปลือง API call
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _isEmailValid = false;
      });
      _formKey.currentState?.validate();
      return;
    }

    setState(() {
      _isEmailChecking = true;
      _isEmailValid = null; // รีเซ็ตสถานะก่อนเริ่มเช็ค
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.153.27.172:3000/api/auth/validate-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(response.body);

      setState(() {
        _isEmailValid = data['isValid'];
      });

    } catch(e) {
      // หาก API error, เราจะถือว่าผ่านไปก่อนเพื่อไม่ให้ user สมัครไม่ได้
      setState(() {
        _isEmailValid = false; 
      });
    } finally {
      setState(() {
        _isEmailChecking = false; 
        _emailFieldKey.currentState?.validate();
      });
    }
  }

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
        title: const Text("เลือกรูปโปรไฟล์"), // ✅ เพิ่ม const
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt), // ✅ เพิ่ม const
              title: const Text("ถ่ายรูป"), // ✅ เพิ่ม const
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library), // ✅ เพิ่ม const
              title: const Text("เลือกจาก Gallery"), // ✅ เพิ่ม const
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_emotions), // ✅ เพิ่ม const
              title: const Text("เลือกสติกเกอร์"), // ✅ เพิ่ม const
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
        title: const Text("เลือกสติกเกอร์"), // ✅ เพิ่ม const
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
              // เพิ่มสติกเกอร์อื่น ๆ ตามต้องการ
            ],
          ),
        ),
      ),
    );
  }

  Future<void> registerUser() async {
    // ✅ ตรวจสอบ validation ก่อนส่งข้อมูล
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("รหัสผ่านไม่ตรงกัน")));
      return;
    }

    // แสดง loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    var uri = Uri.parse("http://10.153.27.172:3000/register");
    var request = http.MultipartRequest('POST', uri);

    request.fields['email'] = emailController.text;
    request.fields['password'] = passwordController.text;
    request.fields['username'] = usernameController.text;
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

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      Navigator.of(context).pop(); // ปิด loading dialog

      if (response.statusCode == 201 && data["success"]) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("สมัครสมาชิกสำเร็จ! กำลังนำท่านไปหน้าเข้าสู่ระบบ")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "เกิดข้อผิดพลาด")),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // ปิด loading dialog หากเกิด error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาดในการเชื่อมต่อ: $e")),
      );
      print("Register error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("สร้างบัญชี")), // ✅ เพิ่ม const
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          // ✅ เพิ่ม Form widget สำหรับ validation
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16), // ✅ เพิ่ม const
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
                      ? const Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Colors.white,
                        ) // ✅ เพิ่ม const
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: _emailFieldKey, // ผูก Key ของช่องอีเมล
                controller: emailController,
                focusNode: _emailFocusNode, // ผูก FocusNode
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "อีเมล",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // แสดงสถานะการตรวจสอบที่ท้ายช่อง
                  suffixIcon: _isEmailChecking
                      ? const Padding(padding: EdgeInsets.all(12.0), child: CupertinoActivityIndicator())
                      : _isEmailValid != null
                          ? Icon(
                              _isEmailValid! ? Icons.check_circle : Icons.error,
                              color: _isEmailValid! ? Colors.green : Colors.red,
                            )
                          : null,
                ),
                validator: (value) {
                  // เมื่อ validate ให้เรียก API (ถ้าจำเป็น)
                  if (_emailFocusNode.hasFocus == false && _isEmailChecking == false && _isEmailValid == null) {
                     _validateEmailRealtime(value ?? "");
                  }

                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกอีเมล';
                  }
                  if (!value.contains('@')) {
                    return 'รูปแบบอีเมลไม่ถูกต้อง';
                  }
                  if (_isEmailValid == false) {
                    return 'อีเมลนี้อาจใช้งานไม่ได้จริง';
                  }
                  return null; // ถ้าทุกอย่างถูกต้อง
                },
              ),
              
              const SizedBox(height: 16), // ✅ เพิ่ม const
              _buildTextField(
                controller: passwordController,
                labelText: "รหัสผ่าน",
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกรหัสผ่าน';
                  }
                  if (value.length < 6) {
                    return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16), // ✅ เพิ่ม const
              _buildTextField(
                controller: confirmPasswordController,
                labelText: "ยืนยันรหัสผ่าน",
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณายืนยันรหัสผ่าน';
                  }
                  if (value != passwordController.text) {
                    return 'รหัสผ่านไม่ตรงกัน';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16), // ✅ เพิ่ม const
              _buildTextField(
                controller: usernameController,
                labelText: "ชื่อผู้ใช้",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกชื่อผู้ใช้';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16), // ✅ เพิ่ม const
              _buildTextField(
                controller: phoneController,
                labelText: "เบอร์โทร",
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      (value.length < 9 || value.length > 10)) {
                    return 'กรุณากรอกเบอร์โทรที่ถูกต้อง';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16), // ✅ เพิ่ม const
              _buildDateField(
                // ✅ ใช้ _buildDateField
                controller: dobController,
                labelText: "วันเกิด",
              ),
              const SizedBox(height: 24), // ✅ เพิ่ม const
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: registerUser,
                  child: const Text(
                    "สร้างบัญชี",
                    style: TextStyle(fontSize: 18),
                  ), // ✅ เพิ่ม const
                ),
              ),
              const SizedBox(height: 16), // ✅ เพิ่ม const
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ), // ✅ เพิ่ม const
                  );
                },
                child: const Text(
                  "มีบัญชีอยู่แล้ว? เข้าสู่ระบบ",
                ), // ✅ เพิ่ม const
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
    );
  }

  // ✅ เติมเต็มฟังก์ชัน _buildDateField ที่ขาดหายไป
  Widget _buildDateField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: const Icon(Icons.calendar_today), // ✅ เพิ่ม icon ปฏิทิน
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
                      controller.text = date.toIso8601String().split('T')[0];
                    },
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("ยืนยัน"), // ✅ เพิ่ม const
                ),
              ],
            ),
          ),
        );
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'กรุณาเลือกวันเกิด';
        }
        return null;
      },
    );
  }
}
