import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/admin/creation.dart';
import 'package:flutter_application_1/admin/editadmin.dart';
import 'package:flutter_application_1/admin/homeamin.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Tasking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasks Admin',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List tasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      // The endpoint is correct, it fetches all tasks
      final response = await http.get(Uri.parse("http://10.0.2.2:3000/tasks/"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Get the full list of tasks from the response
        final allTasks = data["tasks"] as List? ?? [];

        // ✅ **Filter the list to only keep tasks with 'upcoming' status**
        final upcomingTasks = allTasks.where((task) {
          // Use the 'calculated_status' field from your API
          final status = task['calculated_status'] ?? 'upcoming';
          return status == 'upcoming';
        }).toList();

        setState(() {
          // Set the state with the filtered list
          tasks = upcomingTasks;
          isLoading = false;
        });
      } else {
        print("📡 Status: ${response.statusCode}");
        print("📡 Body: ${response.body}");
        throw Exception("Failed to load tasks");
      }
    } catch (e) {
      print("❌ Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _completeTask(int taskId) async {
    // สร้าง URL สำหรับ API endpoint ที่จะอัปเดตสถานะ
    final url = Uri.parse('http://10.0.2.2:3000/tasks/$taskId/complete');

    try {
      // ส่งคำขอ PATCH เพื่ออัปเดตสถานะ
      final response = await http.patch(url);

      if (response.statusCode == 200) {
        print('Task $taskId completed successfully.');

        // แสดง SnackBar เมื่อทำสำเร็จ
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'ภารกิจ "${tasks.firstWhere((t) => t['task_id'] == taskId)['title']}" เสร็จสิ้นแล้ว!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }

        // รีเฟรชรายการภารกิจใหม่
        fetchTasks();
      } else {
        // กรณีเกิดข้อผิดพลาดจากเซิร์ฟเวอร์
        print('Failed to complete task. Status: ${response.statusCode}');
        print('Response: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เกิดข้อผิดพลาดในการอัปเดตภารกิจ'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // กรณีเกิดข้อผิดพลาดในการเชื่อมต่อ
      print('Error completing task: $e');
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomeadmin()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            color: Color(0xFF2E7D32),
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.eco, color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'ภารกิจ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskCreationScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[400],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'สร้างภารกิจ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tasks List
          Expanded(
            child: Container(
              color: Color(0xFFE8F5E8),
              padding: EdgeInsets.all(16),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];

                        // แก้ไขการจัดการ SDGs ให้ปลอดภัย
                        List<int> sdgs = [];
                        if (task["sdgs"] != null) {
                          if (task["sdgs"] is List) {
                            sdgs = (task["sdgs"] as List)
                                .where((item) => item != null)
                                .map(
                                  (item) => item is int
                                      ? item
                                      : int.tryParse(item.toString()) ?? 0,
                                )
                                .where((item) => item > 0)
                                .cast<int>()
                                .toList();
                          }
                        }

                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // รูปภาพหรือพื้นหลังสีเทา
                              Container(
                                height: 160,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child:
                                    task["image"] != null &&
                                        task["image"].toString().isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                        child: Image.network(
                                          task["image"],
                                          height: 160,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[300],
                                                  child: Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.eco,
                                                          size: 48,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                        SizedBox(height: 8),
                                                        Text(
                                                          'รูปภาพกิจกรรมกิจกรรม',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey[600],
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                        ),
                                      )
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.eco,
                                              size: 48,
                                              color: Colors.grey[600],
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'รูปภาพกิจกรรม',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),

                              // ข้อมูลภารกิจ
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ✅ แสดงผล Title
                                    Text(
                                      task["title"] ?? "ไม่มีหัวข้อภารกิจ",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                    SizedBox(height: 8),

                                    // Location
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            task["location"] ??
                                                "ไม่ระบุสถานที่",
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

                                    // Activity Date
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          task["activity_date"] != null
                                              ? DateFormat('dd/MM/yyyy').format(
                                                  DateTime.parse(
                                                    task["activity_date"],
                                                  ),
                                                )
                                              : '02/05/2025',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),

                                    // Description
                                    Text(
                                      task["description"] ?? "รายละเอียดภารกิจ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                        height: 1.3,
                                      ),
                                    ),
                                    SizedBox(height: 16),

                                    // Participants and SDG Tags
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 18,
                                          color: Colors.black87,
                                        ),
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
                                        if (sdgs.isNotEmpty)
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: sdgs.map((sdg) {
                                              return Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green[100],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.green[300]!,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  "SDG$sdg",
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.green[700],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 16),

                                    // Action Buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            // ✅ 2. เปลี่ยน onPressed ให้เรียกฟังก์ชัน _completeTask
                                            onPressed: () {
                                              final taskId = task["task_id"];
                                              if (taskId != null) {
                                                _completeTask(taskId);
                                              }
                                            },
                                            // ✅ 3. เปลี่ยนสีปุ่มให้เป็นสีเขียวเพื่อให้สื่อถึงการเสร็จสิ้น
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFF4CAF50,
                                              ), // สีเขียว
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              elevation: 0,
                                            ),
                                            // ✅ 1. เปลี่ยนข้อความบนปุ่ม
                                            child: Text(
                                              'ภารกิจเสร็จสิ้น',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditTaskScreen(
                                                        taskData: task,
                                                      ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFFFFC107,
                                              ),
                                              foregroundColor: Colors.black87,
                                              padding: EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: Text(
                                              'แก้ไขข้อมูล',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
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
            ),
          ),
        ],
      ),
    );
  }
}
