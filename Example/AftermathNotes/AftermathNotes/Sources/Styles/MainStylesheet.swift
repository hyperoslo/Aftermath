import UIKit
import Fashion

struct MainStylesheet: Stylesheet {

  enum Style: String, StyleConvertible {
    case Content
  }

  func define() {
    UIApplication.sharedApplication().statusBarStyle = .Default

    // Shared styles

    share { (window: UIWindow) in
      window.backgroundColor = UIColor.whiteColor()
    }

    share { (navigationBar: UINavigationBar) in
      navigationBar.translucent = true
      navigationBar.barTintColor = UIColor.whiteColor()
    }

    share { (tableView: UITableView) in
      tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    share { (cell: UITableViewCell) in
      let selectionView = UIView()
      selectionView.backgroundColor = UIColor.lightTextColor()
      cell.selectedBackgroundView = selectionView
    }

    // Custom styles

    register(Style.Content) { (view: UIView) in
      view.backgroundColor = UIColor.whiteColor()
    }
  }
}
