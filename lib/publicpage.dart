import 'package:flutter/material.dart';
import 'package:flutter_application_1/myhome.dart';
import 'package:flutter_application_1/profile.dart';

class Publicpage extends StatefulWidget {
  const Publicpage({super.key});

  @override
  State<Publicpage> createState() => _PublicpageState();
}

class _PublicpageState extends State<Publicpage> {
  static const Color _primaryGreen = Color(0xFF4CAF50);
  static const Color _lightGreen = Color(0xFFE8F5E8);
  static const Color _darkBlue = Color(0xFF1976D2);

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.green.shade700,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: Center(
      child: Text(
        'หน้านี้คือ Publicpage',
        style: TextStyle(fontSize: 24),
      ),
    ),
    bottomNavigationBar: _buildBottomNavigation(context),
  );
}


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

  Widget _buildBottomNavItem(BuildContext context, IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        color: Colors.black,
        size: 28,
      ),
      onPressed: () {
        _onBottomNavTap(context, index);
      },
    );
  }

  void _onBottomNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MyHome(),
          ),
        );
        break;
      case 1:
        //
        break;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ProfilePage(),
          ),
        );
        break;
      case 3:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ProfilePage(),
          ),
        );
        break;
    }
  }
}
