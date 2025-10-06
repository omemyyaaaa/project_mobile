import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LeaderboardPage extends StatefulWidget {
  // 1. เพิ่มตัวแปรเพื่อรับ ID ของผู้ใช้ปัจจุบัน
  final int currentUserId;

  const LeaderboardPage({
    super.key,
    required this.currentUserId, // ทำให้ต้องส่ง ID มาเสมอ
  });

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  Future<List<dynamic>>? _dataFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _dataFuture = Future.wait([
      _fetchLeaderboard(),
      _fetchCurrentUserRank(widget.currentUserId),
    ]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _fetchLeaderboard() async {
    // ... (โค้ดส่วนนี้เหมือนเดิม)
    try {
      final url = Uri.parse('http://10.0.2.2:3000/api/leaderboard');
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['leaderboard'] ?? [];
      } else {
        throw Exception('Failed to load leaderboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching leaderboard: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchCurrentUserRank(int userId) async {
    // ... (โค้ดส่วนนี้เหมือนเดิม)
    try {
      final url = Uri.parse(
        'http://10.0.2.2:3000/api/leaderboard/user/$userId',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['userRank'] ?? {};
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }

  Color _getRankColor(int rank, int points) {
    // ✨ [NEW] ถ้าคะแนนเป็น 0 ให้เป็นสีเทาเสมอ
    if (points == 0) {
      return Colors.grey.shade400;
    }
    
    switch (rank) {
      case 1:
        return Colors.amber.shade600;
      case 2:
        return Colors.grey.shade500;
      case 3:
        return Colors.brown.shade400;
      default:
        return const Color(0xFF2E7D32);
    }
  }

  Widget _buildCurrentUserRankBanner(Map<String, dynamic> currentUserData) {
    if (currentUserData.isEmpty) return const SizedBox.shrink();

    // ✨ แก้ไข try_parse เป็น tryParse
    final rank = int.tryParse(currentUserData['rank']?.toString() ?? '0') ?? 0;
    final points =
        int.tryParse(currentUserData['points']?.toString() ?? '0') ?? 0;
    final username = currentUserData['username'] ?? 'You';
    final profileUrl = currentUserData['profile_url'];
    final String displayRank = points == 0 ? '0' : '$rank';

    String? fullUrl;
    if (profileUrl != null && profileUrl.isNotEmpty) {
      fullUrl = "http://10.0.2.2:3000$profileUrl";
    }

    return Card(
      // ... (โค้ด UI ส่วนนี้เหมือนเดิม)
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: points == 0 ? Colors.grey.shade400 : Colors.blue.shade400,
          child: Text(
            // ✨ [MODIFIED] ใช้ displayRank ที่เตรียมไว้
            displayRank, 
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          username,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '$points คะแนน',
          style: TextStyle(color: Colors.blue.shade800),
        ),
        trailing: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey[200],
          backgroundImage: fullUrl != null ? NetworkImage(fullUrl) : null,
          child: fullUrl == null ? const Icon(Icons.person) : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดอันดับผู้ใช้งาน'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      backgroundColor: const Color(0xFFE8F5E8),
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // ... (โค้ดส่วนนี้เหมือนเดิม)
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'เกิดข้อผิดพลาดในการโหลดข้อมูล:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final leaderboard = snapshot.data?[0] as List? ?? [];
          final currentUserRank =
              snapshot.data?[1] as Map<String, dynamic>? ?? {};

          if (leaderboard.isEmpty) {
            // ... (โค้ดส่วนนี้เหมือนเดิม)
            return const Center(
              child: Text(
                'ยังไม่มีผู้ใช้งานที่มีคะแนน',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final int userIndex = leaderboard.indexWhere(
            (user) => user['id'] == widget.currentUserId,
          );

          if (userIndex != -1) {
            // เลื่อนรายการไปยังตำแหน่งของผู้ใช้ปัจจุบัน
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController.animateTo(
                userIndex * 72.0, // ประมาณความสูงของแต่ละรายการ
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            });
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final user = leaderboard[index];

                    // ✨ แก้ไข try_parse เป็น tryParse
                    final rank =
                        int.tryParse(user['rank']?.toString() ?? '0') ?? 0;
                    final points =
                        int.tryParse(user['points']?.toString() ?? '0') ?? 0;
                    final username = user['username'] ?? 'No Name';
                    final profileUrl = user['profile_url'];
                    final String displayRank = points == 0 ? '' : '$rank';

                    String? fullUrl;
                    if (profileUrl != null && profileUrl.isNotEmpty) {
                      fullUrl = "http://10.0.2.2:3000$profileUrl";
                    }

                    final bool isCurrentUser =
                        user['id'] == widget.currentUserId;

                    return Card(
                      // ... (โค้ด UI ส่วนนี้เหมือนเดิม)
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      color: isCurrentUser
                          ? Colors.green.shade100
                          : Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: _getRankColor(rank, points),
                          child: Text(
                            // ✨ [MODIFIED] ใช้ displayRank ที่เตรียมไว้
                            displayRank, 
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        title: Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          '$points คะแนน',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: fullUrl != null
                              ? NetworkImage(fullUrl)
                              : null,
                          child: fullUrl == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildCurrentUserRankBanner(currentUserRank),
            ],
          );
        },
      ),
    );
  }
}
