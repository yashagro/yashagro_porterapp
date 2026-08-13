import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<void> saveUserToken(String token) async {
    await init();
    await _prefs!.setString("auth_token", token);
  }

  static Future<String?> getUserToken() async {
    await init();
    return _prefs!.getString("auth_token");
  }

  static Future<void> saveUserRole(int role) async {
    await init();
    await _prefs!.setInt("user_role", role);
  }

  static Future<int?> getUserRole() async {
    await init();
    return _prefs!.getInt("user_role");
  }

  static Future<void> clearUserData() async {
    await init();
    await _prefs!.remove("auth_token");
    await _prefs!.remove("user_role");
    await _prefs!.remove("user_id");
  }

  /// **Save User ID** ✅
  static Future<void> saveUserId(int userId) async {
    await init();
    await _prefs!.setInt("user_id", userId);
  }

  /// **Get User ID** ✅
  static Future<int?> getUserId() async {
    await init();
    return _prefs!.getInt("user_id");
  }

  static Future<void> saveOneSignalPlayerID(String playerId) async {
    await init();
    await _prefs!.setString('oneSignalPlayerId', playerId);
  }

  static Future<String?> getOneSignalPlayerID() async {
    await init();
    return _prefs!.getString('oneSignalPlayerId');
  }

  static Future<void> saveMapViewPreference(bool isMap) async {
    await init();
    await _prefs!.setBool("manager_map_view_preference", isMap);
  }

  static Future<bool> getMapViewPreference() async {
    await init();
    return _prefs!.getBool("manager_map_view_preference") ?? false;
  }
}
