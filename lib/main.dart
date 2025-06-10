import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'controllers/app_controller.dart';
import 'controllers/video_post_controller.dart';
import 'controllers/story_upload_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/payment_controller.dart';
import 'themes/app_theme.dart';
import 'translations/app_translations.dart';
import 'views/video_post_page.dart';
import 'views/story_upload_page.dart';
import 'views/profile_page.dart';
import 'views/payment_gateway_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetStorage
  await GetStorage.init();
  
  runApp(SocialMediaApp());
}

class SocialMediaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Social Media Demo',
      debugShowCheckedModeBanner: false,
      
      // GetX Configuration
      initialBinding: AppBinding(),
      
      // Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Internationalization
      translations: AppTranslations(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      
      // Routes
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => MainNavigationPage(),
        ),
        GetPage(
          name: '/video-post',
          page: () => VideoPostPage(),
        ),
        GetPage(
          name: '/story-upload',
          page: () => StoryUploadPage(),
        ),
        GetPage(
          name: '/profile',
          page: () => ProfilePage(),
        ),
        GetPage(
          name: '/payment',
          page: () => PaymentGatewayPage(),
        ),
      ],
    );
  }
}

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize all controllers
    Get.put(AppController(), permanent: true);
    Get.lazyPut(() => VideoPostController());
    Get.lazyPut(() => StoryUploadController());
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => PaymentController());
  }
}

class MainNavigationPage extends StatelessWidget {
  final AppController appController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        switch (appController.selectedTabIndex.value) {
          case 0:
            return VideoPostPage();
          case 1:
            return StoryUploadPage();
          case 2:
            return ProfilePage();
          case 3:
            return PaymentGatewayPage();
          default:
            return VideoPostPage();
        }
      }),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: appController.selectedTabIndex.value,
        onTap: appController.changeTab,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'nav_home'.tr,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'nav_stories'.tr,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'nav_profile'.tr,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'nav_payment'.tr,
          ),
        ],
      )),
    );
  }
} 