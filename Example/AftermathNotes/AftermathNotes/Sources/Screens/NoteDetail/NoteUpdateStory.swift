import Aftermath
import Malibu

struct NoteUpdateStory {

  struct Command: Aftermath.Command {
    typealias Output = Note
    let id: Int
    let title: String
    let body: String
  }

  struct Request: PATCHRequestable {
    var message: Message

    init(command: Command) {
      message = Message(resource: "posts/\(command.id)")
      message.parameters = [
        "title" : command.title,
        "body"  : command.body
      ]
    }
  }

  struct Handler: Aftermath.CommandHandler {

    func handle(command: Command) throws -> Event<Command> {
      // Make network request to patch data.
      let request = Request(command: command)

      Malibu.networking("base").PATCH(request)
        .validate()
        .toJSONDictionary()
        .then({ try Note($0) })
        .done({ note in
          self.publish(data: note)
        })
        .fail({ error in
          self.publish(error: error)
        })

      return Event.Progress
    }
  }
}
