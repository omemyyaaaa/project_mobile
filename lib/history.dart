import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/admin/pubadmin.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// หน้านี้จะแสดงประวัติภารกิจที่ผู้ใช้อัปโหลดและเสร็จสิ้นแล้ว
class HistoryPage extends StatefulWidget {
  final int userId;

  const HistoryPage({super.key, required this.userId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool isLoading = true;
  List historyList = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  // ฟังก์ชันสำหรับดึงข้อมูลจาก API
  Future<void> fetchHistory() async {
    // รีเซ็ต state และเริ่ม loading
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // สร้าง URL ไปยัง API endpoint ที่เราสร้างไว้ใน history.js
      final url = Uri.parse('http://10.0.2.2:3000/history/${widget.userId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // ดึงข้อมูลจาก key 'history' ที่เรากำหนดไว้ใน API
          historyList = data['history'] as List? ?? [];
        });
      } else {
        setState(() {
          errorMessage = "ไม่สามารถโหลดข้อมูลได้ (Code: ${response.statusCode})";
        });
      }
    } catch (e) {
      print("❌ Error fetching history: $e");
      setState(() {
        errorMessage = "เกิดข้อผิดพลาดในการเชื่อมต่อ";
      });
    } finally {
      // เมื่อเสร็จสิ้น ให้หยุด loading
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _publishPost(int uploadId) async {
    final url = Uri.parse('http://10.0.2.2:3000/history/$uploadId/publish');

    try {
      final response = await http.patch(url); // ใช้ http.patch

      if (!mounted) return; // ตรวจสอบว่า Widget ยังอยู่ก่อนใช้งาน context

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('โพสต์สำเร็จแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
        // ดึงข้อมูลใหม่เพื่อให้รายการที่โพสต์ไปแล้วหายไปจากหน้าจอ
        fetchHistory(); 
      } else {
        final data = json.decode(response.body);
        final errorMsg = data['error'] ?? 'เกิดข้อผิดพลาดในการโพสต์';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('การเชื่อมต่อล้มเหลว: $e'),
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
        title: const Text('ประวัติภารกิจที่สำเร็จ'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: _buildBody(),
    );
  }

  // Widget สำหรับจัดการการแสดงผลตามสถานะต่างๆ
  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }
    if (historyList.isEmpty) {
      return const Center(
        child: Text(
          'คุณยังไม่มีประวัติภารกิจที่สำเร็จ',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    
    // ใช้ RefreshIndicator เพื่อให้ผู้ใช้ดึงข้อมูลใหม่ได้
    return RefreshIndicator(
      onRefresh: fetchHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: historyList.length,
        itemBuilder: (context, index) {
          final item = historyList[index];
          return _buildHistoryCard(item);
        },
      ),
    );
  }

  // Widget สำหรับสร้าง Card ของแต่ละรายการ
  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final String imageUrl = item['image_url']?.toString() ?? '';
    final String description = item['descript']?.toString() ?? 'ไม่มีรายละเอียด';
    final dynamic dateValue = item['uploaded_date'];
    String formattedDate = 'ไม่ระบุวันที่';

    if (dateValue != null) {
      DateTime? date;
      if (dateValue is int) {
        // กรณีเป็นตัวเลข (Timestamp) ให้แปลงเป็น DateTime
        // สมมติว่าเป็น millisecond since epoch (มาตรฐานทั่วไป)
        date = DateTime.fromMillisecondsSinceEpoch(dateValue);
      } else if (dateValue is String) {
        // กรณีเป็นข้อความ ให้ลอง parse เป็น DateTime
        date = DateTime.tryParse(dateValue);
      }
      
      if (date != null) {
        // จัดรูปแบบวันที่เป็นภาษาไทย
        formattedDate = DateFormat('dd MMMM yyyy', 'th_TH').format(date);
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // แสดงรูปภาพ
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                ),
              ),
            ),
          
          // แสดงรายละเอียด
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Text(
                      'อัปโหลดเมื่อ: $formattedDate',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final uploadId = item['upload_id'];
                      if (uploadId != null) {
                        // แสดงกล่องโต้ตอบเพื่อยืนยัน
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('ยืนยันการโพสต์'),
                              content: const Text('คุณต้องการเผยแพร่กิจกรรมนี้ใช่หรือไม่?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('ยกเลิก'),
                                  onPressed: () => Navigator.of(dialogContext).pop(),
                                ),
                                TextButton(
                                  child: const Text('ยืนยัน'),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                    // เรียกฟังก์ชันเพื่อโพสต์
                                    _publishPost(uploadId);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'โพสต์',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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