import UIKit
import Hue

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  lazy var window: UIWindow? = {
    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    return window
  }()

  var configurators: [Configurator] = [
    FashionConfigurator(),
    CompassConfigurator(),
    SpotsConfigurator(),
    MalibuConfigurator(),
    AftermathConfigurator()
  ]

  lazy var navigationController: UINavigationController = { [unowned self] in
    let controller = UINavigationController(rootViewController: self.viewController)
    return controller
    }()

  lazy var viewController: WelcomeController = {
    let controller = WelcomeController()
    return controller
  }()

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {


    window?.rootViewController = navigationController

    configurators.forEach {
      $0.configure()
    }

    window?.makeKeyAndVisible()

    return true
  }
}
