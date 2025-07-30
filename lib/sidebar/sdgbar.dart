  import 'package:flutter/material.dart';
  import 'package:flutter_application_1/myhome.dart' show MyHome;
  import 'package:flutter_application_1/profile.dart';
  import 'package:flutter_application_1/publicpage.dart';
import 'package:flutter_application_1/sidebar/sdg1.dart';
  import 'package:flutter_application_1/upload.dart';

  class SDGBar extends StatefulWidget {
    @override
    _SDGbarState createState() => _SDGbarState();
  }

  class _SDGbarState extends State<SDGBar> {
    int currentPage = 0;
    PageController _pageController = PageController();
    static const Color _primaryGreen = Color(0xFF4CAF50);
    static const Color _lightGreen = Color(0xFFE8F5E8);
    static const Color _darkBlue = Color(0xFF1976D2);

    Widget _buildBottomNavigation(BuildContext context) {
      return Container(
        height: 70,
        color: _primaryGreen,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomNavItem(context, Icons.home, 0),
            _buildBottomNavItem(context, Icons.wifi, 1),
            _buildBottomNavItem(context, Icons.cloud_outlined, 2),
            _buildBottomNavItem(context, Icons.person, 3),
          ],
        ),
      );
    }

    void _onBottomNavTap(BuildContext context, int index) {
      switch (index) {
        case 0:
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const MyHome()));
          break;
        case 1:
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const Publicpage()));
          //
          break;
        case 2:
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => UploadPage()));
          break;
        case 3:
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const ProfilePage()));
          break;
      }
    }

    Widget _buildBottomNavItem(BuildContext context, IconData icon, int index) {
      return IconButton(
        icon: Icon(icon, color: Colors.black, size: 28),
        onPressed: () {
          _onBottomNavTap(context, index);
        },
      );
    }

    final List<SDGItem> allSDGs = [
      SDGItem(
        1,
        "ขจัดความยากจน",
        "ทุกรูปแบบ",
        Colors.red[700]!,
        'assets/images/sdg1.png',
      ),
      SDGItem(
        2,
        "ขจัดความหิว",
        "โภชนาการ",
        Colors.orange[600]!,
        'assets/images/sdg2.png',
      ),
      SDGItem(
        3,
        "สุขภาพดี",
        "และความเป็นอยู่",
        Colors.green[600]!,
        'assets/images/sdg3.png',
      ),
      SDGItem(
        4,
        "การศึกษาที่มีคุณภาพ",
        "",
        Colors.red[800]!,
        'assets/images/sdg4.png',
      ),
      SDGItem(
        5,
        "ความเท่าเทียม",
        "ทางเพศ",
        Colors.red[600]!,
        'assets/images/sdg5.png',
      ),
      SDGItem(
        6,
        "น้ำสะอาด",
        "สุขาภิบาล",
        Colors.blue[500]!,
        'assets/images/sdg6.png',
      ),
      SDGItem(
        7,
        "พลังงานสะอาด",
        "ราคาประหยัด",
        Colors.yellow[700]!,
        'assets/images/sdg7.png',
      ),
      SDGItem(
        8,
        "งานที่มีคุณค่า",
        "และการเติบโตทางเศรษฐกิจ",
        Colors.purple[700]!,
        'assets/images/sdg8.png',
      ),
      SDGItem(
        9,
        "อุตสาหกรรม นวัตกรรม",
        "และโครงสร้างพื้นฐาน",
        Colors.orange[700]!,
        'assets/images/sdg9.png',
      ),
      SDGItem(
        10,
        "ลดความเหลื่อมล้ำ",
        "",
        Colors.pink[600]!,
        'assets/images/sdg10.png',
      ),
      SDGItem(
        11,
        "เมืองและชุมชน",
        "ที่ยั่งยืน",
        Colors.orange[600]!,
        'assets/images/sdg11.png',
      ),
      SDGItem(
        12,
        "การบริโภค",
        "และการผลิตอย่างยั่งยืน",
        Colors.orange[700]!,
        'assets/images/sdg12.png',
      ),
      SDGItem(
        13,
        "การรับมือการเปลี่ยนแปลง",
        "สภาพภูมิอากาศ",
        Colors.green[800]!,
        'assets/images/sdg13.png',
      ),
      SDGItem(
        14,
        "ชีวิตใต้น้ำ",
        "",
        Colors.blue[600]!,
        'assets/images/sdg14.png',
      ),
      SDGItem(15, "ชีวิตบนบก", "", Colors.green[700]!, 'assets/images/sdg15.png'),
      SDGItem(
        16,
        "สันติภาพ ยุติธรรม",
        "และสถาบันที่เข้มแข็ง",
        Colors.blue[700]!,
        'assets/images/sdg16.png',
      ),
      SDGItem(
        17,
        "ความร่วมมือ",
        "เพื่อการพัฒนา",
        Colors.blue[800]!,
        'assets/images/sdg17.png',
      ),
    ];

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.green[700],
          elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.white),
              onPressed: () => _showNotificationDialog(context),
            ),
          ],
        ),
        body: Column(
          children: [
            // Header with SDGs logo
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green[700]!, Colors.green[100]!],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.public, color: Colors.green[700], size: 30),
                  ),
                  SizedBox(width: 15),
                  Text(
                    "17 SDGs",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // SDGs Grid
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: allSDGs.length,
                  itemBuilder: (context, index) {
                    return _buildSDGCard(context, allSDGs[index]);
                  },
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigation(context),
      );
    }

    Widget _buildSDGCard(BuildContext context, SDGItem item) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => item.number == 1
              ? Sdg1()
              : SDGDetailPage(item: item),
        ),
      );
    },
    child: Container(
      margin: EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          item.imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 120,
        ),
      ),
    ),
  );
}
    void _navigateToDetail(SDGItem item) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SDGDetailPage(item: item),
    ),
  );
}

    void _onSDGTapped(SDGItem item) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      item.number.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "SDG ${item.number}",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (item.subtitle.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(
                    item.subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
                SizedBox(height: 16),
                Text(
                  "คุณได้เลือก SDG ${item.number}: ${item.title}",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("ปิด"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showSDGDetail(item);
                },
                style: ElevatedButton.styleFrom(backgroundColor: item.color),
                child: Text("ดูรายละเอียด"),
              ),
            ],
          );
        },
      );
    }

    void _showSDGDetail(SDGItem item) {
      // Navigate to detailed SDG page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SDGDetailPage(item: item)),
      );
    }

    void _onBottomNavTapped(String label) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("คุณเลือก: $label"),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green[700],
        ),
      );
    }


    void _showNotificationDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("การแจ้งเตือน"),
            content: Text("ไม่มีการแจ้งเตือนใหม่"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("ปิด"),
              ),
            ],
          );
        },
      );
    }
  }

  class SDGItem {
    final int number;
    final String title;
    final String subtitle;
    final Color color;
    final String imagePath;

    SDGItem(this.number, this.title, this.subtitle, this.color, this.imagePath);
  }

  class SDGDetailPage extends StatelessWidget {
    final SDGItem item;

    const SDGDetailPage({Key? key, required this.item}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: item.color,
          title: Text("SDG ${item.number}"),
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [item.color, Colors.white],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Image.asset(item.imagePath, height: 80, width: 80),
                      SizedBox(height: 20),
                      Text(
                        "SDG ${item.number}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: item.color,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (item.subtitle.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(
                          item.subtitle,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  "รายละเอียด",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    "นี่คือข้อมูลรายละเอียดของ SDG ${item.number}: ${item.title}\n\n"
                    "เป้าหมายการพัฒนาที่ยั่งยืนนี้มุ่งเน้นไปที่การสร้างโลกที่ดีกว่าสำหรับทุกคน\n\n"
                    "สามารถดำเนินการต่อไปได้โดยการศึกษาข้อมูลเพิ่มเติมและร่วมมือกันเพื่อบรรลุเป้าหมาย",
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  // สำหรับใช้งานในแอป Flutter หลัก
  class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'SDGs App',
        theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Roboto'),
        home: SDGBar(),
        debugShowCheckedModeBanner: false,
      );
    }
  }

  void main() {
    runApp(MyApp());
  }
