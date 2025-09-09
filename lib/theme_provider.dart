// import 'package:flutter/material.dart';

// class ThemeProvider with ChangeNotifier {
//   ThemeData _themeData;

//   ThemeProvider(this._themeData);

//   ThemeData get themeData => _themeData;

//   set themeData(ThemeData themeData) {
//     _themeData = themeData;
//     notifyListeners();
//   }

//   void toggleTheme() {
//     if (_themeData == lightTheme) {
//       themeData = darkTheme;
//     } else {
//       themeData = lightTheme;
//     }
//   }
// }

// final lightTheme = ThemeData(
//   brightness: Brightness.light,
//   primaryColor: const Color(0xFF4CAF50),
//   scaffoldBackgroundColor: const Color(0xFFE8F5E8),
//   appBarTheme: const AppBarTheme(
//     backgroundColor: Color(0xFF4CAF50),
//     foregroundColor: Colors.black,
//   ),
//   cardTheme: const CardTheme(
//     color: Colors.white,
//   ),
//   iconTheme: const IconThemeData(
//     color: Colors.black54,
//   ),
//   textTheme: const TextTheme(
//     bodyLarge: TextStyle(color: Colors.black87),
//     bodyMedium: TextStyle(color: Colors.black54),
//   ),
// );

// final darkTheme = ThemeData(
//   brightness: Brightness.dark,
//   primaryColor: const Color(0xFF212121),
//   scaffoldBackgroundColor: const Color(0xFF121212),
//   appBarTheme: const AppBarTheme(
//     backgroundColor: Color(0xFF212121),
//     foregroundColor: Colors.white,
//   ),
//   cardTheme: const CardTheme(
//     color: Color(0xFF1E1E1E),
//   ),
//   iconTheme: const IconThemeData(
//     color: Colors.white54,
//   ),
//   textTheme: const TextTheme(
//     bodyLarge: TextStyle(color: Colors.white),
//     bodyMedium: TextStyle(color: Colors.white54),
//   ),
// );
