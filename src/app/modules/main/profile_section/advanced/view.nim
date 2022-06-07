import NimQml
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc fleetChanged*(self: View) {.signal.}
  proc getFleet*(self: View): string {.slot.} =
    return self.delegate.getFleet()
  QtProperty[string] fleet:
    read = getFleet
    notify = fleetChanged

  proc setFleet*(self: View, fleet: string) {.slot.} =
    self.delegate.setFleet(fleet)

  # include this if we decide to not quit the app on fleet change
  # proc emitFleetSignal*(self: View) =
  #   self.fleetChanged()

  proc logDir*(self: View): string {.slot.} =
    return self.delegate.getLogDir()

  proc bloomLevelChanged*(self: View) {.signal.}
  proc getBloomLevel*(self: View): string {.slot.} =
    return self.delegate.getBloomLevel()
  QtProperty[string] bloomLevel:
    read = getBloomLevel
    notify = bloomLevelChanged

  proc setBloomLevel*(self: View, bloomLevel: string) {.slot.} =
    self.delegate.setBloomLevel(bloomLevel)

  # include this if we decide to not quit the app on bloom level change
  # proc emitBloomLevelSignal*(self: View) =
  #   self.bloomLevelChanged()

  proc wakuV2LightClientEnabledChanged*(self: View) {.signal.}
  proc getWakuV2LightClientEnabled*(self: View): bool {.slot.} =
    return self.delegate.getWakuV2LightClientEnabled()
  QtProperty[bool] wakuV2LightClientEnabled:
    read = getWakuV2LightClientEnabled
    notify = wakuV2LightClientEnabledChanged

  proc setWakuV2LightClientEnabled*(self: View, enabled: bool) {.slot.} =
    self.delegate.setWakuV2LightClientEnabled(enabled)

  # include this if we decide to not quit the app on waku v2 light client change
  # proc emitWakuV2LightClientEnabledSignal*(self: View) =
  #   self.wakuV2LightClientEnabledChanged()

  proc isTelemetryEnabledChanged*(self: View) {.signal.}
  proc getIsTelemetryEnabled*(self: View): bool {.slot.} =
    return self.delegate.isTelemetryEnabled()
  QtProperty[bool] isTelemetryEnabled:
    read = getIsTelemetryEnabled
    notify = isTelemetryEnabledChanged

  proc emitTelemetryEnabledSignal*(self: View) =
    self.isTelemetryEnabledChanged()

  proc toggleTelemetry*(self: View) {.slot.} =
    self.delegate.toggleTelemetry()

  proc isAutoMessageEnabledChanged*(self: View) {.signal.}
  proc getIsAutoMessageEnabled*(self: View): bool {.slot.} =
    return self.delegate.isAutoMessageEnabled()
  QtProperty[bool] isAutoMessageEnabled:
    read = getIsAutoMessageEnabled
    notify = isAutoMessageEnabledChanged

  proc emitAutoMessageEnabledSignal*(self: View) =
    self.isAutoMessageEnabledChanged()

  proc toggleAutoMessage*(self: View) {.slot.} =
    self.delegate.toggleAutoMessage()

  proc isCommunityHistoryArchiveSupportEnabledChanged*(self: View) {.signal.}
  proc getIsCommunityHistoryArchiveSupportEnabled*(self: View): bool {.slot.} =
    return self.delegate.isCommunityHistoryArchiveSupportEnabled()
  QtProperty[bool] isCommunityHistoryArchiveSupportEnabled:
    read = getIsCommunityHistoryArchiveSupportEnabled
    notify = isCommunityHistoryArchiveSupportEnabledChanged

  proc emitCommunityHistoryArchiveSupportEnabledSignal*(self: View) =
    self.isCommunityHistoryArchiveSupportEnabledChanged()

  proc toggleCommunityHistoryArchiveSupport*(self: View) {.slot.} =
    self.delegate.toggleCommunityHistoryArchiveSupport()

  proc isDebugEnabledChanged*(self: View) {.signal.}
  proc getIsDebugEnabled*(self: View): bool {.slot.} =
    return self.delegate.isDebugEnabled()
  QtProperty[bool] isDebugEnabled:
    read = getIsDebugEnabled
    notify = isDebugEnabledChanged

  # include this if we decide to not quit the app on toggle debug
  # proc emitDebugEnabledSignal*(self: View) =
  #   self.isDebugEnabledChanged()

  proc toggleDebug*(self: View) {.slot.} =
    self.delegate.toggleDebug()

  proc toggleWalletSection*(self: View) {.slot.} =
    self.delegate.toggleWalletSection()

  proc toggleBrowserSection*(self: View) {.slot.} =
    self.delegate.toggleBrowserSection()

  proc toggleCommunitySection*(self: View) {.slot.} =
    self.delegate.toggleCommunitySection()

  proc toggleNodeManagementSection*(self: View) {.slot.} =
    self.delegate.toggleNodeManagementSection()

  proc enableDeveloperFeatures*(self: View) {.slot.} =
    self.delegate.enableDeveloperFeatures()

  proc toggleCommunitiesPortalSection*(self: View) {.slot.} =
    self.delegate.toggleCommunitiesPortalSection()
