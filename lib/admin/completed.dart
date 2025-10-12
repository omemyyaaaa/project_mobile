import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/admin/editadmin.dart';
import 'package:flutter_application_1/admin/homeamin.dart';
import 'package:flutter_application_1/admin/score_task_page.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';

class CompletedTasksPage extends StatefulWidget {
  const CompletedTasksPage({super.key});

  @override
  State<CompletedTasksPage> createState() => _CompletedTasksPageState();
}

class _CompletedTasksPageState extends State<CompletedTasksPage> {
  List finishedTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFinishedTasks();
  }

  Future<void> fetchFinishedTasks() async {
    if (mounted) setState(() => isLoading = true);
    try {
      // ✅ **Corrected the URL to match your API route (removed '/api')**
      final response = await http.get(Uri.parse("http://10.0.2.2:3000/tasks/"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allTasks = data["tasks"] as List? ?? [];

        // ✅ **Adjusted the filter to only show 'completed' tasks**
        final filteredTasks = allTasks.where((task) {
          final status = task['calculated_status'] ?? '';
          return status == 'completed'; // Only show completed tasks
        }).toList();

        if (mounted) {
          setState(() {
            finishedTasks = filteredTasks;
            isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to load tasks: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching finished tasks: $e");
      if (mounted) setState(() => isLoading = false);
       QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'เกิดข้อผิดพลาด',
          text: 'ไม่สามารถดึงข้อมูลภารกิจที่เสร็จสิ้นได้',
        );
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F5E8),
      appBar: AppBar(
        backgroundColor: Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // กลับไปหน้า Home Admin
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomeadmin()),
            );
          },
        ),
        title: Text("ภารกิจที่สิ้นสุดแล้ว"),
      ),
      body: _buildFinishedTaskList(),
    );
  }

  Widget _buildFinishedTaskList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (finishedTasks.isEmpty) {
      return Center(
        child: Text(
          "ยังไม่มีภารกิจที่สิ้นสุดแล้ว",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: fetchFinishedTasks,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: finishedTasks.length,
        itemBuilder: (context, index) {
          final task = finishedTasks[index];
          final taskStatus = task['calculated_status'] ?? 'completed';
          final sdgsList = task['sdgs'] is List
              ? (task['sdgs'] as List).whereType<int>().toList()
              : <int>[];

          return Card(
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section for Image
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: task["image"] != null && task["image"].isNotEmpty
                        ? Image.network(
                            task["image"],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                    size: 50,
                                  ),
                                ),
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(
                                Icons.eco,
                                color: Colors.grey[600],
                                size: 50,
                              ),
                            ),
                          ),
                  ),
                ),
                // Section for Task Details
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task["title"] ?? "ไม่มีหัวข้อภารกิจ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              task["location"] ?? "ไม่ระบุสถานที่",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            task["activity_date"] != null
                                ? DateFormat('dd/MM/yyyy').format(
                                    DateTime.parse(task["activity_date"]),
                                  )
                                : 'N/A',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        task["description"] ?? "ไม่มีรายละเอียด",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.person, size: 18, color: Colors.black87),
                          SizedBox(width: 4),
                          Text(
                            // ❗️❗️ แก้ไขบรรทัดนี้ ❗️❗️
                            '${task["current_participants"] ?? 0}/${task["participants"] ?? "N/A"}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Spacer(),
                          if (sdgsList.isNotEmpty)
                            Wrap(
                              spacing: 6,
                              children: sdgsList.map((sdg) {
                                return Chip(
                                  label: Text(
                                    "SDG$sdg",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                  backgroundColor: Colors.green[100],
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 0,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          // 1. Chip แสดงสถานะ (ไม่ต้องมี Center หรือ Expanded ครอบ)
                          Chip(
                            avatar: Icon(
                              taskStatus == 'completed'
                                  ? Icons.check_circle
                                  : Icons.warning,
                              color: taskStatus == 'completed'
                                  ? Colors.green
                                  : Colors.orange,
                              size: 18,
                            ),
                            label: Text(
                              taskStatus == 'completed'
                                  ? 'เสร็จสิ้นแล้ว'
                                  : 'เลยกำหนด',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: taskStatus == 'completed'
                                ? Colors.green[100]
                                : Colors.orange[100],
                          ),

                          // 2. Spacer เพื่อดันปุ่มไปทางขวา
                          const Spacer(),

                          // 3. ปุ่ม 'ให้คะแนน'
                          ElevatedButton.icon(
                            onPressed: () {
                              // ❗️❗️ แก้ไขส่วนนี้ ❗️❗️
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScoreTaskPage(
                                    task:
                                        task, // ส่งข้อมูล task ทั้งหมดไปที่หน้าให้คะแนน
                                  ),
                                ),
                              );
                            },

                            icon: const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.black87,
                            ),
                            label: const Text('ให้คะแนน'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[600],
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
