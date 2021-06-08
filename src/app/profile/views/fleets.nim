import NimQml
import chronicles, strutils
import ../../../status/types as status_types
import ../../../status/[status, settings, accounts]

QtObject:
  type Fleets * = ref object of QObject
    status: Status

  proc setup(self: Fleets) =
    self.QObject.setup

  proc delete*(self: Fleets) =
    self.QObject.delete

  proc newFleets*(status: Status): Fleets =
    new(result, delete)
    result = Fleets()
    result.status = status
    result.setup

  proc fleetChanged*(self: Fleets, newFleet: string) {.signal.}

  proc triggerFleetChange*(self: Fleets) {.slot.} =
    self.fleetChanged($self.status.settings.getFleet())

  proc setFleet*(self: Fleets, newFleet: string) {.slot.} =
    discard self.status.settings.saveSetting(Setting.Fleet, newFleet)
    let fleet = parseEnum[Fleet](newFleet)
    let installationId = self.status.settings.getSetting[:string](Setting.InstallationId)
    let updatedNodeConfig = self.status.accounts.getNodeConfig(self.status.fleet.config, installationId, $self.status.settings.getCurrentNetwork(), fleet)
    discard self.status.settings.saveSetting(Setting.NodeConfig, updatedNodeConfig)

    self.fleetChanged(newFleet)
    quit(QuitSuccess) # quits the app TODO: change this to logout instead when supported

  proc getFleet*(self: Fleets): string {.slot.} = $self.status.settings.getFleet()

  QtProperty[string] fleet:
    read = getFleet
    notify = fleetChanged
