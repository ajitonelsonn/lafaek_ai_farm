/// What the app can say about a crop, and where that capability comes from.
enum CropSupport {
  /// Leaf photos are classified by the on-device vision model, and the
  /// knowledge library and risk rules cover the crop. Works with no signal.
  localScan,

  /// Knowledge articles and risk rules are on the phone, but the vision model
  /// has not been trained on this crop. Advice works offline; photo analysis
  /// needs the online service.
  localAdvice,

  /// Nothing about this crop is on the phone. The farmer can still record it
  /// and get advice, but only while there is a connection.
  onlineOnly,
}

extension CropSupportInfo on CropSupport {
  bool get worksOffline => this != CropSupport.onlineOnly;
  bool get canScanOffline => this == CropSupport.localScan;
}

/// The crops the app knows about, and how well.
///
/// The split is deliberate and visible to the farmer. Crops in [localScan]
/// were trained into the bundled vision model, so a photo is analysed on the
/// phone with no signal. Everything else depends on the online service, and
/// the Add Crop screen says so rather than letting a farmer discover it in a
/// field with no bars.
class CropCatalogue {
  CropCatalogue._();

  /// Crops the on-device vision model has classes for.
  /// Keep in step with `assets/models/model_meta.json`.
  static const List<String> localScanCrops = [
    'Maize',
    'Rice',
    'Tomato',
    'Papaya',
  ];

  /// Crops with knowledge articles and risk rules on the phone, but no
  /// vision class yet.
  static const List<String> localAdviceCrops = [
    'Chili',
    'Beans',
    'Cassava',
  ];

  /// Common Timor-Leste crops the app accepts but has no local data for.
  /// Recording them always works; advice needs a connection.
  static const List<String> onlineOnlyCrops = [
    'Coffee',
    'Coconut',
    'Banana',
    'Sweet potato',
    'Potato',
    'Onion',
    'Cabbage',
    'Water spinach',
    'Peanut',
    'Mango',
    'Citrus',
    'Taro',
  ];

  /// Everything the farmer may choose, best-supported first.
  static const List<String> all = [
    ...localScanCrops,
    ...localAdviceCrops,
    ...onlineOnlyCrops,
  ];

  /// Crops that are useful with no connection at all.
  static const List<String> offlineCrops = [
    ...localScanCrops,
    ...localAdviceCrops,
  ];

  /// Kept for call sites that only need the offline-capable set.
  static const List<String> supported = offlineCrops;

  static CropSupport supportFor(String crop) {
    final name = crop.trim().toLowerCase();
    bool has(List<String> list) =>
        list.any((c) => c.toLowerCase() == name);
    if (has(localScanCrops)) return CropSupport.localScan;
    if (has(localAdviceCrops)) return CropSupport.localAdvice;
    return CropSupport.onlineOnly;
  }

  static bool isScannable(String crop) =>
      supportFor(crop) == CropSupport.localScan;

  /// Example questions shown on an empty assistant screen. They are prompts,
  /// not canned answers — every reply is generated on the device.
  static const List<String> suggestedQuestions = [
    'How can I improve my soil health?',
    'What are common pests in maize?',
    'When is the best time to plant rice?',
    'How much water do tomatoes need?',
  ];
}
