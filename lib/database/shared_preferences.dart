import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  ///////////////////////////////////////////////////////////////////////////
  // MAP BEST SCORE
  ///////////////////////////////////////////////////////////////////////////
  Future<bool> saveMapBestScore(List<String> ranking) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList('MAPBESTSCOREQ', ranking);
  }

  Future<List<String>?> getBestScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('MAPBESTSCOREQ');
  }
}