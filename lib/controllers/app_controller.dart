import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppController extends GetxController {
  static AppController get instance => Get.find();
  
  final GetStorage _storage = GetStorage();
  
  var isDarkMode = false.obs;
  var currentLocale = const Locale('en', 'US').obs;
  var selectedTabIndex = 0.obs;
  
  // Storage keys
  static const String _themeKey = 'isDarkMode';
  static const String _localeKey = 'locale';

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    // Load theme preference
    isDarkMode.value = _storage.read(_themeKey) ?? false;
    
    // Load locale preference
    final localeString = _storage.read(_localeKey);
    if (localeString != null) {
      final parts = localeString.split('_');
      if (parts.length == 2) {
        currentLocale.value = Locale(parts[0], parts[1]);
      }
    }
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _storage.write(_themeKey, isDarkMode.value);
    
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void changeLocale(Locale locale) {
    currentLocale.value = locale;
    _storage.write(_localeKey, '${locale.languageCode}_${locale.countryCode}');
    
    Get.updateLocale(locale);
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  // Navigation helpers
  void goToVideoPost() {
    selectedTabIndex.value = 0;
    Get.toNamed('/video-post');
  }

  void goToStoryUpload() {
    Get.toNamed('/story-upload');
  }

  void goToProfile() {
    selectedTabIndex.value = 1;
    Get.toNamed('/profile');
  }

  void goToPayment() {
    Get.toNamed('/payment');
  }

  // Theme getters
  bool get isLightMode => !isDarkMode.value;
  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
  
  // Locale getters
  bool get isEnglish => currentLocale.value.languageCode == 'en';
  bool get isSpanish => currentLocale.value.languageCode == 'es';

  // Available locales
  List<Locale> get supportedLocales => const [
    Locale('en', 'US'),
    Locale('es', 'ES'),
  ];

  String getLocaleDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  // App lifecycle management
  void onAppResumed() {
    // Handle app resume logic
    print('App resumed');
  }

  void onAppPaused() {
    // Handle app pause logic
    print('App paused');
  }

  void onAppDetached() {
    // Handle app detached logic
    print('App detached');
  }

  @override
  void onClose() {
    super.onClose();
  }
} 