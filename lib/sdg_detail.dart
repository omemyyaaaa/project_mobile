import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/inforsdg.dart';
import 'package:flutter_application_1/task.dart';
import 'package:flutter_application_1/upload.dart';
import 'package:http/http.dart' as http;
import 'sdg_data.dart'; // ยังคงต้องใช้เพื่อดึงข้อมูล static

class SDGDetailPage extends StatefulWidget {
  final int sdgNumber;
  final int userId;

  const SDGDetailPage({
    super.key,
    required this.sdgNumber,
    required this.userId,
  });

  @override
  _SDGDetailPageState createState() => _SDGDetailPageState();
}

class _SDGDetailPageState extends State<SDGDetailPage> {
  int completedTasks = 0;
  int notCompletedTasks = 0;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchSdgSummary();
  }

  Future<void> _fetchSdgSummary() async {
    try {
      final url = Uri.parse(
        'http://10.153.27.172:3000/tasks/sdg/${widget.sdgNumber}/summary',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (mounted) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            completedTasks = data['completed'] ?? 0;
            notCompletedTasks = data['not_completed'] ?? 0;
            isLoading = false;
          });
        } else {
          setState(() {
            error = 'ไม่สามารถโหลดข้อมูลได้: ${response.statusCode}';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'เกิดข้อผิดพลาดในการเชื่อมต่อ';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูลแบบ Static จาก sdgList เหมือนเดิม
    final SDGData data = sdgList.firstWhere(
      (element) => element.number == widget.sdgNumber,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: data.color,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications, color: Colors.white),
          ),
        ],
      ),
      // ✅ body แสดงผล Stack โดยตรง ไม่มีการเช็ค loading หรือ error
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : Stack(
              // ... UI ส่วนที่เหลือเหมือนเดิม แต่จะแก้ไขส่วนแสดงผลตัวเลข
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          data.color,
                          Color.lerp(data.color, Colors.white, 0.5)!,
                          Colors.white,
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    // ... ส่วนหัว Title, Subtitle ...
                    Container(
                      color: Colors.transparent,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${data.number}',
                            style: const TextStyle(
                              fontSize: 58,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            data.title,
                            style: const TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            data.subtitle,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 300, // ลดความสูงลงเล็กน้อย
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(data.backgroundImage),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.2),
                                  BlendMode.darken,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Image.asset(
                              data.goalImage,
                              height: 500,
                              fit: BoxFit.contain,
                            ),
                          ),
                          // ✅ 5. แก้ไขส่วนแสดงผลตัวเลข
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              height: 200,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildCounterColumn(
                                    Icons.check_circle_outline,
                                    '$completedTasks',
                                    'เสร็จสิ้นแล้ว',
                                  ),
                                  _buildCounterColumn(
                                    Icons.schedule,
                                    '$notCompletedTasks',
                                    'ยังไม่เสร็จ',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildBox(
                                  context,
                                  'เกี่ยวกับ',
                                  Icons.edit_note,
                                  data.color.withOpacity(0.7),
                                  // --- เพิ่ม onTap ตรงนี้ ---
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SdgInfoPage(
                                          data: data,
                                        ), // ส่งข้อมูล SDG ไปยังหน้าใหม่
                                      ),
                                    );
                                  },
                                ),
                                _buildBox(
                                  context,
                                  'ภารกิจ', // เปลี่ยนจาก 'เป้าหมาย'
                                  Icons.flag,
                                  data.color,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        // TODO: สร้างหน้า TaskListPage ที่รับ sdgId เพื่อแสดงรายการภารกิจ
                                        builder: (context) => UserTaskListPage(
                                          sdgId: data
                                              .number, // ส่ง sdg number ของหน้านี้ไป
                                          userId: widget
                                              .userId, // ส่ง userId ของผู้ใช้ไป
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildBox(
                              context,
                              'อัปโหลดรูปกิจกรรม',
                              Icons.cloud_upload,
                              Colors.brown.shade200,
                              fullWidth: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UploadPage(userId: widget.userId),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  // Widget สำหรับสร้าง Counter
  Widget _buildCounterColumn(IconData icon, String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

Widget _buildBox(
  BuildContext context,
  String label,
  IconData icon,
  Color color, {
  bool fullWidth = false,
  VoidCallback? onTap,
}) {
  return SizedBox(
    width: fullWidth
        ? double.infinity
        : MediaQuery.of(context).size.width * 0.4,
    child: ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.black),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(label, style: const TextStyle(color: Colors.black)),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
