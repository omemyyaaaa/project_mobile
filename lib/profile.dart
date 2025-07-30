import 'package:flutter/material.dart';
import 'package:flutter_application_1/myhome.dart';
import 'package:flutter_application_1/publicpage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color _primaryGreen = Color(0xFF4CAF50);
  static const Color _lightGreen = Color(0xFFE8F5E8);
  static const Color _darkBlue = Color(0xFF1976D2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightGreen,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _buildProfileContent(),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // App Bar สีเขียว
  Widget _buildAppBar() {
    return Container(
      height: 60,
      color: _primaryGreen,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
                size: 24,
              ),
              onPressed: () {
                // เปิด drawer หรือกลับไปหน้าก่อน
                Navigator.of(context).pop();
              },
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.person,
                color: Colors.black,
                size: 24,
              ),
              onPressed: () {
                // Action สำหรับโปรไฟล์
              },
            ),
          ],
        ),
      ),
    );
  }

  // เนื้อหาหลักของหน้าโปรไฟล์
  Widget _buildProfileContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildProfileHeader(),
          const SizedBox(height: 40),
          _buildProfileAvatar(),
          const SizedBox(height: 30),
          _buildEditProfileButton(),
          const Spacer(),
        ],
      ),
    );
  }

  // ส่วนหัวโปรไฟล์
  Widget _buildProfileHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'โปรไฟล์',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.black54,
              size: 20,
            ),
          ],
        ),
        const Text(
          'ประวัติต่อลาง',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  // รูปโปรไฟล์
  Widget _buildProfileAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey[400]!,
          width: 2,
        ),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.add,
          size: 40,
          color: Colors.black54,
        ),
        onPressed: () {
          _showImagePickerDialog();
        },
      ),
    );
  }

  // ปุ่มแก้ไขโปรไฟล์
  Widget _buildEditProfileButton() {
    return Container(
      decoration: BoxDecoration(
        color: _darkBlue,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextButton(
        onPressed: () {
          _navigateToEditProfile();
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  // Bottom Navigation
  Widget _buildBottomNavigation() {
    return Container(
      height: 70,
      color: _primaryGreen,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavItem(Icons.home, 0),
          _buildBottomNavItem(Icons.wifi, 1),
          _buildBottomNavItem(Icons.cloud_outlined, 2),
          _buildBottomNavItem(Icons.person, 3),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        color: Colors.black,
        size: 28,
      ),
      onPressed: () {
        _onBottomNavTap(index);
      },
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
                // เลือกจากกล้อง
                _pickImageFromCamera();
              },
              child: const Text('กล้อง'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // เลือกจากแกลเลอรี่
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

  void _navigateToEditProfile() {
    // ไปหน้าแก้ไขโปรไฟล์
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfilePage(),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MyHome(),
        ),
      );
        break;
      case 1:
        Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const Publicpage(),
        ),
      );
      case 2:
        // Cloud
        Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ProfilePage(),
        ),
      );
      case 3:
        // Profile (หน้าปัจจุบัน)
        break;
    }
  }
}

// หน้าแก้ไขโปรไฟล์ (ตัวอย่าง)
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขโปรไฟล์'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: const Center(
        child: Text(
          'หน้าแก้ไขโปรไฟล์',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}