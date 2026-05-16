import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';

class RestPresetStorage {
  RestPresetStorage._();

  static final RestPresetStorage instance = RestPresetStorage._();

  static String get _boxName => '${AppConstants.hiveId}-rest-presets';
  static const _key = 'presets';
  static const _lastUsedKey = 'lastUsed';
  static const List<int> _defaultPresets = [30, 60, 90, 120, 180, 300];

  Box<dynamic>? _box;

  Future<void> init() async {
    try {
      await Hive.initFlutter();
    } on MissingPluginException {
      final dir = Directory(
          '${Directory.systemTemp.path}/${AppConstants.appIdentifier}');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      Hive.init(dir.path);
    }
    _box ??= await Hive.openBox<dynamic>(_boxName);
  }

  List<int> getPresets() {
    final raw = _box?.get(_key);
    if (raw == null) return List.of(_defaultPresets);
    return (raw as List).map((e) => (e as num).toInt()).toList();
  }

  Future<void> addPreset(int seconds) async {
    final box = await _ensureBox();
    final presets = getPresets();
    if (!presets.contains(seconds)) {
      presets.add(seconds);
      presets.sort();
      await box.put(_key, presets);
    }
  }

  int? getLastUsed() {
    final raw = _box?.get(_lastUsedKey);
    return raw == null ? null : (raw as num).toInt();
  }

  Future<void> saveLastUsed(int seconds) async {
    final box = await _ensureBox();
    await box.put(_lastUsedKey, seconds);
  }

  Future<void> removePreset(int seconds) async {
    final box = await _ensureBox();
    final presets = getPresets()..remove(seconds);
    await box.put(_key, presets);
  }

  Future<Box<dynamic>> _ensureBox() async {
    if (_box != null) return _box!;
    await init();
    return _box!;
  }
}
