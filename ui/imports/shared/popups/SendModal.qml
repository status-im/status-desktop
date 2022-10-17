import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.0

import utils 1.0
import shared.stores 1.0
import shared.panels 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls.Validators 0.1

import "../panels"
import "../controls"
import "../views"

StatusDialog {
    id: popup

    property string preSelectedRecipient
    property string preDefinedAmountToSend
    property var preSelectedAsset
    property bool interactive: true

    property alias modalHeader: modalHeader.text

    property alias selectedPriority: gasSelector.selectedPriority
    property var store: TransactionStore{}
    property var contactsStore: store.contactStore
    property var selectedAccount: store.currentAccount
    property var bestRoutes
    property string addressText
    property bool isLoading: false
    property int sendType: Constants.SendType.Transfer
    property MessageDialog sendingError: MessageDialog {
        id: sendingError
        title: qsTr("Error sending the transaction")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }

    property var sendTransaction: function() {
        let recipientAddress = Utils.isValidAddress(popup.addressText) ? popup.addressText : d.resolvedENSAddress
        d.isPendingTx = true
        popup.store.authenticateAndTransfer(
                    popup.selectedAccount.address,
                    recipientAddress,
                    assetSelector.selectedAsset.symbol,
                    amountToSendInput.text,
                    d.uuid,
                    gasSelector.selectedPriority,
                    JSON.stringify(popup.bestRoutes)
                    )
    }

    property var recalculateRoutesAndFees: Backpressure.debounce(popup, 600, function() {
        d.sendTxError = false
        if(popup.selectedAccount && assetSelector.selectedAsset) {
            popup.isLoading = true
            let amount = parseFloat(amountToSendInput.text) * Math.pow(10, assetSelector.selectedAsset.decimals)
            popup.store.suggestedRoutes(popup.selectedAccount.address, amount.toString(16), assetSelector.selectedAsset.symbol,
                                        store.disabledChainIdsFromList, store.disabledChainIdsToList,
                                        d.preferredChainIds, gasSelector.selectedPriority, popup.sendType)
        }
    })

    function setSendTxError() {
        d.sendTxError = true
        d.sendTxErrorString = qsTr("Wrong password")
    }

    QtObject {
        id: d
        readonly property double maxFiatBalance: {
            console.error(assetSelector.selectedAsset.name," >>> recalaculayte maxFiatBalance = ", assetSelector.selectedAsset.totalBalance)
            return assetSelector.selectedAsset ? assetSelector.selectedAsset.totalBalance: 0
        }
        readonly property bool isReady: amountToSendInput.valid && !amountToSendInput.pending && recipientReady
        readonly property bool errorMode: (networkSelector.bestRoutes && networkSelector.bestRoutes.length <= 0) || networkSelector.errorMode || isNaN(amountToSendInput.text)
        readonly property bool recipientReady: (isAddressValid || isENSValid) && !recipientSelector.isPending
        property bool isAddressValid: false
        property bool isENSValid: false
        readonly property var resolveENS: Backpressure.debounce(popup, 500, function (ensName) {
            store.resolveENS(ensName)
        })
        property string resolvedENSAddress
        readonly property string uuid: Utils.uuid()
        property bool isPendingTx: false
        property var preferredChainIds: []
        property bool sendTxError: false
        property string sendTxErrorString

        property Timer waitTimer: Timer {
            interval: 1000
            onTriggered: {
                d.isAddressValid = false
                let splitWords = popup.store.plainText(recipientSelector.input.text).split(':')
                let editedText = ""
                for(var i=0; i<splitWords.length; i++) {
                    if(splitWords[i].startsWith("0x")) {
                        d.isAddressValid = Utils.isValidAddress(splitWords[i])
                        popup.addressText =   splitWords[i]
                        editedText += splitWords[i]
                    } else {
                        let chainColor = popup.store.allNetworks.getNetworkColor(splitWords[i])
                        if(!!chainColor) {
                            d.addPreferredChain(popup.store.allNetworks.getNetworkChainId(splitWords[i]))
                             editedText += `<span style='color: %1'>%2</span>`.arg(chainColor).arg(splitWords[i])+':'
                        }
                    }
                }
                editedText +="</a></p>"
                recipientSelector.input.text = editedText
                popup.recalculateRoutesAndFees()
            }
        }

        function addPreferredChain(chainID) {
            if(!chainID)
                return

            if(preferredChainIds.includes(chainID))
                return

            preferredChainIds.push(chainID)
        }
    }

    width: 556
    topMargin: 64 + header.height

    padding: 0
    background: StatusDialogBackground {
        color: Theme.palette.baseColor3
    }

    onSelectedAccountChanged: popup.recalculateRoutesAndFees()

    onOpened: {
        popup.store.disabledChainIdsFromList = []
        popup.store.disabledChainIdsToList = []
        amountToSendInput.input.edit.forceActiveFocus()

        if(!!popup.preSelectedAsset) {
            assetSelector.selectedAsset = popup.preSelectedAsset
        }

        if(!!popup.preDefinedAmountToSend) {
            amountToSendInput.text = popup.preDefinedAmountToSend
        }

        if(!!popup.preSelectedRecipient) {
            recipientSelector.input.text = popup.preSelectedRecipient
            d.waitTimer.restart()
        }
    }

    header: SendModalHeader {
        anchors.top: parent.top
        anchors.topMargin: -height - 18
        model: popup.store.accounts
        selectedAccount: popup.selectedAccount
        changeSelectedAccount: function(newIndex) {
            if (newIndex > popup.store.accounts) {
                return
            }
            popup.store.switchAccount(newIndex)
        }
    }

    StackLayout {
        id: stack
        anchors.fill: parent
        currentIndex: 0
        clip: true
        ColumnLayout {
            id: group1
            Layout.preferredWidth: parent.width
            spacing: Style.current.padding

            Rectangle {
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: assetAndAmmountSelector.height + Style.current.padding
                color: Theme.palette.baseColor3

                layer.enabled: scrollView.contentY > -8
                layer.effect: DropShadow {
                    verticalOffset: 2
                    radius: 16
                    samples: 17
                    color: Theme.palette.dropShadow
                }

                Column {
                    id: assetAndAmmountSelector
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Style.current.xlPadding
                    anchors.rightMargin: Style.current.xlPadding
                    z: 1

                    Row {
                        spacing: 16
                        StatusBaseText {
                            id: modalHeader
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Send")
                            font.pixelSize: 15
                            color: Theme.palette.directColor1
                        }
                        StatusListItemTag {
                            height: 22
                            width: childrenRect.width
                            title: d.sendTxError ? d.sendTxErrorString : d.maxFiatBalance > 0 ? qsTr("Max: %1").arg(LocaleUtils.numberToLocaleString(d.maxFiatBalance)) : qsTr("No balances active")
                            closeButtonVisible: false
                            titleText.font.pixelSize: 12
                            color: d.errorMode || d.sendTxError ? Theme.palette.dangerColor2 : Theme.palette.primaryColor3
                            titleText.color: d.errorMode || d.sendTxError ? Theme.palette.dangerColor1 : Theme.palette.primaryColor1
                        }
                    }
                    Item {
                        width: parent.width
                        height: amountToSendInput.height
                        AmountInputWithCursor {
                            id: amountToSendInput
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: -Style.current.padding
                            width: parent.width - assetSelector.width
                            placeholderText: assetSelector.selectedAsset ? "%1 %2".arg(LocaleUtils.numberToLocaleString(0, 2)).arg(assetSelector.selectedAsset.symbol) : ""
                            input.edit.color: d.errorMode ? Theme.palette.dangerColor1 : Theme.palette.directColor1
                            input.edit.readOnly: !popup.interactive
                            validators: [
                                StatusFloatValidator{
                                    id: floatValidator
                                    bottom: 0
                                    top: assetSelector.selectedAsset ? assetSelector.selectedAsset.totalBalance: 0
                                    errorMessage: ""
                                }
                            ]
                            Keys.onReleased: {
                                let amount = amountToSendInput.text.trim()

                                if (!Utils.containsOnlyDigits(amount) || isNaN(amount)) {
                                    return
                                }
                                popup.recalculateRoutesAndFees()
                            }
                        }
                        StatusAssetSelector {
                            id: assetSelector
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            enabled: popup.interactive
                            assets: popup.selectedAccount && popup.selectedAccount.assets ? popup.selectedAccount.assets : []
                            defaultToken: Style.png("tokens/DEFAULT-TOKEN@3x")
                            getCurrencyBalanceString: function (currencyBalance) {
                                return "%1 %2".arg(Utils.toLocaleString(currencyBalance.toFixed(2), popup.store.locale, {"currency": true})).arg(popup.store.currentCurrency.toUpperCase())
                            }
                            tokenAssetSourceFn: function (symbol) {
                                return symbol ? Style.png("tokens/%1".arg(symbol)) : defaultToken
                            }
                            searchTokenSymbolByAddressFn: function (address) {
                                if(popup.selectedAccount) {
                                    return popup.selectedAccount.findTokenSymbolByAddress(address)
                                }
                                return ""
                            }
                            onSelectedAssetChanged: {
                                if (!assetSelector.selectedAsset) {
                                    return
                                }
                                if (amountToSendInput.text === "" || isNaN(amountToSendInput.text)) {
                                    return
                                }
                                popup.recalculateRoutesAndFees()
                            }
                        }
                    }
                    StatusInput {
                        id: txtFiatBalance
                        anchors.left: parent.left
                        anchors.leftMargin: -12
                        leftPadding: 0
                        rightPadding: 0
                        font.weight: Font.Medium
                        font.pixelSize: 13
                        input.placeholderFont.pixelSize: 13
                        input.leftPadding: 0
                        input.rightPadding: 0
                        input.topPadding: 0
                        input.bottomPadding: 0
                        input.edit.padding: 0
                        input.background.color: "transparent"
                        input.background.border.width: 0
                        input.edit.color: txtFiatBalance.input.edit.activeFocus ? Theme.palette.directColor1 : Theme.palette.baseColor1
                        input.edit.readOnly: true
                        text: {
                            let fiatValue = popup.store.getFiatValue(amountToSendInput.text, assetSelector.selectedAsset.symbol, popup.store.currentCurrency)
                            return parseFloat(fiatValue) === 0 ? LocaleUtils.numberToLocaleString(parseFloat(fiatValue), 2) : LocaleUtils.numberToLocaleString(parseFloat(fiatValue))
                        }
                        input.implicitHeight: 15
                        implicitWidth: txtFiatBalance.input.edit.contentWidth + 50
                        input.rightComponent: StatusBaseText {
                            id: currencyText
                            text: popup.store.currentCurrency.toUpperCase()
                            font.pixelSize: 13
                            color: Theme.palette.directColor5
                        }
                        Keys.onReleased: {
                            let balance = txtFiatBalance.text.trim()
                            if (balance === "" || isNaN(balance)) {
                                return
                            }
                            // To-Do Not refactored yet
                            // amountToSendInput.text = root.getCryptoValue(balance, popup.store.currentCurrency, assetSelector.selectedAsset.symbol)
                        }
                    }
                }
            }

            StatusScrollView {
                id: scrollView
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width
                contentHeight: layout.height
                contentWidth: parent.width
                z: 0
                objectName: "sendModalScroll"

                Column {
                    id: layout
                    width: scrollView.availableWidth
                    spacing: Style.current.halfPadding
                    anchors.left: parent.left

                    StatusInput {
                        id: recipientSelector
                        property bool isPending: false

                        width: parent.width
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.rightMargin: Style.current.bigPadding

                        label: qsTr("To")
                        placeholderText: qsTr("Enter an ENS name or address")
                        input.background.color: Theme.palette.indirectColor1
                        input.background.border.width: 0
                        input.implicitHeight: 56
                        input.clearable: popup.interactive
                        input.edit.readOnly: !popup.interactive
                        multiline: false
                        input.edit.textFormat: TextEdit.RichText
                        input.rightComponent: RowLayout {
                            StatusButton {
                                visible: recipientSelector.text === ""
                                borderColor: Theme.palette.primaryColor1
                                size: StatusBaseButton.Size.Tiny
                                text: qsTr("Paste")
                                onClicked: recipientSelector.input.edit.paste()
                            }
                            StatusFlatRoundButton {
                                visible: recipientSelector.text !== ""
                                type: StatusFlatRoundButton.Type.Secondary
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                icon.name: "clear"
                                icon.width: 16
                                icon.height: 16
                                icon.color: Theme.palette.baseColor1
                                backgroundHoverColor: "transparent"
                                onClicked: {
                                    recipientSelector.input.edit.clear()
                                    d.waitTimer.restart()
                                }
                            }
                        }
                        Keys.onReleased: {
                            d.waitTimer.restart()
                            if(!d.isAddressValid) {
                                isPending = true
                                Qt.callLater(d.resolveENS, input.edit.text)
                            }
                        }
                    }

                    Connections {
                        target: store.mainModuleInst
                        onResolvedENS: {
                            recipientSelector.isPending = false
                            if(Utils.isValidAddress(resolvedAddress)) {
                                d.resolvedENSAddress = resolvedAddress
                                d.isENSValid = true
                            }
                        }
                    }

                    TabAddressSelectorView {
                        id: addressSelector
                        width: parent.width
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.rightMargin: Style.current.bigPadding
                        store: popup.store
                        onContactSelected:  {
                            recipientSelector.input.text = address
                            d.waitTimer.restart()
                        }
                        visible: !d.recipientReady
                    }

                    NetworkSelector {
                        id: networkSelector
                        width: parent.width
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.rightMargin: Style.current.bigPadding
                        store: popup.store
                        interactive: popup.interactive
                        selectedAccount: popup.selectedAccount
                        amountToSend: isNaN(parseFloat(amountToSendInput.text)) ? 0 : parseFloat(amountToSendInput.text)
                        requiredGasInEth: gasSelector.selectedGasEthValue
                        selectedAsset: assetSelector.selectedAsset
                        onReCalculateSuggestedRoute: popup.recalculateRoutesAndFees()
                        visible: d.recipientReady

                        isLoading: popup.isLoading
                        bestRoutes: popup.bestRoutes
                    }

                    Rectangle {
                        id: fees
                        radius: 13
                        color: Theme.palette.indirectColor1
                        height: text.height + gasSelector.height + gasValidator.height + Style.current.xlPadding
                        width: parent.width
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.current.bigPadding
                        anchors.rightMargin: Style.current.bigPadding
                        visible: d.recipientReady

                        RowLayout {
                            id: feesLayout
                            spacing: 10
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.margins: Style.current.padding

                            StatusRoundIcon {
                                id: feesIcon
                                Layout.alignment: Qt.AlignTop
                                radius: 8
                                asset.name: "fees"
                            }
                            Column {
                                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                                Layout.preferredWidth: fees.width - feesIcon.width - Style.current.xlPadding
                                Item {
                                    width: parent.width
                                    height: childrenRect.height
                                    StatusBaseText {
                                        id: text
                                        anchors.left: parent.left
                                        font.pixelSize: 15
                                        font.weight: Font.Medium
                                        color: Theme.palette.directColor1
                                        text: qsTr("Fees")
                                        wrapMode: Text.WordWrap
                                    }
                                    StatusBaseText {
                                        anchors.right: parent.right
                                        anchors.rightMargin: Style.current.padding
                                        id: totalFeesAdvanced
                                        text: popup.isLoading ? "..." : gasSelector.selectedGasFiatValue
                                        font.pixelSize: 15
                                        color: Theme.palette.directColor1
                                        visible: networkSelector.advancedOrCustomMode && popup.bestRoutes.length > 0
                                    }
                                }
                                GasSelector {
                                    id: gasSelector
                                    width: parent.width
                                    getGasEthValue: popup.store.getGasEthValue
                                    getFiatValue: popup.store.getFiatValue
                                    currentCurrency: popup.store.currencyStore.currentCurrency
                                    currentCurrencySymbol: popup.store.currencyStore.currentCurrencySymbol
                                    visible: gasValidator.isValid && !popup.isLoading
                                    advancedOrCustomMode: networkSelector.advancedOrCustomMode
                                    bestRoutes: popup.bestRoutes
                                    selectedTokenSymbol: assetSelector.selectedAsset ? assetSelector.selectedAsset.symbol: ""
                                    onSelectedPriorityChanged: popup.recalculateRoutesAndFees()
                                }
                                GasValidator {
                                    id: gasValidator
                                    width: parent.width
                                    isLoading: popup.isLoading
                                    isValid: popup.bestRoutes ? popup.bestRoutes.length > 0 : true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    footer: SendModalFooter {
        maxFiatFees: popup.isLoading ? "..." : gasSelector.selectedGasFiatValue
        selectedTimeEstimate: popup.isLoading? "..." : gasSelector.selectedTimeEstimate
        pending: d.isPendingTx
        visible: d.isReady && !isNaN(amountToSendInput.text) && gasValidator.isValid && !d.errorMode
        onNextButtonClicked: popup.sendTransaction()
    }

    Component {
        id: transactionSettingsConfirmationPopupComponent
        TransactionSettingsConfirmationPopup {}
    }

    Connections {
        target: popup.store.walletSectionTransactionsInst
        onSuggestedRoutesReady: {
            let response = JSON.parse(suggestedRoutes)
            if(!!response.error) {
                popup.isLoading = false
                return
            }
            popup.bestRoutes =  response.suggestedRoutes.best
            gasSelector.estimatedGasFeesTime = response.suggestedRoutes.gasTimeEstimates
            popup.isLoading = false
        }
    }

    Connections {
        target: popup.store.walletSectionTransactionsInst
        onTransactionSent: {
            d.isPendingTx = false
            try {
                let response = JSON.parse(txResult)
                if (response.uuid !== d.uuid) return

                if (!response.success) {
                    if (Utils.isInvalidPasswordMessage(response.error)) {
                        d.sendTxError = true
                        d.sendTxErrorString = qsTr("Wrong password")
                        return
                    }
                    sendingError.text = response.error
                    return sendingError.open()
                }
                for(var i=0; i<popup.bestRoutes.length; i++) {
                    let txHash = response.result[popup.bestRoutes[i].fromNetwork.chainId]
                    let url = `${popup.store.getEtherscanLink()}/${txHash}`
                    Global.displayToastMessage(qsTr("Transaction pending..."),
                                               qsTr("View on etherscan"),
                                               "",
                                               true,
                                               Constants.ephemeralNotificationType.normal,
                                               url)
                }

                popup.close()
            } catch (e) {
                console.error('Error parsing the response', e)
            }
        }
    }
}

