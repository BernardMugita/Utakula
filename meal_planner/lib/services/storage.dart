import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';


class StorageAccess {
  final storage = const FlutterSecureStorage();

  AndroidOptions _androidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );

  Future <void> writeSecureData(String key, String value) async {
    await storage.write(key: key, value: value, aOptions: _androidOptions());
  }

  Future <String?> readSecureData(String key) async {
    return storage.read(key: key, aOptions: _androidOptions());
  }

  Future <void> deleteSecureData(String key) async {
    await storage.delete(key: key, aOptions: _androidOptions());
  }

  void saveData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, true);
  }

  void saveDate(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  Future<String?> readDate(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future <void> removeDate(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  Future<bool> checkData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  void deleteData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  Future <void> deleteAllData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();

    for (String key in keys) {
      if (key.contains('_over')) {
      print("Deleting key, $key");
      await prefs.remove(key);
      }
    }
  }

}