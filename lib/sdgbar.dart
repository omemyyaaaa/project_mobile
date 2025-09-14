import 'package:flutter/material.dart';
import 'package:flutter_application_1/myhome.dart';
import 'package:flutter_application_1/sdg_detail.dart' show SDGDetailPage;

void main() => runApp(SDGBar());

class SDGBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ตัวอย่าง: ส่ง userId จริงจาก login หรือกำหนดค่าเริ่มต้น
    return MaterialApp(
      home: SDGScreen(userId: 123), // ใส่ userId จริง
      debugShowCheckedModeBanner: false,
    );
  }
}

class SDGScreen extends StatefulWidget {
  final int userId; // เพิ่ม userId ที่นี่

  const SDGScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _SDGScreenState createState() => _SDGScreenState();
}

class _SDGScreenState extends State<SDGScreen> {
  // สร้างข้อมูลตัวอย่างสำหรับแต่ละ SDG
  late final List<Map<String, dynamic>> sdgData;

  @override
  void initState() {
    super.initState();
    sdgData = List.generate(17, (index) {
      int num = index + 1;
      return {
        'sdgNumber': num,
        'sdgTitle': 'เป้าหมายที่ $num',
        'sdgSubtitle': 'คำอธิบายเป้าหมายที่ $num',
        'backgroundImage': 'assets/images/background$num.jpg',
        'activities': num * 3,
        'uploaded': num * 2,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFFCC),
      // AppBar พร้อมลูกศรกลับ
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C6B2D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyHome(), // ใช้ id จริง
              ),
            );
          },
        ),
        title: Row(
          children: const [
            Text(
              '17 SDGs',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Spacer(),
            Icon(Icons.notifications, color: Colors.white),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.public, size: 30, color: Colors.black),
              SizedBox(width: 8),
              Text(
                '17 SDGs',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              padding: const EdgeInsets.all(10),
              children: sdgData.map((data) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SDGDetailPage(sdgNumber: data['sdgNumber']),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/sdg${data['sdgNumber']}.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
