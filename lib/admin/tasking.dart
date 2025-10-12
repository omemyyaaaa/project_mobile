import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/admin/creation.dart';
import 'package:flutter_application_1/admin/editadmin.dart';
import 'package:flutter_application_1/admin/homeamin.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart'; // ✅ 1. เพิ่ม import

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
    // ไม่ต้องเช็ค if (mounted) ตอนต้น เพื่อให้ RefreshIndicator ทำงานได้
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("http://10.0.2.2:3000/tasks/"));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allTasks = data["tasks"] as List? ?? [];

        final upcomingTasks = allTasks.where((task) {
          final status = task['calculated_status'] ?? '';
          return status == 'upcoming';
        }).toList();

        setState(() {
          tasks = upcomingTasks;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load tasks");
      }
    } catch (e) {
      print("❌ Error: $e");
      if(mounted) {
        setState(() => isLoading = false);
        // ✅ 2. ใช้ QuickAlert แจ้งเตือนเมื่อเกิด Error
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'เกิดข้อผิดพลาด',
          text: 'ไม่สามารถดึงข้อมูลภารกิจได้',
        );
      }
    }
  }

  // ✅ 3. สร้างฟังก์ชันสำหรับแสดง Pop-up ยืนยันก่อนกดเสร็จสิ้น
  Future<void> _showCompleteConfirmationDialog(int taskId, String taskTitle) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'ยืนยันการดำเนินการ',
      text: 'คุณต้องการสิ้นสุดภารกิจ "$taskTitle" ใช่หรือไม่?',
      confirmBtnText: 'ยืนยัน',
      cancelBtnText: 'ยกเลิก',
      confirmBtnColor: Colors.green,
      onConfirmBtnTap: () {
        Navigator.of(context, rootNavigator: true).pop(); // ปิด Pop-up ยืนยัน
        _completeTask(taskId, taskTitle); // เรียกฟังก์ชันทำงานจริง
      },
    );
  }

  // ✅ 4. แก้ไขฟังก์ชัน _completeTask ให้ใช้ QuickAlert
  Future<void> _completeTask(int taskId, String taskTitle) async {
    final url = Uri.parse('http://10.0.2.2:3000/tasks/$taskId/complete');

    try {
      final response = await http.patch(url);
      if (!mounted) return;

      if (response.statusCode == 200) {
        // เมื่อสำเร็จ ให้แสดง QuickAlert แบบ success
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'สำเร็จ!',
          text: 'ภารกิจ "$taskTitle" ได้สิ้นสุดลงแล้ว',
        );
        fetchTasks(); // รีเฟรชรายการ
      } else {
        throw Exception('Failed to complete task: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      // เมื่อ Error ให้แสดง QuickAlert แบบ error
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'เกิดข้อผิดพลาด',
        text: 'ไม่สามารถอัปเดตสถานะภารกิจได้',
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomeadmin()),
            );
          },
        ),
        // ✅ 5. แก้ไข Title ให้ตรงกับข้อมูลที่แสดง
        title: Text("ภารกิจที่กำลังจะมาถึง"),
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xFF2E7D32),
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Tasks (${tasks.length})',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.add, size: 18),
                  label: Text('สร้างภารกิจ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TaskCreationScreen()),
                    ).then((_) {
                      // เมื่อกลับมาจากหน้าสร้าง ให้ดึงข้อมูลใหม่
                      fetchTasks();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator( // ✅ 6. เพิ่ม RefreshIndicator ครอบ ListView
                    onRefresh: fetchTasks, // เมื่อดึง จะเรียกฟังก์ชันนี้
                    child: tasks.isEmpty
                        ? Center(
                            child: Text(
                            // ✅ 7. แก้ไขข้อความ
                            "ไม่มีภารกิจที่กำลังจะมาถึง",
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ))
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              
                              List<int> sdgs = [];
                              if (task["sdgs"] is List) {
                                sdgs = (task["sdgs"] as List)
                                  .map((item) => int.tryParse(item.toString()) ?? 0)
                                  .where((item) => item > 0)
                                  .toList();
                              }

                              return Card(
                                margin: EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (task["image"] != null && task["image"].isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                        child: Image.network(
                                          task["image"],
                                          height: 160,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            height: 160,
                                            color: Colors.grey[200],
                                            child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // ✅✅✅ START: โค้ดส่วนที่แก้ไข Layout ✅✅✅
                                          
                                          // 1. ย้ายวันที่มาไว้ข้างบนสุด
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                              SizedBox(width: 6),
                                              Text(
                                                task["activity_date"] != null
                                                    ? DateFormat('dd MMMM yyyy', 'th_TH').format(DateTime.parse(task["activity_date"]))
                                                    : 'ไม่ระบุวันที่',
                                                style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),

                                          // 2. ชื่อภารกิจ (Title)
                                          Text(
                                            task["title"] ?? "ไม่มีหัวข้อภารกิจ",
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                          ),
                                          SizedBox(height: 8),
                                          
                                          // 3. คำอธิบาย (Description)
                                          Text(
                                            task["description"] ?? "ไม่มีรายละเอียด",
                                            style: TextStyle(color: Colors.grey[800], height: 1.4),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 16),

                                          // 4. จำนวนคน และ ป้าย SDG ในบรรทัดเดียวกัน
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(Icons.person, size: 18, color: Colors.grey[700]),
                                              SizedBox(width: 4),
                                              Text(
                                                '${task["current_participants"] ?? 0}/${task["participants"] ?? "N/A"}',
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                              ),
                                              Spacer(), // ตัวดันไปทางขวา
                                              if (sdgs.isNotEmpty)
                                                Wrap(
                                                  spacing: 6,
                                                  children: sdgs.map((sdg) {
                                                    return Chip(
                                                      label: Text(
                                                        "SDG $sdg",
                                                        style: TextStyle(fontSize: 10, color: Colors.green[800], fontWeight: FontWeight.bold),
                                                      ),
                                                      backgroundColor: Colors.green[100],
                                                      padding: EdgeInsets.zero,
                                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                      visualDensity: VisualDensity(horizontal: 0.0, vertical: -4), // ทำให้ Chip เล็กลง
                                                    );
                                                  }).toList(),
                                                ),
                                            ],
                                          ),
                                          
                                          // ✅✅✅ END: โค้ดส่วนที่แก้ไข Layout ✅✅✅

                                          Divider(height: 32),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () {
                                                    final taskId = task["task_id"];
                                                    final taskTitle = task["title"] ?? "ภารกิจ";
                                                    if (taskId != null) {
                                                      _showCompleteConfirmationDialog(taskId, taskTitle);
                                                    }
                                                  },
                                                  icon: Icon(Icons.check, size: 18),
                                                  label: Text('เสร็จสิ้น'),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => EditTaskScreen(taskData: task)),
                                                    ).then((_) => fetchTasks());
                                                  },
                                                  icon: Icon(Icons.edit, size: 18),
                                                  label: Text('แก้ไข'),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700], foregroundColor: Colors.black87),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
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