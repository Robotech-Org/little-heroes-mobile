import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // 1) Explicitly configure Firebase FIRST.
    //    Even though swizzling normally handles this, Flutter 3.35+'s
    //    lazy engine init can race with it. Doing it here guarantees
    //    Firebase is ready before any plugin registers.
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }

    // 2) Register for APNs.
    //    This triggers Apple to hand us the APNs token, which is then
    //    forwarded to FCM via swizzling (FirebaseAppDelegateProxyEnabled=true).
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 3) Plugin registration for the implicit Flutter engine (Flutter 3.35+).
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  // 4) Safety net: forward the APNs token to FCM explicitly.
  //    With FirebaseAppDelegateProxyEnabled=true, swizzling usually
  //    already does this, but adding it here is harmless and fixes the
  //    cases where swizzling misses the callback.
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // 5) Log APNs failures — very useful for diagnosing push issues.
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("❌ APNs registration failed: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}