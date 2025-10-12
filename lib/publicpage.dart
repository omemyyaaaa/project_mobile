import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/sdg_data.dart'; // ✅ 1. Import ข้อมูล SDG ถูกต้องแล้ว
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // แนะนำให้เพิ่มไว้ เผื่อต้องใช้ format วันที่ภาษาไทย

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
    initializeDateFormatting('th_TH', null); // ตั้งค่าภาษาสำหรับ DateFormat
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    // ... (ฟังก์ชันนี้ทำงานถูกต้องแล้ว ไม่ต้องแก้ไข)
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final url = Uri.parse('http://10.0.2.2:3000/posts');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) setState(() => posts = data['posts'] as List? ?? []);
      } else {
        if (mounted)
          setState(
            () => errorMessage =
                "ไม่สามารถโหลดข้อมูลได้ (Code: ${response.statusCode})",
          );
      }
    } catch (e) {
      print("❌ Error fetching posts: $e");
      if (mounted)
        setState(() => errorMessage = "เกิดข้อผิดพลาดในการเชื่อมต่อ");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Color _getColorForSdg(int sdgNumber) {
    try {
      final sdg = sdgList.firstWhere((data) => data.number == sdgNumber);
      return sdg.color;
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (โค้ดส่วน build และ _buildBody ทำงานถูกต้องแล้ว ไม่ต้องแก้ไข)
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'กิจกรรมทั้งหมด',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ), // เปลี่ยนสีไอคอนเป็นขาว
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorMessage != null)
      return Center(
        child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
      );
    if (posts.isEmpty)
      return const Center(child: Text('ยังไม่มีกิจกรรมที่ถูกโพสต์'));

    return RefreshIndicator(
      onRefresh: _fetchPosts,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return _buildPostCard(post);
        },
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    // การจัดการข้อมูล (ทำงานถูกต้องแล้ว)
    final String baseUrl = "http://10.0.2.2:3000";
    final String profileUrl = post['profile_url'] != null
        ? baseUrl + post['profile_url']
        : '';
    final String imageUrl = post['image_url'] ?? '';
    final String description = post['descript'] ?? 'ไม่มีคำอธิบาย';

    // แปลง tasks (sdgs) ให้อยู่ในรูปแบบ List<int> (ทำงานถูกต้องแล้ว)
    final List<int> sdgNumbers = (post['tasks'] as List? ?? [])
        .map((item) => int.tryParse(item.toString()))
        .where((item) => item != null)
        .cast<int>()
        .toList();

    // จัดรูปแบบวันที่ (ทำงานถูกต้องแล้ว)
    final String dateString =
        post['uploaded_date'] ?? DateTime.now().toIso8601String();
    final formattedDate = DateFormat(
      'dd MMM yyyy',
      'th_TH',
    ).format(DateTime.parse(dateString));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: profileUrl.isNotEmpty
                      ? NetworkImage(profileUrl)
                      : null,
                  child: profileUrl.isEmpty ? const Icon(Icons.person) : null,
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
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- Image ---
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              height: 250,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 250,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.error, color: Colors.grey),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. "คำอธิบาย" จะขยายเต็มพื้นที่ด้านซ้าย เพื่อดันวงกลมไปขวาสุด
                Expanded(
                  child: Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: Colors.grey[800],
                    ),
                  ),
                ),


                // --- SDG Tags ---
                if (sdgNumbers.isNotEmpty) ...[
                  const SizedBox(width: 16), // ระยะห่าง
                  Wrap(
                    alignment: WrapAlignment.end, // จัดให้ชิดขวาถ้ามีหลายแถว
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children: sdgNumbers.map((number) {
                      // 3. เปลี่ยนจาก Chip เป็น CircleAvatar ที่ไม่มีชื่อ
                      return CircleAvatar(
                        radius: 12,
                        backgroundColor: _getColorForSdg(
                          number,
                        ), // เรียกใช้ฟังก์ชันดึงสี
                        child: Text(
                          '$number',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Extension นี้ควรย้ายไปอยู่ไฟล์ sdg_data.dart เพื่อการจัดการที่ดีขึ้น
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
      description: this.description,
      targets: this.targets,
    );
  }
}
