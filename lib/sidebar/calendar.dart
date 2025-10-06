import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CalenBar extends StatefulWidget {
  const CalenBar({super.key});

  @override
  State<CalenBar> createState() => _CalenBarState();
}

class _CalenBarState extends State<CalenBar> {
  // State variables
  late DateTime _focusedDate;
  DateTime? _selectedDate;
  bool _isLoading = true;
  String? _error;
  
  // Map สำหรับเก็บ Event ที่ดึงมาจาก API
  // Key: วันที่ (normalized to midnight), Value: List ของ event ในวันนั้น
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTime.now();
    _selectedDate = _normalizeDate(DateTime.now());
    _fetchEvents(_focusedDate.year, _focusedDate.month);
  }

  // ฟังก์ชันสำหรับปรับวันที่ให้เป็นเที่ยงคืน เพื่อใช้เป็น Key ใน Map
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // --- API Fetching ---
  Future<void> _fetchEvents(int year, int month) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _events = {}; // ล้างข้อมูลเก่าก่อนดึงใหม่
    });

    try {
      // ใช้ 10.153.27.172 สำหรับ Android Emulator เพื่อเชื่อมต่อกับ localhost ของเครื่องคอม
      final url = Uri.parse('http://10.153.27.172:3000/api/calendar?year=$year&month=$month');
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> fetchedEvents = data['events'] ?? [];

        final Map<DateTime, List<dynamic>> eventsMap = {};
        for (var event in fetchedEvents) {
          final DateTime activityDate = DateTime.parse(event['activity_date']);
          final normalizedDate = _normalizeDate(activityDate);

          
          if (eventsMap[normalizedDate] == null) {
            eventsMap[normalizedDate] = [];
          }
          eventsMap[normalizedDate]!.add(event);
        }
        
        setState(() {
          _events = eventsMap;
        });

      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = 'เกิดข้อผิดพลาด: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- UI Builder Methods ---

  // ส่วนหัวของปฏิทิน (ชื่อเดือน และปุ่มเลื่อน)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
              });
              _fetchEvents(_focusedDate.year, _focusedDate.month);
            },
          ),
          Text(
            DateFormat.yMMMM().format(_focusedDate),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
              });
              _fetchEvents(_focusedDate.year, _focusedDate.month);
            },
          ),
        ],
      ),
    );
  }
  
  // แถบแสดงวันในสัปดาห์ (S M T W T F S)
  Widget _buildDaysOfWeek() {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((day) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
      )).toList(),
    );
  }

  // ตารางวันที่ของปฏิทิน
  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    // Dart: Monday=1, Sunday=7. เราปรับให้ Sunday=0, Saturday=6
    final firstWeekday = (firstDayOfMonth.weekday % 7);
    final daysInMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemCount: daysInMonth + firstWeekday,
      itemBuilder: (context, index) {
        if (index < firstWeekday) {
          return Container(); // ช่องว่างก่อนวันที่ 1
        }
        
        final day = index - firstWeekday + 1;
        final date = DateTime(_focusedDate.year, _focusedDate.month, day);
        final normalizedDate = _normalizeDate(date);
        
        final isSelected = _selectedDate != null && _selectedDate == normalizedDate;
        final isToday = _normalizeDate(DateTime.now()) == normalizedDate;
        final hasEvents = _events[normalizedDate] != null && _events[normalizedDate]!.isNotEmpty;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = normalizedDate;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.deepPurple.shade300 : (isToday ? Colors.deepPurple.shade100 : Colors.transparent),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (hasEvents)
                  Container(
                    width: 5, height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.white : Colors.red,
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  // รายการภารกิจของวันที่เลือก
  Widget _buildEventList() {
    if (_selectedDate == null) return const SizedBox.shrink();

    final selectedEvents = _events[_selectedDate] ?? [];

    if (selectedEvents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text("ไม่มีภารกิจในวันที่เลือก", style: TextStyle(color: Colors.grey))),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "ภารกิจวันที่ ${DateFormat.yMMMd().format(_selectedDate!)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: selectedEvents.length,
              itemBuilder: (context, index) {
                final event = selectedEvents[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.assignment, color: Colors.deepPurple),
                    title: Text(event['title'] ?? 'No Title'),
                    subtitle: Text(event['description'] ?? 'No Description'),

                    // สามารถเพิ่ม subtitle หรือ trailing ได้ตามต้องการ
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ปฏิทินภารกิจ'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildDaysOfWeek(),
          const Divider(height: 1),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(child: Text(_error!, style: const TextStyle(color: Colors.red))),
            )
          else
            _buildCalendarGrid(),

          const Divider(height: 1, thickness: 1),
          _buildEventList(),
        ],
      ),
    );
  }
}