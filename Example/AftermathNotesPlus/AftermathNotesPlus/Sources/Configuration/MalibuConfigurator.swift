import Malibu

public struct MalibuConfigurator: Configurator {

  public func configure() {
    Malibu.mode = .Regular
    Malibu.logger.level = .Verbose

    let networking = Networking(baseURLString: "http://jsonplaceholder.typicode.com/")

    networking.additionalHeaders = {
      ["Accept" : "application/json"]
    }

    Malibu.register("base", networking: networking)
  }
}
