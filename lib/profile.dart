import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_application_1/custom_bottom_nav.dart'
    show CustomBottomNav;
import 'package:flutter_application_1/myhome.dart';
import 'package:flutter_application_1/publicpage.dart';
import 'package:flutter_application_1/upload.dart';
import 'dart:convert'; // สำหรับ json.decode
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart' show ImageSource, ImagePicker;
import 'package:path_provider/path_provider.dart';

class ProfilePage extends StatefulWidget {
  final int id; // ได้มาจากตอน Login

  const ProfilePage({Key? key, required this.id}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    print("Fetching profile for: '${widget.id}'"); // ดูว่า email ถูกส่งไปไหม

    final apiUrl = "http://10.0.2.2:3000/profile/${widget.id}";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          profileData = data['profile'];
          isLoading = false;
        });
      } else {
        setState(() {
          profileData = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Fetch error: $e");
      setState(() {
        profileData = null;
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
                  const SizedBox(height: 32),
                  _buildStatsSection(),
                  const SizedBox(height: 32),
                  _buildContactInfoCard(),
                  const SizedBox(height: 32),
                  _buildEditProfileButton(),
                  const SizedBox(height: 32),
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
        ? "http://10.0.2.2:3000${profileData!['profile_url']}"
        : "";

    return Column(
      children: [
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
          "${profileData!['firstname']} ${profileData!['lastname']}",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
      final uri = Uri.parse('http://10.0.2.2:3000/profile/upload/$userId');
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

  // ส่วนแสดงสถิติ (โพสต์, ผู้ติดตาม, กำลังติดตาม)
  Widget _buildStatsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('12', 'โพสต์'),
        _buildStatItem('250', 'ผู้ติดตาม'),
        _buildStatItem('180', 'กำลังติดตาม'),
      ],
    );
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
                  initialName:
                      "${profileData!['firstname']} ${profileData!['lastname']}",
                  initialEmail: profileData!['email'] ?? "",
                  initialPhone: profileData!['phonenumber'] ?? "",
                ),
              ),
            ).then((result) {
              if (result != null && result is Map<String, String>) {
                setState(() {
                  // อัปเดตค่าที่แก้ไขกลับมาจาก EditProfilePage
                  profileData!['firstname'] = result['name']!.split(" ").first;
                  profileData!['lastname'] =
                      result['name']!.split(" ").length > 1
                      ? result['name']!.split(" ").last
                      : "";
                  profileData!['email'] = result['email']!;
                  profileData!['phonenumber'] = result['phone']!;
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
          icon: Icons.settings,
          title: 'การตั้งค่า',
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _buildSettingsItem(
          icon: Icons.lock_outline,
          title: 'ความเป็นส่วนตัว',
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _buildSettingsItem(
          icon: Icons.security,
          title: 'ความปลอดภัย',
          onTap: () {},
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
  final String initialName;
  final String initialEmail;
  final String initialPhone;

  const EditProfilePage({
    Key? key,
    required this.initialName,
    required this.initialEmail,
    required this.initialPhone,
  }) : super(key: key);

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

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
      };
      Navigator.pop(context, updatedData);
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
                isPhone: true,
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

// หน้าการตั้งค่า (สร้างใหม่)
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // สถานะสำหรับโหมดมืด
  bool _isDarkMode = false;
  // สถานะสำหรับเปิด/ปิดการแจ้งเตือน
  bool _notificationsEnabled = true;

  // สีสำหรับโหมดสว่างและโหมดมืด
  static const Color _lightBackgroundColor = Color(0xFFFFFFFF);
  static const Color _darkBackgroundColor = Color(0xFF121212);
  static const Color _lightAppBarColor = Color(0xFF4CAF50);
  static const Color _darkAppBarColor = Color(0xFF212121);
  static const Color _lightTextColor = Color(0xFF000000);
  static const Color _darkTextColor = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode
          ? _darkBackgroundColor
          : _lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          'การตั้งค่า',
          style: TextStyle(
            color: _isDarkMode ? _darkTextColor : _lightTextColor,
          ),
        ),
        backgroundColor: _isDarkMode ? _darkAppBarColor : _lightAppBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(
                'โหมดมืด',
                style: TextStyle(
                  color: _isDarkMode ? _darkTextColor : _lightTextColor,
                ),
              ),
              value: _isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  _isDarkMode = value;
                });
                // แสดงสถานะใน console (สามารถนำไปใช้จริงเพื่อเปลี่ยนธีมในแอปได้)
                print('โหมดมืดถูกเปิดใช้งาน: $_isDarkMode');
              },
            ),
            // เพิ่มการแจ้งเตือน
            SwitchListTile(
              title: Text(
                'การแจ้งเตือน',
                style: TextStyle(
                  color: _isDarkMode ? _darkTextColor : _lightTextColor,
                ),
              ),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                print('สถานะการแจ้งเตือน: $_notificationsEnabled');
              },
            ),
            // เพิ่มบันทึกกิจกรรม
            ListTile(
              title: Text(
                'บันทึกกิจกรรม',
                style: TextStyle(
                  color: _isDarkMode ? _darkTextColor : _lightTextColor,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: _isDarkMode ? _darkTextColor : _lightTextColor,
              ),
              onTap: () {
                // เพิ่มการนำทางไปยังหน้าบันทึกกิจกรรม
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActivityLogPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// หน้าความเป็นส่วนตัว (สร้างใหม่)
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ความเป็นส่วนตัว'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: const Center(
        child: Text('หน้าความเป็นส่วนตัว', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

// หน้าความปลอดภัย (สร้างใหม่)
class SecurityPage extends StatelessWidget {
  const SecurityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ความปลอดภัย'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: const Center(
        child: Text('หน้าความปลอดภัย', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

// หน้าบันทึกกิจกรรม (สร้างใหม่)
class ActivityLogPage extends StatelessWidget {
  const ActivityLogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('บันทึกกิจกรรม'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: const Center(
        child: Text('หน้าบันทึกกิจกรรม', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
