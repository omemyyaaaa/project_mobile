import 'package:flutter/material.dart';
import 'package:flutter_application_1/profile.dart';
import 'package:flutter_application_1/publicpage.dart';
import 'package:flutter_application_1/sidebar/calendar.dart';
import 'package:flutter_application_1/sidebar/sdgbar.dart';
import 'package:flutter_application_1/sidebar/trickbar.dart';
import 'package:flutter_application_1/upload.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  // Color constants for consistency
  static const Color _primaryGreen = Color(0xFF2E7D32);
  static const Color _lightGreen = Color(0xFFC5E87D);
  static const Color _backgroundColor = Color(0xFFF5F9E9);
  static const Color _darkBlue = Color(0xFF3F3D56);
  static const Color _bottomNavGreen = Color(0xFF1C5F32);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // App Bar with transparent background
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.black),
          onPressed: () {
            // Add notification functionality here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications clicked!')),
            );
          },
        ),
      ],
    );
  }

  // Main body with background and content
  Widget _buildBody() {
    return Stack(children: [_buildBackground(), _buildMainContent()]);
  }

  // Background image with error handling
  Widget _buildBackground() {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/forrest.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.green[100],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red),
                  SizedBox(height: 8),
                  Text(
                    'ไม่สามารถโหลดรูปพื้นหลังได้',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Main content layout
  Widget _buildMainContent() {
    return Column(
      children: [
        const SizedBox(height: 120),
        _buildSDGLogo(),
        const Spacer(),
        _buildInfoCard(),
      ],
    );
  }

  // SDG Logo with error handling
  Widget _buildSDGLogo() {
    return Center(
      child: Image.asset(
        'assets/images/sdg.png',
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 32),
                SizedBox(height: 4),
                Text('SDG Logo', style: TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

  // Bottom info card
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: _lightGreen,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildInfoTitle(),
          const SizedBox(height: 16),
          _buildInfoDescription(),
          const SizedBox(height: 24),
          _buildStatistics(),
          const SizedBox(height: 24),
          _buildLearnButton(),
        ],
      ),
    );
  }

  // Info card title
  Widget _buildInfoTitle() {
    return const Text(
      "เป้าหมายการพัฒนาที่ยั่งยืน คืออะไร?",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      textAlign: TextAlign.center,
    );
  }

  // Info card description
  Widget _buildInfoDescription() {
    return const Text(
      "เป้าหมายการพัฒนาทั้ง 17 ข้อ สะท้อน 3 เสาหลักของมิติความยั่งยืน คือ\n"
      "มิติด้านสังคม เศรษฐกิจ และสิ่งแวดล้อม บวกกับอีก 2 \n"
      "มิติคือมิติด้านสันติภาพและสถาบันและมิติด้านหุ้นส่วนการพัฒนา\n"
      "ที่เชื่อมร้อยทุกมิติของความยั่งยืนไว้ด้วยกัน",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12, height: 1.5),
    );
  }

  // Statistics row
  Widget _buildStatistics() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          icon: Icons.flag,
          iconColor: Colors.red,
          number: "169",
          label: "เป้าหมาย",
        ),
        _buildStatItem(
          icon: Icons.upload,
          iconColor: Colors.black,
          number: "13",
          label: "ทำแล้ว",
        ),
        _buildStatItem(
          icon: Icons.format_quote,
          iconColor: Colors.pink,
          number: "60",
          label: "เคล็ดลับระดับประเทศ",
        ),
      ],
    );
  }

  // Individual statistic item
  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String number,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 40, color: iconColor),
        const SizedBox(height: 8),
        Text(
          number,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  // Learn more button
  Widget _buildLearnButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      onPressed: () {
         Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SDGBar(),
        ),
      );
      },
      child: const Text(
        "เรียนรู้เกี่ยวกับ SDGs",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Bottom navigation bar
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
  void _onBottomNavTap(int index) {
  switch (index) {
    case 0:
      // myhome(หน้าปัจจุบัน)
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
          builder: (context) => UploadPage(),
        ),
      );
    case 3:
      // Profile
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ProfilePage(),
        ),
      );
      break;
  }
}

  // Navigation drawer
  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: _backgroundColor,
        child: Column(
          children: [
            _buildDrawerHeader(),
            _buildDrawerMenu(),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  // Drawer header with profile info
  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: const BoxDecoration(
        color: _primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              _buildProfileAvatar(),
              const SizedBox(width: 16),
              _buildProfileInfo(),
              const Spacer(),
              _buildCloseButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Profile avatar
  Widget _buildProfileAvatar() {
  return GestureDetector(
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ProfilePage(),
        ),
      );
    },
    child: Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.person, color: Colors.grey, size: 32),
    ),
  );
}

  // Profile information
  Widget _buildProfileInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("profile", style: TextStyle(color: Colors.white70, fontSize: 12)),
        SizedBox(height: 4),
        Text(
          "Name",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Close button for drawer
  Widget _buildCloseButton() {
    return IconButton(
      icon: const Icon(Icons.close, color: Colors.white),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  // Drawer menu items
  Widget _buildDrawerMenu() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            _buildMenuItem(
              icon: Icons.public,
              text: "17 SDGs",
              iconColor: const Color(0xFF4CAF50),
              onTap: () {
                Navigator.of(context).pop(); // ปิด drawer ก่อน
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                         SDGBar() // นำทางไปยัง sdgbar.dart
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.format_quote,
              text: "เคล็ดลับปฏิบัติจริง",
              iconColor: const Color(0xFFE91E63),
              onTap: () {
                Navigator.of(context).pop(); // ปิด drawer ก่อน
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const TrickBar(), // นำทางไปยัง sdgbar.dart
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.calendar_today,
              text: "ปฏิทิน",
              iconColor: const Color(0xFF2196F3),
              onTap: () {
                Navigator.of(context).pop(); // ปิด drawer ก่อน
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const CalenBar(), // นำทางไปยัง sdgbar.dart
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.contact_support,
              text: "ติดต่อเรา",
              iconColor: const Color(0xFF9C27B0),
            ),
          ],
        ),
      ),
    );
  }

  // Individual menu item
  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap:
            onTap ??
            () {
              // default behavior ถ้าไม่มี onTap
              Navigator.of(context).pop();
            },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 16),
              Text(
                text,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Logout button
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('ออกจากระบบ')));
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: 20),
              SizedBox(width: 12),
              Text(
                "LOGOUT",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
