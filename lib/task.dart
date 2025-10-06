// user_task_list_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/sdg_data.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class UserTaskListPage extends StatefulWidget {
  final int sdgId;
  final int userId;

  const UserTaskListPage({
    super.key,
    required this.sdgId,
    required this.userId,
  });

  @override
  State<UserTaskListPage> createState() => _UserTaskListPageState();
}

class _UserTaskListPageState extends State<UserTaskListPage> {
  List tasks = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchTasksBySdg();
  }

  Future<void> fetchTasksBySdg() async {
    try {
      // ✅ เรียก API endpoint ใหม่ที่กรองตาม SDG
      final url = Uri.parse('http://10.153.27.172:3000/tasks/sdg/${widget.sdgId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allTasks = data["tasks"] as List? ?? [];

        // กรองเฉพาะภารกิจที่ยังไม่เริ่ม (เผื่อ API ส่งสถานะอื่นมาด้วย)
        final relevantTasks = allTasks.where((task) {
          final status = task['calculated_status'] as String?;
          return status != 'completed' && status != 'cancelled';
        }).toList();

        setState(() {
          tasks = relevantTasks;
          isLoading = false;
        });
      } else {
        setState(() {
          error = "ไม่สามารถโหลดข้อมูลได้: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "เกิดข้อผิดพลาดในการเชื่อมต่อ";
        isLoading = false;
      });
    }
  }

  Future<void> _joinTask(int taskId) async {
    // 🚨🚨 แก้ไข URL ตรงนี้ให้เป็น /api/participation/join 🚨🚨
    final url = Uri.parse('http://10.153.27.172:3000/api/participation/join');

    // 💡 หากใช้ iOS Simulator หรือ Device จริง ให้เปลี่ยน 10.153.27.172 เป็น IP ของเครื่องคอมพิวเตอร์คุณ
    //    เช่น final url = Uri.parse('http://192.168.1.xxx:3000/api/participation/join');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'userId': widget.userId, // ใช้ userId ที่รับมาจาก widget
              'taskId': taskId,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      final responseData = jsonDecode(response.body);
      final taskTitle = tasks.firstWhere(
        (t) => t['task_id'] == taskId,
      )['title'];

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('คุณเข้าร่วมภารกิจ "$taskTitle" สำเร็จแล้ว!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        fetchTasksBySdg();
      } else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ?? 'คุณได้เข้าร่วมภารกิจนี้แล้ว',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        final errorMessage =
            responseData['message'] ?? 'เกิดข้อผิดพลาดในการเข้าร่วมภารกิจ';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('การเชื่อมต่อล้มเหลว (joinTask): $e'), // เพิ่ม context
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F5E8),
      appBar: AppBar(
        title: Text('ภารกิจ SDG ${widget.sdgId}'),
        backgroundColor: Color(0xFF2E7D32),
      ),
      body: buildTaskList(),
    );
  }

  Widget buildTaskList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text(error!));
    }
    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          'ยังไม่มีภารกิจสำหรับเป้าหมายนี้',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // UI ส่วนที่เหลือจะเหมือนกับหน้า Tasking ของผู้ใช้
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final status = task['calculated_status'] as String?;
        List<int> sdgs = [];
        if (task["sdgs"] != null && task["sdgs"] is List) {
          sdgs = (task["sdgs"] as List)
              .map((item) => int.tryParse(item.toString()) ?? 0)
              .where((item) => item > 0)
              .toList();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child:
                    task["image"] != null && task["image"].toString().isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Image.network(
                          task["image"],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 50,
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.eco,
                          color: Colors.grey[600],
                          size: 50,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task["title"] ?? "ไม่มีหัวข้อภารกิจ",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            task["location"] ?? "ไม่ระบุสถานที่",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task["activity_date"] != null
                              ? DateFormat(
                                  'dd/MM/yyyy',
                                ).format(DateTime.parse(task["activity_date"]))
                              : "ไม่ระบุวันที่",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      task['description'] ?? 'ไม่มีคำอธิบายภารกิจ',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildDetailRow(
                      Icons.star_outline,
                      '${task["points"] ?? 0} คะแนน',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 18,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${task["current_participants"] ?? 0}/${task["participants"] ?? "N/A"}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const Spacer(),
                        if (sdgs.isNotEmpty)
                          Row(
                            children: sdgs.map((sdgNumber) {
                              // ค้นหาข้อมูล SDG จาก sdgList เพื่อเอาสีมาใช้
                              final sdgInfo = sdgList.firstWhere(
                                (item) => item.number == sdgNumber,
                                orElse: () => sdgList.first, // Fallback
                              );

                              return Container(
                                margin: const EdgeInsets.only(left: 6),
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: sdgInfo.color, // ใช้สีจาก sdgList
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '$sdgNumber', // แสดงตัวเลข
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),

                    if (status == 'upcoming')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final taskId = task["task_id"];
                            if (taskId != null) {
                              _joinTask(taskId);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'เข้าร่วมภารกิจ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildDetailRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 16, color: Colors.grey[600]),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
