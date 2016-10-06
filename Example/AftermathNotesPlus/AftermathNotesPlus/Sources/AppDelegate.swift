import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  lazy var window: UIWindow? = {
    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    return window
  }()

  var configurators: [Configurator] = [
    FashionConfigurator(),
    MalibuConfigurator(),
    AftermathConfigurator()
  ]

  lazy var mainController: MainController = {
    let controller = MainController()
    return controller
  }()

  // MARK: - Application lifecycle

  func application(application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window?.rootViewController = mainController

    configurators.forEach {
      $0.configure()
    }

    window?.makeKeyAndVisible()

    return true
  }
}
