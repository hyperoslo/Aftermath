import Aftermath

public struct AftermathConfigurator: Configurator {

  // Don't forget to register your command handlers.
  // You can also use https://github.com/hyperoslo/AftermathTools to monitor warnings and errors.
  public func configure() {
    // Note command handlers
    Engine.shared.use(handler: ListCommandHandler(feature: NoteFeature()))
    Engine.shared.use(handler: DetailCommandHandler(feature: NoteFeature()))
    Engine.shared.use(handler: UpdateCommandHandler(feature: NoteFeature()))
    Engine.shared.use(handler: DeleteCommandHandler(feature: NoteFeature()))

    // Todo command handlers
    Engine.shared.use(handler: ListCommandHandler(feature: TodoFeature()))
    Engine.shared.use(handler: UpdateCommandHandler(feature: TodoFeature()))
    Engine.shared.use(handler: DeleteCommandHandler(feature: TodoFeature()))
  }
}
