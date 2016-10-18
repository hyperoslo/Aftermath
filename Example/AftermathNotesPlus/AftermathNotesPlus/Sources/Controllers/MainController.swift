import UIKit

class MainController: UITabBarController {

  lazy var noteListController: UINavigationController = {
    let controller = ListController(feature: NoteFeature())
    let navigationController = UINavigationController(rootViewController: controller)
    controller.view.stylize(MainStylesheet.Style.content)
    controller.title = "Notes"
    controller.tabBarItem.title = "Notes"
    controller.tabBarItem.image = UIImage(named: "tabNotes")

    return navigationController
  }()

  lazy var todoListController: UINavigationController = {
    let controller = ListController(feature: TodoFeature())
    let navigationController = UINavigationController(rootViewController: controller)
    controller.view.stylize(MainStylesheet.Style.content)
    controller.tabBarItem.title = "Todos"
    controller.title = "Todos"
    controller.tabBarItem.image = UIImage(named: "tabTodos")

    return navigationController
  }()

  lazy var profileController: UINavigationController = {
    let controller = ProfileController()
    let navigationController = UINavigationController(rootViewController: controller)
    controller.tabBarItem.title = "Profile"
    controller.title = "Profile"
    controller.tabBarItem.image = UIImage(named: "tabProfile")

    return navigationController
  }()

  // MARK: - View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Aftermath"
    view.stylize(MainStylesheet.Style.content)
    configureTabBar()
  }

  // MARK: - Configuration

  func configureTabBar() {
    viewControllers = [
      noteListController,
      todoListController,
      profileController
    ]

    selectedIndex = 0
  }
}
