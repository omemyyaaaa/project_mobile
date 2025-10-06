import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ScoreTaskPage extends StatefulWidget {
  // 1. รับข้อมูล task ทั้งหมดเข้ามา เพื่อให้รู้ว่ากำลังให้คะแนนภารกิจไหน
  final Map<String, dynamic> task;

  const ScoreTaskPage({super.key, required this.task});

  @override
  State<ScoreTaskPage> createState() => _ScoreTaskPageState();
}

class _ScoreTaskPageState extends State<ScoreTaskPage> {
  final TextEditingController _scoreController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List _participants = []; // สำหรับเก็บรายชื่อผู้เข้าร่วม
  bool _isParticipantsLoading = true; // สถานะการโหลดรายชื่อ
  final Set<int> _selectedUserIds =
      {}; // Set สำหรับเก็บ ID ของ user ที่ถูกเลือก

  @override
  void initState() {
    super.initState();
    _fetchParticipants(); // เรียกฟังก์ชันดึงรายชื่อตอนเปิดหน้า
  }

  Future<void> _fetchParticipants() async {
    try {
      final taskId = widget.task['task_id'];
      final url = Uri.parse(
        'http://10.0.2.2:3000/api/participation/task/$taskId',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _participants = data['participants'] ?? [];
            _isParticipantsLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load participants');
      }
    } catch (e) {
      print("Error fetching participants: $e");
      if (mounted) {
        setState(() {
          _isParticipantsLoading = false;
        });
      }
    }
  }

  Future<void> _saveScore() async {
    if (_formKey.currentState!.validate()) {
      final score = int.tryParse(_scoreController.text);
      final taskId = widget.task['task_id'];
      final List<int> selectedIds = _selectedUserIds.toList();

      if (selectedIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('กรุณาเลือกผู้เข้าร่วมอย่างน้อย 1 คน'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // --- 🔽 ส่วนสำคัญที่ใช้ยิง API 🔽 ---
      try {
        final url = Uri.parse('http://10.0.2.2:3000/api/participation/award');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'taskId': taskId,
            'score': score,
            'userIds': selectedIds,
          }),
        );

        if (!mounted) return;

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('บันทึกคะแนนสำเร็จ!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // กลับไปหน้าก่อนหน้า
        } else {
          // กรณี API ตอบกลับมาว่า Error
          final responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'เกิดข้อผิดพลาด: ${responseData['message'] ?? 'ไม่สามารถบันทึกได้'}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // กรณีเชื่อมต่อไม่ได้
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('การเชื่อมต่อล้มเหลว: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildParticipantList() {
    if (_participants.isEmpty) {
      return const Center(child: Text('ไม่มีผู้เข้าร่วมภารกิจนี้'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _participants.length,
      itemBuilder: (context, index) {
        final participant = _participants[index];
        final userId = participant['id'];
        final isSelected = _selectedUserIds.contains(userId);

        String? fullUrl;
        if (participant['profile_url'] != null &&
            participant['profile_url'].isNotEmpty) {
          fullUrl = "http://10.0.2.2:3000${participant['profile_url']}";
        }

        return CheckboxListTile(
          title: Text(participant['username'] ?? 'Unknown User'),
          secondary: CircleAvatar(
            backgroundImage: fullUrl != null ? NetworkImage(fullUrl) : null,
            child: fullUrl == null ? const Icon(Icons.person) : null,
          ),
          value: isSelected,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedUserIds.add(userId);
              } else {
                _selectedUserIds.remove(userId);
              }
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      appBar: AppBar(
        title: const Text('ให้คะแนนภารกิจ'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.task['title'] ?? 'ไม่มีชื่อภารกิจ',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ให้คะแนนสำหรับภารกิจนี้ (สูงสุด ${widget.task['points'] ?? 100} คะแนน)',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _scoreController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'คะแนนที่ให้',
                  hintText: 'กรอกคะแนน',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.star),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกคะแนน';
                  }
                  final score = int.tryParse(value);
                  final maxPoints =
                      int.tryParse(
                        widget.task['points']?.toString() ?? '100',
                      ) ??
                      100;
                  if (score == null) {
                    return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                  }
                  if (score < 0 || score > maxPoints) {
                    return 'กรุณากรอกคะแนนระหว่าง 0 - $maxPoints';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'เลือกผู้เข้าร่วมที่จะให้คะแนน',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _isParticipantsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildParticipantList(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveScore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'บันทึกคะแนน',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }
}
