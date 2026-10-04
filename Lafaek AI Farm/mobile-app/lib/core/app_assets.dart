/// Central registry of bundled image assets.
///
/// All core UI imagery is local so the app renders fully offline. The icon,
/// crop, mascot, scene and status artwork is cropped from the project's
/// illustration sheet (`all-images.png`) by `tools/assets/split_sprites.py`.
class AppAssets {
  AppAssets._();

  static const String _images = 'assets/images';
  static const String _icons = '$_images/icons';
  static const String _crops = '$_images/crops';
  static const String _mascot = '$_images/mascot';
  static const String _scenes = '$_images/scenes';
  static const String _status = '$_images/status';
  static const String _farmer = '$_images/farmer';

  static const String logo = '$_images/logo.png';
  static const String background = '$_images/bg.png';

  // ---- Mascot ----------------------------------------------------------
  /// Waving robot — splash and welcome.
  static const String mascotWave = '$_mascot/mascot_wave.png';

  /// Second waving pose — assistant header.
  static const String mascotHello = '$_mascot/mascot_hello.png';

  /// Robot holding a tablet with a chat bubble — assistant empty state.
  static const String mascotChat = '$_mascot/mascot_chat.png';

  /// Robot with a question mark — "no answer" / unclear states.
  static const String mascotQuestion = '$_mascot/mascot_question.png';

  /// Robot with a magnifying glass — scanning and analysis.
  static const String mascotScan = '$_mascot/mascot_scan.png';

  /// Celebrating robot — success and completion.
  static const String mascotCelebrate = '$_mascot/mascot_celebrate.png';

  /// Kept for older call sites; the chat pose is the general-purpose one.
  static const String robot = mascotChat;

  // ---- Timorese farmer character ---------------------------------------
  // Used where a person is more relatable than the robot: onboarding, the
  // profile, and empty states a farmer meets before any data exists.
  static const String farmerWelcome = '$_farmer/farmer_welcome.png';
  static const String farmerWave = '$_farmer/farmer_wave.png';
  static const String farmerPlanting = '$_farmer/farmer_planting.png';
  static const String farmerSeedling = '$_farmer/farmer_seedling.png';
  static const String farmerHarvest = '$_farmer/farmer_harvest.png';
  static const String farmerCrate = '$_farmer/farmer_crate.png';
  static const String farmerInspect = '$_farmer/farmer_inspect.png';
  static const String farmerPhone = '$_farmer/farmer_phone.png';
  static const String farmerTablet = '$_farmer/farmer_tablet.png';
  static const String farmerThink = '$_farmer/farmer_think.png';
  static const String farmerIdea = '$_farmer/farmer_idea.png';
  static const String farmerCheer = '$_farmer/farmer_cheer.png';
  static const String farmerHoe = '$_farmer/farmer_hoe.png';
  static const String farmerAvatar = '$_farmer/farmer_avatar.png';

  // ---- Navigation and feature icons ------------------------------------
  static const String icHome = '$_icons/ic_home.png';
  static const String icScan = '$_icons/ic_scan.png';
  static const String icAssistant = '$_icons/ic_assistant.png';
  static const String icFarm = '$_icons/ic_farm.png';
  static const String icWeather = '$_icons/ic_weather.png';
  static const String icMore = '$_icons/ic_more.png';
  static const String icCropField = '$_icons/ic_crop_field.png';
  static const String icPlanting = '$_icons/ic_planting.png';
  static const String icLocation = '$_icons/ic_location.png';
  static const String icWater = '$_icons/ic_water.png';
  static const String icFertilizer = '$_icons/ic_fertilizer.png';
  static const String icPest = '$_icons/ic_pest.png';
  static const String icProtect = '$_icons/ic_protect.png';
  static const String icSoil = '$_icons/ic_soil.png';

  // ---- Action icons -----------------------------------------------------
  static const String icCamera = '$_icons/ic_camera.png';
  static const String icGallery = '$_icons/ic_gallery.png';
  static const String icReports = '$_icons/ic_reports.png';
  static const String icKnowledge = '$_icons/ic_knowledge.png';
  static const String icHistory = '$_icons/ic_history.png';
  static const String icSync = '$_icons/ic_sync.png';
  static const String icSettings = '$_icons/ic_settings.png';
  static const String icProfile = '$_icons/ic_profile.png';
  static const String icAlerts = '$_icons/ic_alerts.png';
  static const String icSearch = '$_icons/ic_search.png';
  static const String icEdit = '$_icons/ic_edit.png';
  static const String icDelete = '$_icons/ic_delete.png';
  static const String icAdd = '$_icons/ic_add.png';
  static const String icCheck = '$_icons/ic_check.png';
  static const String icClose = '$_icons/ic_close.png';
  static const String icBack = '$_icons/ic_back.png';

  // ---- State icons ------------------------------------------------------
  static const String icEmptyGrowth = '$_icons/ic_empty_growth.png';
  static const String icEmptyNone = '$_icons/ic_empty_none.png';
  static const String icOffline = '$_icons/ic_offline.png';
  static const String icUpload = '$_icons/ic_upload.png';
  static const String icVoice = '$_icons/ic_voice.png';
  static const String icTip = '$_icons/ic_tip.png';
  static const String icWarning = '$_icons/ic_warning.png';
  static const String icSuccess = '$_icons/ic_success.png';
  static const String icInfo = '$_icons/ic_info.png';

  // ---- Status glyphs ----------------------------------------------------
  static const String glyphHealthy = '$_status/glyph_healthy.png';
  static const String glyphMonitor = '$_status/glyph_monitor.png';
  static const String glyphDiseased = '$_status/glyph_diseased.png';
  static const String glyphRiskLow = '$_status/glyph_risk_low.png';
  static const String glyphRiskMedium = '$_status/glyph_risk_medium.png';
  static const String glyphRiskHigh = '$_status/glyph_risk_high.png';
  static const String glyphOnlineAi = '$_status/glyph_online_ai.png';
  static const String glyphOfflineAi = '$_status/glyph_offline_ai.png';
  static const String glyphSyncing = '$_status/glyph_syncing.png';

  // ---- Crop thumbnails --------------------------------------------------
  static const String cropMaize = '$_crops/crop_maize.png';
  static const String cropRice = '$_crops/crop_rice.png';
  static const String cropTomato = '$_crops/crop_tomato.png';
  static const String cropChili = '$_crops/crop_chili.png';
  static const String cropBeans = '$_crops/crop_beans.png';
  static const String cropOnion = '$_crops/crop_onion.png';
  static const String cropCassava = '$_crops/crop_cassava.png';
  static const String cropSweetPotato = '$_crops/crop_sweet_potato.png';
  static const String cropBanana = '$_crops/crop_banana.png';
  static const String cropCabbage = '$_crops/crop_cabbage.png';
  static const String cropGreens = '$_crops/crop_greens.png';
  static const String cropPotato = '$_crops/crop_potato.png';
  static const String cropSeedling = '$_crops/crop_seedling.png';

  // ---- Wide scene photos ------------------------------------------------
  static const String sceneValley = '$_scenes/scene_valley.png';
  static const String sceneLeaves = '$_scenes/scene_leaves.png';
  static const String sceneAssistant = '$_scenes/scene_assistant.png';
  static const String sceneVillage = '$_scenes/scene_village.png';
  static const String sceneMountains = '$_scenes/scene_mountains.png';
  static const String sceneFarmhouse = '$_scenes/scene_farmhouse.png';
  static const String sceneFarmer = '$_scenes/scene_farmer.png';

  // ---- Scan photos (unchanged) -----------------------------------------
  static const String scanMaizeHealthy = '$_images/scan_maize_healthy.png';
  static const String scanMaizeSpot = '$_images/scan_maize_spot.png';
  static const String scanTomato = '$_images/scan_tomato.png';
  static const String scanChili = '$_images/scan_chili.png';
  static const String leafBlight = '$_images/leaf_blight.png';

  /// Real maize northern-leaf-blight photo (PlantVillage, CC0) used as the
  /// sample when the device has no camera, so the demo shows a true result.
  static const String sampleLeaf = '$_images/sample_leaf.jpg';

  /// Thumbnail for a crop by name. Unknown crops get a seedling rather than
  /// the wrong vegetable.
  static String cropImageFor(String cropName) {
    switch (cropName.trim().toLowerCase()) {
      case 'maize':
      case 'corn':
        return cropMaize;
      case 'rice':
      case 'paddy':
        return cropRice;
      case 'tomato':
        return cropTomato;
      case 'chili':
      case 'chilli':
      case 'pepper':
        return cropChili;
      case 'beans':
      case 'bean':
      case 'mung beans':
      case 'peanut':
        return cropBeans;
      case 'onion':
      case 'shallot':
        return cropOnion;
      case 'cassava':
        return cropCassava;
      case 'sweet potato':
        return cropSweetPotato;
      case 'banana':
        return cropBanana;
      case 'cabbage':
        return cropCabbage;
      case 'spinach':
      case 'greens':
      case 'kangkung':
      case 'water spinach':
        return cropGreens;
      case 'potato':
        return cropPotato;
      default:
        return cropSeedling;
    }
  }

  /// Wide header photo for a crop.
  static String fieldImageFor(String cropName) {
    switch (cropName.trim().toLowerCase()) {
      case 'rice':
      case 'paddy':
        return sceneValley;
      case 'tomato':
      case 'chili':
      case 'chilli':
        return sceneLeaves;
      case 'maize':
      case 'corn':
        return sceneVillage;
      default:
        return sceneFarmhouse;
    }
  }
}
