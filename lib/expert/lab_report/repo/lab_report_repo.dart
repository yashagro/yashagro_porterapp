import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:partener_app/constants.dart';
import 'package:partener_app/expert/lab_report/model/lab_report_model.dart';
import 'package:partener_app/services/shared_prefs.dart';

class LabReportRepo {
  final String baseUrl = '${ApiRoutes.baseUri}${ApiRoutes.labReportsEndpoint}';

  Future<List<Labreport>> fetchLabReports(String plotId) async {
    final token = await SharedPrefs.getUserToken();
    if (token == null) throw Exception("Missing token");

    final response = await http.get(
      Uri.parse('$baseUrl$plotId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    log('[LabReportRepo] Status Code: ${response.statusCode}');
    log('[LabReportRepo] Body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> rawList = decoded['data'];

      // Extract only the `labreport` from each item
      final List<Labreport> reports =
          rawList.map((item) => Labreport.fromJson(item['labreport'])).toList();

      return reports;
    } else {
      throw Exception('Failed to load lab reports');
    }
  }
}
