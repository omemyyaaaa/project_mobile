import 'package:flutter/material.dart';
import 'package:flutter_application_1/admin/adminlogin.dart';
import 'package:flutter_application_1/custom_bottom_nav.dart';
import 'package:flutter_application_1/leaderboard.dart';
import 'package:flutter_application_1/profile.dart';
import 'package:flutter_application_1/publicpage.dart';
import 'package:flutter_application_1/screen/homesr.dart';
import 'package:flutter_application_1/screen/loginsr.dart';
import 'package:flutter_application_1/sidebar/calendar.dart';
import 'package:flutter_application_1/sdgbar.dart';
import 'package:flutter_application_1/upload.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  int? userId; // เก็บ userId ที่ดึงจาก SharedPreferences
  int? _upcomingTasksCount; // สำหรับเก็บจำนวนภารกิจ
  bool _isLoadingTasks = true;
  int? _completedTasksCount;
  bool _isLoadingCompleted = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchUpcomingTasksCount();
    _fetchCompletedTasksCount();
  }

  Future<void> _fetchCompletedTasksCount() async {
    final url = Uri.parse('http://10.0.2.2:3000/tasks/status/completed');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // อัปเดต State ด้วยจำนวนที่ได้จาก key "count"
        setState(() {
          _completedTasksCount = data['count'];
          _isLoadingCompleted = false;
        });
      } else {
        setState(() {
          _completedTasksCount = 0;
          _isLoadingCompleted = false;
        });
      }
    } catch (e) {
      print("Error fetching completed tasks: $e");
      setState(() {
        _completedTasksCount = 0;
        _isLoadingCompleted = false;
      });
    }
  }

  Future<void> _fetchUpcomingTasksCount() async {
    // ใช้ 10.0.2.2 สำหรับ Android Emulator
    final url = Uri.parse('http://10.0.2.2:3000/tasks/status/upcoming');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List tasks = data['tasks']; // เข้าถึง list ของ tasks

        // อัปเดต State ด้วยจำนวนที่นับได้
        setState(() {
          _upcomingTasksCount = tasks.length;
          _isLoadingTasks = false;
        });
      } else {
        // กรณี Error
        setState(() {
          _upcomingTasksCount = 0;
          _isLoadingTasks = false;
        });
      }
    } catch (e) {
      // กรณีเชื่อมต่อไม่ได้
      print("Error fetching tasks: $e");
      setState(() {
        _upcomingTasksCount = 0;
        _isLoadingTasks = false;
      });
    }
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt("userId");
    });
    print("Loaded userId: $userId"); // Debug
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
      bottomNavigationBar: CustomBottomNav(
        // ✅ ใช้ CustomBottomNav
        currentIndex: 0, // index 0 = หน้า Home
        userId: id, // ส่ง userId ที่โหลดมาจาก SharedPreferences
      ),
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
        Column(
          children: [
            const Icon(Icons.flag, size: 40, color: Colors.red),
            const SizedBox(height: 8),
            _isLoadingTasks
                ? const SizedBox(
                    height: 24, // กำหนดความสูงให้เท่ากับ Text
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Text(
                    _upcomingTasksCount?.toString() ??
                        '0', // แสดงจำนวนที่ได้จาก API
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

            // --- จบจุดที่เปลี่ยนแปลง ---
            const Text(
              "เป้าหมาย",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),

        // ส่วนของ "ทำแล้ว" ยังคงเหมือนเดิม
        Column(
        children: [
          const Icon(Icons.upload, size: 40, color: Colors.black),
          const SizedBox(height: 8),
          
          // --- จุดที่เปลี่ยนแปลง ---
          // ถ้ากำลังโหลด ให้แสดง ProgressIndicator
          // ถ้าโหลดเสร็จแล้ว ให้แสดงตัวเลข
          _isLoadingCompleted
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Text(
                  _completedTasksCount?.toString() ?? '0', // แสดงจำนวนที่ได้จาก API
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
          // --- จบจุดที่เปลี่ยนแปลง ---

          const Text(
            "ทำแล้ว",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ],
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
        // ตรวจสอบก่อนว่า userId ไม่ใช่ null
        if (userId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              // ❗️❗️ แก้ตรงนี้ ❗️❗️
              // ไม่ใช่ SDGBar() แต่เป็น SDGScreen และส่ง userId ไปด้วย
              builder: (context) => SDGScreen(userId: userId!),
            ),
          );
        } else {
          // กรณีที่ยังโหลด userId ไม่เสร็จ หรือไม่มี userId
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('กรุณาล็อกอินก่อนใช้งาน')),
          );
        }
      },
      child: const Text("เรียนรู้เกี่ยวกับ SDGs"),
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
  static const Color _darkBlue = Color(0xFF1565C0);

  // Helper to get userId for navigation
  int get id => userId ?? 0;
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
              const SizedBox(width: 10),
              ProfileInfoWidget(userId: id), // ✅ ใช้ widget ใหม่
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
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => ProfilePage(id: id)));
      },
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  // Profile information

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
                if (userId != null) {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SDGScreen(userId: userId!),
                    ),
                  );
                }
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
              icon: Icons.leaderboard,
              text: "จัดอันดับ",
              iconColor: const Color(0xFFFF9800),
              onTap: () {
                // 1. ตรวจสอบก่อนว่า userId โหลดเสร็จแล้วหรือยัง (ไม่ใช่ null)
                if (userId != null) {
                  Navigator.of(context).pop(); // ปิด Drawer ก่อน
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // 2. ส่ง userId ที่ไม่เป็น null เข้าไปใน LeaderboardPage
                      builder: (context) =>
                          LeaderboardPage(currentUserId: userId!),
                    ),
                  );
                } else {
                  // 3. กรณีที่ยังโหลด userId ไม่เสร็จ ให้แจ้งเตือน
                  Navigator.of(context).pop(); // ปิด Drawer ก่อน
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('กำลังโหลดข้อมูลผู้ใช้ กรุณาลองใหม่'),
                    ),
                  );
                }
              },
            ),
            _buildMenuItem(
              icon: Icons.admin_panel_settings,
              text: "Admin",
              iconColor: const Color(0xFF2196F3),
              onTap: () {
                Navigator.of(context).pop(); // ปิด drawer ก่อน
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AdminLoginScreen(), // นำทางไปยัง sdgbar.dart
                  ),
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

class ProfileInfoWidget extends StatefulWidget {
  final int userId;

  const ProfileInfoWidget({super.key, required this.userId});

  @override
  State<ProfileInfoWidget> createState() => _ProfileInfoWidgetState();
}

class _ProfileInfoWidgetState extends State<ProfileInfoWidget> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final apiUrl = "http://10.0.2.2:3000/profile/${widget.userId}";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          profileData = data['profile'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Text(
        "กำลังโหลด...",
        style: TextStyle(color: Colors.white, fontSize: 16),
      );
    }

    if (profileData == null) {
      return const Text(
        "ไม่พบข้อมูล",
        style: TextStyle(color: Colors.white, fontSize: 16),
      );
    }

    final String profileUrl =
        profileData?['profile_url'] != null && profileData!['profile_url'] != ""
        ? "http://10.0.2.2:3000${profileData!['profile_url']}"
        : "";
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ProfilePage(id: widget.userId), // ✅ ใช้ widget.userId
              ),
            );
          },
          child: CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: profileUrl.isNotEmpty
                  ? Image.network(
                      profileUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      color: Colors.grey[200], // ✅ ไม่มีไอคอน ใช้พื้นหลังแทน
                    ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${profileData!['username']}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
