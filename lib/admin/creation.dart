import 'package:flutter/material.dart';
import 'package:flutter_application_1/admin/homeamin.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Creation App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      home: TaskCreationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TaskCreationScreen extends StatefulWidget {
  @override
  _TaskCreationScreenState createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _participantController = TextEditingController(text: '20');
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _showTaskList = false;
  String _savedDescription = '';
  int _savedParticipantCount = 20;
  DateTime _savedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2d5a3d),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyHomeadmin(), // ใช้ id จริง
              ),
            );
          },
        ),
        actions: [
          if (_showTaskList)
            Icon(
              Icons.notifications,
              color: Colors.white,
            ),
        ],
      ),
      backgroundColor: Color(0xFFf0f8e8),
      body: _showTaskList ? _buildTaskListView() : _buildCreateTaskView(),
    );
  }

  Widget _buildCreateTaskView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สร้างภารกิจใหม่',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2d5a3d),
              ),
            ),
            SizedBox(height: 20),
            
            // จำนวนผู้เข้าร่วม
            _buildFormField(
              label: 'จำนวนผู้เข้าร่วม',
              child: TextFormField(
                controller: _participantController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('20'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกจำนวนผู้เข้าร่วม';
                  }
                  return null;
                },
              ),
            ),
            
            // วันที่เริ่มต้น
            _buildFormField(
              label: 'วันที่เริ่มต้น',
              child: InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Icon(Icons.calendar_today, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
            
            // รายละเอียดภารกิจ
            _buildFormField(
              label: 'รายละเอียดภารกิจ',
              child: TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration(''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกรายละเอียดภารกิจ';
                  }
                  return null;
                },
              ),
            ),
            
            // อัปโหลดเอกสาร
            _buildFormField(
              label: 'อัปโหลดเอกสารภารกิจ',
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Color(0xFFd0d0d0),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  onTap: _uploadDocument,
                  borderRadius: BorderRadius.circular(15),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      size: 40,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 30),
            
            // ปุ่มยกเลิกและบันทึก
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _cancelTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6c5ce7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'ยกเลิก',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2d3436),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'บันทึก',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskListView() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.camera_alt,
                size: 24,
                color: Color(0xFF2d5a3d),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  'ภารกิจ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2d5a3d),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF00b894),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'ยืนยันสถานะ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFe17055),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'ปิดใช้งาน',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 20),
          
          // Task Card
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFFe8e8e8),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'รูปภาพเพื่อรับกิจกรรม',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2d5a3d),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  DateFormat('dd/MM/yyyy').format(_savedDate),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'รายละเอียดภารกิจ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  _savedDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 5),
                        Text(
                          '0/$_savedParticipantCount',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle view users
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFf1c40f),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        'ดูผู้ใช้',
                        style: TextStyle(
                          color: Color(0xFF2d3436),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        child,
        SizedBox(height: 15),
      ],
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(
          color: Color(0xFF2d5a3d).withOpacity(0.3),
          width: 2,
        ),
      ),
    );
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
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _uploadDocument() {
    // Handle file upload
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('เปิดตัวเลือกไฟล์...'),
        backgroundColor: Color(0xFF2d5a3d),
      ),
    );
  }

  void _cancelTask() {
    _participantController.text = '20';
    _descriptionController.clear();
    _selectedDate = DateTime.now();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _savedDescription = _descriptionController.text;
        _savedParticipantCount = int.parse(_participantController.text);
        _savedDate = _selectedDate;
        _showTaskList = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('บันทึกภารกิจเรียบร้อยแล้ว!'),
          backgroundColor: Color(0xFF00b894),
        ),
      );
    }
  }

  @override
  void dispose() {
    _participantController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}