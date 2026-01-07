import UIKit
import Flutter
import GoogleSignIn
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Notification delegate setup
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle Deep Links (Google Sign In + Branch + Others)
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    
    // 1. Try Google Sign In
    if GIDSignIn.sharedInstance.handle(url) {
      return true
    }
    
    // 2. Pass to Flutter plugins (This lets Branch.io handle the link if Google didn't)
    return super.application(app, open: url, options: options)
  }
}