import UIKit
import Brick
import Spots

class TableCell: UITableViewCell, SpotConfigurable {

  var size = CGSize(width: 0, height: 64)

  // MARK: - Initialization

  override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()
  }

  // MARK: - Configuration

  func configure(inout item: ViewModel) {
    detailTextLabel?.text = item.subtitle
    textLabel?.text = item.title
    styles = item.meta("styles", "")

    item.size.height = size.height
  }
}
