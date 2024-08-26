// import 'package:logger/logger.dart';
// import 'package:universal_html/html.dart';

// class LocalStorage {
//   var logger = Logger(printer: PrettyPrinter());
//   write(String key, var value) {
//     window.localStorage[key] = value;
//   }

//   String? read(String key) {
//     return window.localStorage[key];
//   }

//   clearAll() {
//     window.localStorage.clear();
//   }
// }
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  Future<void> write(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  String? read(String key) {
    SharedPreferences prefs = SharedPreferences.getInstance() as SharedPreferences;
    return prefs.getString(key);
  }

  Future<void> remove(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}
