import io_interface
import ../../../../../app_service/service/about/service as about_service
import ../../../../core/eventemitter

type
  Controller* = ref object of RootObj
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

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_VERSION_FETCHED) do(e: Args):
    let args = VersionArgs(e)
    self.delegate.versionFetched(args.available, args.version, args.url)

proc getAppVersion*(self: Controller): string =
  return self.aboutService.getAppVersion()

proc checkForUpdates*(self: Controller) =
  self.aboutService.checkForUpdates()

proc getNodeVersion*(self: Controller): string =
  return self.aboutService.getNodeVersion()

proc getStatusGoVersion*(self: Controller): string =
  self.aboutService.getStatusGoVersion()
