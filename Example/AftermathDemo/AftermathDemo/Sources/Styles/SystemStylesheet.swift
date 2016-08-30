import UIKit
import Fashion
import Hue

struct Colors {
  static let tint = UIColor(hex: "F57D2D")
}

struct SystemStylesheet: Stylesheet {

  func define() {
    UIApplication.sharedApplication().statusBarStyle = .Default

    share { (window: UIWindow) in
      window.backgroundColor = UIColor.whiteColor()
    }

    share { (navigationBar: UINavigationBar) in
      navigationBar.translucent = true
      navigationBar.barTintColor = UIColor.whiteColor()
      navigationBar.tintColor = Colors.tint
    }

    share { (tabBar: UITabBar) in
      tabBar.translucent = true
      tabBar.tintColor = Colors.tint
    }

    share { (tableView: UITableView) in
      tableView.tableFooterView = UIView(frame: CGRect.zero)
      tableView.separatorStyle = .None
      tableView.separatorInset = UIEdgeInsetsZero
    }

    share { (cell: UITableViewCell) in
      let selectionView = UIView()
      selectionView.backgroundColor = UIColor.lightTextColor()
      cell.selectedBackgroundView = selectionView
    }
  }
}
