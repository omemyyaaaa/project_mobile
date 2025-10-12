import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_application_1/screen/loginsr.dart'; // Make sure this path is correct
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:quickalert/quickalert.dart'; // Ensure pinput is imported

// Enum to manage the current state of the registration process
enum RegisterStep { enterDetails, verifyOtp }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- Controllers and Keys ---
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // --- State Variables ---
  File? _profileImage;
  String? _stickerPath;
  final ImagePicker _picker = ImagePicker();
  RegisterStep _currentStep = RegisterStep.enterDetails;
  bool _isLoading = false;

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    dobController.dispose();
    otpController.dispose();
    super.dispose();
  }

  // --- API Calls ---

  // Step 1: Send user details to the backend to request an OTP
  Future<void> _requestRegistrationOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() { _isLoading = true; });

    var uri = Uri.parse("http://10.0.2.2:3000/api/auth/register-request");
    var request = http.MultipartRequest('POST', uri)
      ..fields['email'] = emailController.text.trim()
      ..fields['password'] = passwordController.text
      ..fields['username'] = usernameController.text.trim()
      ..fields['phone_number'] = phoneController.text.trim()
      ..fields['birthday'] = dobController.text;

    if (_profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath('profile', _profileImage!.path));
    } else if (_stickerPath != null) {
      final byteData = await rootBundle.load(_stickerPath!);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/sticker.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      request.files.add(await http.MultipartFile.fromPath('profile', file.path));
    }

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      if (!mounted) return;
      final data = jsonDecode(respStr);

      if (response.statusCode == 200) {
        // กรณีสำเร็จ ยังใช้ SnackBar ได้ เพราะเป็นการแจ้งเตือนสั้นๆ ก่อนเปลี่ยนหน้า
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data["message"])));
        setState(() { _currentStep = RegisterStep.verifyOtp; });
      } else {
        // --- กรณี Error จาก Server ---
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'ผิดพลาด',
          text: data["message"] ?? "เกิดข้อผิดพลาด",
        );
      }
    } catch (e) {
      if (!mounted) return;
      // --- กรณีเชื่อมต่อไม่ได้ ---
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'การเชื่อมต่อล้มเหลว',
        text: 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้',
      );
      print("Request OTP exception: $e");
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  // Step 2: Send the OTP to the backend to complete the registration
  Future<void> _completeRegistration() async {
    if (otpController.text.length < 6) {
      QuickAlert.show(context: context, type: QuickAlertType.warning, text: 'กรุณากรอก OTP 6 หลัก');
      return;
    }
    setState(() { _isLoading = true; });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/auth/register-verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'otp': otpController.text,
        }),
      );
      final data = jsonDecode(response.body);
      if (!mounted) return;

      if (response.statusCode == 201) {
        // --- กรณีสำเร็จ ---
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'สำเร็จ!',
          text: 'สมัครสมาชิกเรียบร้อยแล้ว',
          confirmBtnText: 'ไปหน้าเข้าสู่ระบบ',
          barrierDismissible: false,
          onConfirmBtnTap: () {
            Navigator.of(context, rootNavigator: true).pop(); // ปิด QuickAlert ก่อน
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
        );
      } else {
        // --- กรณี OTP ผิด ---
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'ผิดพลาด',
          text: data["message"] ?? "OTP ไม่ถูกต้อง",
        );
      }
    } catch (e) {
      if (!mounted) return;
      // --- กรณีเชื่อมต่อไม่ได้ ---
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'การเชื่อมต่อล้มเหลว',
        text: 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาตรวจสอบอินเทอร์เน็ต',
      );
      print("Complete registration exception: $e");
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentStep == RegisterStep.enterDetails
              ? "สร้างบัญชี"
              : "ยืนยันอีเมล",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        // Use AnimatedSwitcher for a smooth transition between forms
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _currentStep == RegisterStep.enterDetails
              ? _buildDetailsForm()
              : _buildOtpForm(),
        ),
      ),
    );
  }

  // Widget for the first step: Entering user details
  Widget _buildDetailsForm() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('detailsForm'), // Key for AnimatedSwitcher
        children: [
          // Profile Image Picker
          GestureDetector(
            onTap: _pickProfileImage,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : _stickerPath != null
                  ? AssetImage(_stickerPath!) as ImageProvider
                  : null,
              child: (_profileImage == null && _stickerPath == null)
                  ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          // Input Fields
          _buildTextField(
            controller: emailController,
            labelText: "อีเมล",
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v == null || v.isEmpty || !v.contains('@'))
                ? 'รูปแบบอีเมลไม่ถูกต้อง'
                : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: passwordController,
            labelText: "รหัสผ่าน",
            obscureText: true,
            validator: (v) => (v == null || v.length < 6)
                ? 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร'
                : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: confirmPasswordController,
            labelText: "ยืนยันรหัสผ่าน",
            obscureText: true,
            validator: (v) =>
                (v != passwordController.text) ? 'รหัสผ่านไม่ตรงกัน' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: usernameController,
            labelText: "ชื่อผู้ใช้",
            validator: (v) =>
                (v == null || v.isEmpty) ? 'กรุณากรอกชื่อผู้ใช้' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: phoneController,
            labelText: "เบอร์โทร (ไม่บังคับ)",
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildDateField(
            controller: dobController,
            labelText: "วันเกิด (ไม่บังคับ)",
          ),
          const SizedBox(height: 24),
          // Action Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _requestRegistrationOtp,
              child: _isLoading
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : const Text("รับรหัสยืนยัน", style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            child: const Text("มีบัญชีอยู่แล้ว? เข้าสู่ระบบ"),
          ),
        ],
      ),
    );
  }

  // Widget for the second step: Verifying OTP
  Widget _buildOtpForm() {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, color: Colors.black),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
    );
    return Column(
      key: const ValueKey('otpForm'), // Key for AnimatedSwitcher
      children: [
        const SizedBox(height: 32),
        const Text(
          "ยืนยันรหัส OTP",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          "กรอกรหัส 6 หลักที่ส่งไปยัง\n${emailController.text}",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 32),
        Pinput(
          length: 6,
          controller: otpController,
          defaultPinTheme: defaultPinTheme,
          autofocus: true,
          onCompleted: (pin) => _completeRegistration(),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _completeRegistration,
            child: _isLoading
                ? const CupertinoActivityIndicator(color: Colors.white)
                : const Text(
                    "ยืนยันและสร้างบัญชี",
                    style: TextStyle(fontSize: 18),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _isLoading
              ? null
              : () => setState(() => _currentStep = RegisterStep.enterDetails),
          child: const Text("กลับไปแก้ไขข้อมูล"),
        ),
      ],
    );
  }

  // --- Helper Widgets ---

  void _pickProfileImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("เลือกรูปโปรไฟล์"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("ถ่ายรูป"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("เลือกจาก Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_emotions),
              title: const Text("เลือกสติกเกอร์"),
              onTap: () {
                Navigator.pop(context);
                _showStickerPicker();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null && mounted) {
      setState(() {
        _profileImage = File(image.path);
        _stickerPath = null;
      });
    }
  }

  void _showStickerPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("เลือกสติกเกอร์"),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            children: [
              GestureDetector(
                onTap: () {
                  _pickSticker("assets/images/sticker1.png");
                  Navigator.pop(context);
                },
                child: Image.asset("assets/images/sticker1.png"),
              ),
              GestureDetector(
                onTap: () {
                  _pickSticker("assets/images/sticker2.png");
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

  void _pickSticker(String assetPath) {
    setState(() {
      _stickerPath = assetPath;
      _profileImage = null;
    });
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
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () {
        // ซ่อนคีย์บอร์ดที่อาจจะแสดงอยู่
        FocusScope.of(context).requestFocus(FocusNode());

        // แสดง Popup แบบ iOS จากด้านล่าง
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext builderContext) {
            return Container(
              height: MediaQuery.of(context).copyWith().size.height * 0.35,
              color: Colors.white,
              child: Column(
                children: [
                  // --- แถบเครื่องมือพร้อมปุ่ม "ยืนยัน" ---
                  Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 0.5, color: Colors.grey),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CupertinoButton(
                          child: const Text('ยืนยัน'),
                          onPressed: () {
                            // ถ้าผู้ใช้ไม่เคยเลื่อนเลือกวันเลย ให้ตั้งค่าเป็นวันปัจจุบัน
                            if (controller.text.isEmpty) {
                              setState(() {
                                controller.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
                              });
                            }
                            Navigator.of(builderContext).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  // --- ตัวเลือกวันที่แบบวงล้อ ---
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: DateTime(2000, 1, 1), // วันที่เริ่มต้น
                      minimumDate: DateTime(1900), // ปีเก่าสุดที่เลือกได้
                      maximumDate: DateTime.now(),   // วันที่ใหม่สุดที่เลือกได้
                      onDateTimeChanged: (DateTime newDate) {
                        // อัปเดตค่าในช่องข้อความทันทีที่ผู้ใช้เลื่อน
                        final formatter = DateFormat('yyyy-MM-dd');
                        controller.text = formatter.format(newDate);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
