import NimQml
import applicationView
import chats
import assets
import json
import state
import status/utils
import strformat
import strutils

import status/core as status
import status/chat as status_chat
import status/test as status_test
import status/types as types
import status/wallet as status_wallet

proc mainProc() =
  # From QT docs:
  # For any GUI application using Qt, there is precisely one QApplication object,
  # no matter whether the application has 0, 1, 2 or more windows at any given time.
  # For non-QWidget based Qt applications, use QGuiApplication instead, as it does
  # not depend on the QtWidgets library. Use QCoreApplication for non GUI apps
  var app = newQApplication()
  defer: app.delete() # Defer will run this just before mainProc() function ends

  var appState = state.newAppState()
  echo appState.title

  var chatsModel = newChatsModel();
  defer: chatsModel.delete

  var assetsModel = newAssetsModel();
  defer: assetsModel.delete

  var engine = newQQmlApplicationEngine()
  defer: engine.delete()

  status.init(appState)

  status_test.setupNewAccount()
  discard status_test.addPeer("enode://2c8de3cbb27a3d30cbb5b3e003bc722b126f5aef82e2052aaef032ca94e0c7ad219e533ba88c70585ebd802de206693255335b100307645ab5170e88620d2a81@47.244.221.14:443")
  echo status.callPrivateRPC("{\"jsonrpc\":\"2.0\", \"method\":\"wakuext_requestMessages\", \"params\":[{\"topics\": [\"0x7998f3c8\"]}], \"id\": 1}")

  # 1. get balance of an address
  var balance = status_wallet.getBalance("0x0000000000000000000000000000000000000000")
  echo(fmt"balance in hex: {balance}")

  # 2. convert balance to eth
  var eth_value = status_wallet.hex2Eth(balance)
  echo(fmt"balance in eth: {eth_value}")

  # 3. get usd price of 1 eth
  var usd_eth_price = status_wallet.getPrice("ETH", "USD")
  echo(fmt"usd_price: {usd_eth_price}")

  # 4. convert balance to usd
  var usd_balance = parseFloat(eth_value) * parseFloat(usd_eth_price)
  echo(fmt"balance in usd: {usd_balance}")

  # result.accountResult = status.queryAccounts()

  var sendMessage = proc (msg: string): string =
    status_chat.sendPublicChatMessage("test", msg)

  let logic = newApplicationView(app, sendMessage)
  defer: logic.delete

  let logicVariant = newQVariant(logic)
  defer: logicVariant.delete

  let chatsVariant = newQVariant(chatsModel)
  defer: chatsVariant.delete



  appState.subscribe(proc () =
    chatsModel.names = @[]
    for channel in appState.channels:
      echo channel.name
      chatsModel.addNameTolist(channel.name)
  )

  let assetsVariant = newQVariant(assetsModel)
  defer: chatsVariant.delete

  status.startMessenger()

  appState.addChannel("test")
  appState.addChannel("test2")

  engine.setRootContextProperty("logic", logicVariant)
  engine.setRootContextProperty("chatsModel", chatsVariant)
  engine.setRootContextProperty("assetsModel", assetsVariant)

  let symbol = "ETH"
  assetsModel.addAssetToList("Ethereum", symbol, fmt"{eth_value:.6}", "$" & fmt"{usd_balance:.6}", fmt"../../img/token-icons/{toLowerAscii(symbol)}.svg")

  engine.load("../ui/main.qml")
  
  # EXAMPLE: this will be triggered once a message is received
  appState.onSignal(SignalType.Message, proc(myMessage: string): void =
    echo "I received a message: ", myMessage
  );

  # Handle signals as part of the state
  var signalWorker: Thread[AppState]
  signalWorker.createThread(proc(s:AppState) = s.processSignals, appState)
  defer: signalWorker.joinThread()
  
  
  # Qt main event loop is entered here
  # The termination of the loop will be performed when exit() or quit() is called
  app.exec()



when isMainModule:
  mainProc()
  GC_fullcollect()
