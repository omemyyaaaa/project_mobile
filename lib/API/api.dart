import 'dart:convert';
import 'package:http/http.dart' as http;

class SDGApi {
 static Future<List<dynamic>> fetchIndicatorsByGoal(int goalNumber) async {
  final url = 'https://unstats.un.org/SDGAPI/v1/sdg/Indicator/List?goal=$goalNumber';
  print('เรียก API ที่: $url');

  final response = await http.get(Uri.parse(url));

  print('status code: ${response.statusCode}');
  print('response body: ${response.body}');

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('ไม่สามารถดึงตัวชี้วัดของเป้าหมายที่ $goalNumber ได้');
  }
}

}
