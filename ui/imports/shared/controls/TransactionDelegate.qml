import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared 1.0

/*!
   \qmltype TransactionDelegate
   \inherits StatusListItem
   \inqmlmodule shared.controls
   \since shared.controls 1.0
   \brief Delegate for transaction activity list

   Delegate to display transaction activity data.

   \qml
    TransactionDelegate {
        id: delegate
        width: ListView.view.width
        modelData: model
        swapCryptoValue: 0.18
        swapFiatValue: 340
        swapSymbol: "SNT"
        timeStampText: LocaleUtils.formatRelativeTimestamp(modelData.timestamp * 1000)
        cryptoValue: 0.1234
        fiatValue: 123123
        currentCurrency: "USD"
        networkName: "Optimism"
        symbol: "ETH"
        bridgeNetworkName: "Mainnet"
        feeFiatValue: 10.34
        feeCryptoValue: 0.013
        transactionStatus: TransactionDelegate.Pending
        transactionType: TransactionDelegate.Send
        formatCurrencyAmount: RootStore.formatCurrencyAmount
        loading: isModelDataValid && modelData.loadingTransaction
    }
   \endqml

   Additional usages should be handled using states.
*/

StatusListItem {
    id: root

    signal retryClicked()

    property var modelData
    property string symbol
    property string swapSymbol // TODO fill when swap data is implemented
    property int transactionType
    property int transactionStatus: transferStatus === 0 ? TransactionDelegate.TransactionStatus.Pending : TransactionDelegate.TransactionStatus.Finished
    property string currentCurrency
    property int transferStatus
    property double cryptoValue
    property double swapCryptoValue // TODO fill when swap data is implemented
    property double fiatValue
    property double swapFiatValue // TODO fill when swap data is implemented
    property double feeCryptoValue // TODO fill when bridge data is implemented
    property double feeFiatValue // TODO fill when bridge data is implemented
    property string networkIcon
    property string networkColor
    property string networkName
    property string bridgeNetworkName // TODO fill when bridge data is implemented
    property string timeStampText
    property string addressNameTo
    property string addressNameFrom
    property var formatCurrencyAmount: function() {}

    readonly property bool isModelDataValid: modelData !== undefined && !!modelData
    readonly property bool isNFT: isModelDataValid && modelData.isNFT
    readonly property string transactionValue: {
        if (!isModelDataValid)
            return qsTr("N/A")
        if (root.isNFT) {
            return modelData.nftName ? modelData.nftName : "#" + modelData.tokenID
        } else {
            return root.formatCurrencyAmount(cryptoValue, symbol)
        }
    }
    readonly property string swapTransactionValue: {
        if (!isModelDataValid) {
            return qsTr("N/A")
        }
        return root.formatCurrencyAmount(swapCryptoValue, swapSymbol)
    }

    readonly property string tokenImage: {
        if (!isModelDataValid)
            return ""
        if (root.isNFT) {
            return modelData.nftImageUrl ? modelData.nftImageUrl : ""
        } else {
            return root.symbol ? Style.png("tokens/%1".arg(root.symbol)) : ""
        }
    }

    readonly property string swapTokenImage: {
        if (!isModelDataValid)
            return ""
        return root.swapSymbol ? Style.png("tokens/%1".arg(root.swapSymbol)) : ""
    }

    readonly property string toAddress: !!addressNameTo ?
                                            addressNameTo :
                                            isModelDataValid ?
                                                Utils.compactAddress(modelData.to, 4) :
                                                ""

    readonly property string fromAddress: !!addressNameFrom ?
                                            addressNameFrom :
                                            isModelDataValid ?
                                                Utils.compactAddress(modelData.from, 4) :
                                                ""

    property StatusAssetSettings statusIconAsset: StatusAssetSettings {
        width: 12
        height: 12
        bgWidth: width + 2
        bgHeight: bgWidth
        bgRadius: bgWidth / 2
        bgColor: root.color
        color: "transparent"
        name: {
            switch(root.transactionStatus) {
            case TransactionDelegate.TransactionStatus.Pending:
                return Style.svg("transaction/pending")
            case TransactionDelegate.TransactionStatus.Verified:
                return Style.svg("transaction/verified")
            case TransactionDelegate.TransactionStatus.Finished:
                return Style.svg("transaction/finished")
            case TransactionDelegate.TransactionStatus.Failed:
                return Style.svg("transaction/failed")
            default:
                return ""
            }
        }
    }

    property StatusAssetSettings tokenIconAsset: StatusAssetSettings {
        width: 18
        height: 18
        bgWidth: width
        bgHeight: height
        bgColor: "transparent"
        color: "transparent"
        isImage: !loading
        name: root.tokenImage
        isLetterIdenticon: loading
    }

    enum TransactionType {
        Send,
        Receive,
        Buy,
        Sell,
        Destroy,
        Swap,
        Bridge
    }

    enum TransactionStatus {
        Pending,
        Failed,
        Verified,
        Finished
    }

    QtObject {
        id: d

        property int loadingPixelSize: 13
        property int datePixelSize: 12
        property int titlePixelSize: 15
        property int subtitlePixelSize: 13
    }

    rightPadding: 16
    enabled: !loading
    color: sensor.containsMouse ? Theme.palette.baseColor5 : Theme.palette.statusListItem.backgroundColor

    statusListItemIcon.active: (loading || root.asset.name)
    asset {
        width: 24
        height: 24
        isImage: false
        imgIsIdenticon: true
        isLetterIdenticon: loading
        name: {
            switch(root.transactionType) {
            case TransactionDelegate.TransactionType.Send:
                return "receive"
            case TransactionDelegate.TransactionType.Receive:
                return "send"
            case TransactionDelegate.TransactionType.Buy:
            case TransactionDelegate.TransactionType.Sell:
                return "token"
            case TransactionDelegate.TransactionType.Destroy:
                return "destroy"
            case TransactionDelegate.TransactionType.Swap:
                return "swap"
            case TransactionDelegate.TransactionType.Bridge:
                return "bridge"
            default:
                return ""
            }
        }
        bgColor: "transparent"
        color: Theme.palette.directColor1
        bgBorderWidth: 1
        bgBorderColor: Theme.palette.primaryColor3
    }

    sensor.children: [
        StatusRoundIcon {
            id: leftIconStatusIcon
            visible: !root.loading
            anchors {
                right: root.statusListItemIcon.right
                bottom: root.statusListItemIcon.bottom
            }
            asset: root.statusIconAsset
        }
    ]

    // Title
    title: {
        if (root.loading) {
            return "dummmy"
        } else if (!root.isModelDataValid) {
            return ""
        }

        const isPending = root.transactionStatus === TransactionDelegate.TransactionStatus.Pending
        const failed = root.transactionStatus === TransactionDelegate.TransactionStatus.Failed
        switch(root.transactionType) {
        case TransactionDelegate.TransactionType.Send:            
            return failed ? qsTr("Send failed") : (isPending ? qsTr("Sending") : qsTr("Sent"))
        case TransactionDelegate.TransactionType.Receive:
            return failed ? qsTr("Receive failed") : (isPending ? qsTr("Receiving") : qsTr("Received"))
        case TransactionDelegate.TransactionType.Buy:
            return failed ? qsTr("Buy failed") : (isPending ? qsTr("Buying") : qsTr("Bought"))
        case TransactionDelegate.TransactionType.Sell:
            return failed ? qsTr("Sell failed") : (isPending ? qsTr("Selling") : qsTr("Sold"))
        case TransactionDelegate.TransactionType.Destroy:
            return failed ? qsTr("Destroy failed") : (isPending ? qsTr("Destroying") : qsTr("Destroyed"))
        case TransactionDelegate.TransactionType.Swap:
            return failed ? qsTr("Swap failed") : (isPending ? qsTr("Swapping") : qsTr("Swapped"))
        case TransactionDelegate.TransactionType.Bridge:
            return failed ? qsTr("Bridge failed") : (isPending ? qsTr("Bridging") : qsTr("Bridged"))
        default:
            return ""
        }
    }
    statusListItemTitleArea.anchors.rightMargin: root.rightPadding
    statusListItemTitle.font.weight: Font.DemiBold
    statusListItemTitle.font.pixelSize: root.loading ? d.loadingPixelSize : d.titlePixelSize

    // title icons and date
    statusListItemTitleIcons.sourceComponent: Row {
        spacing: 8
        Row {
            visible: !root.loading
            spacing: swapTokenImage.visible ? -tokenImage.width * 0.2 : 0
            StatusRoundIcon {
                id: tokenImage
                anchors.verticalCenter: parent.verticalCenter
                asset: root.tokenIconAsset
            }
            StatusRoundIcon {
                id: swapTokenImage
                visible: !root.isNFT && !!root.swapTokenImage && root.transactionType === TransactionDelegate.TransactionType.Swap
                anchors.verticalCenter: parent.verticalCenter
                asset: StatusAssetSettings {
                    width: root.tokenIconAsset.width
                    height: root.tokenIconAsset.height
                    bgWidth: width + 2
                    bgHeight: height + 2
                    bgRadius: bgWidth / 2
                    bgColor: root.color
                    isImage:root.tokenIconAsset.isImage
                    color: root.tokenIconAsset.color
                    name: root.swapTokenImage
                    isLetterIdenticon: root.tokenIconAsset.isLetterIdenticon
                }
            }
        }
        StatusTextWithLoadingState {
            anchors.verticalCenter: parent.verticalCenter
            text: root.loading ? root.title : root.timeStampText
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: root.loading ? d.loadingPixelSize : d.datePixelSize
            visible: !!text
            loading: root.loading
            customColor: Theme.palette.baseColor1
        }
    }

    // subtitle
    subTitle: {
        if (!root.isModelDataValid) {
            return ""
        }
        switch(root.transactionType) {
        case TransactionDelegate.TransactionType.Receive:
            return qsTr("%1 from %2 via %3").arg(transactionValue).arg(fromAddress).arg(networkName)
        case TransactionDelegate.TransactionType.Buy:
        case TransactionDelegate.TransactionType.Sell:
            return qsTr("%1 on %2 via %3").arg(transactionValue).arg(toAddress).arg(networkName)
        case TransactionDelegate.TransactionType.Destroy:
            return qsTr("%1 at %2 via %3").arg(transactionValue).arg(toAddress).arg(networkName)
        case TransactionDelegate.TransactionType.Swap:
            return qsTr("%1 to %2 via %3").arg(transactionValue).arg(swapTransactionValue).arg(networkName)
        case TransactionDelegate.TransactionType.Bridge:
            return qsTr("%1 from %2 to %3").arg(transactionValue).arg(bridgeNetworkName).arg(networkName)
        default:
            return qsTr("%1 to %2 via %3").arg(transactionValue).arg(toAddress).arg(networkName)
        }
    }
    statusListItemSubTitle.maximumLoadingStateWidth: 300
    statusListItemSubTitle.customColor: Theme.palette.directColor1
    statusListItemSubTitle.font.pixelSize: root.loading ? d.loadingPixelSize : d.subtitlePixelSize
    statusListItemTagsRowLayout.anchors.topMargin: 4 // Spacing between title row nad subtitle row

    // Right side components
    components: [
        Loader {
            active: !headerStatusLoader.active
            visible: active
            sourceComponent: ColumnLayout {
                StatusTextWithLoadingState {
                    id: cryptoValueText
                    text: {
                        if (root.loading) {
                            return "dummy text"
                        } else if (!root.isModelDataValid || root.isNFT) {
                            return ""
                        }

                        switch(root.transactionType) {
                        case TransactionDelegate.TransactionType.Send:
                        case TransactionDelegate.TransactionType.Sell:
                            return "-" + root.transactionValue
                        case TransactionDelegate.TransactionType.Buy:
                        case TransactionDelegate.TransactionType.Receive:
                            return "+" + root.transactionValue
                        case TransactionDelegate.TransactionType.Swap:
                            return "<font color=\"%1\">-%2</font> <font color=\"%3\">/</font> <font color=\"%4\">+%5</font>"
                                          .arg(Theme.palette.directColor1)
                                          .arg(root.transactionValue)
                                          .arg(Theme.palette.baseColor1)
                                          .arg(Theme.palette.successColor1)
                                          .arg(root.swapTransactionValue)
                        case TransactionDelegate.TransactionType.Bridge:
                            return "-" + root.formatCurrencyAmount(feeCryptoValue, root.symbol)
                        default:
                            return ""
                        }
                    }
                    horizontalAlignment: Qt.AlignRight
                    Layout.alignment: Qt.AlignRight
                    font.pixelSize: root.loading ? d.loadingPixelSize : 13
                    customColor: {
                        switch(root.transactionType) {
                        case TransactionDelegate.TransactionType.Receive:
                        case TransactionDelegate.TransactionType.Buy:
                        case TransactionDelegate.TransactionType.Swap:
                            return Theme.palette.successColor1
                        default:
                            return Theme.palette.directColor1
                        }
                    }
                    loading: root.loading
                }
                StatusTextWithLoadingState {
                    id: fiatValueText
                    Layout.alignment: Qt.AlignRight
                    horizontalAlignment: Qt.AlignRight
                    text: {
                        if (root.loading) {
                            return "dummy text"
                        } else if (!root.isModelDataValid || root.isNFT) {
                            return ""
                        }

                        switch(root.transactionType) {
                        case TransactionDelegate.TransactionType.Send:
                        case TransactionDelegate.TransactionType.Sell:
                        case TransactionDelegate.TransactionType.Buy:
                            return "-" + root.formatCurrencyAmount(root.fiatValue, root.currentCurrency)
                        case TransactionDelegate.TransactionType.Receive:
                            return "+" + root.formatCurrencyAmount(root.fiatValue, root.currentCurrency)
                        case TransactionDelegate.TransactionType.Swap:
                            return "-%1 / +%2".arg(root.formatCurrencyAmount(root.fiatValue, root.currentCurrency))
                                              .arg(root.formatCurrencyAmount(root.swapFiatValue, root.currentCurrency))
                        case TransactionDelegate.TransactionType.Bridge:
                            return "-" + root.formatCurrencyAmount(root.feeFiatValue, root.currentCurrency)
                        default:
                            return ""
                        }
                    }
                    font.pixelSize: root.loading ? d.loadingPixelSize : 12
                    customColor: Theme.palette.baseColor1
                    loading: root.loading
                }
            }
        },
        Loader {
            id: headerStatusLoader
            active: false
            visible: active
            sourceComponent: Rectangle {
                id: statusRect
                width: transactionTypeIcon.width + (retryButton.visible ? retryButton.width + 5 : 0)
                height: transactionTypeIcon.height
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"
                radius: 100
                border {
                    width: retryButton.visible ? 1 : 0
                    color: root.asset.bgBorderColor
                }

                StatusButton {
                    id: retryButton
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 10
                    radius: height / 2
                    height: parent.height * 0.7
                    verticalPadding: 0
                    horizontalPadding: radius
                    textFillWidth: true
                    text: qsTr("Retry")
                    size: StatusButton.Small
                    type: StatusButton.Primary
                    visible: !root.loading && root.transactionStatus === TransactionDelegate.Failed
                    onClicked: root.retryClicked()
                }

                StatusSmartIdenticon {
                    id: transactionTypeIcon
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    enabled: false
                    asset: root.asset
                    active: !!root.asset.name
                    loading: root.loading
                    name: root.title
                }
                StatusRoundIcon {
                    visible: !root.loading
                    anchors {
                        right: transactionTypeIcon.right
                        bottom: transactionTypeIcon.bottom
                    }
                    asset: root.statusIconAsset
                }
            }
        }
    ]

    states: [
        State {
            name: "header"
            PropertyChanges {
                target: headerStatusLoader
                active: true
            }
            PropertyChanges {
                target: leftIconStatusIcon
                visible: false
            }
            PropertyChanges {
                target: root.statusListItemIcon
                active: false
            }
            PropertyChanges {
                target: root.asset
                bgBorderWidth: root.transactionStatus === TransactionDelegate.Failed ? 0 : 1
                width: 34
                height: 34
                bgWidth: 56
                bgHeight: 56
            }
            PropertyChanges {
                target: root.statusIconAsset
                width: 17
                height: 17
            }
            PropertyChanges {
                target: root.tokenIconAsset
                width: 20
                height: 20
            }
            PropertyChanges {
                target: d
                titlePixelSize: 17
                datePixelSize: 13
                subtitlePixelSize: 15
                loadingPixelSize: 14
            }
        }
    ]
}
