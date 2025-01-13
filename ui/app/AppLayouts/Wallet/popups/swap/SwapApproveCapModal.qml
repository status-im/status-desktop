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
import AppLayouts.Wallet.controls 1.0

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
    required property string accountBalanceFormatted

    required property string networkShortName // e.g. "oeth"
    required property string networkName // e.g. "Optimism"
    required property string networkIconPath // e.g. `Theme.svg("network/Network=Optimism")`
    required property string networkBlockExplorerUrl

    required property string fiatFees
    required property string cryptoFees
    // need to check how this is done in new router, right now it is Enum type
    required property int estimatedTime // Constants.TransactionEstimatedTime.XXX enum

    property string serviceProviderName: Constants.swap.paraswapName
    property string serviceProviderHostname: Constants.swap.paraswapHostname
    property string serviceProviderTandCUrl: Constants.swap.paraswapTermsAndConditionUrl
    property string serviceProviderURL: Constants.swap.paraswapUrl // TODO https://github.com/status-im/status-desktop/issues/15329
    property string serviceProviderContractAddress: Constants.swap.paraswapV6_2ContractAddress
    property string serviceProviderIcon: Theme.png("swap/%1".arg(Constants.swap.paraswapIcon)) // FIXME svg

    title: qsTr("Approve spending cap")
    subtitle: root.serviceProviderHostname

    gradientColor: root.accountColor
    fromImageSmartIdenticon.asset.name: "filled-account"
    fromImageSmartIdenticon.asset.emoji: root.accountEmoji
    fromImageSmartIdenticon.asset.color: root.accountColor
    fromImageSmartIdenticon.asset.isLetterIdenticon: !!root.accountEmoji
    toImageSource: Constants.tokenIcon(root.fromTokenSymbol)

    //: e.g. "Set 100 DAI spending cap in <account name> for <service> on <network name>"
    headerMainText: qsTr("Set %1 spending cap in %2 for %3 on %4").arg(formatBigNumber(root.fromTokenAmount, root.fromTokenSymbol))
        .arg(root.accountName).arg(root.serviceProviderHostname).arg(root.networkName)
    headerSubTextLayout: [
        ColumnLayout {
            spacing: 12
            StatusBaseText {
                Layout.fillWidth: true
                horizontalAlignment: Qt.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: Theme.additionalTextSize
                text: qsTr("The smart contract specified will be able to spend up to %1 of your current or future balance.").arg(formatBigNumber(root.fromTokenAmount, root.fromTokenSymbol))
            }
            SwapProvidersTermsAndConditionsText {
                serviceProviderName: root.serviceProviderName
                onLinkClicked: root.openLinkWithConfirmation(root.serviceProviderURL)
                onTermsAndConditionClicked: root.openLinkWithConfirmation(root.serviceProviderTandCUrl)
            }
        }
    ]

    infoTagText: qsTr("Review all details before signing")

    headerIconComponent: StatusSmartIdenticon {
        asset.name: root.serviceProviderIcon
        asset.isImage: true
        asset.bgWidth: 40
        asset.bgHeight: 40
    }

    leftFooterContents: ObjectModel {
        RowLayout {
            Layout.leftMargin: 4
            spacing: Theme.bigPadding
            ColumnLayout {
                spacing: 2
                StatusBaseText {
                    text: qsTr("Max fees:")
                    color: Theme.palette.baseColor1
                    font.pixelSize: Theme.additionalTextSize
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
                    text: qsTr("Est. time:")
                    color: Theme.palette.baseColor1
                    font.pixelSize: Theme.additionalTextSize
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
        Layout.bottomMargin: Theme.bigPadding
        objectName: "spendingCapBox"
        caption: qsTr("Set spending cap")
        primaryText: formatBigNumber(root.fromTokenAmount, root.fromTokenSymbol, true)
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
        Layout.bottomMargin: Theme.bigPadding
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
                tagPrimaryLabel.text: root.accountBalanceFormatted
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
        Layout.bottomMargin: Theme.bigPadding
        objectName: "tokenBox"
        caption: qsTr("Token")
        primaryText: root.fromTokenSymbol
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

    // Smart contract
    SignInfoBox {
        Layout.fillWidth: true
        Layout.bottomMargin: Theme.bigPadding
        objectName: "smartContractBox"
        caption: qsTr("Via smart contract")
        primaryText: root.serviceProviderName
        secondaryText: SQUtils.Utils.elideAndFormatWalletAddress(root.serviceProviderContractAddress)
        icon: root.serviceProviderIcon
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
        Layout.bottomMargin: Theme.bigPadding
        objectName: "networkBox"
        caption: qsTr("Network")
        primaryText: root.networkName
        icon: root.networkIconPath
    }

    // Fees
    SignInfoBox {
        Layout.fillWidth: true
        Layout.bottomMargin: Theme.bigPadding
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
                    font.pixelSize: Theme.additionalTextSize
                    loading: root.feesLoading
                }
                StatusTextWithLoadingState {
                    objectName: "cryptoFeesText"
                    Layout.alignment: Qt.AlignRight
                    text: loading ? Constants.dummyText : root.cryptoFees
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: Theme.additionalTextSize
                    customColor: Theme.palette.baseColor1
                    loading: root.feesLoading
                }
            }
        ]
    }
}
