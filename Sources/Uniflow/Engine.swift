public class Domain {

  static var input: Inputable = Input()
  static var output: Outputable = Output()
}

public protocol Inputable {

}

class Input: Inputable {

}

public protocol Outputable {
}

class Output: Outputable {

}
