import Flutter
import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  var flutterEngine: FlutterEngine?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    
    // Get or create Flutter engine
    if flutterEngine == nil {
      flutterEngine = FlutterEngine(name: "scene_engine")
      flutterEngine?.run()
    }
    
    // Create window
    window = UIWindow(windowScene: windowScene)
    
    // Create Flutter view controller with the engine
    let flutterViewController = FlutterViewController(engine: flutterEngine!, nibName: nil, bundle: nil)
    flutterViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
    
    // Set as root view controller
    window?.rootViewController = flutterViewController
    window?.makeKeyAndVisible()
    
    // Register plugins
    GeneratedPluginRegistrant.register(with: flutterViewController)
  }

  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
  }

  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
  }
}