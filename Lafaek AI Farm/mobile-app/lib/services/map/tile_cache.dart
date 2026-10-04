import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Stores OpenStreetMap tiles on the phone so the map still draws offline.
///
/// Written by hand rather than taken from a package: the app already depends
/// on `path_provider`, the behaviour needed here is small, and the dedicated
/// caching packages carry licences this project would have to account for.
///
/// Tiles are kept under `<app support>/map_tiles/<z>_<x>_<y>.png`, served from
/// disk first and refreshed from the network in the background when they are
/// older than [refreshAfter]. Offline, whatever was stored is used however old
/// it is — a month-old map of your own field is still your field.
class MapTileCache {
  MapTileCache({this.maxTiles = 1500, this.refreshAfter = const Duration(days: 30)});

  /// Roughly 25–40 MB of tiles; trimmed oldest-first past this.
  final int maxTiles;
  final Duration refreshAfter;

  Directory? _dir;
  Future<Directory?>? _opening;

  /// The cache directory, or null when there is nowhere to write — in tests,
  /// or if the platform refuses. Callers treat null as "no cache", never as
  /// an error: a map without a cache still works, it just needs the network.
  Future<Directory?> _directory() {
    final open = _opening ??= () async {
      try {
        final support = await getApplicationSupportDirectory();
        final dir = Directory(p.join(support.path, 'map_tiles'));
        if (!await dir.exists()) await dir.create(recursive: true);
        _dir = dir;
        return dir;
      } catch (e) {
        debugPrint('map tile cache unavailable, tiles will not be stored: $e');
        return null;
      }
    }();
    return open;
  }

  File? fileForSync(TileCoordinates c) {
    final dir = _dir;
    if (dir == null) return null;
    return File(p.join(dir.path, '${c.z}_${c.x}_${c.y}.png'));
  }

  Future<File?> fileFor(TileCoordinates c) async {
    final dir = await _directory();
    if (dir == null) return null;
    return File(p.join(dir.path, '${c.z}_${c.x}_${c.y}.png'));
  }

  Future<void> write(TileCoordinates c, Uint8List bytes) async {
    try {
      final file = await fileFor(c);
      if (file == null) return;
      await file.writeAsBytes(bytes, flush: false);
      unawaited(_trim());
    } catch (e) {
      debugPrint('tile cache write failed: $e');
    }
  }

  /// Number of tiles held, for the Offline & Sync screen.
  Future<int> count() async {
    try {
      final dir = await _directory();
      return dir == null ? 0 : dir.listSync().whereType<File>().length;
    } catch (_) {
      return 0;
    }
  }

  Future<int> sizeBytes() async {
    try {
      final dir = await _directory();
      if (dir == null) return 0;
      var total = 0;
      for (final f in dir.listSync().whereType<File>()) {
        total += f.statSync().size;
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  Future<void> clear() async {
    try {
      final dir = await _directory();
      if (dir == null) return;
      for (final f in dir.listSync().whereType<File>()) {
        await f.delete();
      }
    } catch (e) {
      debugPrint('tile cache clear failed: $e');
    }
  }

  bool _trimming = false;

  Future<void> _trim() async {
    if (_trimming) return;
    _trimming = true;
    try {
      final dir = await _directory();
      if (dir == null) return;
      final files = dir.listSync().whereType<File>().toList();
      if (files.length <= maxTiles) return;
      files.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
      for (final f in files.take(files.length - maxTiles)) {
        await f.delete();
      }
    } catch (e) {
      debugPrint('tile cache trim failed: $e');
    } finally {
      _trimming = false;
    }
  }
}

/// Serves map tiles from [cache] first, then the network.
///
/// A tile that is on disk is shown immediately — that is what makes the map
/// usable with no signal. If it is also past its refresh age and the network
/// is reachable, a fresh copy is downloaded for next time without disturbing
/// what is on screen.
class CachedNetworkTileProvider extends TileProvider {
  CachedNetworkTileProvider({
    required this.cache,
    required this.userAgent,
    HttpClient? client,
  }) : _client = client ?? (HttpClient()..userAgent = userAgent);

  final MapTileCache cache;

  /// The OSM tile usage policy requires a identifying User-Agent.
  final String userAgent;
  final HttpClient _client;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      _CachedTileImage(
        url: getTileUrl(coordinates, options),
        coordinates: coordinates,
        provider: this,
      );

  @override
  void dispose() {
    _client.close(force: true);
    super.dispose();
  }

  Future<Uint8List> load(TileCoordinates c, String url) async {
    final file = await cache.fileFor(c);

    if (file != null && await file.exists()) {
      final age = DateTime.now().difference(await file.lastModified());
      if (age <= cache.refreshAfter) return file.readAsBytes();
      // Stale but usable: serve it now, refresh quietly for next time.
      unawaited(_download(c, url).catchError((_) => Uint8List(0)));
      return file.readAsBytes();
    }

    try {
      return await _download(c, url);
    } catch (e) {
      // Nothing stored and no network. A blank tile leaves the rest of the
      // map — the pin, the other tiles — readable, which beats an error grid.
      debugPrint('tile unavailable, drawing blank: $e');
      return blankTile;
    }
  }

  /// A 1x1 transparent PNG, drawn where there is no tile and no network.
  static final Uint8List blankTile = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk'
      'YPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==');

  Future<Uint8List> _download(TileCoordinates c, String url) async {
    final request = await _client.getUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.userAgentHeader, userAgent);
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException('tile ${response.statusCode}', uri: Uri.parse(url));
    }
    final bytes = await consolidateHttpClientResponseBytes(response);
    await cache.write(c, bytes);
    return bytes;
  }
}

class _CachedTileImage extends ImageProvider<_CachedTileImage> {
  const _CachedTileImage({
    required this.url,
    required this.coordinates,
    required this.provider,
  });

  final String url;
  final TileCoordinates coordinates;
  final CachedNetworkTileProvider provider;

  @override
  Future<_CachedTileImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_CachedTileImage>(this);

  @override
  ImageStreamCompleter loadImage(
      _CachedTileImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _load(decode),
      scale: 1,
      debugLabel: url,
    );
  }

  Future<ui.Codec> _load(ImageDecoderCallback decode) async {
    var bytes = await provider.load(coordinates, url);
    if (bytes.isEmpty) bytes = CachedNetworkTileProvider.blankTile;
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) =>
      other is _CachedTileImage && other.url == url;

  @override
  int get hashCode => url.hashCode;
}
