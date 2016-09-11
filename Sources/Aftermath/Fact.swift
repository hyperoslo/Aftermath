public protocol Fact {}

// MARK: - Fact command

struct FactCommand<T: Fact>: Command {
  typealias Output = T
}

// MARK: - Fact producer

public protocol FactProducer {}

public extension FactProducer {

  func publish<T: Fact>(fact fact: T) {
    let event = Event<FactCommand<T>>.Data(fact)
    Engine.sharedInstance.eventBus.publish(event)
  }
}
