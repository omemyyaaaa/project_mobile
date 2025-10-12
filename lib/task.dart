// user_task_list_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/sdg_data.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';

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
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final url = Uri.parse(
        'http://10.0.2.2:3000/tasks/sdg/${widget.sdgId}?userId=${widget.userId}',
      );
      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // กรองเอาเฉพาะภารกิจที่ยังไม่เสร็จ (เผื่อ API ส่งมาเกิน)
        final unfinishedTasks = (data["tasks"] as List? ?? []).where((task) {
          final status = task['calculated_status'];
          return status != 'completed' && status != 'cancelled';
        }).toList();

        setState(() {
          tasks = unfinishedTasks;
          isLoading = false;
        });
      } else {
        setState(() {
          error = "ไม่สามารถโหลดข้อมูลได้: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = "เกิดข้อผิดพลาดในการเชื่อมต่อ: $e";
          isLoading = false;
        });
      }
    }
  }


  Future<void> _joinTask(int taskId, String taskTitle) async {
  final url = Uri.parse('http://10.0.2.2:3000/tasks/join'); 

  // เปลี่ยนมาใช้ QuickAlert เพื่อให้เหมือนกับฟังก์ชันอื่น
  QuickAlert.show(
    context: context,
    type: QuickAlertType.loading,
    text: 'กำลังเข้าร่วม...',
    disableBackBtn: true,
  );

  try {
    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'userId': widget.userId,
            'taskId': taskId,
          }),
        )
        .timeout(const Duration(seconds: 10));

    // ปิด Loading Alert
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
    if (!mounted) return;

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 201) {
      // ใช้ taskTitle ที่รับมาได้เลย
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'เข้าร่วมสำเร็จ!',
        text: 'คุณได้เข้าร่วมภารกิจ "$taskTitle" เรียบร้อยแล้ว',
      );
      fetchTasksBySdg(); // รีเฟรชข้อมูล
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'ผิดพลาด',
        text: responseData['message'] ?? 'เกิดข้อผิดพลาดในการเข้าร่วม',
      );
    }
  } catch (e) {
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
    if (!mounted) return;
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'การเชื่อมต่อล้มเหลว',
      text: 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้',
    );
  }
}

  void _showJoinConfirmationDialog(int taskId, String taskTitle) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'ยืนยันการเข้าร่วม',
      text: 'คุณต้องการเข้าร่วมภารกิจ "$taskTitle" ใช่หรือไม่?',
      confirmBtnText: 'ยืนยัน',
      cancelBtnText: 'ยกเลิก',
      confirmBtnColor: Colors.green,
      onConfirmBtnTap: () {
        Navigator.of(context, rootNavigator: true).pop();
        _joinTask(taskId, taskTitle);
      },
    );
  }

  Future<void> _cancelTask(int taskId, String taskTitle) async {
    // 🚨🚨 ตรวจสอบ Endpoint ของคุณให้ถูกต้อง 🚨🚨
    final url = Uri.parse('http://10.0.2.2:3000/tasks/cancel'); 

    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      text: 'กำลังยกเลิก...',
      disableBackBtn: true,
    );

    try {
      final response = await http
          .delete(
            url,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'userId': widget.userId, 'taskId': taskId}),
          )
          .timeout(const Duration(seconds: 10));

      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      if (!mounted) return;

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'ยกเลิกสำเร็จ!',
          text: 'คุณได้ยกเลิกการเข้าร่วมภารกิจ "$taskTitle" แล้ว',
        );
        fetchTasksBySdg(); // รีเฟรชข้อมูล
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'ผิดพลาด',
          text: responseData['message'] ?? 'เกิดข้อผิดพลาดในการยกเลิก',
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      if (!mounted) return;
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'การเชื่อมต่อล้มเหลว',
        text: 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้',
      );
    }
  }

  void _showCancelConfirmationDialog(int taskId, String taskTitle) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'ยืนยันการยกเลิก',
      text: 'คุณต้องการยกเลิกการเข้าร่วมภารกิจ "$taskTitle" ใช่หรือไม่?',
      confirmBtnText: 'ใช่, ยกเลิก',
      cancelBtnText: 'ไม่',
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () {
        Navigator.of(context, rootNavigator: true).pop();
        _cancelTask(taskId, taskTitle);
      },
    );
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

     return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index] as Map<String, dynamic>;
        return _buildTaskCard(task);
      },
    );
  }

    // UI ส่วนที่เหลือจะเหมือนกับหน้า Tasking ของผู้ใช้
   Widget _buildTaskCard(Map<String, dynamic> task) {
    final bool isJoined = task['is_joined'] ?? false;
    final status = task['calculated_status'] as String?;
    final taskId = task["task_id"];
    final taskTitle = task["title"] ?? "ไม่มีชื่อภารกิจ";

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
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (ส่วนแสดงผลข้อมูลภารกิจเหมือนเดิม) ...
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
                child: task["image"] != null && task["image"].toString().isNotEmpty
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

                   if (status == 'upcoming' || isJoined)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: isJoined
                    // 🟢 ถ้าเข้าร่วมแล้ว (isJoined = true) -> แสดงปุ่ม "ยกเลิก"
                    ? ElevatedButton.icon(
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('ยกเลิกการเข้าร่วม'),
                        onPressed: () {
                          if (taskId != null) {
                            _showCancelConfirmationDialog(taskId, taskTitle);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      )
                    // 🔴 ถ้ายังไม่เข้าร่วม (isJoined = false) และ status เป็น 'upcoming' -> แสดงปุ่ม "เข้าร่วม"
                    : (status == 'upcoming'
                        ? ElevatedButton.icon(
                            icon: const Icon(Icons.add_task),
                            label: const Text('เข้าร่วมภารกิจ'),
                            onPressed: () {
                              if (taskId != null) {
                                _showJoinConfirmationDialog(taskId, taskTitle);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          )
                        : const SizedBox.shrink()), // ถ้าไม่เข้าเงื่อนไข ไม่ต้องแสดงอะไรเลย
              ),
            ),
                  ],
                ),
              ),
            ],
          ),
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
