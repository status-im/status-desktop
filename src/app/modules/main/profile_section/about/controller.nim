import ./controller_interface
import io_interface
import ../../../../../app_service/service/about/service as about_service
import ../../../../core/eventemitter

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    aboutService: about_service.Service

proc newController*(
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    aboutService: about_service.Service
    ): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.aboutService = aboutService

method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  self.events.on(SIGNAL_VERSION_FETCHED) do(e: Args):
    let args = VersionArgs(e)
    self.delegate.versionFetched(args.version)

method getAppVersion*(self: Controller): string =
  return self.aboutService.getAppVersion()

method checkForUpdates*(self: Controller) =
  self.aboutService.checkForUpdates()

method getNodeVersion*(self: Controller): string =
  return self.aboutService.getNodeVersion()
