import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

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

    required property string fromTokenSymbol
    required property string fromTokenAmount
    required property string fromTokenContractAddress

    required property string accountName
    required property string accountAddress
    required property string accountEmoji
    required property color accountColor

    /** TODO: Use new recipients appraoch from
    https://github.com/status-im/status-desktop/issues/16916 **/
    required property string recipientAddress

    required property string networkShortName // e.g. "oeth"
    required property string networkName // e.g. "Optimism"
    required property string networkIconPath // e.g. `Theme.svg("network/Network=Optimism")`
    required property string networkBlockExplorerUrl

    required property string fiatFees
    required property string cryptoFees
    required property string estimatedTime

    required property string collectibleContractAddress
    required property string collectibleTokenId
    required property string collectibleName
    required property string collectibleBackgroundColor
    required property bool collectibleIsMetadataValid
    required property string collectibleMediaUrl
    required property string collectibleMediaType
    required property string collectibleFallbackImageUrl

    required property var fnGetOpenSeaExplorerUrl

    title: qsTr("Sign Send")
    //: e.g. (Send) 100 DAI to batista.eth
    subtitle: {
        const tokenToSend = root.isCollectible ?
                              root.collectibleName:
                              formatBigNumber(fromTokenAmount, fromTokenSymbol)
        return qsTr("%1 to %2").
        arg(tokenToSend).
        arg(SQUtils.Utils.elideAndFormatWalletAddress(root.recipientAddress))
    }

    gradientColor: root.accountColor
    fromImageSmartIdenticon.asset.name: "filled-account"
    fromImageSmartIdenticon.asset.emoji: root.accountEmoji
    fromImageSmartIdenticon.asset.color: root.accountColor
    fromImageSmartIdenticon.asset.isLetterIdenticon: !!root.accountEmoji

    fromAccountSmartIdenticon.asset.name: "filled-account"
    fromAccountSmartIdenticon.asset.emoji: root.accountEmoji
    fromAccountSmartIdenticon.asset.color: root.accountColor
    fromAccountSmartIdenticon.asset.isLetterIdenticon: !!root.accountEmoji
    fromAccountSmartIdenticon.asset.isImage: root.isCollectible

    toImageSource: Constants.tokenIcon(root.fromTokenSymbol)

    collectibleMedia.backgroundColor: root.collectibleBackgroundColor
    collectibleMedia.isMetadataValid: root.collectibleIsMetadataValid
    collectibleMedia.mediaUrl: root.collectibleMediaUrl
    collectibleMedia.mediaType: root.collectibleMediaType
    collectibleMedia.fallbackImageUrl: root.collectibleFallbackImageUrl

    //: e.g. "Send 100 DAI to recipient on <network chain name>"
    headerMainText: {
        const tokenToSend = root.isCollectible ?
                              root.collectibleName:
                              formatBigNumber(fromTokenAmount, fromTokenSymbol)
        return qsTr("Send %1 to %2 on %3").arg(tokenToSend)
        .arg(SQUtils.Utils.elideAndFormatWalletAddress(root.recipientAddress)).arg(root.networkName)
    }
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
        bridgeBadge.color: Theme.palette.darkBlue
        bridgeBadge.image.source: Theme.svg("sign")
    }

    leftFooterContents: ObjectModel {
        RowLayout {
            Layout.leftMargin: 4
            spacing: Theme.bigPadding
            ColumnLayout {
                spacing: 2
                StatusBaseText {
                    text: qsTr("Est time")
                    color: Theme.palette.baseColor1
                    font.pixelSize: Theme.additionalTextSize
                }
                StatusTextWithLoadingState {
                    objectName: "footerEstTimeText"
                    text: loading ? Constants.dummyText : root.estimatedTime
                    loading: root.feesLoading
                }
            }
            ColumnLayout {
                spacing: 2
                StatusBaseText {
                    text: qsTr("Max fees")
                    color: Theme.palette.baseColor1
                    font.pixelSize: Theme.additionalTextSize
                }
                StatusTextWithLoadingState {
                    objectName: "footerFiatFeesText"
                    text: loading ? Constants.dummyText : root.fiatFees
                    loading: root.feesLoading
                }
            }
        }
    }

    // Send Asset
    SignInfoBox {
        objectName: "sendAssetBox"
        Layout.fillWidth: true
        Layout.bottomMargin: Theme.bigPadding
        caption: qsTr("Send")
        primaryText: formatBigNumber(root.fromTokenAmount, root.fromTokenSymbol)
        secondaryText: root.fromTokenSymbol !== Constants.ethToken ?
                           SQUtils.Utils.elideAndFormatWalletAddress(root.fromTokenContractAddress) : ""
        icon: Constants.tokenIcon(root.fromTokenSymbol)
        badge: root.networkIconPath
        highlighted: contractInfoButtonWithMenu.hovered
        components: [
            ContractInfoButtonWithMenu {
                id: contractInfoButtonWithMenu

                objectName: "contractInfoButtonWithMenu"
                visible: root.fromTokenSymbol !== Constants.ethToken
                symbol: root.fromTokenSymbol
                contractAddress: root.fromTokenContractAddress
                networkName: root.networkName
                networkShortName: root.networkShortName
                networkBlockExplorerUrl: root.networkBlockExplorerUrl
                onOpenLink: (link) => root.openLinkWithConfirmation(link)
            }
        ]
        visible: !root.isCollectible
    }

    // Send Collectible
    ColumnLayout {
        objectName: "sendCollectibleBox"
        StatusBaseText {
            objectName: "collectibleCaption"
            text: qsTr("Send")
            font.pixelSize: Theme.additionalTextSize
        }
        SignCollectibleInfoBox {
            Layout.fillWidth: true
            Layout.bottomMargin: Theme.bigPadding
            name: !!root.collectibleName ? root.collectibleName: qsTr("Unknown")
            backgroundColor: root.collectibleBackgroundColor
            isMetadataValid: root.collectibleIsMetadataValid
            fallbackImageUrl: root.collectibleFallbackImageUrl
            contractAddress: root.collectibleContractAddress
            tokenId: root.collectibleTokenId
            networkShortName: root.networkShortName
            networkBlockExplorerUrl: root.networkBlockExplorerUrl
            openSeaExplorerUrl: root.fnGetOpenSeaExplorerUrl(root.networkShortName)
            onOpenLink: (link) => root.openLinkWithConfirmation(link)
        }
        visible: root.isCollectible
    }

    // From
    SignInfoBox {
        Layout.fillWidth: true
        Layout.bottomMargin: Theme.bigPadding
        objectName: "accountBox"
        caption: qsTr("From")
        primaryText: root.accountName
        secondaryText: SQUtils.Utils.elideAndFormatWalletAddress(root.accountAddress)
        asset.name: "filled-account"
        asset.emoji: root.accountEmoji
        asset.color: root.accountColor
        asset.isLetterIdenticon: !!root.accountEmoji
    }

    /** TODO: Use new recipients appraoch from
    https://github.com/status-im/status-desktop/issues/16916 **/
    // To
    SignInfoBox {
        Layout.fillWidth: true
        Layout.bottomMargin: Theme.bigPadding
        objectName: "recipientBox"
        caption: qsTr("To")
        primaryText: root.recipientAddress
        asset.name: "address"
        asset.isLetterIdenticon: false
        asset.isImage: false
        highlighted: recipientInfoButtonWithMenu.hovered
        components: [
            RecipientInfoButtonWithMenu {
                id: recipientInfoButtonWithMenu

                objectName: "recipientInfoButtonWithMenu"
                recipientAddress: root.recipientAddress
                networkName: root.networkName
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
