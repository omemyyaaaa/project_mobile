import 'package:flutter/material.dart';
import 'package:flutter_application_1/myhome.dart';
import 'package:flutter_application_1/profile.dart';
import 'package:flutter_application_1/publicpage.dart';
import 'package:flutter_application_1/upload.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final int userId; // เพิ่ม userId

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.userId, // ต้องรับจาก parent
  }) : super(key: key);

  static const Color _primaryGreen = Color(0xFF4CAF50);

  void _onBottomNavTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget? page;
    switch (index) {
      case 0:
        page = MyHome();
        break;
      case 1:
        return; // ถ้าไม่มีหน้าสำหรับ index 1
       case 2:
case 2:
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => UploadPage(userId: userId)), // ใช้ userId จาก class
  );
  break;
      case 3:
        page = ProfilePage(id: userId);
        break;
      default:
        return;
    }

    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: _primaryGreen,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(context, Icons.home, 0),
          _buildNavItem(context, Icons.wifi, 1),
          _buildNavItem(context, Icons.cloud_outlined, 2),
          _buildNavItem(context, Icons.person, 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, int index) {
    final bool isActive = currentIndex == index;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: isActive ? Colors.white : Colors.black87,
            size: 28,
          ),
          onPressed: () => _onBottomNavTap(context, index),
        ),
        if (isActive)
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}
