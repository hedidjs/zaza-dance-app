import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Create Flutter engine early for better stability
    let flutterEngine = FlutterEngine(name: "main_engine")
    flutterEngine.run()
    
    // Configure Flutter view controller if not using scenes
    if #available(iOS 13.0, *) {
      // Using Scene Delegate for iOS 13+
    } else {
      // Create window and controller for iOS 12
      let controller = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
      controller.modalPresentationStyle = .fullScreen
      
      window = UIWindow(frame: UIScreen.main.bounds)
      window?.rootViewController = controller
      window?.makeKeyAndVisible()
      
      // Register plugins
      GeneratedPluginRegistrant.register(with: controller)
    }
    
    // Enable background refresh
    UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle background app refresh
  override func application(
    _ application: UIApplication,
    performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    completionHandler(.newData)
  }
  
  // Handle app becoming active
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    // Ensure Flutter engine is running
    if let controller = window?.rootViewController as? FlutterViewController {
      controller.engine?.lifecycleChannel.sendStatus("AppLifecycleState.resumed")
    }
  }
  
  // Handle app entering background
  override func applicationDidEnterBackground(_ application: UIApplication) {
    super.applicationDidEnterBackground(application)
    // Properly pause Flutter engine
    if let controller = window?.rootViewController as? FlutterViewController {
      controller.engine?.lifecycleChannel.sendStatus("AppLifecycleState.paused")
    }
  }
  
  // Handle app entering foreground
  override func applicationWillEnterForeground(_ application: UIApplication) {
    super.applicationWillEnterForeground(application)
    // Resume Flutter engine
    if let controller = window?.rootViewController as? FlutterViewController {
      controller.engine?.lifecycleChannel.sendStatus("AppLifecycleState.resumed")
    }
  }
  
  // Handle memory warnings
  override func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
    super.applicationDidReceiveMemoryWarning(application)
    // Flutter will handle memory cleanup
  }
}
