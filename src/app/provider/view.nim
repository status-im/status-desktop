import NimQml
import ../../status/status

QtObject:
  type Web3ProviderView* = ref object of QObject
    status*: Status

  proc setup(self: Web3ProviderView) =
    self.QObject.setup

  proc delete*(self: Web3ProviderView) =
    self.QObject.delete

  proc newWeb3ProviderView*(status: Status): Web3ProviderView =
    new(result, delete)
    result = Web3ProviderView()
    result.status = status
    result.setup

  proc postMessage*(self: Web3ProviderView, data: string): string {.slot.} =
    # TODO: implement code from status-react/src/status_im/browser/core.cljs
    echo "==========================================="
    echo "Message received from JS web3 provider: ", data
    return "Hello World!" # This can only be seen in chrome devtools