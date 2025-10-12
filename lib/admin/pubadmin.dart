import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/sdg_data.dart'; // ตรวจสอบว่า path ไปยังไฟล์ sdg_data.dart ถูกต้อง
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';

class PublicAdminPage extends StatefulWidget {
  const PublicAdminPage({super.key});

  @override
  State<PublicAdminPage> createState() => _PublicAdminPageState();
}

class _PublicAdminPageState extends State<PublicAdminPage> {
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

  // ฟังก์ชันสำหรับ "บล็อก" โพสต์
  Future<void> _blockPost(int postId) async {
    final url = Uri.parse('http://10.0.2.2:3000/posts/$postId/block');

    try {
      // ใช้ http.patch เพื่อส่งคำขออัปเดตสถานะ
      final response = await http.patch(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        // เมื่อบล็อกสำเร็จ ให้อัปเดต UI โดยการลบโพสต์นั้นออกจาก List ที่แสดงผล
        setState(() {
          posts.removeWhere((post) => post['post_id'] == postId);
        });
           QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'สำเร็จ',
          text: 'บล็อกโพสต์สำเร็จแล้ว',
          confirmBtnText: 'ตกลง ',
        );
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'เกิดข้อผิดพลาด',
          text: 'บล็อกโพสต์ไม่สำเร็จ (Code: ${response.statusCode})',
        );
      }
    } catch (e) {
       if (!mounted) return;
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'การเชื่อมต่อผิดพลาด',
        text: 'เกิดข้อผิดพลาด: $e',
      );
    }
  }

  // แสดง Dialog เพื่อยืนยันการบล็อก
  void _showBlockConfirmationDialog(int postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการบล็อก'),
          content: const Text('คุณแน่ใจหรือไม่ว่าต้องการบล็อกโพสต์นี้?\n(โพสต์จะไม่แสดงในหน้าสาธารณะอีกต่อไป)'),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('บล็อก'),
              onPressed: () {
                Navigator.of(context).pop();
                _blockPost(postId);
              },
            ),
          ],
        );
      },
    );
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'จัดการกิจกรรม (Admin)',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFD32F2F), // สีแดงสำหรับ Admin
        elevation: 1,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

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
      return const Center(child: Text('ยังไม่มีกิจกรรมที่ต้องจัดการ'));
    }

    return RefreshIndicator(
      onRefresh: _fetchPosts,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return _buildPostCard(post);
        },
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    // 1. ใช้ Key ที่ถูกต้องและสันนิษฐานว่า API ส่ง URL เต็มมาให้
    final String profileUrl = post['profile_url'] ?? '';
    final String imageUrl = post['image_url'] ?? '';
    final String description = post['descript'] ?? 'ไม่มีคำอธิบาย';
    final int postId = post['post_id'] ?? post['upload_id'] ?? 0;

    // 2. ใช้ Key 'tasks' สำหรับ SDGs (เหมือนใน Publicpage)
    final List<int> sdgNumbers = (post['tasks'] as List? ?? [])
        .map((item) => int.tryParse(item.toString()))
        .where((item) => item != null)
        .cast<int>()
        .toList();

    // 3. ใช้ Key 'uploaded_date' สำหรับวันที่ (เหมือนใน Publicpage)
    final String dateString = post['uploaded_date'] ?? DateTime.now().toIso8601String();
    final formattedDate = DateFormat('dd MMM yyyy', 'th_TH').format(DateTime.parse(dateString));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: profileUrl.isNotEmpty ? NetworkImage(profileUrl) : null,
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
                IconButton(
                  icon: const Icon(Icons.block, color: Colors.red),
                  tooltip: 'Block Post',
                  onPressed: () {
                    if (postId != 0) {
                      _showBlockConfirmationDialog(postId);
                    }
                  },
                ),
              ],
            ),
          ),
          if (imageUrl.isNotEmpty)
            Image.network(
              imageUrl, // <-- ใช้ imageUrl ที่เป็น URL เต็มๆ โดยตรง
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
                if (sdgNumbers.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children: sdgNumbers.map((number) {
                      return CircleAvatar(
                        radius: 12,
                        backgroundColor: _getColorForSdg(number),
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
      targets: [],
    );
  }
}