import UIKit
import Aftermath

class TableCell: UITableViewCell, Identifiable {

  // MARK: - Initialization

  override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
