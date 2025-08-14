import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:kaat/src/app/controllers/language_controller.dart';
import 'package:kaat/src/services/game_class.dart';
import 'package:kaat/src/services/myerient_service.dart';
import 'package:kaat/src/services/screenscraper_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RomsListController extends GetxController {
  late Map<String, dynamic> platform;
  var allRoms = RxList<Map<String, dynamic>>([]);
  final roms = <Map<String, dynamic>>[].obs;
  var loading = true.obs;
  final searchText = ''.obs;
  final searchCtrl = TextEditingController();
  Worker? _debouncer;

  RomsListController();
  @override
  void onInit() {
    super.onInit();
    platform = Get.parameters as Map<String, dynamic>;
    _debouncer = debounce<String>(
      searchText,
      (_) => _applyFilter(),
      time: const Duration(milliseconds: 300),
    );
    loadRomsList();
  }

  void onSearchChanged(String text) {
    searchText.value = text;
  }

  Future<void> loadRomsList() async {
    try {
      loading.value = true;
      final myrient = MyrientService();
      final list = await myrient.listRoms(platform);
      allRoms.assignAll(list);
      roms.assignAll(list);
    } catch (e) {
      debugPrint("Error cargando platforms.yml: $e");
    } finally {
      loading.value = false;
    }
  }

  String _normalize(String s) {
    final lower = s.toLowerCase();
    const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const to = 'aaaaaeeeeiiiiooooouuuunc';
    final buf = StringBuffer();
    for (final ch in lower.split('')) {
      final i = from.indexOf(ch);
      buf.write(i >= 0 ? to[i] : ch);
    }
    return buf.toString();
  }

  void _applyFilter() {
    final q = _normalize(searchText.value);
    if (q.isEmpty) {
      roms.assignAll(allRoms);
      return;
    }
    roms.assignAll(
      allRoms.where((m) {
        final name = _normalize(m['name']?.toString() ?? '');
        return name.contains(q);
      }),
    );
  }

  String clearGameName(String fileName) {
    var name = '';
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex > 0) {
      name = fileName.substring(0, dotIndex);
    }
    name = name.replaceAll(RegExp(r'\(.*?\)'), '');
    name = name.replaceAll(RegExp(r'\[.*?\]'), '');

    name = name.replaceAll(RegExp(r'[_\.]+'), ' ');

    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
    return name;
  }

  Future<Game> screenScrapper(String name, int systemId) async {
    try {
      final ss = ScreenScraperService();
      final languageController = Get.find<LanguageController>();
      final devId = dotenv.env['SCREENSCRAPER_DEVUSER'];
      final devPassword = dotenv.env['SCREENSCRAPER_DEVPASSWORD'];
      final softName = dotenv.env['SCREENSCRAPER_SOFTNAME'];
      ss.configureDev(
        devId: devId!,
        devPassword: devPassword!,
        softName: softName!,
      );
      var clearName = clearGameName(name);
      final r = await ss.searchGames(clearName, systemId: systemId);
      final items = (r['response']?['jeux'] ?? r['jeux'] ?? []) as List;

      final game = Game.fromSearchItem(
        items.first as Map<String, dynamic>,
        languageController.effectiveLocale,
      );
      // debugPrint('-------------------------------');
      // debugPrint(game.title);
      // debugPrint(game.synopsis);
      // debugPrint(game.box2D);
      // debugPrint(game.logo);
      // debugPrint(game.date);
      // debugPrint(game.developer);
      // debugPrint(game.publisher);
      // debugPrint(game.screenshots.first);
      // debugPrint(game.rating.toString());
      return game;
    } catch (err) {
      debugPrint('searchGames error');
      rethrow;
    }
  }

  Future<void> openMyrient(String url) async {
    // final uri = Uri.parse(url);
    // if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    //   throw Exception('Could not launch $uri');
    // }

    final uri = Uri.parse(url);
    final dirUrl = uri
        .replace(path: uri.path.substring(0, uri.path.lastIndexOf('/')))
        .toString();

    final ok = await launchUrl(
      Uri.parse(dirUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!ok) throw Exception('Could not launch $dirUrl');
  }

  Future<void> copyRomUrl(String fileUrl) async {
    await Clipboard.setData(ClipboardData(text: fileUrl));
  }
}
