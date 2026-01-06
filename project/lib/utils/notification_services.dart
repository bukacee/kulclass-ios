import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:shortie/pages/bottom_bar_page/controller/bottom_bar_controller.dart';
import 'package:shortie/pages/profile_page/controller/profile_controller.dart';
import 'package:shortie/routes/app_routes.dart';
import 'package:shortie/utils/database.dart';
import 'package:shortie/utils/utils.dart';

class NotificationServices {
  static Callback callback = () {};

  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // This Method Call in Main...
    var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/shortie_notification_icon');

    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();

    final initializationSettings =
        InitializationSettings(android: androidInitializationSettings, iOS: initializationSettingsDarwin);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) {
        callback.call();
      },
    );

    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  static Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(100000).toString(),
      "High Importance Notification",
      importance: Importance.max,
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      playSound: true,
      channel.id,
      channel.name,
      channelDescription: "your channel description",
      // importance: Importance.high,
      priority: Priority.high,
      ticker: "ticker",
      enableVibration: true,
      icon: "@mipmap/shortie_notification_icon",
    );

    DarwinNotificationDetails darwinNotificationDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    _flutterLocalNotificationsPlugin.show(
      Random.secure().nextInt(100000),
      message.notification?.title.toString(),
      message.notification?.body.toString(),
      notificationDetails,
    );
  }

  static Future<void> firebaseInit() async {
    // This Method Call in Main...
    FirebaseMessaging.onMessage.listen(
      (message) {
        Utils.showLog(
            "Local Notification => Is Show Notification => ${Database.isShowNotification} => Is App Open => ${Utils.isAppOpen}");
        Utils.showLog("Notification => ${message.data}");
        Utils.showLog("Notification Title => ${message.notification?.title.toString()}");
        Utils.showLog("Notification Body => ${message.notification?.body.toString()}");

        if (Database.isShowNotification && Utils.isAppOpen.value) {
          showNotification(message);
          callback = () async {
            try {
              if (message.data["type"] == "CHAT") {
                debugPrint("Click To Chat Notification");
                Get.offAllNamed(AppRoutes.bottomBarPage);
                await 1.seconds.delay();
                final bottomBarController = Get.find<BottomBarController>();
                bottomBarController.onChangeBottomBar(3); // Go To Chat Page...
              } else if (message.data["type"] == "VIDEOLIKE") {
                debugPrint("Click To Video Like Notification");
                Get.offAllNamed(AppRoutes.bottomBarPage);
                await 1.seconds.delay();
                final bottomBarController = Get.find<BottomBarController>();
                bottomBarController.onChangeBottomBar(4); // Go To Profile Page...
              } else if (message.data["type"] == "LIVE") {
                debugPrint("Click To Live Notification");
                Get.offAllNamed(AppRoutes.bottomBarPage);
                await 1.seconds.delay();
                final bottomBarController = Get.find<BottomBarController>();
                bottomBarController.onChangeBottomBar(1); // Go To Stream Page...
              } else if (message.data["type"] == "FOLLOW") {
                debugPrint("Click To Follow Notification");
                Get.offAllNamed(AppRoutes.bottomBarPage);
                await 1.seconds.delay();
                final bottomBarController = Get.find<BottomBarController>();
                bottomBarController.onChangeBottomBar(4); // Go To Profile Page...
              } else if (message.data["type"] == "GIFT") {
                debugPrint("Click To Gift Notification");
                Get.offAllNamed(AppRoutes.bottomBarPage);
                await 1.seconds.delay();
                final bottomBarController = Get.find<BottomBarController>();
                bottomBarController.onChangeBottomBar(4); // Go To Profile Page...
                final profileController = Get.find<ProfileController>();
                await 1.seconds.delay();
                profileController.tabController?.index = 2;
              }
            } catch (e) {
              Utils.showLog("Notification Change Routes Failed => ${e}");
            }
          };
        }
      },
    );
  }

  static Future<void> onShowBackgroundNotification(RemoteMessage message) async {
    Utils.showLog(
        "Background Notification => Is Show Notification => ${Database.isShowNotification} => Is App Open => ${Utils.isAppOpen} => ${message.messageId}");
    // if (Database.isShowNotification && Utils.isAppOpen.value == false) {
    //   showNotification(message);
    // }
  }
}
