import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Constants/colors.dart';
import '../Constants/styles.dart';

class VersionService {
  static String? _cachedVersion;
  static Future<String>? _versionFuture;

  static Future<String> getVersion() async {
    if (_cachedVersion != null) {
      return _cachedVersion!;
    }

    _versionFuture ??= _fetchVersion();
    return _versionFuture!;
  }

  static Future<String> _fetchVersion() async {
    try {
      final String jsonString = await rootBundle.loadString('version.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _cachedVersion = jsonMap['version'] as String;
      return _cachedVersion!;
    } catch (e) {
      print('Error reading version: $e');
      _cachedVersion = 'Unknown version';
      return _cachedVersion!;
    }
  }
}

class VersionDisplay extends StatefulWidget {
  const VersionDisplay({Key? key}) : super(key: key);

  @override
  State<VersionDisplay> createState() => _VersionDisplayState();
}

class _VersionDisplayState extends State<VersionDisplay> {
  String? version;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final ver = await VersionService.getVersion();
    if (mounted) {
      setState(() {
        version = ver;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (version == null) {
      return const CircularProgressIndicator();
    }

    return Text(
      'v$version',
      style: Style.conigenColorChangableRegularText(color: Clr.black),
    );
  }
}
