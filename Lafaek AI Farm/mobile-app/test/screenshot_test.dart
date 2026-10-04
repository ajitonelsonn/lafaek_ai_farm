@Tags(['screenshots'])
library;

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lafaek_ai_farm/navigation/app_routes.dart';
import 'package:lafaek_ai_farm/services/connectivity_service.dart';
import 'package:lafaek_ai_farm/services/weather/open_meteo_client.dart';

import 'app_test.dart' show TestApp, settle;

/// Renders screens at 360 dp and writes PNGs to `build/screenshots/`.
///
/// A development tool, not a check: it writes files and asserts nothing, so it
/// stays out of the default run and is enabled explicitly.
///
///   SCREENSHOTS=1 flutter test test/screenshot_test.dart
final _enabled = Platform.environment['SCREENSHOTS'] == '1';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (!_enabled) return;
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      final loader = FontLoader('Inter')
        ..addFont(File('assets/fonts/Inter-$weight.ttf')
            .readAsBytes()
            .then((b) => ByteData.view(Uint8List.fromList(b).buffer)));
      await loader.load();
    }
  });

  Future<void> shoot(WidgetTester tester, String name) async {
    final dir = Directory('build/screenshots')..createSync(recursive: true);
    final layer = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey('shot')));
    final image = await tester.runAsync(() => layer.toImage(pixelRatio: 2));
    final bytes = await tester
        .runAsync(() => image!.toByteData(format: ui.ImageByteFormat.png));
    File('${dir.path}/$name.png').writeAsBytesSync(
        bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    image!.dispose();
  }

  Future<void> open(WidgetTester tester, String route, String name,
      {Object? arguments, bool liveWeather = false}) async {
    tester.view.physicalSize = const Size(360 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final app = await TestApp.create(
      tester,
      connectivity: ManualConnectivityService(),
      initialRoute: route,
      arguments: arguments,
    );
    if (liveWeather) {
      // Seed a recorded Open-Meteo response so the rainfall chart draws real
      // numbers; the test has no network.
      await tester.runAsync(() async {
        await app.db.putWeather(
          locationKey: 'dili',
          payloadJson: jsonEncode(OpenMeteoClient.payloadFrom(
            jsonDecode(File('test/fixtures/open_meteo_dili.json')
                .readAsStringSync()) as Map<String, dynamic>,
            locationName: 'Home field, Dili',
          )),
          source: 'live',
        );
        await app.farm.refreshWeather();
      });
    }
    await tester.pumpWidget(
      RepaintBoundary(key: const ValueKey('shot'), child: app.widget),
    );
    await settle(tester);
    // Asset images decode off the test zone's clock.
    await tester.runAsync(() async {
      for (final e in find.byType(Image).evaluate()) {
        await precacheImage((e.widget as Image).image, e);
      }
    });
    await settle(tester);
    await shoot(tester, name);
    await TestApp.disposeWith(tester, app);
  }

  const routes = {
    'knowledge': AppRoutes.knowledge,
    'alerts': AppRoutes.alerts,
    'profile': AppRoutes.profile,
    'offline_sync': AppRoutes.offlineSync,
    'weather': AppRoutes.weather,
    'scan_history': AppRoutes.scanHistory,
    'farm_activity': AppRoutes.farmActivity,
    'log_activity': AppRoutes.logActivity,
    'add_crop': AppRoutes.addCrop,
  };

  routes.forEach((name, route) {
    testWidgets('screenshot $name', (tester) async {
      await open(tester, route, name);
    }, skip: !_enabled);
  });

  // The five tabs live inside the shell.
  const tabs = <String, int>{
    'tab_home': MainTab.home,
    'tab_assistant': MainTab.assistant,
    'tab_farm': MainTab.farm,
    'tab_more': MainTab.more,
  };

  testWidgets('screenshot weather_live', (tester) async {
    await open(tester, AppRoutes.weather, 'weather_live', liveWeather: true);
  }, skip: !_enabled);

  tabs.forEach((name, tab) {
    testWidgets('screenshot $name', (tester) async {
      await open(tester, AppRoutes.shell, name, arguments: tab);
    }, skip: !_enabled);
  });
}
