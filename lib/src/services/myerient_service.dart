import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

class MyrientService {
  // Singleton instance
  static final MyrientService _instance = MyrientService._internal();
  factory MyrientService() => _instance;
  MyrientService._internal();

  String removeFileExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex > 0) {
      return fileName.substring(0, dotIndex);
    }
    return fileName;
  }

  /// List ROMs from a Myrient folder URL
  /// Returns a list of maps: { name, url, size, date }
  Future<List<Map<String, dynamic>>> listRoms(
    Map<String, dynamic> platform,
  ) async {
    final List<Map<String, dynamic>> roms = [];

    try {
      debugPrint("MyrientService: Requesting URL: ${platform['url']}");
      debugPrint("MyrientService: Platform: ${platform['platform_abbr']}");

      final response = await http.get(
        Uri.parse(platform['url']),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:133.0) Gecko/20100101 Firefox/133.0',
        },
      );

      debugPrint("MyrientService: HTTP Status: ${response.statusCode}");
      debugPrint("MyrientService: Response body length: ${response.body.length}");

      if (response.statusCode != 200) {
        throw Exception('Failed to load Myrient URL: HTTP ${response.statusCode}');
      }

      // Parse HTML
      final document = html_parser.parse(response.body);
      // Find all <a> tags inside the listing
      final rows = document.querySelectorAll('table tbody tr');
      debugPrint("MyrientService: Found ${rows.length} table rows");

      for (final row in rows) {
        final link = row.querySelector('td.link a');
        final size = row.querySelector('td.size')?.text;
        final date = row.querySelector('td.date')?.text;

        final name = link?.text.trim();
        final href = link?.attributes['href'] ?? '';

        // Skip parent dir links
        if (name == '../' ||
            name == './' ||
            name == 'Parent directory/' ||
            name == null ||
            name.isEmpty) {
          continue;
        }
        var logo =
            '${platform['roms_logos']}${Uri.encodeComponent(removeFileExtension(name))}.png';
        var boxart =
            '${platform['roms_boxarts']}${Uri.encodeComponent(removeFileExtension(name))}.png';
        roms.add({
          'name': name,
          'url': Uri.parse(platform['url']).resolve(href).toString(),
          'date': date,
          'size': size,
          'logo': logo,
          'boxart': boxart,
          'ssSystemId': platform['ssSystemId'],
          'platformAbbr': platform['platform_abbr'],
        });
      }

      debugPrint("MyrientService: Successfully parsed ${roms.length} ROMs");
    } catch (e, stackTrace) {
      debugPrint("MyrientService ERROR: $e");
      debugPrint("MyrientService STACK TRACE: $stackTrace");
    }

    return roms;
  }
}
