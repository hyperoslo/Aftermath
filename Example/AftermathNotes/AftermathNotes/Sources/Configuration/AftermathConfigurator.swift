import Aftermath

public struct AftermathConfigurator: Configurator {

  public func configure() {
    Engine.shared.use(handler: NoteListStory.Handler())
    Engine.shared.use(handler: NoteDetailStory.Handler())
    Engine.shared.use(handler: NoteUpdateStory.Handler())
  }
}
