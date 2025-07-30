import 'package:flutter/material.dart';
import 'package:flutter_application_1/myhome.dart';
import 'package:flutter_application_1/profile.dart';
import 'package:flutter_application_1/publicpage.dart';
import 'package:flutter_application_1/upload.dart';

class Sdg1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text(''),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(icon: Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),

       bottomNavigationBar: _buildBottomNavigation(context),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // หัวข้อ SDG 1
            Container(
              color: Colors.red[700],
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1 ความยากจนต้องหมดไป',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ขจัดความยากจนทุกรูปแบบในทุกพื้นที่',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.family_restroom,
                        color: Colors.white,
                        size: 40,
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ],
              ),
            ),

            // ภาพ background + สองไอคอน
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/goal1.png', // แทนที่ด้วย path รูปจริง
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: 90,
                  top: 120,
                  child: Column(
                    children: [
                      Icon(Icons.visibility, color: Colors.white),
                      Text(
                        "7 การรับรู้",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 90,
                  top: 120,
                  child: Column(
                    children: [
                      Icon(Icons.cloud_upload, color: Colors.white),
                      Text(
                        "13 กิจกรรมแล้ว",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // กล่องเป้าหมายและเกี่ยวข้อง
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMiniCard(
                    Icons.edit_note,
                    "เกี่ยวข้อง",
                    Colors.red[300]!,
                  ),
                  _buildMiniCard(Icons.flag, "เป้าหมาย", Colors.red[400]!),
                ],
              ),
            ),

            // ปุ่มอัปโหลด
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[100],
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.cloud_upload, color: Colors.black),
                label: Text(
                  "อัปโหลดรูปกิจกรรม",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const Color _primaryGreen = Color(0xFF4CAF50);
  static const Color _lightGreen = Color(0xFFE8F5E8);
  static const Color _darkBlue = Color(0xFF1976D2);

  Widget _buildMiniCard(IconData icon, String label, Color color) {
    return Container(
      width: 100,
      height: 100,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.black, size: 30),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      height: 70,
      color: _primaryGreen,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavItem(context, Icons.home, 0),
          _buildBottomNavItem(context, Icons.wifi, 1),
          _buildBottomNavItem(context, Icons.cloud_outlined, 2),
          _buildBottomNavItem(context, Icons.person, 3),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(BuildContext context, IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        color: Colors.black,
        size: 28,
      ),
      onPressed: () {
        _onBottomNavTap(context, index);
      },
    );
  }

  void _onBottomNavTap(BuildContext context, int index) {
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
        break;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UploadPage(),
          ),
        );
        break;
      case 3:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ProfilePage(),
          ),
        );
        break;
    }
  }
}
