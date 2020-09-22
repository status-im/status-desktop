import NimQml, chronicles
import ../../status/signals/types
import ../../status/status
import view

logScope:
  topics = "web3-provider"

type Web3ProviderController* = ref object
  status*: Status
  view*: Web3ProviderView
  variant*: QVariant

proc newController*(status: Status): Web3ProviderController =
  result = Web3ProviderController()
  result.status = status
  result.view = newWeb3ProviderView(status)
  result.variant = newQVariant(result.view)

proc delete*(self: Web3ProviderController) =
  delete self.variant
  delete self.view

proc init*(self: Web3ProviderController) =
  discard
