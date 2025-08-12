import 'package:flutter/material.dart';
import 'package:flutter_application_1/custom_bottom_nav.dart';

class Publicpage extends StatefulWidget {
  const Publicpage({Key? key}) : super(key: key);

  @override
  State<Publicpage> createState() => _PublicpageState();
}

class _PublicpageState extends State<Publicpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Page'),
        backgroundColor: Colors.green.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(child: Text('Public Content')),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1, onTap: null,),
    );
  }
}
