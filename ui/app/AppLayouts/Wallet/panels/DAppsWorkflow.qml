import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import SortFilterProxyModel 0.2

import AppLayouts.Wallet 1.0
import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.services.dapps 1.0
import AppLayouts.Wallet.services.dapps.types 1.0

import shared.popups.walletconnect 1.0

import utils 1.0

DappsComboBox {
    id: root

    // Values mapped to Constants.LoginType
    required property int loginType
    /*
        Accounts model

        Expected model structure:
        name                    [string] - account name e.g. "Piggy Bank"
        address                 [string] - wallet account address e.g. "0x1234567890"
        colorizedChainPrefixes  [string] - chain prefixes with rich text colors e.g. "<font color=\"red\">eth:</font><font color=\"blue\">oeth:</font><font color=\"green\">arb:</font>"
        emoji                   [string] - emoji for account e.g. "🐷"
        colorId                 [string] - color id for account e.g. "1"
        currencyBalance         [var]    - fiat currency balance
            amount              [number] - amount of currency e.g. 1234
            symbol              [string] - currency symbol e.g. "USD"
            optDisplayDecimals  [number] - optional number of decimals to display
            stripTrailingZeroes [bool]   - strip trailing zeroes
        walletType              [string] - wallet type e.g. Constants.watchWalletType. See `Constants` for possible values
        migratedToKeycard       [bool]   - whether account is migrated to keycard
        accountBalance          [var]    - account balance for a specific network
            formattedBalance    [string] - formatted balance e.g. "1234.56B"
            balance             [string] - balance e.g. "123456000000"
            iconUrl             [string] - icon url e.g. "network/Network=Hermez"
            chainColor          [string] - chain color e.g. "#FF0000"
    */
    property var accountsModel
    /*
      Networks model
      Expected model structure:
        chainName      [string]          - chain long name. e.g. "Ethereum" or "Optimism"
        chainId        [int]             - chain unique identifier
        iconUrl        [string]          - SVG icon name. e.g. "network/Network=Ethereum"
        layer          [int]             - chain layer. e.g. 1 or 2
        isTest         [bool]            - true if the chain is a testnet
    */
    property var networksModel
    /*
      ObjectModel containig session requests
        requestId     [string]                  - unique identifier for the request
        requestItem   [SessionRequestResolved]  - request object
    */ 
    property SessionRequestsModel sessionRequestsModel
    property string selectedAccountAddress

    property var formatBigNumber: (number, symbol, noSymbolOption) => console.error("formatBigNumber not set")

    signal pairWCReady()

    signal disconnectRequested(string connectionId)
    signal pairingRequested(string uri)
    signal pairingValidationRequested(string uri)
    signal connectionAccepted(string pairingId, var chainIds, string selectedAccount)
    signal connectionDeclined(string pairingId)
    signal signRequestAccepted(string connectionId, string requestId)
    signal signRequestRejected(string connectionId, string requestId)
    signal signRequestIsLive(string connectionId, string requestId)

    /// Response to pairingValidationRequested
    function pairingValidated(validationState) {
        if (pairWCLoader.item) {
            pairWCLoader.item.pairingValidated(validationState)
        }
    }

    /// Confirmation received on connectionAccepted
    function connectionSuccessful(pairingId, newConnectionId) {
        connectDappLoader.connectionSuccessful(pairingId, newConnectionId)
    }

    /// Confirmation received on connectionAccepted
    function connectionFailed(pairingId) {
        connectDappLoader.connectionFailed(pairingId)
    }

    /// Request to connect to a dApp
    function connectDApp(dappChains, dappUrl, dappName, dappIcon, pairingId) {
        connectDappLoader.connect(dappChains, dappUrl, dappName, dappIcon, pairingId)
    }

    onPairDapp: {
        pairWCLoader.active = true
    }

    onDisconnectDapp: (dappUrl) => {
        disconnectdAppDialogLoader.dAppUrl = dappUrl
        disconnectdAppDialogLoader.active = true
    }

    Loader {
        id: disconnectdAppDialogLoader

        property string dAppUrl

        active: false

        onLoaded: {
            const dApp = SQUtils.ModelUtils.getByKey(root.model, "url", dAppUrl);
            if (dApp) {
                item.dappName = dApp.name;
                item.dappIcon = dApp.iconUrl;
                item.dappUrl = disconnectdAppDialogLoader.dAppUrl;
            }

            item.open();
        }

        sourceComponent: DAppConfirmDisconnectPopup {

            visible: true

            onClosed: {
                disconnectdAppDialogLoader.active = false
            }

            onAccepted: {
                SQUtils.ModelUtils.forEach(model, (dApp) => {
                    if (dApp.url === dAppUrl) {
                        root.disconnectRequested(dApp.topic)
                    }
                })
            }
        }
    }

    Loader {
        id: pairWCLoader

        active: false

        onLoaded: {
            item.open()
            root.pairWCReady()
        }

        sourceComponent: PairWCModal {
            visible: true

            onClosed: pairWCLoader.active = false
            onPair: (uri) => root.pairingRequested(uri)
            onPairUriChanged: (uri) => root.pairingValidationRequested(uri)
        }
    }

    Loader {
        id: connectDappLoader

        active: false

        // Array of chaind ids
        property var dappChains
        property url dappUrl
        property string dappName
        property url dappIcon
        property var key
        property var topic

        property var connectionQueue: []
        onActiveChanged: {
            if (!active && connectionQueue.length > 0) {
                connect(connectionQueue[0].dappChains,
                        connectionQueue[0].dappUrl,
                        connectionQueue[0].dappName,
                        connectionQueue[0].dappIcon,
                        connectionQueue[0].key)
                connectionQueue.shift()
            }
        }

        function connect(dappChains, dappUrl, dappName, dappIcon, key) {
            if (connectDappLoader.active) {
                connectionQueue.push({ dappChains, dappUrl, dappName, dappIcon, key })
                return
            }

            connectDappLoader.dappChains = dappChains
            connectDappLoader.dappUrl = dappUrl
            connectDappLoader.dappName = dappName
            connectDappLoader.dappIcon = dappIcon
            connectDappLoader.key = key

            if (pairWCLoader.item) {
                // Allow user to get the uri valid confirmation
                pairWCLoader.item.pairingValidated(Pairing.errors.dappReadyForApproval)
                connectDappTimer.start()
            } else {
                connectDappLoader.active = true
            }
        }

        function connectionSuccessful(key, newTopic) {
            if (connectDappLoader.key === key && connectDappLoader.item) {
                connectDappLoader.topic = newTopic
                connectDappLoader.item.pairSuccessful()
            }
        }

        function connectionFailed(id) {
            if (connectDappLoader.key === key && connectDappLoader.item) {
                connectDappLoader.item.pairFailed()
            }
        }

        sourceComponent: ConnectDAppModal {
            visible: true

            onClosed: connectDappLoader.active = false
            accounts: root.accountsModel
            flatNetworks: SortFilterProxyModel {
                sourceModel: root.networksModel
                filters: [
                    FastExpressionFilter {
                        inverted: true
                        expression: connectDappLoader.dappChains.indexOf(chainId) === -1
                        expectedRoles: ["chainId"]
                    }
                ]
            }
            selectedAccountAddress: root.selectedAccountAddress

            dAppUrl: connectDappLoader.dappUrl
            dAppName: connectDappLoader.dappName
            dAppIconUrl: connectDappLoader.dappIcon
            connectButtonEnabled: root.enabled

            onConnect: {
                if (!selectedAccount || !selectedAccount.address) {
                    console.error("Missing account selection")
                    return
                }
                if (!selectedChains || selectedChains.length === 0) {
                    console.error("Missing chain selection")
                    return
                }
                
                root.connectionAccepted(connectDappLoader.key, selectedChains, selectedAccount.address)
            }

            onDecline: {
                root.connectionDeclined(connectDappLoader.key)
                close()
            }

           onDisconnect: {
                root.disconnectRequested(connectDappLoader.topic)
                close()
            }
        }
    }

    Instantiator {
        model: root.sessionRequestsModel
        delegate: DAppSignRequestModal {
            id: dappRequestModal
            objectName: "dappsRequestModal"

            required property var model
            required property int index

            readonly property var request: model.requestItem
            readonly property var account: accountEntry.available ? accountEntry.item : {
                name: "",
                address: "",
                emoji: "",
                colorId: 0,
                migratedToKeycard: false
            }

            readonly property var network: networkEntry.available ? networkEntry.item : {
                chainName: "",
                iconUrl: ""
            }
            property bool requestHandled: false

            function rejectRequest() {
                // Allow rejecting only once
                if (requestHandled) {
                    return
                }
                requestHandled = true
                root.signRequestRejected(request.topic, request.requestId)
            }

            parent: root

            loginType: account.migratedToKeycard ? Constants.LoginType.Keycard : root.loginType
            formatBigNumber: root.formatBigNumber

            visible: !!request.dappUrl

            dappUrl: request.dappUrl
            dappIcon: request.dappIcon
            dappName: request.dappName

            accountColor: Utils.getColorForId(account.colorId)
            accountName: account.name
            accountAddress: account.address
            accountEmoji: account.emoji

            networkName: network.chainName
            networkIconPath: Theme.svg(network.iconUrl)

            fiatFees: request.fiatMaxFees ? request.fiatMaxFees.toFixed() : ""
            cryptoFees: request.ethMaxFees ? request.ethMaxFees.toFixed() : ""
            estimatedTime: WalletUtils.getLabelForEstimatedTxTime(request.estimatedTimeCategory)
            feesLoading: hasFees && (!fiatFees || !cryptoFees)
            hasFees: signingTransaction
            enoughFundsForTransaction: request.haveEnoughFunds
            enoughFundsForFees: request.haveEnoughFees

            signButtonEnabled: ((!hasFees) || enoughFundsForTransaction && enoughFundsForFees) && root.enabled
            signingTransaction: !!request.method && (request.method === SessionRequest.methods.signTransaction.name
                                                  || request.method === SessionRequest.methods.sendTransaction.name)
            requestPayload: {
                try {
                    const data = JSON.parse(request.preparedData)

                    delete data.maxFeePerGas
                    delete data.maxPriorityFeePerGas
                    delete data.gasPrice

                    return JSON.stringify(data, null, 2)
                } catch(_) {
                    return request.preparedData
                }
            }
            expirationSeconds: request.expirationTimestamp ? request.expirationTimestamp - requestTimestamp.getTime() / 1000
                                                            : 0
            hasExpiryDate: !!request.expirationTimestamp

            onOpened: {
                root.signRequestIsLive(request.topic, request.requestId)
            }

            onClosed: {
                Qt.callLater(rejectRequest)
            }

            onAccepted: {
                requestHandled = true
                root.signRequestAccepted(request.topic, request.requestId)
            }

            onRejected: {
                rejectRequest()
            }

            ModelEntry {
                id: accountEntry
                sourceModel: root.accountsModel
                key: "address"
                value: request.accountAddress
            }

            ModelEntry {
                id: networkEntry
                sourceModel: root.networksModel
                key: "chainId"
                value: request.chainId
            }
        }
    }

    // Used between transitioning from PairWCModal to ConnectDAppModal
    Timer {
        id: connectDappTimer

        interval: 500
        running: false
        repeat: false

        onTriggered: {
            pairWCLoader.item.close()
            connectDappLoader.active = true
        }
    }
}
