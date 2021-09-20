import NimQml, json, strutils, sequtils, sugar, strformat, times, chronicles

import model, item

import ../../../../../app_service/[main]
import status/[status, wallet2]
import status/settings as status_settings
import status/utils as status_utils
import status/eth/contracts as status_contracts
import status/statusgo_backend/tokens as status_tokens
import status/types/[transaction, setting, network_type]

logScope:
  topics = "app-wallet2-activity-tab"

QtObject:
  type WalletActivityTabController* = ref object of QObject
    status: Status
    appService: AppService
    activityModel: WalletActivityModel
    activeAddress: string
    initialActivitiesReceived: bool
    hasMoreActivities: bool
    loadingActivities: bool

  proc setup(self: WalletActivityTabController) = 
    self.QObject.setup

  proc delete*(self: WalletActivityTabController) =
    self.activityModel.delete
    self.QObject.delete

  proc newWalletActivityTabController*(status: Status, appService: AppService): 
    WalletActivityTabController =
    new(result, delete)
    result.status = status
    result.appService = appService
    result.activityModel = newWalletActivityModel()
    result.initialActivitiesReceived = false
    result.hasMoreActivities = true
    result.loadingActivities = false
    result.setup

  proc loadingActivitiesChanged*(self: WalletActivityTabController) {.signal.}

  proc getLoadingActivities(self: WalletActivityTabController): QVariant {.slot.} = 
    newQVariant(self.loadingActivities)

  proc setLoadingActivities(self: WalletActivityTabController, value: bool) = 
    if(value == self.loadingActivities):
      return

    self.loadingActivities = value
    self.loadingActivitiesChanged()

  QtProperty[QVariant] isLoadingActivities:
    read = getLoadingActivities
    notify = loadingActivitiesChanged

  proc getActivityModel(self: WalletActivityTabController): QVariant {.slot.} = 
    newQVariant(self.activityModel)

  QtProperty[QVariant] activityModel:
    read = getActivityModel

  proc resetState(self: WalletActivityTabController) =
    self.activityModel.clear()
    self.initialActivitiesReceived = false
    self.hasMoreActivities = true
    self.setLoadingActivities(false)

  proc setActiveAddress*(self: WalletActivityTabController, address: string) =
    self.activeAddress = address
    self.resetState()

  proc defaultCurrency*(self: WalletActivityTabController): string {.slot.} =
    self.status.wallet2.getDefaultCurrency()

  proc activitiesFetched*(self:WalletActivityTabController) {.signal.}

  proc fetchInitialActivities*(self: WalletActivityTabController) {.slot.} =
    if(self.initialActivitiesReceived):
      return

    if(self.loadingActivities):
      return

    self.setLoadingActivities(true)
    self.appService.walletService.asyncFetchInitialTransactions(self.activeAddress)

  proc fetchMoreActivities*(self: WalletActivityTabController) {.slot.} =
    if(not self.hasMoreActivities):
      self.activitiesFetched()
      return

    if(self.loadingActivities):
      return

    let blockNumber = self.activityModel.getOldestItemBlockNumber()
    if(blockNumber.len == 0):
      return

    self.setLoadingActivities(true)
    self.appService.walletService.asyncFetchMoreTransactions(self.activeAddress, 
    blockNumber)
      
  proc onActivitiesFetched*(self: WalletActivityTabController, address: string, 
    transactions: seq[Transaction]) =
    self.setLoadingActivities(false)
    if(not self.initialActivitiesReceived):
      self.initialActivitiesReceived = true

    if(transactions.len == 0):
      self.hasMoreActivities = false

    var networks = status_settings.getAllNetworks()
    var allContracts = status_contracts.getErc20Contracts().concat(
      status_tokens.getCustomTokens())

    var items: seq[WalletActivityItem]
    for tx in transactions:
      let contract = allContracts.getErc20ContractByAddress(
        status_utils.parseAddress(tx.contract)) 
      
      var tokenSymbol = "NA"
      var tokenName = "Unknown"
      var tokenIcon = "/img/tokens/DEFAULT-TOKEN@3x.png"
      if (contract.isNil):
        tokenSymbol = "ETH"
        tokenName = "Ethereum"
        tokenIcon = "/img/tokens/ETH.png"
      else:
        tokenSymbol = contract.symbol
        tokenName = contract.name
        if(contract.hasIcon):
          tokenIcon = fmt"/img/tokens/{contract.symbol}.png"
      
      var networkName = "unknown"
      var filteredList = networks.filter((network: NetworkDetails) => 
        network.config.networkId == tx.networkId)
      if filteredList.len > 0:
        networkName = filteredList[0].name

      let ts = fromHex[int64](tx.timestamp)
      let dt = fromUnix(ts).local
      let sectionName = dt.format("dd MMMM")

      items.add(initWalletActivityItem(tx.id, sectionName, tx.networkId, networkName, 
      tokenSymbol, tokenName, tokenIcon, tx.typeValue, tx.txHash, tx.txStatus, 
      $fromHex[int](tx.blockNumber), tx.blockHash, tx.contract, $fromHex[int](tx.nonce), 
      $fromHex[int](tx.value), tx.fromAddress, tx.to, $fromHex[int](tx.value), $fromHex[int](tx.gasLimit), 
      $fromHex[int](tx.gasUsed), $fromHex[int](tx.gasPrice), "0", tx.input, ts))

    self.activityModel.add(items)
    self.activitiesFetched()