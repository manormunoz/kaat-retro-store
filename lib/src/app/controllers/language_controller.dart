import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kaat/l10n/app_localizations.dart';

class LanguageController extends GetxController {
  static const _key = 'locale';
  final _box = GetStorage();

  final Rxn<Locale> locale = Rxn<Locale>();

  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  @override
  void onInit() {
    final saved = _box.read<String?>(_key);
    if (saved != null && saved.isNotEmpty) {
      locale.value = _fromTag(saved);
    } else {
      locale.value = null;
    }
    super.onInit();
  }

  void setLocale(Locale? value) {
    locale.value = value;
    if (value == null) {
      _box.remove(_key);
    } else {
      _box.write(_key, _toTag(value));
    }
  }

  void useSystem() => setLocale(null);

  void toggle() {
    if (locale.value == null) {
      setLocale(
        supportedLocales.isNotEmpty
            ? supportedLocales.first
            : const Locale('en'),
      );
    } else {
      useSystem();
    }
  }

  void nextLocale() {
    if (supportedLocales.isEmpty) return;
    if (locale.value == null) {
      setLocale(supportedLocales.first);
      return;
    }
    final idx = supportedLocales.indexWhere(
      (l) => _sameLocale(l, locale.value!),
    );
    final next = (idx < 0 || idx + 1 >= supportedLocales.length)
        ? null
        : supportedLocales[idx + 1];
    setLocale(next);
  }

  bool get isSystem => locale.value == null;

  Locale get effectiveLocale {
    if (locale.value != null) return locale.value!;
    final sys = WidgetsBinding.instance.platformDispatcher.locale;
    return _closestSupported(sys) ??
        supportedLocales.firstOrNull ??
        const Locale('en');
  }

  bool _sameLocale(Locale a, Locale b) =>
      a.languageCode == b.languageCode &&
      (a.countryCode ?? '') == (b.countryCode ?? '');

  String _toTag(Locale l) => (l.countryCode?.isNotEmpty ?? false)
      ? '${l.languageCode}-${l.countryCode}'
      : l.languageCode;

  Locale _fromTag(String tag) {
    final parts = tag.split(RegExp('[-_]'));
    return parts.length >= 2 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
  }

  Locale? _closestSupported(Locale sys) {
    final exact = supportedLocales.firstWhereOrNull(
      (l) =>
          l.languageCode == sys.languageCode &&
          (l.countryCode ?? '') == (sys.countryCode ?? ''),
    );
    if (exact != null) return exact;

    return supportedLocales.firstWhereOrNull(
      (l) => l.languageCode == sys.languageCode,
    );
  }
}
