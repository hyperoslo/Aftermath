// MARK: - Functions

enum LogType {
  case normal
  case warning
  case error
  case unknown
}

func log(_ text: String, type: LogType = .normal) {
  var emoticon: String = ""

  switch type {
  case .warning:
    emoticon = "⚠️ "
  case .error:
    emoticon = "⛔️ "
  case .unknown:
    emoticon = "🤔 "
  default:
    break
  }

  print("🔮 AFTERMATH: \(emoticon)\(text)")
}
