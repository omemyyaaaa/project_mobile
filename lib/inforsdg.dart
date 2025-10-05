import 'package:flutter/material.dart';
import 'sdg_data.dart'; // import class SDGData เข้ามา

class SdgInfoPage extends StatelessWidget {
  final SDGData data;

  const SdgInfoPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'เกี่ยวกับเป้าหมายที่ ${data.number}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: data.color,
        iconTheme: const IconThemeData(color: Colors.white), // ทำให้ปุ่ม back เป็นสีขาว
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ส่วนของคำอธิบายหลัก
              Text(
                data.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: data.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                data.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // ส่วนของเป้าหมายย่อย
              Text(
                'เป้าหมายย่อย (${data.targets.length} ข้อ)',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // แสดงรายการเป้าหมายย่อย
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(), // ป้องกันการ scroll ซ้อนกัน
                shrinkWrap: true,
                itemCount: data.targets.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: data.color.withOpacity(0.2),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: data.color,
                        ),
                      ),
                    ),
                    title: Text(data.targets[index]),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}