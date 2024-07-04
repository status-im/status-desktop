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

import AppLayouts.Wallet 1.0
import AppLayouts.Wallet.panels 1.0
import AppLayouts.Wallet.popups 1.0

import shared.controls 1.0
import utils 1.0

SignTransactionModalBase {
    id: root

    required property string fromTokenSymbol
    required property string fromTokenAmount
    required property string fromTokenContractAddress

    required property string accountName
    required property string accountAddress
    required property string accountEmoji
    required property color accountColor
    required property string accountBalanceAmount

    required property string networkShortName // e.g. "oeth"
    required property string networkName // e.g. "Optimism"
    required property string networkIconPath // e.g. `Style.svg("network/Network=Optimism")`
    required property string networkBlockExplorerUrl

    required property string currentCurrency
    required property string fiatFees
    required property string cryptoFees
    // need to check how this is done in new router, right now it is Enum type
    required property int estimatedTime // Constants.TransactionEstimatedTime.XXX enum

    property string serviceProviderName: "Paraswap"
    property string serviceProviderURL: Constants.swap.paraswapUrl // TODO https://github.com/status-im/status-desktop/issues/15329
    property string serviceProviderContractAddress: "0x1bD435F3C054b6e901B7b108a0ab7617C808677b"

    title: qsTr("Approve spending cap")
    subtitle: serviceProviderURL

    gradientColor: Utils.setColorAlpha(root.accountColor, 0.05) // 5% of wallet color
    fromImageSmartIdenticon.asset.name: "filled-account"
    fromImageSmartIdenticon.asset.emoji: root.accountEmoji
    fromImageSmartIdenticon.asset.color: root.accountColor
    fromImageSmartIdenticon.asset.isLetterIdenticon: !!root.accountEmoji
    toImageSource: Constants.tokenIcon(root.fromTokenSymbol)

    //: e.g. "Set 100 DAI spending cap in <account name> for <service> on <network name>"
    headerMainText: qsTr("Set %1 %2 spending cap in %3 for %4 on %5").arg(formatBigNumber(root.fromTokenAmount)).arg(root.fromTokenSymbol)
        .arg(root.accountName).arg(root.serviceProviderURL).arg(root.networkName)
    headerSubTextLayout: [
        StatusBaseText {
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.pixelSize: Style.current.additionalTextSize
            text: qsTr("The smart contract specified will be able to spend up to %1 %2 of your current or future balance.").arg(formatBigNumber(root.fromTokenAmount)).arg(root.fromTokenSymbol)
        }
    ]

    headerIconComponent: StatusSmartIdenticon {
        asset.name: Style.png("swap/paraswap") // FIXME svg
        asset.isImage: true
        asset.bgWidth: 40
        asset.bgHeight: 40
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
                    text: "%1 %2".arg(formatBigNumber(root.fiatFees)).arg(root.currentCurrency)
                    loading: root.feesLoading
                }
            }
            ColumnLayout {
                spacing: 2
                StatusBaseText {
                    text: qsTr("Est. time:")
                    color: Theme.palette.baseColor1
                    font.pixelSize: Style.current.additionalTextSize
                }
                StatusTextWithLoadingState {
                    objectName: "footerEstimatedTime"
                    text: WalletUtils.getLabelForEstimatedTxTime(root.estimatedTime)
                    loading: root.feesLoading
                }
            }
        }
    }

    // spending cap
    SignInfoBox {
        Layout.fillWidth: true
        Layout.bottomMargin: Style.current.bigPadding
        objectName: "spendingCapBox"
        caption: qsTr("Set spending cap")
        primaryText: formatBigNumber(root.fromTokenAmount)
        listItemHeight: 44
        components: [
            StatusSmartIdenticon {
                asset.name: Constants.tokenIcon(root.fromTokenSymbol)
                asset.isImage: true
                asset.width: 20
                asset.height: 20
            },
            StatusBaseText {
                text: root.fromTokenSymbol
            }
        ]
    }

    // Account
    SignInfoBox {
        Layout.fillWidth: true
        Layout.bottomMargin: Style.current.bigPadding
        objectName: "accountBox"
        caption: qsTr("Account")
        primaryText: root.accountName
        secondaryText: SQUtils.Utils.elideAndFormatWalletAddress(root.accountAddress)
        asset.name: "filled-account"
        asset.emoji: root.accountEmoji
        asset.color: root.accountColor
        asset.isLetterIdenticon: !!root.accountEmoji
        components: [
            InformationTag {
                tagPrimaryLabel.text: "%1 %2".arg(formatBigNumber(root.accountBalanceAmount, 2)).arg(root.fromTokenSymbol)
                rightComponent: StatusRoundedImage {
                    width: 16
                    height: 16
                    image.source: root.networkIconPath
                }
            }
        ]
    }

    // Token
    SignInfoBox {
        Layout.fillWidth: true
        Layout.bottomMargin: Style.current.bigPadding
        objectName: "tokenBox"
        caption: qsTr("Token")
        primaryText: root.fromTokenSymbol
        secondaryText: SQUtils.Utils.elideAndFormatWalletAddress(root.fromTokenContractAddress)
        icon: Constants.tokenIcon(root.fromTokenSymbol)
        badge: root.networkIconPath
        components: [
            ContractInfoButtonWithMenu {
                symbol: root.fromTokenSymbol
                contractAddress: root.fromTokenContractAddress
                networkName: root.networkName
                networkShortName: root.networkShortName
                networkBlockExplorerUrl: root.networkBlockExplorerUrl
                onOpenLink: (link) => root.openLinkWithConfirmation(link)
            }
        ]
    }

    // Smart contract
    SignInfoBox {
        Layout.fillWidth: true
        Layout.bottomMargin: Style.current.bigPadding
        objectName: "smartContractBox"
        caption: qsTr("Via smart contract")
        primaryText: root.serviceProviderName
        secondaryText: SQUtils.Utils.elideAndFormatWalletAddress(root.serviceProviderContractAddress)
        icon: Style.png("swap/paraswap") // FIXME svg
        components: [
            ContractInfoButtonWithMenu {
                symbol: ""
                contractAddress: root.serviceProviderContractAddress
                networkName: root.serviceProviderName
                networkShortName: root.networkShortName
                networkBlockExplorerUrl: root.networkBlockExplorerUrl
                onOpenLink: (link) => root.openLinkWithConfirmation(link)
            }
        ]
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
        secondaryText: " "
        components: [
            ColumnLayout {
                spacing: 2
                StatusTextWithLoadingState {
                    objectName: "fiatFeesText"
                    Layout.alignment: Qt.AlignRight
                    text: "%1 %2".arg(formatBigNumber(root.fiatFees)).arg(root.currentCurrency)
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: Style.current.additionalTextSize
                    loading: root.feesLoading
                }
                StatusTextWithLoadingState {
                    objectName: "cryptoFeesText"
                    Layout.alignment: Qt.AlignRight
                    text: "%1 ETH".arg(formatBigNumber(root.cryptoFees))
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: Style.current.additionalTextSize
                    customColor: Theme.palette.baseColor1
                    loading: root.feesLoading
                }
            }
        ]
    }
}
