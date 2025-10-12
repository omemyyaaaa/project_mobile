  import 'package:flutter/material.dart';
import 'package:flutter_application_1/myhome.dart';
  import 'package:flutter_application_1/screen/homesr.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';
  import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('th_TH', null);

  // ✅ Initialize Supabase ก่อน runApp
  await Supabase.initialize(
    url: 'https://your-project.supabase.co', // เปลี่ยนเป็น URL ของคุณ
    anonKey: 'your-anon-key', // เปลี่ยนเป็น anon key ของคุณ
  );

  runApp(MyApp());
}

  class MyApp extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Flutter Demo',
        initialRoute: '/', // สมมติว่าหน้าแรกคือ Login
      routes: {
        '/': (context) => HomeScreen(), // หน้า Login ของคุณ
        '/home': (context) => const MyHome(), // <<--- ตั้งชื่อให้ MyHome ตรงนี้
        // ... routes อื่นๆ ของคุณ
      },
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
      );
    }
  } 
