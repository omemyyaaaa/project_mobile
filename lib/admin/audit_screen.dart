import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/admin/homeamin.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:quickalert/quickalert.dart';

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  List userUploads = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('th', null);
    fetchAllUploads();
  }

  // 1. ดึงข้อมูล (API จะกรองเฉพาะ 'upcoming' มาให้แล้ว)
  Future<void> fetchAllUploads() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/api/audit/all"),
      );
      if (response.statusCode == 200) {
        setState(() {
          userUploads = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load uploads");
      }
    } catch (e) {
      print("❌ Error fetching uploads: $e");
      setState(() => isLoading = false);
    }
  }

    Widget _buildTaskChips(dynamic tasksData) {
    if (tasksData == null) {
      return const SizedBox.shrink(); // ถ้าไม่มีข้อมูล ก็ไม่ต้องแสดงอะไรเลย
    }

    List<String> tasksList = [];

    // ตรวจสอบว่าข้อมูลที่ได้มาเป็น List หรือไม่
    if (tasksData is List) {
      // ถ้าใช่ ก็แปลงแต่ละ item เป็น String
      tasksList = tasksData.map((task) => task.toString()).toList();
    } 
    // ถ้าข้อมูลที่ได้มาเป็น String (เช่น "{1,13,15}")
    else if (tasksData is String) {
      // ทำความสะอาด String โดยการลบวงเล็บปีกกา แล้วค่อย split
      tasksList = tasksData
          .replaceAll('{', '')
          .replaceAll('}', '')
          .split(',')
          .where((s) => s.trim().isNotEmpty) // กรองค่าว่างออก
          .toList();
    }

    // ถ้าไม่มี task เลย ก็ไม่ต้องแสดงอะไร
    if (tasksList.isEmpty) {
      return const SizedBox.shrink();
    }

    // สร้าง Chip จาก List ที่ทำความสะอาดแล้ว
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: tasksList.map((taskNumber) {
        return Chip(
          label: Text('SDGs ${taskNumber.trim()}'), // เพิ่มคำว่า "SDGs" เข้าไปข้างหน้า
          backgroundColor: Colors.green[50],
          labelStyle: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          side: BorderSide(color: Colors.green.shade200),
        );
      }).toList(),
    );
  }

  // 2. ฟังก์ชันแสดง Dialog ให้คะแนน
  Future<void> _showCompletionDialog(Map<String, dynamic> upload) async {
    final pointsController = TextEditingController();
    final feedbackController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final uploadId = upload['upload_id'];
    final username = upload['username'];

    if (uploadId == null) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'เกิดข้อผิดพลาด: ไม่พบ ID ของผลงาน');
      return;
    }

    QuickAlert.show(
      context: context,
      type: QuickAlertType.custom,
      barrierDismissible: true,
      title: 'อนุมัติและให้คะแนน',
      widget: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ผลงานของ: $username',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: pointsController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'คะแนนที่จะให้',
                prefixIcon: const Icon(Icons.star, color: Colors.amber),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    int.tryParse(value) == null) {
                  return 'กรุณาใส่คะแนนเป็นตัวเลข';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: feedbackController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'ข้อเสนอแนะ (ไม่บังคับ)',
                hintText: 'เช่น "ทำได้ดีมากครับ!"',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      showCancelBtn: true,
      confirmBtnText: 'ยืนยัน',
      cancelBtnText: 'ยกเลิก',
      onConfirmBtnTap: () {
        if (formKey.currentState!.validate()) {
          // ปิด QuickAlert ก่อน แล้วค่อยส่งข้อมูล
          Navigator.of(context, rootNavigator: true).pop();
          _submitCompletion(
            uploadId,
            int.parse(pointsController.text),
            feedbackController.text.trim(),
          );
        }
      },
    );
  }

  // 4. ฟังก์ชันส่งข้อมูลไป API เพื่อเปลี่ยนสถานะและให้คะแนน
  Future<void> _submitCompletion(
      int uploadId, int points, String feedback) async {
    try {
      final url = Uri.parse(
        "http://10.0.2.2:3000/api/audit/$uploadId/complete",
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'points': points,
          'feedback': feedback,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'สำเร็จ!',
          text: 'อนุมัติผลงานและให้คะแนนเรียบร้อยแล้ว',
        );
        fetchAllUploads(); // รีเฟรชหน้าจอ
      } else {
        throw Exception('Failed to complete: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'เกิดข้อผิดพลาด',
        text: 'ไม่สามารถดำเนินการได้: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F5E8),
      appBar: AppBar(
        title: Text("อนุมัติผลงาน"),
        backgroundColor: Color(0xFF2E7D32),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MyHomeadmin()),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Color(0xFF2E7D32),
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Text(
              'ผลงานที่รอการอนุมัติ (${userUploads.length} รายการ)',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Color(0xFFE8F5E8),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: fetchAllUploads,
                      child: userUploads.isEmpty
                          ? Center(
                              child: Text(
                                'ไม่มีผลงานที่รอการอนุมัติ',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: userUploads.length,
                              itemBuilder: (context, index) {
                                final upload = userUploads[index];
                                return _buildUploadCard(upload);
                              },
                            ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard(Map<String, dynamic> upload) {
    final username = upload['username'] ?? 'ไม่ระบุชื่อ';
    final profileUrl = upload['profile_url'];
    final uploadedDateString = upload['uploaded_date'];
    final formattedDate = uploadedDateString != null
        ? DateFormat(
            'd MMMM yyyy',
            'th',
          ).format(DateTime.parse(uploadedDateString))
        : 'ไม่ระบุวันที่';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: profileUrl != null
                      ? NetworkImage(profileUrl)
                      : null,
                  child: profileUrl == null
                      ? Icon(Icons.person, color: Colors.grey[600])
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'อัปโหลดเมื่อ: $formattedDate', // <-- นำตัวแปรที่จัดการแล้วมาแสดง
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (upload["image_url"] != null)
            Image.network(
              upload["image_url"],
              fit: BoxFit.cover,
              width: double.infinity,
              height: 220,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 220,
                color: Colors.grey[200],
                child: Center(
                  child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                ),
              ),
            ),
          if (upload['descript'] != null &&
              upload['descript'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Text(
                upload['descript'],
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
           Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: _buildTaskChips(upload['tasks']),
          ),

          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.check_circle_outline),
                label: Text('อนุมัติและให้คะแนน'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  _showCompletionDialog(upload);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
