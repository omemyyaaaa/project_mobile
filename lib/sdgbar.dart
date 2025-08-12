import 'package:flutter/material.dart';
import 'package:flutter_application_1/custom_bottom_nav.dart';
import 'package:flutter_application_1/sdg_detail.dart' show SDGDetailPage;

void main() => runApp(SDGBar());

class SDGBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SDGScreen(), debugShowCheckedModeBanner: false);
  }
}

class SDGScreen extends StatefulWidget {
  @override
  _SDGScreenState createState() => _SDGScreenState();
}

class _SDGScreenState extends State<SDGScreen> {
  // สร้างข้อมูลตัวอย่างสำหรับแต่ละ SDG
  final List<Map<String, dynamic>> sdgData = List.generate(17, (index) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFFCC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C6B2D),
        title: Row(
          children: const [
            Icon(Icons.menu, color: Colors.white),
            SizedBox(width: 10),
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
                          offset: Offset(2, 4), // ความเอียงของเงา
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
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1, onTap: null),
    );
  }
}
