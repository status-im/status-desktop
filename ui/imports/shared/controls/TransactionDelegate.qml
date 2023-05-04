import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared 1.0
import shared.stores 1.0

StatusListItem {
    id: root

    property var modelData
    property string symbol
    property bool isPending: true
    property int transactionType
    property int transactionStatus
    property string currentCurrency
    // TODO investigate
    property int transferStatus
    property double cryptoValue
    property double fiatValue
    property string networkIcon
    property string networkColor
    property string networkName
    property string timeStampText
    property string savedAddressNameTo
    property string savedAddressNameFrom
    property bool isSummary: false

    readonly property bool isModelDataValid: modelData !== undefined && !!modelData
    readonly property bool isNFT: isModelDataValid && modelData.isNFT
    // TODO rename name to something else
    readonly property string name: {
        if (!isModelDataValid)
            return "N/A"
        if (root.isNFT) {
            return modelData.nftName ? modelData.nftName : "#" + modelData.tokenID
        } else {
            return RootStore.formatCurrencyAmount(cryptoValue, symbol)
        }
    }

    // TODO rename
    readonly property string image: {
        if (!isModelDataValid)
            return ""
        if (root.isNFT) {
            return modelData.nftImageUrl ? modelData.nftImageUrl : ""
        } else {
            return root.symbol ? Style.png("tokens/%1".arg(root.symbol)) : ""
        }
    }

    readonly property string toAddress: !!savedAddressNameTo ?
                                            savedAddressNameTo :
                                            isModelDataValid ?
                                                Utils.compactAddress(modelData.to, 4) :
                                                ""

    readonly property string fromAddress: !!savedAddressNameFrom ?
                                            savedAddressNameFrom :
                                            isModelDataValid ?
                                                Utils.compactAddress(modelData.from, 4) :
                                                ""

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
        VerifyGreen,
        VerifyBlue
    }

    state: "normal"
    enabled: !loading
    color: sensor.containsMouse ? Theme.palette.baseColor5 : Theme.palette.statusListItem.backgroundColor

    statusListItemIcon.active: isSummary && (loading || root.asset.name)
    asset {
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
                return "destroy" // TODO test asset
            case TransactionDelegate.TransactionType.Swap:
                return "swap"
            case TransactionDelegate.TransactionType.Bridge:
                return "bridge"
            default:
                return ""
            }
        }
        bgColor: "transparent"
        color: Theme.palette.black
        borderWidth: 1
        bgBorderColor: Theme.palette.primaryColor3
    }

    // Title
    title: {
        if (!root.isModelDataValid)
            return ""

        switch(root.transactionType) {
        case TransactionDelegate.TransactionType.Send:
            return root.isPending ? qsTr("Receiving") : qsTr("Received")
        case TransactionDelegate.TransactionType.Receive:
            return root.isPending ? qsTr("Sending") : qsTr("Sent")
        case TransactionDelegate.TransactionType.Buy:
            return root.isPending ? qsTr("Buying") : qsTr("Bought")
        case TransactionDelegate.TransactionType.Sell:
            return root.isPending ? qsTr("Selling") : qsTr("Sold")
        case TransactionDelegate.TransactionType.Destroy:
            return root.isPending ? qsTr("Destroying") : qsTr("Destroyed")
        case TransactionDelegate.TransactionType.Swap:
            return root.isPending ? qsTr("Swapping") : qsTr("Swapped")
        case TransactionDelegate.TransactionType.Bridge:
            return root.isPending ? qsTr("Bridging") : qsTr("Bridged")
        default:
            return ""
        }
    }
    statusListItemTitle.font.weight: Font.DemiBold

    // title icons and date
    statusListItemTitleIcons.sourceComponent: Row {
        spacing: 8
        StatusSmartIdenticon {
            anchors.verticalCenter: parent.verticalCenter
            asset: StatusAssetSettings {
                width: 18
                height: 18
                isImage: !loading
                name: root.image
                isLetterIdenticon: loading
            }
            active: loading || !!asset.name
            badge.border.color: root.color
            ringSettings: root.ringSettings
            loading: root.loading
        }
        StatusTextWithLoadingState {
            anchors.verticalCenter: parent.verticalCenter
            text: root.timeStampText
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: 12
            visible: !!text
            loading: root.loading
            customColor: Theme.palette.baseColor1
        }
    }

    // subtitle
    subTitle: {
        switch(root.transactionType) {
        case TransactionDelegate.TransactionType.Receive:
            return qsTr("%1 to %2 via %3").arg(name).arg(toAddress).arg(networkName)
        case TransactionDelegate.TransactionType.Buy:
        case TransactionDelegate.TransactionType.Sell:
            return qsTr("%1 on %2 via %3").arg(name).arg(toAddress).arg(networkName)
        case TransactionDelegate.TransactionType.Destroy:
            return qsTr("%1 at %2 via %3").arg(name).arg(toAddress).arg(networkName)
        case TransactionDelegate.TransactionType.Swap:
            // TODO second argument use swapped currency
            return qsTr("%1 to %2 via %3").arg(name).arg(name).arg(networkName)
        case TransactionDelegate.TransactionType.Bridge:
            // TODO use bridge network name
            return qsTr("%1 from %2 to %3").arg(name).arg(networkName).arg(networkName)
        default:
            return qsTr("%1 to %2 via %3").arg(name).arg(toAddress).arg(networkName)
        }
    }
    statusListItemSubTitle.customColor: Theme.palette.directColor1
    statusListItemSubTitle.font.pixelSize: 13
    statusListItemTagsRowLayout.anchors.topMargin: 4 // Spacing between title row nad subtitle row

    // Right side components
    components: [
        Item { // Padding
            width: 12
            height: parent.height
        },
        ColumnLayout {
            visible: !root.isNFT && root.isSummary
            StatusTextWithLoadingState {
                id: cryptoValueText
                text: {
                    switch(root.transactionType) {
                    case TransactionDelegate.TransactionType.Send:
                    case TransactionDelegate.TransactionType.Sell:
                        return "-" + RootStore.formatCurrencyAmount(cryptoValue, root.symbol)
                    case TransactionDelegate.TransactionType.Buy:
                    case TransactionDelegate.TransactionType.Receive:
                        return "+" + RootStore.formatCurrencyAmount(cryptoValue, root.symbol)
                    case TransactionDelegate.TransactionType.Swap:
                        // TODO use swapped crypto instead for second argument
                        return String("<font color=\"%1\">-%2</font> <font color=\"%3\">/</font> <font color=\"%4\">+%5</font>")
                                      .arg(Theme.palette.directColor1)
                                      .arg(RootStore.formatCurrencyAmount(cryptoValue, root.symbol))
                                      .arg(Theme.palette.baseColor1)
                                      .arg(Theme.palette.successColor1)
                                      .arg(RootStore.formatCurrencyAmount(cryptoValue, root.symbol))
                    case TransactionDelegate.TransactionType.Bridge:
                        // TODO use fee value
                        return "-" + RootStore.formatCurrencyAmount(cryptoValue, root.symbol)
                    default:
                        return ""
                    }
                }
                horizontalAlignment: Qt.AlignRight
                Layout.alignment: Qt.AlignRight
                Binding on width {
                    when: root.loading
                    value: 111
                    restoreMode: Binding.RestoreBindingOrValue
                }
                font.pixelSize: 13
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
                    switch(root.transactionType) {
                    case TransactionDelegate.TransactionType.Send:
                    case TransactionDelegate.TransactionType.Sell:
                    case TransactionDelegate.TransactionType.Buy:
                        return "-" + RootStore.formatCurrencyAmount(fiatValue, root.symbol)
                    case TransactionDelegate.TransactionType.Receive:
                        return "+" + RootStore.formatCurrencyAmount(fiatValue, root.symbol)
                    case TransactionDelegate.TransactionType.Swap:
                        // TOOD use swapped fiat instead for second argument
                        return String("-%1 / +%2").arg(RootStore.formatCurrencyAmount(fiatValue, root.symbol))
                                                  .arg(RootStore.formatCurrencyAmount(fiatValue, root.symbol))
                    case TransactionDelegate.TransactionType.Bridge:
                        // TODO use fee value
                        return "-" + RootStore.formatCurrencyAmount(fiatValue, root.symbol)
                    default:
                        return ""
                    }
                }
                font.pixelSize: 12
                customColor: Theme.palette.baseColor1
                loading: root.loading
            }
        }
    ]
}
