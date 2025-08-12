import 'package:flutter/material.dart';
import 'package:flutter_application_1/API/api.dart';
import 'sdg_data.dart';

class SDGDetailPage extends StatefulWidget {
  final int sdgNumber;
  const SDGDetailPage({super.key, required this.sdgNumber});

  @override
  _SDGDetailPageState createState() => _SDGDetailPageState();
}

class _SDGDetailPageState extends State<SDGDetailPage> {
  List<dynamic> indicators = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadIndicators();
  }

  Future<void> loadIndicators() async {
    try {
      final data = await SDGApi.fetchIndicatorsByGoal(widget.sdgNumber);
      setState(() {
        indicators = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'ไม่สามารถโหลดข้อมูลตัวชี้วัดได้';
        isLoading = false;
      });
      print('Error loading indicators: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final SDGData data = sdgList.firstWhere(
      (element) => element.number == widget.sdgNumber,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: data.color,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    data.color,
                    Color.lerp(data.color, Colors.white, 0.5)!,
                    Colors.white,
                  ],
                  stops: [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                color: Colors.transparent,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${data.number}',
                        style: const TextStyle(
                            fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(data.title,
                        style: const TextStyle(
                            fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(data.subtitle,
                        style: const TextStyle(fontSize: 14, color: Colors.white)),
                  ],
                ),
              ),
              Container(
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/goal${data.number}.png',
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.2),
                      colorBlendMode: BlendMode.darken,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(data.backgroundImage),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.2), BlendMode.darken),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.track_changes, color: Colors.white, size: 30),
                            const SizedBox(height: 4),
                            Text('${data.activities} การดำเนินการ',
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload, color: Colors.white, size: 30),
                            const SizedBox(height: 4),
                            Text('${data.uploaded} ดำเนินการแล้ว',
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBox(context, 'เกี่ยวกับ', Icons.edit_note,
                              data.color.withOpacity(0.7)),
                          _buildBox(context, 'เป้าหมาย', Icons.flag, data.color),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildBox(context, 'อัปโหลดรูปกิจกรรม', Icons.cloud_upload,
                          Colors.brown.shade200,
                          fullWidth: true),
                      const SizedBox(height: 20),

                      // แสดงข้อมูลตัวชี้วัดที่ดึงจาก API
                      Expanded(
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : error != null
                                ? Center(child: Text(error!))
                                : ListView.builder(
                                    itemCount: indicators.length,
                                    itemBuilder: (context, index) {
                                      final indicator = indicators[index];
                                      return ListTile(
                                        title: Text(indicator['indicator'] ?? 'ไม่มีชื่อ'),
                                        subtitle:
                                            Text(indicator['shortDefinition'] ?? 'ไม่มีคำอธิบาย'),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBox(
    BuildContext context,
    String label,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : MediaQuery.of(context).size.width * 0.4,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: Colors.black),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(label, style: const TextStyle(color: Colors.black)),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
