import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_application_1/custom_bottom_nav.dart'
    show CustomBottomNav;
import 'package:flutter_application_1/history.dart';
import 'package:flutter_application_1/myhome.dart';
import 'package:flutter_application_1/publicpage.dart';
import 'package:flutter_application_1/upload.dart';
import 'dart:convert'; // สำหรับ json.decode
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart' show ImageSource, ImagePicker;
import 'package:path_provider/path_provider.dart';

class ProfilePage extends StatefulWidget {
  final int id; // ได้มาจากตอน Login

  const ProfilePage({super.key, required this.id});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color _primaryGreen = Color(0xFF4CAF50);
  static const Color _lightGreen = Color(0xFFE8F5E8);
  static const Color _darkBlue = Color(0xFF1976D2);

  static const Color _backgroundColor = Color(0xFFE8F5E8);

  Map<String, dynamic>? profileData;
  bool isLoading = true;
  File? _imageFile;
  String? _stickerPath;
  int? totalActivities;

  @override
  void initState() {
    super.initState();
    fetchProfileAndActivities();
  }

  Future<void> fetchProfileAndActivities() async {
    // ทำให้ State เป็น Loading ก่อน
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      // เรียก API พร้อมกัน 2 ตัวเพื่อความรวดเร็ว
      final profileFuture = http.get(
        Uri.parse("http://10.153.27.172:3000/profile/${widget.id}"),
      );
      final activitiesFuture = http.get(
        Uri.parse("http://10.153.27.172:3000/profile/${widget.id}/activities"),
      );

      final responses = await Future.wait([profileFuture, activitiesFuture]);

      final profileResponse = responses[0];
      final activitiesResponse = responses[1];

      // จัดการข้อมูล Profile
      if (profileResponse.statusCode == 200) {
        final data = json.decode(profileResponse.body);
        profileData = data['profile'];
      } else {
        profileData = null;
      }

      // จัดการข้อมูลจำนวน Activities
      if (activitiesResponse.statusCode == 200) {
        final data = json.decode(activitiesResponse.body);
        totalActivities = data['total_activities'];
      } else {
        totalActivities = 0; // ถ้า error ให้เป็น 0
      }
    } catch (e) {
      print("Fetch error: $e");
      profileData = null;
      totalActivities = 0;
    } finally {
      // อัปเดต UI ครั้งเดียวหลังข้อมูลครบ
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _primaryGreen,
        elevation: 0,
        title: const Text(
          'โปรไฟล์',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileData == null
          ? const Center(
              child: Text(
                "ไม่พบข้อมูลผู้ใช้หรือเกิดข้อผิดพลาด",
                style: TextStyle(fontSize: 16),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildProfileAvatarSection(),
                  const SizedBox(height: 5),
                  _buildContactInfoCard(),
                  const SizedBox(height: 32),
                  _buildEditProfileButton(),
                  const SizedBox(height: 20),
                  _buildSettingsList(),
                ],
              ),
            ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 3, // หน้า Profile
        userId: widget.id,
      ),
    );
  }

  Widget _buildProfileAvatarSection() {
    final String fullProfileUrl =
        profileData?['profile_url'] != null && profileData!['profile_url'] != ""
        ? "http://10.153.27.172:3000${profileData!['profile_url']}"
        : "";

    return Column(
      children: [
        // ... (ส่วนรูปโปรไฟล์เหมือนเดิม)
        GestureDetector(
          onTap: _showImagePickerDialog,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[400]!, width: 2),
            ),
            child: ClipOval(
              child: _imageFile != null
                  ? Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    )
                  : (_stickerPath != null
                        ? Image.asset(
                            _stickerPath!,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                          )
                        : (fullProfileUrl.isNotEmpty
                              ? Image.network(
                                  fullProfileUrl,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.black54,
                                ))),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "${profileData!['username']}",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // สร้างแถบแสดงสถิติ (Points และ Activities)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // แสดง Points
            _buildStatItem(profileData!['points']?.toString() ?? '0', 'Points'),
            // แสดงจำนวนกิจกรรม
            _buildStatItem(totalActivities?.toString() ?? '0', 'Activities'),
          ],
        ),
      ],
    );
  }

  Future<void> _showImagePickerDialog() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('เลือกรูปโปรไฟล์'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('กล้อง'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('แกลเลอรี่'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_emotions),
              title: const Text('สติกเกอร์'),
              onTap: () {
                Navigator.pop(context);
                _showStickerPicker(); // เรียก Dialog สติกเกอร์
              },
            ),
          ],
        ),
      ),
    );

    // ถ้าเลือกกล้องหรือแกลเลอรี่
    if (source != null) {
      await _pickImage(source);
    }
  }

  Future<void> _showStickerPicker() async {
    final selectedSticker = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('เลือกสติกเกอร์'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            children: [
              GestureDetector(
                onTap: () =>
                    Navigator.pop(context, 'assets/images/sticker1.png'),
                child: Image.asset('assets/images/sticker1.png'),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.pop(context, 'assets/images/sticker2.png'),
                child: Image.asset('assets/images/sticker2.png'),
              ),
              // เพิ่มสติกเกอร์อื่น ๆ ตามต้องการ
            ],
          ),
        ),
      ),
    );

    if (selectedSticker != null) {
      setState(() {
        _imageFile = null; // ยกเลิกรูปจริง
        _stickerPath = selectedSticker;
      });

      // อัปโหลดสติกเกอร์เป็นไฟล์ชั่วคราวเหมือน AdditionalInfoScreen
      await _uploadSticker(selectedSticker);
    }
  }

  Future<void> _uploadSticker(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/sticker.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    await _uploadProfileImage(
      widget.id,
      file,
    ); // เรียกฟังก์ชันอัปโหลดที่มีอยู่แล้ว
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // อัปโหลดไฟล์ไปเซิร์ฟเวอร์
      await _uploadProfileImage(widget.id, _imageFile!);
    }
  }

  Future<void> _uploadProfileImage(int userId, File imageFile) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final uri = Uri.parse('http://10.153.27.172:3000/profile/upload/$userId');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('profile', imageFile.path),
      );

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      Navigator.of(context).pop(); // ปิด dialog loading

      if (response.statusCode == 200) {
        final data = json.decode(respStr);
        setState(() {
          profileData!['profile_url'] = data['profile_url'];
        });
        // ไม่แสดง SnackBar
      } else {
        // ไม่ทำอะไร
      }
    } catch (e) {
      Navigator.of(context).pop();
      // ไม่แสดง SnackBar
    }
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  // การ์ดข้อมูลติดต่อ
  Widget _buildContactInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
        child: Column(
          children: [
            _buildContactRow(Icons.email, profileData!['email']),
            const SizedBox(height: 16),
            _buildContactRow(Icons.phone, profileData!['phonenumber']),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Widget ย่อยสำหรับแต่ละแถวของข้อมูลติดต่อ
  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[800]),
        const SizedBox(width: 18),
        Text(text, style: const TextStyle(fontSize: 20, color: Colors.black87)),
      ],
    );
  }

  // ปุ่มแก้ไขโปรไฟล์
  Widget _buildEditProfileButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _darkBlue,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextButton(
        onPressed: () {
          if (profileData != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfilePage(
                  userId: widget.id,
                  initialName: profileData!['username'] ?? "",
                  initialEmail: profileData!['email'] ?? "",
                  initialPhone: profileData!['phonenumber'] ?? "",
                ),
              ),
            ).then((result) {
              // result คือข้อมูล profile ที่ได้จาก API
              if (result != null && result is Map<String, dynamic>) {
                // <-- แก้ไขประเภทข้อมูล
                setState(() {
                  // อัปเดตค่าที่แก้ไขกลับมาจาก EditProfilePage
                  // ซึ่งเป็นข้อมูลล่าสุดจาก Server
                  profileData!['username'] = result['username'];
                  profileData!['email'] = result['email'];
                  profileData!['phonenumber'] = result['phonenumber'];
                });
              }
            });
          }
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text(
          'แก้ไขข้อมูลโปรไฟล์',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // รายการเมนูตั้งค่า
  Widget _buildSettingsList() {
    return Column(
      children: [
        _buildSettingsItem(
          icon: Icons.history,
          title: 'บันทึกกิจกรรม',
          onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        // ส่ง userId ไปยัง HistoryPage
        builder: (context) => HistoryPage(userId: widget.id),
      ),
    );
  },
        ),
      ],
    );
  }

  // Widget ย่อยสำหรับแต่ละรายการเมนูตั้งค่า
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}

// หน้าแก้ไขโปรไฟล์ (ตัวอย่าง)
class EditProfilePage extends StatefulWidget {
  final int userId;
  final String initialName;
  final String initialEmail;
  final String initialPhone;

  const EditProfilePage({
    super.key,
    required this.userId,
    required this.initialName,
    required this.initialEmail,
    required this.initialPhone,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    // <-- เปลี่ยนเป็น async
    if (_formKey.currentState!.validate()) {
      // แสดง Loading Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final updatedData = {
        'username': _nameController.text,
        'email': _emailController.text,
        'phonenumber': _phoneController.text,
      };

      try {
        final apiUrl = 'http://10.153.27.172:3000/profile/${widget.userId}';
        final response = await http.put(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(updatedData),
        );

        Navigator.of(context).pop(); // ปิด Loading Dialog

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          // ส่งข้อมูลที่อัปเดตแล้วกลับไปหน้า ProfilePage
          Navigator.pop(context, responseData['profile']);
        } else {
          // แสดงข้อความ Error หาก API ไม่สำเร็จ
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('เกิดข้อผิดพลาดในการอัปเดตข้อมูล')),
          );
        }
      } catch (e) {
        Navigator.of(context).pop(); // ปิด Loading Dialog
        // แสดงข้อความ Error หากเชื่อมต่อไม่ได้
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('การเชื่อมต่อล้มเหลว: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขโปรไฟล์'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField('ชื่อ', _nameController, Icons.person),
              const SizedBox(height: 16),
              _buildTextField(
                'อีเมล',
                _emailController,
                Icons.email,
                isEmail: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'เบอร์โทรศัพท์',
                _phoneController,
                Icons.phone,
                isPhone: false,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'บันทึก',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'กรุณาใส่ $label';
        }
        if (isEmail && !value.contains('@')) {
          return 'กรุณาใส่อีเมลที่ถูกต้อง';
        }
        if (isPhone && value.length < 10) {
          return 'กรุณาใส่เบอร์โทรศัพท์ที่ถูกต้อง';
        }
        return null;
      },
    );
  }
}
