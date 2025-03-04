import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static Future<void> saveUserToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
  }

  static Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  static Future<void> saveUserRole(int role) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("user_role", role);
  }

  static Future<int?> getUserRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("user_role");
  }

  static Future<void> clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("user_role");
  }

  /// **Save User ID** ✅
  static Future<void> saveUserId(int userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("user_id", userId);
  }

  /// **Get User ID** ✅
  static Future<int?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("user_id");
  }

  static Future<void> saveOneSignalPlayerID(String playerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('oneSignalPlayerId', playerId);
  }

  static Future<String?> getOneSignalPlayerID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('oneSignalPlayerId');
  }
}
