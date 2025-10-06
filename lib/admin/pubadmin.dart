import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/sdg_data.dart'; // ตรวจสอบว่า path ไปยังไฟล์ sdg_data.dart ถูกต้อง
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
      final url = Uri.parse('http://10.153.27.172:3000/posts');
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
    final url = Uri.parse('http://10.153.27.172:3000/posts/$postId/block');

    try {
      // ใช้ http.patch เพื่อส่งคำขออัปเดตสถานะ
      final response = await http.patch(url);

      if (response.statusCode == 200) {
        // เมื่อบล็อกสำเร็จ ให้อัปเดต UI โดยการลบโพสต์นั้นออกจาก List ที่แสดงผล
        setState(() {
          posts.removeWhere((post) => post['post_id'] == postId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('บล็อกโพสต์สำเร็จแล้ว'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('บล็อกโพสต์ไม่สำเร็จ (Code: ${response.statusCode})'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    final String baseUrl = "http://10.153.27.172:3000";
    final String profileUrl = post['profile_url'] != null ? baseUrl + post['profile_url'] : '';
    final String imageUrl = post['image_url'] ?? '';
    final String taskName = post['tasks']?.toString() ?? 'กิจกรรม';
    final List<int> sdgNumbers = (post['sdgs'] as List? ?? []).map((item) => int.tryParse(item.toString())).where((item) => item != null).cast<int>().toList();
    final String dateString = post['uploaded_date'];
    final formattedDate = DateFormat('dd MMM yyyy', 'th_TH').format(DateTime.parse(dateString));
    final postId = post['upload_id'];

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
                        child: Icon(Icons.error, color: Colors.grey)),
                  ),
                )
              else
                Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.image_not_supported,
                        color: Colors.grey, size: 50),
                  ),
                ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                        Colors.black.withOpacity(0.8)
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
                        child: profileUrl.isEmpty ? const Icon(Icons.person) : null,
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
                                  Shadow(blurRadius: 2, color: Colors.black54)
                                ]),
                          ),
                          Text(
                            formattedDate,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                shadows: const [
                                  Shadow(blurRadius: 2, color: Colors.black54)
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withOpacity(0.85),
                  child: IconButton(
                    icon:
                        const Icon(Icons.block, color: Colors.red, size: 22),
                    tooltip: 'Block Post',
                    onPressed: () {
                      _showBlockConfirmationDialog(postId);
                    },
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              taskName,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    post['descript'] ?? 'ไม่มีคำอธิบาย',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 15, height: 1.4, color: Colors.grey[700]),
                  ),
                ),
                const SizedBox(width: 8),
                if (sdgNumbers.isNotEmpty)
                  Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 6.0,
                      runSpacing: 4.0,
                      children: sdgNumbers.map((number) {
                        final sdgInfo = sdgList.firstWhere(
                          (sdg) => sdg.number == number,
                          orElse: () => sdgList.first.copyWith(
                              number: 0, title: 'Unknown'),
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
                              fontSize: 11,
                            ),
                          ),
                          backgroundColor: sdgInfo.color,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
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
      subtitle: subtitle,
      color: color,
      backgroundImage: backgroundImage,
      activities: activities,
      uploaded: uploaded,
      goalImage: goalImage,
      description: '',
      targets: [],
    );
  }
}