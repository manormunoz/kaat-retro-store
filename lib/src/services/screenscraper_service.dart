import 'dart:convert';
import 'package:http/http.dart' as http;

class ScreenScraperService {
  // Singleton
  ScreenScraperService._();
  static final ScreenScraperService _instance = ScreenScraperService._();
  factory ScreenScraperService() => _instance;
  static ScreenScraperService get I => _instance;

  String? devId;
  String? devPassword;
  String? softName;
  String? ssid;
  String? ssPassword;

  void configureDev({
    required String devId,
    required String devPassword,
    required String softName,
  }) {
    this.devId = devId;
    this.devPassword = devPassword;
    this.softName = softName;
  }

  void configureUser({required String ssid, required String ssPassword}) {
    this.ssid = ssid;
    this.ssPassword = ssPassword;
  }

  Future<Map<String, dynamic>> _get(
    String endpoint,
    Map<String, String> params,
  ) async {
    final uri = Uri.https('www.screenscraper.fr', '/api2/$endpoint', {
      'devid': devId!,
      'devpassword': devPassword!,
      'softname': softName!,
      'output': 'json',
      if (ssid != null) 'ssid': ssid!,
      if (ssPassword != null) 'sspassword': ssPassword!,
      ...params,
    });

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> searchGames(String name, {int? systemId}) {
    return _get('jeuRecherche.php', {
      'recherche': name,
      if (systemId != null) 'systemeid': '$systemId',
    });
  }

  Future<Map<String, dynamic>> gameInfo(int gameId) {
    return _get('jeuInfos.php', {'gameid': '$gameId'});
  }
}
