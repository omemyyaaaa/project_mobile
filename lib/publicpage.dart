import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/custom_bottom_nav.dart'; // สมมติว่าคุณมีไฟล์นี้
import 'package:flutter_application_1/myhome.dart';
import 'package:flutter_application_1/sdg_data.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Public Feed',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Kanit', // แนะนำให้ใช้ Font ที่รองรับภาษาไทย
      ),
      // ส่ง userId เริ่มต้นเข้าไป (ในแอปจริง ค่านี้จะมาจากหน้า Login)
      home: Publicpage(),
    );
  }
}
// -------------------------

class Publicpage extends StatefulWidget {
  const Publicpage({super.key});

  @override
  State<Publicpage> createState() => _PublicpageState();
}

class _PublicpageState extends State<Publicpage> {
  bool isLoading = true;
  List posts = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  // ฟังก์ชันสำหรับดึงข้อมูลโพสต์ทั้งหมดจาก API
  Future<void> _fetchPosts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final url = Uri.parse('http://10.0.2.2:3000/posts');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          posts = data['posts'] as List? ?? [];
        });
      } else {
        setState(() {
          errorMessage =
              "ไม่สามารถโหลดข้อมูลได้ (Code: ${response.statusCode})";
        });
      }
    } catch (e) {
      print("❌ Error fetching posts: $e");
      setState(() {
        errorMessage = "เกิดข้อผิดพลาดในการเชื่อมต่อ";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'กิจกรรมทั้งหมด',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 1,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  // Widget สำหรับจัดการการแสดงผลตามสถานะ
  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(
        child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (posts.isEmpty) {
      return const Center(child: Text('ยังไม่มีกิจกรรมที่ถูกโพสต์'));
    }

    return RefreshIndicator(
      onRefresh: _fetchPosts,
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return _buildPostCard(post);
        },
      ),
    );
  }

  // Widget สำหรับสร้าง Card ของแต่ละโพสต์
  Widget _buildPostCard(Map<String, dynamic> post) {
    // สร้าง URL ที่สมบูรณ์สำหรับรูปภาพ
    final String baseUrl = "http://10.0.2.2:3000";
    final String profileUrl = post['profile_url'] != null
        ? baseUrl + post['profile_url']
        : '';
    final String imageUrl = post['image_url'] ?? '';
    final String taskName = post['tasks']?.toString() ?? 'กิจกรรม';
    final List<int> sdgNumbers = (post['sdgs'] as List? ?? [])
        .map(
          (item) => int.tryParse(item.toString()),
        ) // 1. แปลงทุกอย่างเป็น String แล้วลองแปลงเป็น int
        .where(
          (item) => item != null,
        ) // 2. คัดเฉพาะอันที่แปลงได้สำเร็จ (ไม่เป็น null)
        .cast<int>() // 3. ยืนยันประเภทข้อมูลว่าเป็น int
        .toList();

    final String dateString = post['uploaded_date'];
    final formattedDate = DateFormat(
      'dd MMM yyyy',
      'th_TH',
    ).format(DateTime.parse(dateString));
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // 1. Widget พื้นหลัง: รูปภาพของโพสต์ (ต้องอยู่เป็นอันดับแรกใน Stack)
              if (imageUrl.isNotEmpty)
                Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  height: 300,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.grey),
                    ),
                  ),
                )
              else
                Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 50,
                    ),
                  ),
                ),

              // 2. Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: profileUrl.isNotEmpty
                            ? NetworkImage(profileUrl)
                            : null,
                        child: profileUrl.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['username'] ?? 'Anonymous',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                              shadows: [
                                Shadow(blurRadius: 2, color: Colors.black54),
                              ],
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              shadows: const [
                                Shadow(blurRadius: 2, color: Colors.black54),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
  child: Text(
    taskName,
    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
  ),
),
Padding(
  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
  // 1. ใช้ Row เพื่อจัดของในแนวนอน
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.end, // จัดให้ส่วนล่างของข้อความและแท็กตรงกัน
    children: [
      // 2. ให้ "คำอธิบาย" ขยายเต็มพื้นที่ด้านซ้าย เพื่อดันแท็กไปขวาสุด
      Expanded(
        child: Text(
          post['descript'] ?? 'ไม่มีคำอธิบาย',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: Colors.grey[700],
          ),
        ),
      ),
      const SizedBox(width: 8), // ระยะห่าง

      // 3. "แท็ก SDG" จะถูกดันไปอยู่ขวาสุดโดยอัตโนมัติ
      if (sdgNumbers.isNotEmpty)
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 6.0,
          runSpacing: 4.0,
          children: sdgNumbers.map((number) {
            final sdgInfo = sdgList.firstWhere(
              (sdg) => sdg.number == number,
              orElse: () => sdgList.first.copyWith(number: 0, title: 'Unknown'),
            );
            return Chip(
              avatar: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: sdgInfo.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              label: Text(
                sdgInfo.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11, // ปรับขนาดให้เล็กลงเล็กน้อย
                ),
              ),
              backgroundColor: sdgInfo.color,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // ปรับขนาด Chip
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            );
          }).toList(),
        ),
    ],
  ),
),
        ],
      ),
    );
  }
}

extension on SDGData {
  SDGData copyWith({int? number, String? title}) {
    return SDGData(
      number: number ?? this.number,
      title: title ?? this.title,
      subtitle: this.subtitle,
      color: this.color,
      backgroundImage: this.backgroundImage,
      activities: this.activities,
      uploaded: this.uploaded,
      goalImage: this.goalImage,
      description: '',
    targets: [
    ],
    );
  }
}
