import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/admin/homeamin.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class TaskCreationScreen extends StatefulWidget {
  @override
  _TaskCreationScreenState createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  final _formKey = GlobalKey<FormState>();

  // 1. เพิ่ม TextEditingController สำหรับ title และ location
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _participantController =
      TextEditingController(text: '');
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  File? _imageFile;

  final List<String> _sdgList = List.generate(17, (i) => "SDG${i + 1}");
  List<String> _selectedSdgs = [];
  final ImagePicker _picker = ImagePicker();
  bool _sdgDropdownOpen = false;

  Future<void> _pickImageFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _pickImageFromCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF2d5a3d),
            colorScheme: ColorScheme.light(primary: Color(0xFF2d5a3d)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      // 3. แก้ไข URL ของ API ให้ถูกต้องตามที่เราได้ทำไว้
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("http://10.0.2.2:3000/create/create"),
      );

      // 4. เพิ่ม title และ location เข้าไปใน request.fields
      request.fields["title"] = _titleController.text;
      request.fields["location"] = _locationController.text;
      request.fields["participants"] = _participantController.text;
      request.fields["activity_date"] =
          DateFormat("yyyy-MM-dd").format(_selectedDate);
      request.fields["description"] = _descriptionController.text;
      request.fields["points"] = _pointsController.text;
      request.fields["sdgs"] = _selectedSdgs.join(",");

      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath("image", _imageFile!.path),
        );
      }

      var response = await request.send();
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ บันทึกภารกิจเรียบร้อย")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomeadmin()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ บันทึกไม่สำเร็จ [${response.statusCode}]")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ เกิดข้อผิดพลาด: $e")),
      );
    }
  }

  @override
  void dispose() {
    // 5. dispose controller ที่เพิ่มเข้ามาใหม่
    _titleController.dispose();
    _locationController.dispose();
    _participantController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("สร้างภารกิจ"),
        backgroundColor: Color(0xFF2d5a3d),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Color(0xFFf0f8e8),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 2. เพิ่ม TextFormField สำหรับ Title และ Location ใน UI
                      _buildFormField(
                        label: 'หัวข้อภารกิจ',
                        child: TextFormField(
                          controller: _titleController,
                          decoration: _inputDecoration('ระบุหัวข้อภารกิจ'),
                          validator: (v) => v == null || v.isEmpty
                              ? 'กรุณากรอกหัวข้อภารกิจ'
                              : null,
                        ),
                      ),
                      _buildFormField(
                        label: 'สถานที่',
                        child: TextFormField(
                          controller: _locationController,
                          decoration: _inputDecoration('ระบุสถานที่จัดกิจกรรม'),
                          validator: (v) => v == null || v.isEmpty
                              ? 'กรุณากรอกสถานที่'
                              : null,
                        ),
                      ),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(DateFormat('dd/MM/yyyy')
                                    .format(_selectedDate)),
                                Icon(Icons.calendar_today,
                                    color: Colors.grey.shade600),
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
              SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("เลือกเป้าหมาย SDGs",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      _buildMultiSelectDropdown(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) {
                      return SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: Icon(Icons.photo),
                              title: Text("เลือกจากแกลเลอรี"),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImageFromGallery();
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.camera_alt),
                              title: Text("ถ่ายรูป"),
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
                  ),
                  child: _imageFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                size: 40, color: Colors.grey.shade600),
                            SizedBox(height: 8),
                            Text("เพิ่มรูปภาพ",
                                style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(_imageFile!,
                              width: double.infinity,
                              height: 160,
                              fit: BoxFit.cover),
                        ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomeadmin()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text("ยกเลิก"),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 48, 159, 87),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text("บันทึก"),
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
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (_sdgDropdownOpen)
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.all(8),
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
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87)),
          SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}