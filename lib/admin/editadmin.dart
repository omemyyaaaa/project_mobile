import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class EditTaskScreen extends StatefulWidget {
  final Map<String, dynamic> taskData;

  const EditTaskScreen({Key? key, required this.taskData}) : super(key: key);

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _participantController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _pointsController;
  late DateTime _selectedDate;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final List<String> _sdgList = List.generate(17, (i) => "SDG${i + 1}");
  List<String> _selectedSdgs = [];
  bool _sdgDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _participantController = TextEditingController(
      text: widget.taskData['participants'].toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.taskData['description'],
    );
    _pointsController = TextEditingController(
      text: widget.taskData['points'].toString(),
    );

    try {
      _selectedDate = DateTime.parse(widget.taskData['activity_date']);
    } catch (e) {
      _selectedDate = DateTime.now(); // fallback
    }

    final dynamic sdgsData = widget.taskData['sdgs'];
    if (sdgsData != null && sdgsData is List) {
      // ตัวกรองเผื่อกรณีมีค่า null ใน list ที่ถูกส่งมาจาก json_agg
      _selectedSdgs = sdgsData
          .where((sdgNum) => sdgNum != null)
          .map((sdgNum) => "SDG$sdgNum")
          .toList();
    }
  }

  Future<void> _deleteTask() async {
    // ปิด SnackBar เก่าๆ (ถ้ามี) ก่อนแสดงอันใหม่
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    try {
      final taskId = widget.taskData['task_id'];
      final url = Uri.parse("http://10.0.2.2:3000/api/tasks/$taskId");
      final response = await http.delete(url);

      if (!mounted) return; // ตรวจสอบว่า widget ยังอยู่ใน tree

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ ลบภารกิจเรียบร้อย"), backgroundColor: Colors.green),
        );
        // ส่งค่า true กลับไป 2 ชั้น (ปิด dialog และ ปิดหน้า edit) เพื่อบอกให้หน้ารายการ refresh
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ ลบไม่สำเร็จ [${response.statusCode}]"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ เกิดข้อผิดพลาดในการเชื่อมต่อ: $e"), backgroundColor: Colors.orange),
      );
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("ยืนยันการลบ"),
          content: const Text("คุณแน่ใจหรือไม่ว่าต้องการลบภารกิจนี้? การกระทำนี้ไม่สามารถย้อนกลับได้"),
          actions: <Widget>[
            TextButton(
              child: const Text("ยกเลิก"),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ปิดแค่กล่องโต้ตอบ
              },
            ),
            TextButton(
              child: const Text("ลบ", style: TextStyle(color: Colors.red)),
              onPressed: () {
                 Navigator.of(dialogContext).pop(); // ปิดกล่องโต้ตอบก่อน
                _deleteTask(); // แล้วค่อยเรียกฟังก์ชันลบ
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF2d5a3d),
            colorScheme: const ColorScheme.light(primary: Color(0xFF2d5a3d)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _updateTask() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final taskId = widget.taskData['task_id']; // ใช้ `task_id` จาก backend
      var request = http.MultipartRequest(
        "PUT",
        Uri.parse(
          "http://10.0.2.2:3000/api/tasks/$taskId",
        ), // <--- ลบ /edit ออก
      );

      request.fields["participants"] = _participantController.text;
      request.fields["activity_date"] = DateFormat(
        "yyyy-MM-dd",
      ).format(_selectedDate);
      request.fields["description"] = _descriptionController.text;
      request.fields["points"] = _pointsController.text;
      request.fields["sdgs"] = _selectedSdgs.join(",");

      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath("image", _imageFile!.path),
        );
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ แก้ไขภารกิจเรียบร้อย")));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ แก้ไขไม่สำเร็จ [${response.statusCode}]")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("⚠️ เกิดข้อผิดพลาด: $e")));
    }
  }
  

  @override
  void dispose() {
    _participantController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: เปลี่ยน 'image_url' เป็น 'image'
    final String? currentImageUrl = widget.taskData['image'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("แก้ไขภารกิจ"),
        backgroundColor: const Color(0xFF2d5a3d),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            tooltip: 'ลบภารกิจ',
            onPressed: _showDeleteConfirmationDialog, // กดแล้วให้แสดงกล่องยืนยัน
          ),
        ],
      ),
      backgroundColor: const Color(0xFFf0f8e8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ✅ FIX: เพิ่มส่วนฟอร์มข้อมูลที่หายไปกลับเข้ามา
              // --- เริ่มส่วนฟอร์ม ---
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildFormField(
                        label: 'จำนวนผู้เข้าร่วม',
                        child: TextFormField(
                          controller: _participantController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(''),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'กรุณากรอกจำนวน' : null,
                        ),
                      ),
                      _buildFormField(
                        label: 'วันที่เริ่มต้น',
                        child: InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(_selectedDate),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey.shade600,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _buildFormField(
                        label: 'รายละเอียดภารกิจ',
                        child: TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: _inputDecoration('กรอกรายละเอียดภารกิจ'),
                          validator: (v) => v == null || v.isEmpty
                              ? 'กรุณากรอกรายละเอียด'
                              : null,
                        ),
                      ),
                      _buildFormField(
                        label: 'คะแนน',
                        child: TextFormField(
                          controller: _pointsController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('กรอกคะแนน'),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'กรุณากรอกคะแนน' : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "เลือกเป้าหมาย SDGs",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildMultiSelectDropdown(),
                    ],
                  ),
                ),
              ),

              // --- จบส่วนฟอร์ม ---
              const SizedBox(height: 16),

              // ✅ ส่วนอัปโหลดรูปภาพที่แก้ไขแล้ว
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) {
                      return SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo),
                              title: const Text("เลือกจากแกลเลอรี"),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImageFromGallery();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text("ถ่ายรูป"),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImageFromCamera();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[200],
                    image: _imageFile == null && currentImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(currentImageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: _imageFile != null
                        ? Image.file(
                            _imageFile!,
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                          )
                        : (currentImageUrl == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "เพิ่มรูปภาพ",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                )
                              : Container()),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ✅ FIX: เพิ่มส่วนปุ่มที่หายไปกลับเข้ามา
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("ยกเลิก"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2d5a3d),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("บันทึก"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelectDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _sdgDropdownOpen = !_sdgDropdownOpen;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selectedSdgs.isEmpty
                        ? "เลือก SDGs"
                        : _selectedSdgs.join(", "),
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (_sdgDropdownOpen)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Column(
              children: _sdgList.map((sdg) {
                final isSelected = _selectedSdgs.contains(sdg);
                return CheckboxListTile(
                  title: Text(sdg),
                  value: isSelected,
                  onChanged: (checked) {
                    setState(() {
                      checked == true
                          ? _selectedSdgs.add(sdg)
                          : _selectedSdgs.remove(sdg);
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
