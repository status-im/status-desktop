import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import AppLayouts.Wallet.panels 1.0
import AppLayouts.Wallet.popups 1.0

import utils 1.0

SignTransactionModalBase {
    id: root

    required property var currencyStore

    required property string fromTokenSymbol
    required property string fromTokenAmount
    required property string fromTokenContractAddress

    required property string toTokenSymbol
    required property string toTokenAmount
    required property string toTokenContractAddress

    required property string accountName
    required property string accountAddress
    required property string accountEmoji
    required property color accountColor

    required property string networkShortName // e.g. "oeth"
    required property string networkName // e.g. "Optimism"
    required property string networkIconPath // e.g. `Style.svg("network/Network=Optimism")`
    required property string networkBlockExplorerUrl

    required property string fiatFees
    required property string cryptoFees
    required property double slippage

    required property string serviceProviderName
    required property string serviceProviderURL

    title: qsTr("Sign Swap")
    //: e.g. (swap) 100 DAI to 100 USDT
    subtitle: qsTr("%1 to %2")
    .arg(root.currencyStore.formatCurrencyAmount(fromTokenAmount, fromTokenSymbol))
    .arg(root.currencyStore.formatCurrencyAmount(toTokenAmount, toTokenSymbol))

    gradientColor: Utils.setColorAlpha(root.accountColor, 0.05) // 5% of wallet color
    fromImageSource: Constants.tokenIcon(root.fromTokenSymbol)
    toImageSource: Constants.tokenIcon(root.toTokenSymbol)

    //: e.g. "Swap 100 DAI to 100 USDT in <account name> on <network chain name>"
    headerMainText: qsTr("Swap %1 %2 to %3 %4 in %5 on %6").arg(formatBigNumber(root.fromTokenAmount)).arg(root.fromTokenSymbol)
        .arg(formatBigNumber(root.toTokenAmount)).arg(root.toTokenSymbol).arg(root.accountName).arg(root.networkName)
    headerSubTextLayout: [
        StatusBaseText {
            font.pixelSize: Style.current.additionalTextSize
            text: qsTr("Powered by")
        },
        StatusLinkText {
            Layout.topMargin: 1 // compensate for the underline
            text: root.serviceProviderName
            normalColor: Theme.palette.directColor1
            linkColor: Theme.palette.directColor1
            font.weight: Font.Normal
            onClicked: root.openLinkWithConfirmation(root.serviceProviderURL)
        },
        StatusIcon {
            Layout.leftMargin: -2
            width: 16
            height: 16
            icon: "external-link"
            color: Theme.palette.directColor1
        }
    ]
    infoTagText: qsTr("Review all details before signing")

    headerIconComponent: StatusSmartIdenticon {
        asset.name: "filled-account"
        asset.emoji: root.accountEmoji
        asset.color: root.accountColor
        asset.isLetterIdenticon: !!root.accountEmoji
        asset.bgWidth: 40
        asset.bgHeight: 40

        bridgeBadge.visible: true
        bridgeBadge.border.width: 2
        bridgeBadge.color: Style.current.darkBlue
        bridgeBadge.image.source: Style.svg("sign")
    }

    leftFooterContents: ObjectModel {
        RowLayout {
            Layout.leftMargin: 4
            spacing: Style.current.bigPadding
            ColumnLayout {
                spacing: 2
                StatusBaseText {
                    text: qsTr("Max fees:")
                    color: Theme.palette.baseColor1
                    font.pixelSize: Style.current.additionalTextSize
                }
                StatusTextWithLoadingState {
                    objectName: "footerFiatFeesText"
                    text: loading ? Constants.dummyText : root.fiatFees
                    loading: root.feesLoading
                }
            }
            ColumnLayout {
                spacing: 2
                StatusBaseText {
                    text: qsTr("Max slippage:")
                    color: Theme.palette.baseColor1
                    font.pixelSize: Style.current.additionalTextSize
                }
                StatusBaseText {
                    objectName: "footerMaxSlippageText"
                    text: "%1%".arg(LocaleUtils.numberToLocaleString(root.slippage))
                }
            }
        }
    }

    // Pay
    SignInfoBox {
        Layout.fillWidth: true
        Layout.bottomMargin: Style.current.bigPadding
        objectName: "payBox"
        caption: qsTr("Pay")
        primaryText: "%1 %2".arg(formatBigNumber(root.fromTokenAmount)).arg(root.fromTokenSymbol)
        secondaryText: root.fromTokenSymbol !== Constants.ethToken ? SQUtils.Utils.elideAndFormatWalletAddress(root.fromTokenContractAddress) : ""
        icon: Constants.tokenIcon(root.fromTokenSymbol)
        badge: root.networkIconPath
        components: [
            ContractInfoButtonWithMenu {
                visible: root.fromTokenSymbol !== Constants.ethToken
                symbol: root.fromTokenSymbol
                contractAddress: root.fromTokenContractAddress
                networkName: root.networkName
                networkShortName: root.networkShortName
                networkBlockExplorerUrl: root.networkBlockExplorerUrl
                onOpenLink: (link) => root.openLinkWithConfirmation(link)
            }
        ]
    }

    // Receive
    SignInfoBox {
        Layout.fillWidth: true
        Layout.bottomMargin: Style.current.bigPadding
        objectName: "receiveBox"
        caption: qsTr("Receive")
        primaryText: "%1 %2".arg(formatBigNumber(root.toTokenAmount)).arg(root.toTokenSymbol)
        secondaryText: root.toTokenSymbol !== Constants.ethToken ? SQUtils.Utils.elideAndFormatWalletAddress(root.toTokenContractAddress) : ""
        icon: Constants.tokenIcon(root.toTokenSymbol)
        badge: root.networkIconPath
        components: [
            ContractInfoButtonWithMenu {
                visible: root.toTokenSymbol !== Constants.ethToken
                symbol: root.toTokenSymbol
                contractAddress: root.toTokenContractAddress
                networkName: root.networkName
                networkShortName: root.networkShortName
                networkBlockExplorerUrl: root.networkBlockExplorerUrl
                onOpenLink: (link) => root.openLinkWithConfirmation(link)
            }
        ]
    }

    // Account
    SignInfoBox {
        Layout.fillWidth: true
        Layout.bottomMargin: Style.current.bigPadding
        objectName: "accountBox"
        caption: qsTr("In account")
        primaryText: root.accountName
        secondaryText: SQUtils.Utils.elideAndFormatWalletAddress(root.accountAddress)
        asset.name: "filled-account"
        asset.emoji: root.accountEmoji
        asset.color: root.accountColor
        asset.isLetterIdenticon: !!root.accountEmoji
    }

    // Network
    SignInfoBox {
        Layout.fillWidth: true
        Layout.bottomMargin: Style.current.bigPadding
        objectName: "networkBox"
        caption: qsTr("Network")
        primaryText: root.networkName
        icon: root.networkIconPath
    }

    // Fees
    SignInfoBox {
        Layout.fillWidth: true
        Layout.bottomMargin: Style.current.bigPadding
        objectName: "feesBox"
        caption: qsTr("Fees")
        primaryText: qsTr("Max. fees on %1").arg(root.networkName)
        primaryTextCustomColor: Theme.palette.baseColor1
        secondaryText: " "
        components: [
            ColumnLayout {
                spacing: 2
                StatusTextWithLoadingState {
                    objectName: "fiatFeesText"
                    Layout.alignment: Qt.AlignRight
                    text: loading ? Constants.dummyText : root.fiatFees
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: Style.current.additionalTextSize
                    loading: root.feesLoading
                }
                StatusTextWithLoadingState {
                    objectName: "cryptoFeesText"
                    Layout.alignment: Qt.AlignRight
                    text: loading ? Constants.dummyText : root.cryptoFees
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: Style.current.additionalTextSize
                    customColor: Theme.palette.baseColor1
                    loading: root.feesLoading
                }
            }
        ]
    }
}
