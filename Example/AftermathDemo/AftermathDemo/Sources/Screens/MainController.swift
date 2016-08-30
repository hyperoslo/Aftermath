import UIKit

class MainController: UITabBarController {

  lazy var postsController: UINavigationController = {
    let controller = AftermathController(presenter: PostsPresenter())
    let navigationController = UINavigationController(rootViewController: controller)
    controller.view.stylize(Styles.Content)
    controller.tabBarItem.title = "Wall"
    controller.tabBarItem.image = UIImage(named: "tabPosts")

    return navigationController
  }()

  lazy var usersController: UINavigationController = {
    let controller = AftermathController(presenter: UsersPresenter())
    let navigationController = UINavigationController(rootViewController: controller)
    controller.view.stylize(Styles.Content)
    controller.tabBarItem.title = "Users"
    controller.tabBarItem.image = UIImage(named: "tabUsers")

    return navigationController
  }()

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    view.stylize(Styles.Content)
    configureTabBar()
  }

  // MARK: - Configuration

  func configureTabBar() {
    viewControllers = [
      postsController,
      usersController
    ]

    selectedIndex = 0
  }
}
