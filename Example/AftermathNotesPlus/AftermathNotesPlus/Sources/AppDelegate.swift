import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  var configurators: [Configurator] = [
    // Use Fashion to share and reuse UI styles.
    FashionConfigurator(),
    // Use Malibu for networking.
    MalibuConfigurator(),
    // Use Aftermath to establish command-event flow in the app.
    AftermathConfigurator()
  ]

  lazy var mainController: MainController = {
    let controller = MainController()
    return controller
  }()

  // MARK: - Application lifecycle

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = mainController

    configurators.forEach {
      $0.configure()
    }

    window?.makeKeyAndVisible()

    return true
  }
}
