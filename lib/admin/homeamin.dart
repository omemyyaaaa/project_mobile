import 'package:flutter/material.dart';
import 'package:flutter_application_1/admin/audit_screen.dart';
import 'package:flutter_application_1/admin/completed.dart';
import 'package:flutter_application_1/admin/creation.dart';
import 'package:flutter_application_1/admin/pubadmin.dart';
import 'package:flutter_application_1/admin/tasking.dart';
import 'package:flutter_application_1/screen/homesr.dart';
import 'package:flutter_application_1/sidebar/calendar.dart';

class MyHomeadmin extends StatefulWidget {
  const MyHomeadmin({super.key});

  @override
  State<MyHomeadmin> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHomeadmin> {
  int? userId; // เก็บ userId ที่ดึงจาก SharedPreferences

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
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

  // Custom colors
  static const Color _primaryGreen = Color(0xFF4CAF50);
  static const Color _lightGreen = Color(0xFFE8F5E9);
  static const Color _backgroundColor = Color(0xFFF5F5F5);

  // Helper to get userId for navigation
  int get id => userId ?? 0;

  // Drawer header - simplified without profile
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
              const Text(
                "เมนู",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildCloseButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Close button for drawer
  Widget _buildCloseButton() {
    return IconButton(
      icon: const Icon(Icons.close, color: Colors.white),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  // Drawer menu items - removed 17 SDGs option
  Widget _buildDrawerMenu() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            _buildMenuItem(
              icon: Icons.add_task,
              text: "สร้างภารกิจ",
              iconColor: const Color(0xFF4CAF50),
              onTap: () {
                Navigator.of(context).pop(); // ปิด Drawer ก่อน
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskCreationScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.gps_fixed,
              text: "ภารกิจ",
              iconColor: const Color(0xFFFF9800),
              onTap: () {
                Navigator.of(context).pop(); // ปิด Drawer ก่อน
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Tasking()),
                );
              },
            ),

            _buildMenuItem(
              icon: Icons.checklist,
              text: "ภารกิจที่เสร็จแล้ว",
              iconColor: const Color(0xFFFF9800),
              onTap: () {
                Navigator.of(context).pop(); // ปิด Drawer ก่อน
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CompletedTasksPage()),
                );
              },
            ),

            _buildMenuItem(
              icon: Icons.check_circle,
              text: "ตรวจสอบภารกิจ",
              iconColor: const Color(0xFFFF9800),
              onTap: () {
                Navigator.of(context).pop(); // ปิด Drawer/เมนู ก่อน
                // ไปยังหน้า AuditScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AuditScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.campaign,
              text: "เผยแพร่",
              iconColor: const Color(0xFF2196F3),
              onTap: () {
                Navigator.of(context).pop(); // ปิด Drawer ก่อน
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PublicAdminPage()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.calendar_today,
              text: "ปฏิทิน",
              iconColor: const Color(0xFF9C27B0),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalenBar()),
                );
              },
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
            // แสดงข้อความ SnackBar
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('ออกจากระบบ')));

            // ไปหน้า LoginPage แบบแทนที่ (ไม่สามารถย้อนกลับมาได้)
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (Route<dynamic> route) => false, // เคลียร์ทุกหน้าเก่าออก
            );
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
