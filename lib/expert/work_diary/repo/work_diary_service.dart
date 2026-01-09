import 'package:dio/dio.dart';
import 'package:partener_app/constants.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:partener_app/expert/farmer_details/model/farmer_plot_model.dart';
import 'package:partener_app/expert/work_diary/model/workD_darie_model.dart';

class WorkDiaryService {
  final Dio _dio = Dio();
  final String _base = ApiRoutes.baseUri;

  /// Fetch Work Diaries
  Future<List<WorkDiarieModel>> fetchWorkDiaries(int userId, int plotId) async {
    String? token = await SharedPrefs.getUserToken();
    if (token == null) throw Exception("Token not found");

    final response = await _dio.get(
      "$_base${ApiRoutes.expertWorkEndpoint}$userId&plot_id=$plotId",
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }),
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      List<dynamic> rawList = response.data['data']['workDiaries'] ?? [];
      return rawList.map((item) => WorkDiarieModel.fromJson(item)).toList();
    } else {
      throw Exception("Failed to fetch work diaries");
    }
  }

  /// Fetch Plot Details
  Future<FarmerPlotModel?> fetchPlotDetails(int plotId) async {
    final response = await _dio.get("$_base/api/plot/$plotId");

    if (response.statusCode == 200 && response.data != null) {
      return FarmerPlotModel.fromJson(response.data);
    } else {
      throw Exception("Failed to fetch plot details");
    }
  }
}
