import 'package:flutter/material.dart';
import 'package:flutter_application_1/admin/creation.dart';
import 'package:flutter_application_1/admin/homeamin.dart';

void main() {
  runApp(Tasking());
}

class Tasking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thai Recipe App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2E7D32),
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
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E8), Color(0xFFF1F8E9)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Header section with logo and buttons
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.gps_fixed,
                      color: const Color.fromARGB(255, 252, 0, 0),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'ภารกิจ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(221, 0, 0, 0),
                    ),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskCreationScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text('สร้างภารกิจ', style: TextStyle(fontSize: 12)),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // ใส่การทำงานของปุ่มชุมชนที่นี่
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF5722),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text('ลบภารกิจ', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Recipe card
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'รูปภาพที่บ่งบอกนิสัยกรรม',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'เชวอเคอร์',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    Text(
                      'รายละเอียดอาหารกรรม',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    Text(
                      '★★★★★',
                      style: TextStyle(fontSize: 16, color: Colors.orange),
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(Icons.person, size: 20, color: Colors.black54),
                        SizedBox(width: 8),
                        Text(
                          '0/20',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            // ใส่การทำงานของปุ่มดูรายละเอียดที่นี่
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF3F51B5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                          child: Text(
                            'ดูรายละเอียด',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            // ใส่การทำงานของปุ่มเข้าร่วมที่นี่
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFC107),
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                          child: Text(
                            'เข้าร่วม',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
