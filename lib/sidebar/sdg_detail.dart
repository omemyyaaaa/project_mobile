import 'package:flutter/material.dart';
import 'package:flutter_application_1/sidebar/sdgbar.dart';
import 'sdg_item.dart' hide SDGItem;

class SDGDetail extends StatelessWidget {
  final SDGItem sdg;

  const SDGDetail({super.key, required this.sdg});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              sdg.color.withOpacity(0.8),
              sdg.color.withOpacity(0.4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // รูปเป้าหมาย
                    Center(
                      child: Image.asset(
                        sdg.imagePath,
                        height: 150,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // หัวข้อเป้าหมาย
                    Text(
                      sdg.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // คำอธิบาย
                    Text(
                      sdg.description,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // ปุ่มอัปโหลดหรืออื่น ๆ
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: เพิ่ม action การอัปโหลด
                      },
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text("อัปโหลดกิจกรรม"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: sdg.color,
                      ),
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
