import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:html/parser.dart' as html_parser;

class MyrientService {
  // Singleton instance
  static final MyrientService _instance = MyrientService._internal();
  factory MyrientService() => _instance;
  MyrientService._internal();

  // Create a custom HTTP client that handles SSL certificates properly on Windows
  http.Client _createHttpClient() {
    final ioClient = HttpClient();
    // Allow bad certificates (Myrient uses Let's Encrypt which should be fine, but just in case)
    ioClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      debugPrint("Certificate warning for $host:$port");
      // Only accept certificates from myrient.erista.me
      return host == 'myrient.erista.me';
    };
    return IOClient(ioClient);
  }

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
    final client = _createHttpClient();

    try {
      debugPrint("MyrientService: Requesting URL: ${platform['url']}");
      debugPrint("MyrientService: Platform: ${platform['platform_abbr']}");

      final response = await client.get(
        Uri.parse(platform['url']),
        headers: {
          'User-Agent': 'Kaat-Retro-Store/1.0',
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
    } finally {
      client.close();
    }

    return roms;
  }
}
