import 'package:flutter/material.dart';
import 'package:flutter_application_1/myhome.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' show basename;
import 'package:quickalert/quickalert.dart';

//=========================================================
//  หน้าที่ 1: เลือกรูปภาพ
//=========================================================
class UploadPage extends StatefulWidget {
  final int userId; // รับค่า user id มาจากหน้าก่อนหน้า

  const UploadPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // แสดงตัวเลือกการอัปโหลด (จากแกลเลอรี่ หรือ กล้อง)
  Future<void> _showUploadOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('เลือกรูปภาพ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildUploadOption(
                    icon: Icons.photo_library,
                    label: 'แกลเลอรี่',
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget สำหรับสร้างปุ่มตัวเลือก (แกลเลอรี่/กล้อง)
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
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  // ฟังก์ชันสำหรับเลือกรูปภาพ
  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // ปิด BottomSheet ก่อน
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
    if (image != null && mounted) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // นำทางไปยังหน้ารายละเอียด
  void _goToNextPage() {
    if (_selectedImage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UploadDetailsPage(
            selectedImage: _selectedImage!,
            userId: widget.userId,
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
        title: const Text('อัปโหลดกิจกรรม', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Upload area
            GestureDetector(
              onTap: _selectedImage == null ? _showUploadOptions : null,
              child: Container(
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
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 60, color: Colors.grey.shade600),
                          const SizedBox(height: 12),
                          Text('เพิ่มรูปภาพ', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                        ],
                      ),
              ),
            ),
            if (_selectedImage != null)
              TextButton.icon(
                onPressed: _showUploadOptions,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('เปลี่ยนรูปภาพ'),
              ),
            const Spacer(),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text('ยกเลิก', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedImage != null ? _goToNextPage : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      disabledBackgroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text('ถัดไป', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//=========================================================
//  หน้าที่ 2: ใส่รายละเอียดและเลือกเป้าหมาย
//=========================================================
class UploadDetailsPage extends StatefulWidget {
  final File selectedImage;
  final int userId;

  const UploadDetailsPage({
    Key? key,
    required this.selectedImage,
    required this.userId,
  }) : super(key: key);

  @override
  _UploadDetailsPageState createState() => _UploadDetailsPageState();
}

class _UploadDetailsPageState extends State<UploadDetailsPage> {
  List<String> _selectedCategories = [];
  final TextEditingController _descriptionController = TextEditingController();
  bool _isUploading = false;

  final Map<String, int> categoryMap = {
    'SDGs 1': 1, 'SDGs 2': 2, 'SDGs 3': 3, 'SDGs 4': 4, 'SDGs 5': 5,
    'SDGs 6': 6, 'SDGs 7': 7, 'SDGs 8': 8, 'SDGs 9': 9, 'SDGs 10': 10,
    'SDGs 11': 11, 'SDGs 12': 12, 'SDGs 13': 13, 'SDGs 14': 14, 'SDGs 15': 15,
    'SDGs 16': 16, 'SDGs 17': 17,
  };

  final List<String> allCategories = [
    'SDGs 1', 'SDGs 2', 'SDGs 3', 'SDGs 4', 'SDGs 5', 'SDGs 6', 'SDGs 7',
    'SDGs 8', 'SDGs 9', 'SDGs 10', 'SDGs 11', 'SDGs 12', 'SDGs 13', 'SDGs 14',
    'SDGs 15', 'SDGs 16', 'SDGs 17',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _uploadData() async {
    // ป้องกันการกดซ้ำ
    if (_isUploading) return;
    
    // ตรวจสอบว่ากรอกข้อมูลครบหรือไม่
    if (_selectedCategories.isEmpty || _descriptionController.text.trim().isEmpty) {
        QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'ข้อมูลไม่ครบถ้วน',
        text: 'กรุณาเลือกเป้าหมายและใส่คำอธิบาย',
      );
        return;
    }

    setState(() { _isUploading = true; });

    try {
      var uri = Uri.parse("http://10.0.2.2:3000/upload");
      var request = http.MultipartRequest('POST', uri);

      request.fields['userId'] = widget.userId.toString();
      request.fields['descript'] = _descriptionController.text.trim();

      String tasksValue = _selectedCategories
          .map((category) => categoryMap[category])
          .where((id) => id != null)
          .join(',');

      request.fields['tasks'] = tasksValue;

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          widget.selectedImage.path,
          filename: basename(widget.selectedImage.path),
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        if(mounted) _showSuccessAndNavigate();
      } else {
        final respStr = await response.stream.bytesToString();
        if(mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'อัปโหลดล้มเหลว',
            text: respStr,
          );
        }
      }
    } catch (e) {
        if(mounted) {
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'การเชื่อมต่อล้มเหลว',
            text: 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้',
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isUploading = false; });
      }
    }
  }

  void _showSuccessAndNavigate() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'ส่งสำเร็จ!',
      text: 'ข้อมูลของคุณถูกอัปโหลดเรียบร้อยแล้ว',
      barrierDismissible: false, // ป้องกันการกดออก
      confirmBtnText: 'ตกลง',
      onConfirmBtnTap: () {
        if (mounted) {
          // ลบทุกหน้าใน Stack ทิ้ง แล้ว Push หน้า MyHome ขึ้นมาใหม่
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MyHome()),
            (Route<dynamic> route) => false,
          );
        }
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 80, color: Colors.green.shade600),
                const SizedBox(height: 20),
                Text('ส่งสำเร็จ!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                const SizedBox(height: 10),
                Text('ข้อมูลของคุณถูกอัปโหลดแล้ว', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
              ],
            ),
          ),
        );
      },
    );

    // หน่วงเวลา 2 วินาที แล้วปิด Dialog และกลับไปหน้าแรกสุด
    Future.delayed(const Duration(seconds: 2), () {
    if (mounted) {
      // ✅✅ แก้ไขเป็นคำสั่งนี้ ✅✅
      // ลบทุกหน้าใน Stack ทิ้ง แล้ว Push หน้า MyHome ขึ้นมาใหม่
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MyHome()),
        (Route<dynamic> route) => false,
      );
    }
  });
}

  Future<void> _showMultiSelectDialog() async {
    final List<String> tempSelectedValues = List.from(_selectedCategories);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('เลือกเป้าหมายที่เกี่ยวข้อง'),
          content: SizedBox(
            width: double.maxFinite,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: allCategories.length,
                  itemBuilder: (context, index) {
                    final category = allCategories[index];
                    return CheckboxListTile(
                      title: Text(category),
                      value: tempSelectedValues.contains(category),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelectedValues.add(category);
                          } else {
                            tempSelectedValues.remove(category);
                          }
                        });
                      },
                    );
                  },
                );
              },
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
                setState(() {
                  _selectedCategories = tempSelectedValues;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text('รายละเอียด', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(widget.selectedImage, height: 200, width: double.infinity, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 20),

                  // Multi-select "Dropdown"
                  const Text('เป้าหมาย (เลือกได้หลายข้อ)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _showMultiSelectDialog,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _selectedCategories.isEmpty
                                ? Text("กรุณาเลือกเป้าหมาย...", style: TextStyle(color: Colors.grey.shade600, fontSize: 16))
                                : Wrap(
                                    spacing: 6.0,
                                    runSpacing: 4.0,
                                    children: _selectedCategories.map((item) => Chip(
                                      label: Text(item, style: const TextStyle(fontSize: 12)),
                                      onDeleted: () {
                                        setState(() {
                                          _selectedCategories.remove(item);
                                        });
                                      },
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      padding: const EdgeInsets.all(2),
                                    )).toList(),
                                  ),
                          ),
                          Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade700),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text('คำอธิบาย', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'เพิ่มคำอธิบายเกี่ยวกับกิจกรรม...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Action buttons (Fixed at the bottom)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text('กลับ', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _uploadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: _isUploading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : const Text('อัปโหลด', style: TextStyle(color: Colors.white, fontSize: 16)),
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