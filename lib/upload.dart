  import 'package:flutter/material.dart';
  import 'package:image_picker/image_picker.dart';
  import 'dart:io';
  import 'package:http/http.dart' as http;
  import 'package:path/path.dart' show basename;
  import 'package:supabase_flutter/supabase_flutter.dart'; // เพิ่มนี้

  // หน้าแรก - เลือกรูปภาพ
  class UploadPage extends StatefulWidget {
    final int userId; // รับจาก ProfilePage

  const UploadPage({Key? key, required this.userId}) : super(key: key);

    @override
    _UploadPageState createState() => _UploadPageState();
  }

  class _UploadPageState extends State<UploadPage> {
    File? _selectedImage;
    final ImagePicker _picker = ImagePicker();

    Future<void> _showUploadOptions() async {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.green.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'รูปภาพ/วิดีโอ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'x',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildUploadOption(
                    icon: Icons.photo,
                    label: 'แกลลอรี่',
                    color: Colors.orange,
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                  _buildUploadOption(
                    icon: Icons.camera_alt,
                    label: 'ถ่ายภาพ',
                    color: Colors.blue,
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                ],
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      );
    }

    Widget _buildUploadOption({
      required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 14, color: Colors.black87)),
          ],
        ),
      );
    }

    Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // ปลอดภัย เพราะยังอยู่ใน synchronous code
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null && mounted) { // <- check mounted ก่อน setState
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

    void _goToNextPage() {
  if (_selectedImage != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadDetailsPage(
          selectedImage: _selectedImage!,
          userId: widget.userId, // ส่งต่อ userId
        ),
      ),
    );
  }
}

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.green.shade50,
        appBar: AppBar(
          backgroundColor: Colors.green.shade700,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with icon
              Row(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 32,
                    color: Colors.black87,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'อัปโหลดรูปกิจกรรม',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Status row
              Row(
                children: [
                  Text(
                    '1 รูปภาพ/วิดีโอ',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Upload area
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : InkWell(
                        onTap: _showUploadOptions,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              size: 60,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'เพิ่มรูปภาพ',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              Spacer(),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2E3B5C),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'ยกเลิก',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedImage != null ? _goToNextPage : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedImage != null
                            ? Colors.green.shade700
                            : Colors.grey.shade400,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'ถัดไป',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      );
    }
  }

  // หน้าที่สอง - เลือกเป้าหมายและคำอธิบาย
  class UploadDetailsPage extends StatefulWidget {
    final File selectedImage;
  final int userId; // รับจาก UploadPage
  

  const UploadDetailsPage({
    Key? key,
    required this.selectedImage,
    required this.userId,
  }) : super(key: key);


    @override
    _UploadDetailsPageState createState() => _UploadDetailsPageState();
  }

  class _UploadDetailsPageState extends State<UploadDetailsPage> {
    String? _selectedCategory;
    final TextEditingController _descriptionController = TextEditingController();
    final supabase = Supabase.instance.client;
      final Map<String, int> categoryMap = {
  'เป้าหมายที่1': 1,
  'เป้าหมายที่2': 2,
  'เป้าหมายที่3': 3,
  'เป้าหมายที่4': 4,
  'เป้าหมายที่5': 5,
};
    

  Future<void> uploadImage() async {
  // สมมติคุณมี email ของผู้ใช้จาก login
  final userEmail = 'user@example.com'; // <-- เปลี่ยนเป็น email จริง

  var uri = Uri.parse("http://10.0.2.2:3000/upload");
  var request = http.MultipartRequest('POST', uri);
  
request.fields['userId'] = widget.userId.toString();
request.fields['descript'] = _descriptionController.text.trim();
int taskValue = categoryMap[_selectedCategory] ?? 0;
request.fields['tasks'] = taskValue.toString(); // ถ้า tasks เป็นตัวเลข

  request.files.add(
    await http.MultipartFile.fromPath(
      'image',
      widget.selectedImage.path,
      filename: basename(widget.selectedImage.path),
    ),
  );

  final response = await request.send();
  if (response.statusCode == 200) {
    _showSuccessDialog();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('อัปโหลดล้มเหลว')),
    );
  }
}
void _showSuccessDialog() {
  BuildContext? dialogContext;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      dialogContext = context;
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade400, width: 3),
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Colors.green.shade600,
                ),
              ),
              SizedBox(height: 25),
              Text(
                'ส่งสำเร็จ!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'ข้อมูลของคุณถูกอัปโหลดแล้ว',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    },
  );

  // ปิด dialog และย้อนกลับหน้าหลักอัตโนมัติ
  Future.delayed(Duration(seconds: 2), () {
    if (!mounted) return;
    if (dialogContext != null) Navigator.of(dialogContext!).pop(); // ปิด dialog
    Navigator.of(context).pop(); // ปิด details page
    Navigator.of(context).pop(); // ปิด upload page
  });
}
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.green.shade50,
        appBar: AppBar(
          backgroundColor: Colors.green.shade700,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'รายละเอียดการอัปโหลด',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),

              // Image preview
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(widget.selectedImage, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 15),

              // Category selection
              Text(
                'เป้าหมาย/หมวดหมู่',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 5),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory, // เริ่มเป็น null
                    hint: Text(
                      "กรุณาเลือกเป้าหมาย/หมวดหมู่",
                    ), // ข้อความแสดงตอนยังไม่เลือก
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down),
                    items:
                        [
                          'เป้าหมายที่1',
                          'เป้าหมายที่2',
                          'เป้าหมายที่3',
                          'เป้าหมายที่4',
                          'เป้าหมายที่5',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 15),

              // Description field
              Text(
                'คำอธิบาย',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  onChanged: (value) => setState(() {}), // Update button state
                  decoration: InputDecoration(
                    hintText: 'เพิ่มคำอธิบายเกี่ยวกับรูปภาพ...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(15),
                  ),
                ),
              ),

              Spacer(),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2E3B5C),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'กลับ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                    onPressed: _descriptionController.text.trim().isNotEmpty
    ? () async {
        await uploadImage(); // upload และแสดง dialog ภายในฟังก์ชัน
        if (!mounted) return;
        // ไม่ต้องเรียก _showSuccessDialog() ซ้ำ
      }
    : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _descriptionController.text.trim().isNotEmpty
                            ? Colors.green.shade700
                            : Colors.grey.shade400,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'อัปโหลด',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      );
    }

    @override
    void dispose() {
      _descriptionController.dispose();
      super.dispose();
    }
  }
