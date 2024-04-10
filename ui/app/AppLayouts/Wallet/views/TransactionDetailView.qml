import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.14
import QtQuick.Window 2.12
import QtGraphicalEffects 1.15

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import shared.controls 1.0
import shared.panels 1.0
import shared.stores 1.0
import utils 1.0
import shared.popups.send 1.0

import "../controls"
import "../popups"
import "../stores" as WalletStores
import ".."
import "../panels"

Item {
    id: root

    property var overview: WalletStores.RootStore.overview
    property var contactsStore
    property var communitiesStore
    property var networkConnectionStore
    property var controller
    property var sendModal
    property bool showAllAccounts: false

    readonly property alias transaction: d.transaction

    Component.onCompleted: d.updateTransactionDetails()

    QtObject {
        id: d

        readonly property var transaction: root.controller.activityEntry
        readonly property bool isTransactionValid: transaction !== undefined && !!transaction

        onTransactionChanged: {
            d.reEvaluateSender = !d.reEvaluateSender
            d.reEvaluateRecipient = !d.reEvaluateRecipient
            d.reEvaluateSender = !d.reEvaluateSender
            d.reEvaluateRecipient = !d.reEvaluateRecipient

            d.updateTransactionDetails()
        }

        property bool reEvaluateSender: true
        property bool reEvaluateRecipient: true

        property var details: root.controller.activityDetails
        readonly property bool isDetailsValid: details !== undefined && !!details

        onDetailsChanged: {
            if (!!d.details && !!d.details.input && d.details.input !== "0x") {
                d.loadingInputDate = true
                RootStore.fetchDecodedTxData(d.details.txHashOut, d.details.input)
            }
        }

        readonly property bool isIncoming: transactionType === Constants.TransactionType.Received || transactionType === Constants.TransactionType.ContractDeployment
        readonly property string networkShortName: d.isTransactionValid ? ModelUtils.getByKey(RootStore.flatNetworks, "chainId", transaction.chainId, "shortName") : ""
        readonly property string networkIcon: isTransactionValid ? ModelUtils.getByKey(RootStore.flatNetworks, "chainId", transaction.chainId, "iconUrl") : "network/Network=Custom"
        readonly property int blockNumber: isDetailsValid ? details.blockNumber : 0
        readonly property int blockNumberIn: isDetailsValid ? details.blockNumberIn : 0
        readonly property int blockNumberOut: isDetailsValid ? details.blockNumberOut : 0
        readonly property string networkShortNameOut: networkShortName
        readonly property string networkShortNameIn: transactionHeader.isMultiTransaction ? ModelUtils.getByKey(RootStore.flatNetworks, "chainId", transaction.chainIdIn, "shortName") : ""
        readonly property string symbol: isTransactionValid ? transaction.symbol : ""
        readonly property string inSymbol: isTransactionValid ? transaction.inSymbol : ""
        readonly property string outSymbol: isTransactionValid ? transaction.outSymbol : ""
        readonly property var multichainNetworks: [] // TODO fill icon for networks for multichain
        readonly property string fiatValueFormatted: {
            if (!d.isTransactionValid || transactionHeader.isMultiTransaction || !symbol)
                return ""
            return RootStore.formatCurrencyAmount(transactionHeader.fiatValue, RootStore.currentCurrency)
        }
        readonly property string cryptoValueFormatted: {
            if (!d.isTransactionValid || transactionHeader.isMultiTransaction)
                return ""
            const formatted = RootStore.formatCurrencyAmount(transaction.amount, transaction.symbol)
            return symbol || (!d.isDetailsValid || !d.details.contract) ? formatted : "%1 (%2)".arg(formatted).arg(Utils.compactAddress(transaction.tokenAddress, 4))
        }
        readonly property string outFiatValueFormatted: {
            if (!d.isTransactionValid || !transactionHeader.isMultiTransaction || !outSymbol)
                return ""
            return RootStore.formatCurrencyAmount(transactionHeader.outFiatValue, RootStore.currentCurrency)
        }
        readonly property string outCryptoValueFormatted: {
            if (!d.isTransactionValid || !transactionHeader.isMultiTransaction)
                return ""
            const formatted = RootStore.formatCurrencyAmount(transaction.outAmount, transaction.outSymbol)
            return outSymbol || !transaction.tokenOutAddress ? formatted : "%1 (%2)".arg(formatted).arg(Utils.compactAddress(transaction.tokenOutAddress, 4))
        }
        readonly property real feeEthValue: d.details ? RootStore.getFeeEthValue(d.details.totalFees) : 0
        readonly property real feeFiatValue: d.isTransactionValid ? RootStore.getFiatValue(d.feeEthValue, Constants.ethToken) : 0
        readonly property int transactionType: d.isTransactionValid ? transaction.txType : Constants.TransactionType.Send
        readonly property bool isBridge: d.transactionType === Constants.TransactionType.Bridge

        property string decodedInputData: ""
        property bool loadingInputDate: false

        function retryTransaction() {
            // TODO handle failed transaction retry
        }

        function updateTransactionDetails() {
            d.decodedInputData = ""
            if (!d.transaction)
                return

            root.controller.fetchExtraTxDetails()
        }
    }

    Connections {
        target: RootStore.walletSectionInst
        function onTxDecoded(txHash: string, dataDecoded: string) {
            if (!d.isTransactionValid || (d.isDetailsValid && txHash !== d.details.txHashOut))
                return
            if (!dataDecoded) {
                d.loadingInputDate = false
                return
            }

            try {
                const decodedObject = JSON.parse(dataDecoded)
                let text = qsTr("Function: %1").arg(decodedObject.signature)
                text += "\n" + qsTr("MethodID: %1").arg(decodedObject.id)
                for (const [key, value] of Object.entries(decodedObject.inputs)) {
                    text += "\n[%1]: %2".arg(key).arg(value)
                }
                d.decodedInputData = text
            } catch(e) {
                console.error("Failed to parse decoded tx data. Data:", dataDecoded)
            }
            d.loadingInputDate = false
        }
    }

    StatusScrollView {
        id: scrollView
        anchors.fill: parent
        contentWidth: availableWidth

        Column {
            id: column
            width: scrollView.availableWidth
            spacing: Style.current.xlPadding + Style.current.halfPadding

            Column {
                width: parent.width
                spacing: Style.current.bigPadding

                TransactionDelegate {
                    id: transactionHeader
                    objectName: "transactionDetailHeader"
                    width: parent.width
                    leftPadding: 0
                    sensor.enabled: false
                    color: Theme.palette.transparent
                    state: "header"

                    showAllAccounts: root.showAllAccounts
                    modelData: transaction
                    timeStampText: d.isTransactionValid ? qsTr("Signed at %1").arg(LocaleUtils.formatDateTime(transaction.timestamp * 1000, Locale.LongFormat)): ""
                    rootStore: RootStore
                    walletRootStore: WalletStores.RootStore
                    community: isModelDataValid && communityId && communitiesStore ? communitiesStore.getCommunityDetailsAsJson(communityId) : null

                    onRetryClicked: d.retryTransaction()
                }

                Separator { }
            }

            WalletTxProgressBlock {
                id: progressBlock
                width: Math.min(513, root.width)
                readonly property int latestBlockNumber: d.isTransactionValid && !pending && !error ? WalletStores.RootStore.getEstimatedLatestBlockNumber(d.transaction.chainId) : 0
                readonly property int latestBlockNumberIn: d.isTransactionValid && !pending && !error && transactionHeader.isMultiTransaction && d.isBridge ? WalletStores.RootStore.getEstimatedLatestBlockNumber(d.transaction.chainIdIn) : 0
                error: transactionHeader.transactionStatus === Constants.TransactionStatus.Failed
                pending: transactionHeader.transactionStatus === Constants.TransactionStatus.Pending
                outNetworkLayer: d.isTransactionValid ? Number(ModelUtils.getByKey(RootStore.flatNetworks, "chainId", transactionHeader.isMultiTransaction ? d.transaction.chainIdOut : d.transaction.chainId, "layer")) : 0
                inNetworkLayer: d.isTransactionValid && transactionHeader.isMultiTransaction && d.isBridge ?
                                    ModelUtils.getByKey(RootStore.flatNetworks, "chainId", d.transaction.chainIdIn, "layer") : 0
                outNetworkTimestamp: d.isTransactionValid ? d.transaction.timestamp : 0
                inNetworkTimestamp: d.isTransactionValid ? d.transaction.timestamp : 0
                outChainName: transactionHeader.isMultiTransaction ? transactionHeader.networkNameOut : transactionHeader.networkName
                inChainName: transactionHeader.isMultiTransaction && d.isBridge ? transactionHeader.networkNameIn : ""
                outNetworkConfirmations: d.isTransactionValid && latestBlockNumber > 0 ? latestBlockNumber - d.blockNumberOut : 0
                inNetworkConfirmations: d.isTransactionValid && latestBlockNumberIn > 0 ? latestBlockNumberIn - d.blockNumberIn : 0
            }

            Separator {
                width: progressBlock.width
            }

            WalletNftPreview {
                visible: d.isTransactionValid && transactionHeader.isNFT && !!transaction.nftImageUrl
                width: Math.min(304, progressBlock.width)
                nftName: d.isTransactionValid ? transaction.nftName : ""
                nftUrl: d.isTransactionValid && !!transaction.nftImageUrl ? transaction.nftImageUrl : ""
                strikethrough: d.transactionType === Constants.TransactionType.Destroy
                tokenId: d.isTransactionValid ? transaction.tokenID : ""
                tokenAddress: d.isTransactionValid ? transaction.tokenAddress : ""
                areTestNetworksEnabled: WalletStores.RootStore.areTestNetworksEnabled
                isGoerliEnabled: WalletStores.RootStore.isGoerliEnabled
            }

            Column {
                width: progressBlock.width
                spacing: 0

                StatusBaseText {
                    width: parent.width
                    font.pixelSize: 15
                    color: Theme.palette.directColor5
                    text: qsTr("Transaction summary")
                    elide: Text.ElideRight
                }

                Item {
                    width: parent.width
                    height: Style.current.smallPadding
                }

                DetailsPanel {
                    RowLayout {
                        spacing: 0
                        width: parent.width
                        height: fromNetworkTile.visible || toNetworkTile.visible ? 85 : 0
                        TransactionDataTile {
                            id: fromNetworkTile
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            title: qsTr("From")
                            subTitle: {
                                if (!d.isTransactionValid)
                                    return ""
                                switch(d.transactionType) {
                                case Constants.TransactionType.Swap:
                                    return !!d.outSymbol ? d.outSymbol : " "
                                case Constants.TransactionType.Bridge:
                                    return transactionHeader.networkNameOut
                                default:
                                    return ""
                                }
                            }
                            asset.name: {
                                if (!d.isTransactionValid)
                                    return ""
                                switch(d.transactionType) {
                                case Constants.TransactionType.Swap:
                                    return Constants.tokenIcon(d.outSymbol)
                                case Constants.TransactionType.Bridge:
                                    return Style.svg(ModelUtils.getByKey(RootStore.flatNetworks, "chainId", d.transaction.chainIdOut, "iconUrl")) ?? Style.svg("network/Network=Custom")
                                default:
                                    return ""
                                }
                            }
                            visible: !!subTitle
                        }
                        TransactionDataTile {
                            id: toNetworkTile
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            title: qsTr("To")
                            subTitle: {
                                switch(d.transactionType) {
                                case Constants.TransactionType.Swap:
                                    return !!d.inSymbol ? d.inSymbol : " "
                                case Constants.TransactionType.Bridge:
                                    return transactionHeader.networkNameIn ?? " "
                                default:
                                    return ""
                                }
                            }
                            asset.name: {
                                switch(d.transactionType) {
                                case Constants.TransactionType.Swap:
                                    return Constants.tokenIcon(d.inSymbol)
                                case Constants.TransactionType.Bridge:
                                    return Style.svg(RootStore.Icon(d.transaction.chainIdIn)) ?? Style.svg("network/Network=Custom")
                                default:
                                    return ""
                                }
                            }
                            visible: !!subTitle
                        }
                    }
                    TransactionAddressTile {
                        width: parent.width
                        title: d.transactionType === Constants.TransactionType.Swap || d.transactionType === Constants.TransactionType.Bridge ?
                                   qsTr("In") : qsTr("From")
                        addresses: d.isTransactionValid && d.reEvaluateSender? [d.transaction.sender] : []
                        contactsStore: root.contactsStore
                        rootStore: WalletStores.RootStore
                        onButtonClicked: {
                            if (d.transactionType === Constants.TransactionType.Swap || d.transactionType === Constants.TransactionType.Bridge) {
                                addressMenu.openEthAddressMenu(this, addresses[0], [d.networkShortNameIn, d.networkShortNameOut])
                            } else {
                                addressMenu.openSenderMenu(this, addresses[0], [d.networkShortName])
                            }
                        }
                    }
                    TransactionDataTile {
                        id: contractDeploymentTile
                        readonly property bool hasValue: d.isDetailsValid && !!d.details.contractOut
                                                         && transactionHeader.transactionStatus !== Constants.TransactionStatus.Pending
                                                         && transactionHeader.transactionStatus !== Constants.TransactionStatus.Failed
                        width: parent.width
                        title: qsTr("To")
                        visible: d.transactionType === Constants.TransactionType.ContractDeployment
                        subTitle: {
                            if (transactionHeader.transactionStatus === Constants.TransactionStatus.Failed) {
                                return qsTr("Contract address not created")
                            } else if (!hasValue) {
                                return qsTr("Awaiting contract address...")
                            }
                            return qsTr("Contract created") + "\n" + d.details.contract
                        }
                        buttonIconName: hasValue ? "more" : ""
                        statusListItemSubTitle.customColor: hasValue ? Theme.palette.directColor1 : Theme.palette.directColor5
                        onButtonClicked: addressMenu.openContractMenu(this, d.details.contract, [d.networkShortName], d.symbol)
                        components: [
                            Loader {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: Style.current.halfPadding
                                active: transactionHeader.transactionStatus === Constants.TransactionStatus.Pending
                                width: active ? implicitWidth : 0
                                sourceComponent: StatusLoadingIndicator { }
                            }
                        ]
                    }
                    TransactionAddressTile {
                        width: parent.width
                        title: qsTr("To")
                        addresses: d.isTransactionValid && visible && d.reEvaluateRecipient? [d.transaction.recipient] : []
                        contactsStore: root.contactsStore
                        rootStore: WalletStores.RootStore
                        onButtonClicked: addressMenu.openReceiverMenu(this, addresses[0], [d.networkShortName])
                        visible: d.transactionType !== Constants.TransactionType.ContractDeployment && d.transactionType !== Constants.TransactionType.Swap && d.transactionType !== Constants.TransactionType.Bridge && d.transactionType !== Constants.TransactionType.Destroy
                    }
                    TransactionDataTile {
                        width: parent.width
                        title: qsTr("Using")
                        subTitle: d.isDetailsValid ? d.details.protocol : ""
                        asset.name: d.isDetailsValid && d.details.protocol ? Style.svg("protocol/Protocol=%1".arg(d.details.protocol)) : Style.svg("network/Network=Custom")
                        iconSettings.bgRadius: iconSettings.bgWidth / 2
//                        buttonIconName: "external" // TODO handle external link #11982
                        visible: !!subTitle
                    }
                    TransactionDataTile {
                        width: parent.width
                        title: qsTr("%1 Tx hash").arg(transactionHeader.networkName)
                        subTitle: d.isDetailsValid ? d.details.txHash : ""
                        visible: !!subTitle && !transactionHeader.isMultiTransaction
                        buttonIconName: "more"
                        onButtonClicked: addressMenu.openTxMenu(this, subTitle, [d.networkShortName])
                    }
                    TransactionDataTile {
                        width: parent.width
                        title: qsTr("%1 Tx hash").arg(transactionHeader.networkNameOut)
                        subTitle: d.isDetailsValid ? d.details.txHashOut : ""
                        visible: !!subTitle && transactionHeader.isMultiTransaction
                        buttonIconName: "more"
                        onButtonClicked: addressMenu.openTxMenu(this, subTitle, [d.networkShortNameOut])
                    }
                    TransactionDataTile {
                        width: parent.width
                        title: qsTr("%1 Tx hash").arg(transactionHeader.networkNameIn)
                        subTitle: d.isDetailsValid ? d.details.txHashIn : ""
                        visible: !!subTitle && transactionHeader.isMultiTransaction
                        buttonIconName: "more"
                        onButtonClicked: addressMenu.openTxMenu(this, subTitle, [d.networkShortNameIn])
                    }
//                    TransactionContractTile {
//                        // Used for Bridge and Swap to display 'From' network Protocol contract address
//                        address: "" // TODO fill protocol contract address for 'from' network for Bridge and Swap
//                        symbol: "" // TODO fill protocol name for Bridge and Swap
//                        networkName: transactionHeader.networkName
//                        shortNetworkName: d.networkShortName
//                        visible: !!subTitle && (d.transactionType === Constants.TransactionType.Bridge || d.transactionType === Constants.TransactionType.Swap)
//                    }
                    TransactionContractTile {
                        // Used to display contract address for any network
                        address: d.isDetailsValid ? d.details.contractIn : ""
                        symbol: {
                            if (!d.isTransactionValid)
                                return ""
                            return d.symbol ? d.symbol : "(%1)".arg(Utils.compactAddress(transaction.tokenAddress, 4))
                        }
                        networkName: transactionHeader.networkName
                        shortNetworkName: d.networkShortName
                        visible: !!subTitle && d.transactionType !== Constants.TransactionType.ContractDeployment
                    }
//                    TransactionContractTile {
//                        // Used for Bridge to display 'To' network Protocol contract address
//                        address: "" // TODO fill protocol contract address for 'to' network for Bridge
//                        symbol: "" // TODO fill protocol name for Bridge
//                        networkName: transactionHeader.networkNameOut
//                        shortNetworkName: d.networkShortNameOut
//                        visible: !!subTitle && d.transactionType === Constants.TransactionType.Bridge
//                    }
                    TransactionContractTile {
                        // Used for Bridge and Swap to display 'To' network token contract address
                        address: {
                            if (!d.isTransactionValid)
                                return ""
                            switch(d.transactionType) {
                            case Constants.TransactionType.Swap:
                            case Constants.TransactionType.Bridge:
                                return d.isDetailsValid ? d.details.contractOut : ""
                            default:
                                return ""
                            }
                        }
                        symbol: {
                            if (!d.isTransactionValid)
                                return ""
                            switch(d.transactionType) {
                            case Constants.TransactionType.Swap:
                                return d.inSymbol
                            case Constants.TransactionType.Bridge:
                                return d.outSymbol
                            default:
                                return ""
                            }
                        }
                        networkName: transactionHeader.networkNameIn
                        shortNetworkName: d.networkShortNameIn
                        visible: d.isTransactionValid && !!subTitle
                    }
                }

                Item {
                    width: parent.width
                    height: Style.current.bigPadding
                }

                DetailsPanel {
                    width: progressBlock.width
                    RowLayout {
                        width: parent.width
                        height: networkNameTile.statusListItemSubTitle.lineCount > 1 ? 85 : 70
                        spacing: 0
                        TransactionDataTile {
                            id: multichainNetworksTile
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            title: qsTr("Networks")
                            visible: d.multichainNetworks.length > 0
                            Row {
                                anchors {
                                    top: parent.top
                                    topMargin: multichainNetworksTile.statusListItemTitleArea.height + multichainNetworksTile.topPadding
                                    left: parent.left
                                    leftMargin: multichainNetworksTile.leftPadding
                                }
                                spacing: -4
                                Repeater {
                                    model: d.multichainNetworks
                                    delegate: StatusRoundedImage {
                                        width: 20
                                        height: 20
                                        visible: image.source !== ""
                                        border.width: index === 0 ? 0 : 1
                                        border.color: Theme.palette.white
                                        image.source: Style.svg("tiny/" + modelData)
                                        z: index + 1
                                    }
                                }
                            }
                        }
                        TransactionDataTile {
                            id: networkNameTile
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            title: qsTr("Network")
                            subTitle: transactionHeader.networkName
                            asset.name: !!d.networkIcon ? Style.svg(d.networkIcon) : ""
                            subTitleBadgeLoaderAlignment: Qt.AlignTop
                            smallIcon: true
                            visible: !!subTitle && d.transactionType !== Constants.TransactionType.Bridge
                        }
                        TransactionDataTile {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            title: qsTr("Token format")
                            subTitle: d.isDetailsValid ? d.details.tokenType.toUpperCase() : ""
                            visible: !!subTitle
                        }
                        TransactionDataTile {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            title: qsTr("Nonce")
                            subTitle: d.isDetailsValid ? d.details.nonce : ""
                            visible: !!subTitle
                        }
                    }
                    TransactionDataTile {
                        width: parent.width
                        height: d.loadingInputDate ? 112 : Math.min(implicitHeight + bottomPadding, 112)
                        title: qsTr("Input data")
                        // Input string can be really long. Getting substring just for 3+ lines to speedup formatting.
                        subTitle: {
                            if (d.loadingInputDate) {
                                return ""
                            } else if (!!d.decodedInputData) {
                                return d.decodedInputData.substring(0, 200)
                            } else if (d.isDetailsValid) {
                                return String(d.details.input).substring(0, 200)
                            }
                            return ""
                        }
                        visible: !!subTitle || d.loadingInputDate
                        buttonIconName: d.loadingInputDate ? "" : "more"
                        statusListItemSubTitle.maximumLineCount: 4
                        statusListItemSubTitle.lineHeight: 1.21
                        statusListItemSubTitle.layer.enabled: statusListItemSubTitle.lineCount > 3
                        statusListItemSubTitle.layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: 10
                                height: 10
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#f00" }
                                    GradientStop { position: 0.4; color: "#a0ff0000" }
                                    GradientStop { position: 0.75; color: "#00ff0000" }
                                }
                            }
                        }
                        tertiaryTitle: !d.loadingInputDate && !d.decodedInputData ? qsTr("Data could not be decoded") : ""
                        statusListItemTertiaryTitle.anchors.top: undefined
                        statusListItemTertiaryTitle.anchors.baseline: statusListItemTitle.baseline
                        statusListItemTertiaryTitle.font: statusListItemTitle.font
                        onButtonClicked: addressMenu.openInputDataMenu(this, !!d.decodedInputData ? d.decodedInputData : d.details.input)

                        Loader {
                            anchors {
                                left: parent.left
                                bottom: parent.bottom
                                right: parent.right
                                margins: 12
                            }
                            active: d.loadingInputDate
                            sourceComponent: Column {
                                spacing: 10
                                Repeater {
                                    model: 3
                                    LoadingComponent {
                                        anchors {
                                            left: parent.left
                                            right: index === 2 ? parent.horizontalCenter : parent.right
                                        }
                                        height: 11
                                        radius: 4
                                        enabled: false
                                    }
                                }
                            }
                        }
                    }
                    TransactionDataTile {
                        // Tile used only for multiTx
                        width: parent.width
                        title: !!transactionHeader.networkNameOut ? qsTr("Included in Block on %1").arg(transactionHeader.networkNameOut) : qsTr("Included on Block")
                        subTitle: d.blockNumberOut
                        tertiaryTitle: d.isTransactionValid ? LocaleUtils.formatDateTime(transaction.timestamp * 1000, Locale.LongFormat) : ""
                        visible: d.blockNumberOut > 0 && transactionHeader.isMultiTransaction
                    }
                    TransactionDataTile {
                        // Tile used for multiTx and normal tx
                        width: parent.width
                        readonly property int blockNumber: transactionHeader.isMultiTransaction ? d.blockNumberIn : d.blockNumber
                        readonly property string networkName: transactionHeader.isMultiTransaction ? transactionHeader.networkNameIn : transactionHeader.networkName
                        title: !!networkName ? qsTr("Included in Block on %1").arg(networkName) : qsTr("Included on Block")
                        subTitle: blockNumber
                        tertiaryTitle: d.isTransactionValid ? LocaleUtils.formatDateTime(transaction.timestamp * 1000, Locale.LongFormat) : ""
                        visible: blockNumber > 0
                    }
                }
            }

            Column {
                width: progressBlock.width
                spacing: Style.current.smallPadding
                visible: !(transactionHeader.isNFT && d.isIncoming)

                RowLayout {
                    width: parent.width
                    visible: amountSentTile.visible || amountReceiveTile.visible || feesTile.visible || totalTile.visible
                    StatusBaseText {
                        Layout.alignment: Qt.AlignLeft
                        font.pixelSize: 15
                        color: Theme.palette.directColor5
                        text: qsTr("Values")
                        elide: Text.ElideRight
                    }

                    StatusBaseText {
                        Layout.alignment: Qt.AlignRight
                        font.pixelSize: 15
                        color: Theme.palette.directColor5
                        text: d.isTransactionValid ? qsTr("as of %1").arg(LocaleUtils.formatDateTime(transaction.timestamp * 1000, Locale.LongFormat)) : ""
                        elide: Text.ElideRight
                    }
                }

                DetailsPanel {
                    TransactionDataTile {
                        id: amountSentTile
                        width: parent.width
                        title: qsTr("Amount sent")
                        subTitle: transactionHeader.isMultiTransaction ? d.outCryptoValueFormatted : d.cryptoValueFormatted
                        tertiaryTitle: transactionHeader.isMultiTransaction ? d.outFiatValueFormatted : d.fiatValueFormatted
                        visible: {
                            if (transactionHeader.isNFT)
                                return false
                            switch(d.transactionType) {
                            case Constants.TransactionType.Send:
                            case Constants.TransactionType.Swap:
                            case Constants.TransactionType.Bridge:
                                return true
                            default:
                                return false
                            }
                        }
                    }
                    TransactionDataTile {
                        id: amountReceiveTile
                        width: parent.width
                        title: transactionHeader.transactionStatus === Constants.TransactionStatus.Pending ? qsTr("Amount to receive") : qsTr("Amount received")
                        subTitle: {
                            if (!d.isTransactionValid || transactionHeader.isNFT)
                                return ""
                            const type = d.transactionType
                            if (type === Constants.TransactionType.Swap) {
                                return RootStore.formatCurrencyAmount(transactionHeader.inCryptoValue, d.inSymbol)
                            } else if (type === Constants.TransactionType.Bridge) {
                                // Reduce crypto value by fee value
                                const valueInCrypto = RootStore.getCryptoValue(transactionHeader.outFiatValue - d.feeFiatValue, d.inSymbol)
                                return RootStore.formatCurrencyAmount(valueInCrypto, d.inSymbol)
                            }
                            return ""
                        }
                        tertiaryTitle: {
                            const type = d.transactionType
                            if (type === Constants.TransactionType.Swap) {
                                return RootStore.formatCurrencyAmount(transactionHeader.inFiatValue, RootStore.currentCurrency)
                            } else if (type === Constants.TransactionType.Bridge) {
                                return RootStore.formatCurrencyAmount(transactionHeader.outFiatValue - d.feeFiatValue, RootStore.currentCurrency)
                            }
                            return ""
                        }
                        visible: !!subTitle
                    }
                    TransactionDataTile {
                        id: feesTile
                        width: parent.width
                        title: d.symbol ? qsTr("Fees") : qsTr("Estimated max fee")
                        subTitle: {
                            if (!d.isTransactionValid || transactionHeader.isNFT || !d.isDetailsValid)
                                return ""
                            if (!d.symbol) {
                                const maxFeeEth = RootStore.getFeeEthValue(d.details.maxTotalFees)
                                return RootStore.formatCurrencyAmount(maxFeeEth, Constants.ethToken)
                            }

                            switch(d.transactionType) {
                            case Constants.TransactionType.Send:
                            case Constants.TransactionType.Swap:
                            case Constants.TransactionType.Bridge:
                                return LocaleUtils.currencyAmountToLocaleString(d.details.totalFees)
                            default:
                                return ""
                            }
                        }
                        tertiaryTitle: {
                            if (!subTitle)
                                return ""
                            let fiatValue
                            if (!d.symbol) {
                                const maxFeeEth = RootStore.getFeeEthValue(d.details.maxTotalFees)
                                fiatValue = RootStore.getFiatValue(maxFeeEth, Constants.ethToken)
                            } else {
                                fiatValue = d.feeFiatValue
                            }
                            return RootStore.formatCurrencyAmount(fiatValue, RootStore.currentCurrency)
                        }
                        visible: !!subTitle
                    }
                    TransactionDataTile {
                        id: totalTile
                        width: parent.width
                        readonly property bool fieldIsHidden: (transactionHeader.isNFT && d.isIncoming) || !d.symbol
                        readonly property bool showMaxFee: d.transactionType === Constants.TransactionType.ContractDeployment && transactionHeader.transactionStatus === Constants.TransactionStatus.Pending
                        readonly property bool showFee: d.transactionType === Constants.TransactionType.Destroy || transactionHeader.isNFT || d.transactionType === Constants.TransactionType.ContractDeployment
                        readonly property bool showValue: d.transactionType === Constants.TransactionType.Receive || (d.transactionType === Constants.TransactionType.Buy && progressBlock.isLayer1)
                        // NOTE Using fees in this tile because of same higlight and color settings as Total
                        title: {
                            if (showMaxFee) {
                                return qsTr("Estimated max fee")
                            } else if (showFee) {
                                return qsTr("Fees")
                            }
                            return qsTr("Total")
                        }
                        subTitle: {
                            if (fieldIsHidden)
                                return ""
                            if (showMaxFee) {
                                const maxFeeEth = RootStore.getFeeEthValue(d.details.maxTotalFees)
                                return RootStore.formatCurrencyAmount(maxFeeEth, Constants.ethToken)
                            } else if (showFee) {
                                return RootStore.formatCurrencyAmount(d.feeEthValue, Constants.ethToken)
                            } else if (showValue) {
                                return d.cryptoValueFormatted
                            }
                            const cryptoValue = transactionHeader.isMultiTransaction ? d.outCryptoValueFormatted : d.cryptoValueFormatted
                            return "%1 + %2".arg(cryptoValue).arg(RootStore.formatCurrencyAmount(d.feeEthValue, Constants.ethToken))
                        }
                        tertiaryTitle: {
                            if (fieldIsHidden)
                                return ""
                            if (showMaxFee) {
                                const maxFeeEth = RootStore.getFeeEthValue(d.details.maxTotalFees)
                                const maxFeeFiat = RootStore.getFiatValue(d.feeEthValue, Constants.ethToken)
                                return RootStore.formatCurrencyAmount(maxFeeFiat, RootStore.currentCurrency)
                            } else if (showFee) {
                                return RootStore.formatCurrencyAmount(d.feeFiatValue, RootStore.currentCurrency)
                            } else if (showValue) {
                                return d.fiatValueFormatted
                            }
                            const fiatValue = transactionHeader.isMultiTransaction ? transactionHeader.outFiatValue : transactionHeader.fiatValue
                            return RootStore.formatCurrencyAmount(fiatValue + d.feeFiatValue, RootStore.currentCurrency)
                        }
                        visible: !!subTitle
                        highlighted: true
                        statusListItemTertiaryTitle.customColor: Theme.palette.directColor1
                    }
                }
            }

            Separator {
                width: progressBlock.width
            }

            RowLayout {
                width: progressBlock.width
                visible: d.isTransactionValid
                spacing: 8
                StatusButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: copyDetailsButton.height
                    text: qsTr("Repeat transaction")
                    size: StatusButton.Small

                    property alias tx: d.transaction

                    visible: {
                        if (!d.isTransactionValid || root.overview.isWatchOnlyAccount)
                            return false

                        return WalletStores.RootStore.isTxRepeatable(tx)
                    }
                    onClicked: {
                        let asset = WalletStores.RootStore.getAssetForSendTx(tx)
                        let req = Helpers.lookupAddressesForSendModal(tx.sender, tx.recipient, asset, tx.isNFT, tx.amount)

                        root.sendModal.preSelectedAccount = req.preSelectedAccount
                        root.sendModal.preSelectedRecipient = req.preSelectedRecipient
                        root.sendModal.preSelectedRecipientType = req.preSelectedRecipientType
                        root.sendModal.preSelectedHoldingID = req.preSelectedHoldingID
                        root.sendModal.preSelectedHoldingType = req.preSelectedHoldingType
                        root.sendModal.preSelectedSendType = req.preSelectedSendType
                        root.sendModal.preDefinedAmountToSend = req.preDefinedAmountToSend
                        root.sendModal.onlyAssets = false
                        root.sendModal.open()
                    }
                }
                StatusButton {
                    id: copyDetailsButton
                    Layout.fillWidth: true
                    text: qsTr("Copy details")
                    icon.name: "copy"
                    icon.width: 20
                    icon.height: 20
                    size: StatusButton.Small
                    onClicked: RootStore.copyToClipboard(transactionHeader.getDetailsString(d.details))
                }
            }
        }
    }

    TransactionAddressMenu {
        id: addressMenu

        areTestNetworksEnabled: WalletStores.RootStore.areTestNetworksEnabled
        isGoerliEnabled: WalletStores.RootStore.isGoerliEnabled
        contactsStore: root.contactsStore
        networkConnectionStore: root.networkConnectionStore
        onOpenSendModal: (address) => root.sendModal.open(address)
    }

    component DetailsPanel: Item {
        width: parent.width
        height: {
            // Using childrenRect and transactionvalid properties to refresh this binding
            if (!d.isTransactionValid || detailsColumn.childrenRect.height === 0)
                return 0

            // Height is calculated from visible children because Column doesn't handle
            // visibility change properly and childrenRect.height gives different values
            // comparing to manual check
            var visibleHeight = 0
            for (var i = 0 ; i < detailsColumn.children.length ; i++) {
                if (detailsColumn.children[i].visible)
                    visibleHeight += detailsColumn.children[i].height
            }
            return visibleHeight
        }

        default property alias content: detailsColumn.children

        Rectangle {
            id: tileBackground
            anchors.fill: parent
            color: Style.current.transparent
            radius: 8
            border.width: 1
            border.color: Style.current.separator
        }

        Column {
            id: detailsColumn
            anchors.fill: parent
            anchors.margins: 1
            spacing: 0
            layer.enabled: true
            layer.effect: OpacityMask {
                // Separate rectangle is used as mask because background rectangle must be transaprent
                maskSource: Rectangle {
                    width: tileBackground.width
                    height: tileBackground.height
                    radius: tileBackground.radius
                }
            }
        }
    }

    component TransactionContractTile: TransactionDataTile {
        property string networkName: ""
        property string symbol: ""
        property string address: ""
        property string shortNetworkName: ""
        width: parent.width
        title: visible ? qsTr("%1 %2 contract address").arg(networkName).arg(symbol) : ""
        subTitle: !!address && !/0x0+$/.test(address) ? address : ""
        buttonIconName: "more"
        visible: !!subTitle
        onButtonClicked: addressMenu.openContractMenu(this, address, shortNetworkName, symbol)
    }
}
