import 'dart:io';

import 'package:flutter/services.dart';

/// Serves the app's real asset files from disk so pure-Dart tests can seed
/// knowledge and load model metadata without a Flutter engine.
class FakeBundle extends CachingAssetBundle {
  FakeBundle({String root = '.'}) : _root = root;
  final String _root;

  @override
  Future<ByteData> load(String key) async {
    final f = File('$_root/$key');
    final bytes = await f.readAsBytes();
    return ByteData.view(bytes.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) =>
      File('$_root/$key').readAsString();
}
