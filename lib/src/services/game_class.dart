import 'package:flutter/material.dart';

class Game {
  final int id;
  final int? systemId;
  final String title;
  final String? synopsis;
  final double?
  rating; // 0..20 (SS suele usar /20). Puedes mapear a /5 si quieres
  final String? date;
  final String? developer;
  final String? publisher;

  final String? box2D;
  final String? logo;
  final List<String> screenshots;

  Game({
    required this.id,
    required this.title,
    this.systemId,
    this.synopsis,
    this.rating,
    this.date,
    this.developer,
    this.publisher,
    this.box2D,
    this.logo,
    this.screenshots = const [],
  });

  factory Game.fromJeuInfos(Map<String, dynamic> json, Locale locale) {
    final resp = _firstMap(json, 'response') ?? json;

    // Nodo “jeu” (a veces viene directo en response)
    final jeu = _firstMap(resp, 'jeu') ?? resp;

    final id = _asInt(jeu['id']) ?? _asInt(resp['id']) ?? 0;
    final systemId = _asInt(jeu['systemeid'] ?? resp['systemeid']);

    final title = _pickLocalizedText(
      candidates: [
        jeu['noms'], // title
        jeu['nom'],
        resp['noms'],
        resp['nom'],
      ],
      locale: locale,
      // fallbackKeys: const ['nom', 'name', 'titre', 'title'],
      defaultValue: 'Unknown',
    );

    final synopsis = _pickLocalizedText(
      candidates: [jeu['synopsis'], resp['synopsis'], jeu['synopsys']],
      locale: locale,
      // fallbackKeys: const ['synopsis', 'synopsys', 'resume', 'description'],
      defaultValue: null,
    );

    final rating = _asDouble(
      _pickLocalizedText(
        candidates: [jeu['note'], resp['note']],
        locale: locale,
        // fallbackKeys: const ['note', 'text'],
        defaultValue: null,
      ),
    );

    final date = _pickLocalizedText(
      candidates: [jeu['dates'], resp['dates']],
      locale: locale,
      // fallbackKeys: const ['date', 'dates'],
      defaultValue: null,
    );

    final developer = _pickLocalizedText(
      candidates: [jeu['developpeur'], resp['developpeur']],
      locale: locale,
      fallbackKeys: const ['text'],
      defaultValue: 'Unknown',
    );
    final publisher = _pickLocalizedText(
      candidates: [jeu['editeur'], resp['editeur']],
      locale: locale,
      fallbackKeys: const ['text'],
      defaultValue: 'Unknown',
    );
    final medias = _asList(jeu['medias'] ?? resp['medias'] ?? resp['media']);
    final box2D = _firstMediaUrl(medias, ['box-2d', 'box2d', 'box-2D']);
    final logo = _firstMediaUrl(medias, ['logo', 'wheel']);
    final screenshots = _allMediaUrls(medias, ['screenshot', 'snap', 'screen']);

    return Game(
      id: id,
      systemId: systemId,
      title: title!,
      synopsis: synopsis,
      rating: rating,
      date: date,
      developer: developer,
      publisher: publisher,
      box2D: box2D,
      logo: logo,
      screenshots: screenshots,
    );
  }

  factory Game.fromSearchItem(Map<String, dynamic> item, Locale locale) {
    final id = _asInt(item['id']) ?? 0;
    final systemId = _asInt(item['systemeid']);

    final title = _pickLocalizedText(
      candidates: [item['noms'], item['nom']],
      locale: locale,
      // fallbackKeys: const ['nom', 'name', 'titre', 'title'],
      defaultValue: 'Unknown',
    );

    final synopsis = _pickLocalizedText(
      candidates: [item['synopsis']],
      locale: locale,
      // fallbackKeys: const ['synopsis', 'description'],
      defaultValue: null,
    );

    final rating = _asDouble(
      _pickLocalizedText(
        candidates: [item['note']],
        locale: locale,
        // fallbackKeys: const ['note', 'text'],
        defaultValue: null,
      ),
    );
    final date = _pickLocalizedText(
      candidates: [item['dates']],
      locale: locale,
      // fallbackKeys: const ['date', 'dates', 'text'],
      defaultValue: 'Unknown',
    );
    final developer = _pickLocalizedText(
      candidates: [item['developpeur']],
      locale: locale,
      fallbackKeys: const ['text'],
      defaultValue: 'Unknown',
    );
    final publisher = _pickLocalizedText(
      candidates: [item['editeur']],
      locale: locale,
      fallbackKeys: const ['text'],
      defaultValue: 'Unknown',
    );
    final medias = _asList(item['medias'] ?? item['media']);
    final box2D = _firstMediaUrl(medias, ['box-2d', 'box2d', 'box-2D']);
    final logo = _firstMediaUrl(medias, ['logo', 'wheel']);
    final screenshots = _allMediaUrls(medias, ['screenshot', 'snap', 'screen']);

    return Game(
      id: id,
      systemId: systemId,
      title: title!,
      synopsis: synopsis,
      rating: rating,
      date: date,
      developer: developer,
      publisher: publisher,
      box2D: box2D,
      logo: logo,
      screenshots: screenshots,
    );
  }

  static String _norm(String s) => s.toLowerCase().replaceAll('_', '-').trim();

  static String? _pickLocalizedText({
    required List<dynamic> candidates,
    required Locale locale,
    List<String> fallbackKeys = const [],
    String? defaultValue,
  }) {
    final primary = locale.languageCode.toLowerCase();
    final region = (locale.countryCode ?? '').toLowerCase();
    final exactTag = (region.isEmpty) ? primary : '$primary-$region';

    // 0) string
    for (final c in candidates) {
      if (c is String && c.trim().isNotEmpty) return c.trim();
    }

    // 1) map { "en": "...", "es": "..." }
    for (final c in candidates) {
      if (c is Map) {
        final byLang = <String, String>{};
        c.forEach((k, v) {
          if (v is String && v.trim().isNotEmpty) {
            byLang[_norm(k.toString())] = v.trim();
          }
        });

        // exact tag (en-us), idioma base (en)
        if (byLang.containsKey(_norm(exactTag))) return byLang[_norm(exactTag)];
        if (byLang.containsKey(primary)) return byLang[primary];
        if (byLang.containsKey('en')) return byLang['en'];
        for (final k in fallbackKeys) {
          if (byLang.containsKey(_norm(k))) return byLang[_norm(k)];
        }

        if (byLang.isNotEmpty) return byLang.values.first;
      }
    }

    // 2) List [{langue: 'en', text: '...'}]
    for (final c in candidates) {
      final list = (c is List) ? c : const [];
      if (list.isEmpty) continue;

      String? pick(bool Function(String code) match) {
        for (final e in list) {
          if (e is! Map) continue;
          final raw =
              (e['langue'] ?? e['langueid'] ?? e['lang'] ?? e['language'] ?? '')
                  .toString();
          final code = _norm(raw);
          if (code.isEmpty) continue;

          if (match(code)) {
            final v =
                e['text'] ??
                e['nom'] ??
                e['texte'] ??
                e['synopsis'] ??
                e['value'] ??
                e['desc'];
            if (v is String && v.trim().isNotEmpty) return v.trim();
            for (final k in fallbackKeys) {
              final x = e[k];
              if (x is String && x.trim().isNotEmpty) return x.trim();
            }
          }
        }
        return null;
      }

      final exact = pick((code) => code == _norm(exactTag));
      if (exact != null) return exact;

      final base = pick(
        (code) => code == primary || code.startsWith('$primary-'),
      );
      if (base != null) return base;

      final en = pick((code) => code == 'en' || code.startsWith('en-'));
      if (en != null) return en;

      var count = 0;
      var worRegion = false;
      for (var e in list) {
        var region = e['region'];
        if (region == 'wor') {
          worRegion = true;
          var item = list.removeAt(count);
          list.insert(0, item);
        } else if (!worRegion && region == 'us') {
          var item = list.removeAt(count);
          list.insert(0, item);
        }
        count++;
      }
      for (final e in list) {
        if (e is! Map) continue;
        for (final key in [
          'text',
          'nom',
          'texte',
          'synopsis',
          'value',
          'desc',
          ...fallbackKeys,
        ]) {
          final v = e[key];
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
      }
    }

    return defaultValue;
  }

  static String? _firstMediaUrl(
    List<Map<String, dynamic>> medias,
    List<String> typeContains,
  ) {
    for (final m in medias) {
      final t = (m['type'] ?? m['nom'] ?? '').toString().toLowerCase();
      if (typeContains.any((tc) => t.contains(tc.toLowerCase()))) {
        final u = m['url2'] ?? m['url'];
        if (u is String && u.isNotEmpty) return u;
      }
    }
    return null;
  }

  static List<String> _allMediaUrls(
    List<Map<String, dynamic>> medias,
    List<String> typeContains,
  ) {
    final out = <String>[];
    for (final m in medias) {
      final t = (m['type'] ?? m['nom'] ?? '').toString().toLowerCase();
      if (typeContains.any((tc) => t.contains(tc.toLowerCase()))) {
        final u = m['url2'] ?? m['url'];
        if (u is String && u.isNotEmpty) out.add(u);
      }
    }
    return out;
  }

  static Map<String, dynamic>? _firstMap(
    Map<String, dynamic> root,
    String key,
  ) {
    final v = root[key];
    if (v is Map<String, dynamic>) return v;
    if (v is List && v.isNotEmpty && v.first is Map) {
      return (v.first as Map).cast<String, dynamic>();
    }
    return null;
  }

  static List<Map<String, dynamic>> _asList(dynamic v) {
    if (v is List) {
      return v.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    }
    return const [];
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  // static String? _string(dynamic v) {
  //   if (v == null) return null;
  //   final s = v.toString().trim();
  //   return s.isEmpty ? null : s;
  // }

  /// Pasa rating de 0..20 a 0..5
  double? get ratingOutOf5 {
    if (rating == null) {
      return null;
    }
    if (rating! > 5) {
      return rating! / 4.0;
    }
    return rating;
  }
}
