public protocol Fact {}

// MARK: - Fact command

struct FactCommand<T: Fact>: Command {
  typealias Output = T
}

// MARK: - Fact producer

public protocol FactProducer {}

public extension FactProducer {

  func post<T: Fact>(fact: T) {
    let event = Event<FactCommand<T>>.data(fact)
    Engine.sharedInstance.eventBus.publish(event)
  }
}
