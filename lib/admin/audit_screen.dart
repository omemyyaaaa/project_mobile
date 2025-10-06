import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/admin/homeamin.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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
        Uri.parse("http://10.153.27.172:3000/api/audit/all"),
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

  // 2. ฟังก์ชันแสดง Dialog ให้คะแนน
  Future<void> _showCompletionDialog(Map<String, dynamic> upload) async {
    final pointsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // ✅ แก้ไข: ดึง upload_id ให้ถูกต้อง
    final uploadId = upload['upload_id'];
    final username = upload['username'];

    // ป้องกันกรณีที่ uploadId เป็น null
    if (uploadId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: ไม่พบ ID ของผลงาน'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('อนุมัติและให้คะแนน'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ผลงานของ: $username',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: pointsController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'คะแนนที่จะให้',
                    prefixIcon: Icon(Icons.star, color: Colors.amber),
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
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('ยืนยัน'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // 3. เรียกฟังก์ชัน submit พร้อมส่ง uploadId และ points
                  _submitCompletion(
                    context,
                    uploadId,
                    int.parse(pointsController.text),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // 4. ฟังก์ชันส่งข้อมูลไป API เพื่อเปลี่ยนสถานะและให้คะแนน
  Future<void> _submitCompletion(
    BuildContext dialogContext,
    int uploadId,
    int points,
  ) async {
    Navigator.of(dialogContext).pop();

    try {
      // เรียก Endpoint สำหรับ complete
      final url = Uri.parse(
        "http://10.153.27.172:3000/api/audit/$uploadId/complete",
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'points': points}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ดำเนินการสำเร็จ!'),
            backgroundColor: Colors.green,
          ),
        );
        // สำคัญ: เรียก fetchAllUploads() เพื่อรีเฟรชหน้าจอ
        fetchAllUploads();
      } else {
        throw Exception('Failed to complete: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
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
          if (upload['tasks'] != null && upload['tasks'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Wrap(
                spacing: 8.0,
                children: (upload['tasks'].toString())
                    .split(',')
                    .map(
                      (task) => Chip(
                        label: Text(task.trim()),
                        backgroundColor: Colors.green[50],
                        labelStyle: TextStyle(color: Colors.green[800]),
                      ),
                    )
                    .toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Divider(),
          ),
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
