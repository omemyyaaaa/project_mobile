import 'package:flutter/material.dart';
import 'package:flutter_application_1/myhome.dart';
import 'package:flutter_application_1/publicpage.dart';
import 'package:flutter_application_1/upload.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color _primaryGreen = Color(0xFF4CAF50);
  static const Color _lightGreen = Color(0xFFE8F5E8);
  static const Color _darkBlue = Color(0xFF1976D2);

  // เปลี่ยนสีพื้นหลังตามดีไซน์ในภาพ
  static const Color _backgroundColor = Color(0xFFE8F5E8);

  // ข้อมูลโปรไฟล์ที่สามารถเปลี่ยนแปลงได้
  String _name = 'Kanpicha Ngoila';
  String _email = 'kanpicha@example.com';
  String _phone = '+66 123 456 789';

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // ลบปุ่มการตั้งค่าจาก AppBar
        actions: const [],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  // ส่วนรูปโปรไฟล์ ชื่อ และคำอธิบาย
  Widget _buildProfileAvatarSection() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[400]!, width: 2),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.camera_alt_outlined,
              size: 50,
              color: Colors.black54,
            ),
            onPressed: () {
              _showImagePickerDialog();
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Hello! I love developing mobile apps.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
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

  // Widget ย่อยสำหรับแสดงแต่ละสถิติ
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            _buildContactRow(Icons.email, _email),
            const SizedBox(height: 16),
            _buildContactRow(Icons.phone, _phone),
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
        const SizedBox(width: 16),
        Text(text, style: const TextStyle(fontSize: 16, color: Colors.black87)),
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
          _navigateToEditProfile();
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
        // เพิ่มรายการตั้งค่า
        _buildSettingsItem(
          icon: Icons.settings,
          title: 'การตั้งค่า',
          onTap: () {
            _navigateToSettingsPage();
          },
        ),
        const SizedBox(height: 8),
        _buildSettingsItem(
          icon: Icons.lock_outline,
          title: 'ความเป็นส่วนตัว',
          onTap: () {
            _navigateToPrivacyPage();
          },
        ),
        const SizedBox(height: 8),
        _buildSettingsItem(
          icon: Icons.security,
          title: 'ความปลอดภัย',
          onTap: () {
            _navigateToSecurityPage();
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

  // Bottom Navigation
  Widget _buildBottomNavigation() {
    return Container(
      height: 70,
      color: _primaryGreen,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavItem(Icons.home, 0, 'หน้าแรก'),
          _buildBottomNavItem(Icons.wifi, 1, 'ฟีด'),
          _buildBottomNavItem(Icons.cloud_outlined, 2, 'อัปโหลด'),
          _buildBottomNavItem(Icons.person, 3, 'โปรไฟล์'),
        ],
      ),
    );
  }

  // Widget ย่อยสำหรับแต่ละรายการใน Bottom Navigation
  Widget _buildBottomNavItem(IconData icon, int index, String label) {
    return InkWell(
      onTap: () {
        _onBottomNavTap(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.black, size: 28),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // Functions
  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เลือกรูปโปรไฟล์'),
          content: const Text('คุณต้องการเลือกรูปจากแหล่งใด?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageFromCamera();
              },
              child: const Text('กล้อง'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageFromGallery();
              },
              child: const Text('แกลเลอรี่'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ยกเลิก'),
            ),
          ],
        );
      },
    );
  }

  void _pickImageFromCamera() {
    // เพิ่ม logic สำหรับถ่ายรูป
    print('เลือกรูปจากกล้อง');
  }

  void _pickImageFromGallery() {
    // เพิ่ม logic สำหรับเลือกรูปจากแกลเลอรี่
    print('เลือกรูปจากแกลเลอรี่');
  }

  void _navigateToEditProfile() async {
    // ไปหน้าแก้ไขโปรไฟล์และรอผลลัพธ์
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          initialName: _name,
          initialEmail: _email,
          initialPhone: _phone,
        ),
      ),
    );

    // อัปเดตข้อมูลหากมีการแก้ไขและบันทึก
    if (result != null && result is Map<String, String>) {
      setState(() {
        _name = result['name']!;
        _email = result['email']!;
        _phone = result['phone']!;
      });
    }
  }

  void _navigateToSettingsPage() {
    // ไปหน้าการตั้งค่า
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  void _navigateToPrivacyPage() {
    // ไปหน้าความเป็นส่วนตัว
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPage()),
    );
  }

  void _navigateToSecurityPage() {
    // ไปหน้าความปลอดภัย
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SecurityPage()),
    );
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const MyHome()));
        break;
      case 1:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const Publicpage()));
        break;
      case 2:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => UploadPage()));
        break;
      case 3:
        // หน้าปัจจุบัน ไม่ต้องทำอะไร
        break;
    }
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