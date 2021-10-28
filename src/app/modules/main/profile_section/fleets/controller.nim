import strutils
import ./controller_interface
import ../../../../../app_service/service/settings/service as settings_service
import status/types/[fleet]

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: T
    settingsService: settings_service.ServiceInterface

proc newController*[T](delegate: T,
  settingsService: settings_service.ServiceInterface
  ): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.settingsService = settingsService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard

method getFleet*[T](self: Controller[T]): string =
  self.settingsService.getFleet()

method setFleet*[T](self: Controller[T], newFleet: string) =
  let fleet = parseEnum[Fleet](newFleet)
  let statusGoResult = self.settingsService.setFleet(fleet)
  if statusGoResult.error != "":
    echo "Error saving updated node config: ", statusGoResult.error

  let isWakuV2 = if fleet == WakuV2Prod or fleet == WakuV2Test: true else: false
  # Updating waku version because it makes no sense for some fleets to run under wakuv1 or v2 config
  if isWakuV2:
    self.settingsService.setWakuVersion(2)
  else:
    self.settingsService.setWakuVersion(1)
  
  quit(QuitSuccess) # quits the app TODO: change this to logout instead when supported
