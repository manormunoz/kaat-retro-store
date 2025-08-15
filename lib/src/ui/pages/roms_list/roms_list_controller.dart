import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kaat/l10n/app_localizations.dart';
import 'package:kaat/src/app/controllers/language_controller.dart';
import 'package:kaat/src/services/db_service.dart';
import 'package:kaat/src/services/game_class.dart';
import 'package:kaat/src/services/myerient_service.dart';
import 'package:kaat/src/services/screenscraper_service.dart';
import 'package:kaat/src/ui/pages/config/config_controller.dart';
import 'package:kaat/src/ui/widgets/app_snackbar/app_snackbar.dart';
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

  String removeFileExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex > 0) {
      return fileName.substring(0, dotIndex);
    }
    return fileName;
  }

  Future<void> loadRomsList() async {
    try {
      loading.value = true;
      final myrient = MyrientService();
      final list = await myrient.listRoms(platform);
      if (platform['platform_abbr'] == 'mame') {
        final dbService = DbService();
        final dbPlatform = await dbService.getPlatformByAbbr(
          abbr: platform['platform_abbr'],
        );
        for (var rom in list) {
          final dbRom = await dbService.getRom(
            platformId: dbPlatform!['id'] as int,
            rom: clearGameName(rom['name']),
          );
          if (dbRom != null) {
            final logo =
                '${platform['roms_logos']}${Uri.encodeComponent(removeFileExtension(dbRom['title']))}.png';
            final boxart =
                '${platform['roms_boxarts']}${Uri.encodeComponent(removeFileExtension(dbRom['title']))}.png';
            final r = {
              ...rom,
              'name': clearGameName(dbRom['title']),
              'rom': rom['name'],
              'logo': logo,
              'boxart': boxart,
            };
            allRoms.add(r);
            // debugPrint(r.keys.toString());
          } else {
            allRoms.add(rom);
          }
        }
      } else {
        allRoms.assignAll(list);
      }
      roms.assignAll(allRoms);
    } catch (e) {
      debugPrint("loadRomsList Error: $e");
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
        final rom = _normalize(m['rom']?.toString() ?? '');

        return name.contains(q) || (rom.isNotEmpty && rom.contains(q));
      }),
    );
  }

  String clearGameName(String fileName) {
    var name = fileName;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex > 0) {
      name = name.substring(0, dotIndex);
    }
    name = name.replaceAll(RegExp(r'\(.*?\)'), '');
    name = name.replaceAll(RegExp(r'\[.*?\]'), '');

    name = name.replaceAll(RegExp(r'[_\.]+'), ' ');

    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
    return name;
  }

  final _box = GetStorage();

  Future<Game> screenScrapper(String name, int systemId) async {
    try {
      final ss = ScreenScraperService();
      final languageController = Get.find<LanguageController>();
      final devId = dotenv.env['SCREENSCRAPER_DEVUSER'];
      final devPassword = dotenv.env['SCREENSCRAPER_DEVPASSWORD'];
      final softName = dotenv.env['SCREENSCRAPER_SOFTNAME'];
      final ssid = _box.read<String?>(ConfigController.kUser);
      final ssPassword = _box.read<String?>(ConfigController.kPass);
      debugPrint('----------------username---------------------');
      ss.configureDev(
        devId: devId!,
        devPassword: devPassword!,
        softName: softName!,
      );
      if (ssid != null && ssPassword != null) {
        ss.configureUser(ssid: ssid, ssPassword: ssPassword);
      }
      var clearName = clearGameName(name);
      debugPrint(clearName);
      debugPrint(systemId.toString());
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
      // debugPrint(game.ratingOutOf5.toString());
      return game;
    } catch (err) {
      debugPrint('searchGames error');
      err.printError();
      Get.showSnackbar(AppSnackbar(SnackbarType.danger, err.toString()));
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
