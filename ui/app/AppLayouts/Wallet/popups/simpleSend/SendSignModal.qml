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

    /** Input property holding selected token symbol **/
    required property string tokenSymbol
    /** Input property holding selected token amount **/
    required property string tokenAmount
    /** Input property holding selected token contract address **/
    required property string tokenContractAddress

    /** Input property holding selected account name **/
    required property string accountName
    /** Input property holding selected account address **/
    required property string accountAddress
    /** Input property holding selected account emoji **/
    required property string accountEmoji
    /** Input property holding selected account color **/
    required property color accountColor

    /** TODO: Use new recipients appraoch from
    https://github.com/status-im/status-desktop/issues/16916 **/
    required property string recipientAddress

    /** Input property holding selected network short name **/
    required property string networkShortName
    /** Input property holding selected network name **/
    required property string networkName
    /** Input property holding selected network icon path
    e.g. `Theme.svg("network/Network=Optimism")`**/
    required property string networkIconPath
    /** Input property holding selected network blockchain
    explorer name **/
    required property string networkBlockExplorerUrl

    /** Input property holding localised path fees in fiat **/
    required property string fiatFees
    /** Input property holding localised path fees in crypto **/
    required property string cryptoFees
    /** Input property holding localised path estimate time **/
    required property string estimatedTime

    /** Input property holding selected collectible name **/
    required property string collectibleName
    /** Input property holding selected collectible token id **/
    required property string collectibleTokenId
    /** Input property holding selected collectible media url **/
    required property string collectibleMediaUrl
    /** Input property holding selected collectible media type **/
    required property string collectibleMediaType
    /** Input property holding selected collectible fallback media url **/
    required property string collectibleFallbackImageUrl
    /** Input property holding selected collectible contract address **/
    required property string collectibleContractAddress
    /** Input property holding selected collectible background color **/
    required property string collectibleBackgroundColor
    /** Input property holding selected if collectible meta data is valid **/
    required property bool collectibleIsMetadataValid

    /** Input property holding function openSea explorer url for the collectible **/
    required property var fnGetOpenSeaExplorerUrl

    title: qsTr("Sign Send")
    //: e.g. (Send) 100 DAI to batista.eth
    subtitle: {
        const tokenToSend = root.isCollectible ? root.collectibleName:
                              "%1 %2".arg(root.tokenAmount).arg(root.tokenSymbol)
        return qsTr("%1 to %2").
        arg(tokenToSend).
        arg(SQUtils.Utils.elideAndFormatWalletAddress(root.recipientAddress))
    }

    headerActionsCloseButtonVisible: true

    // Wallet account background color to be used as gardient in the header
    gradientColor: root.accountColor

    // In case if selected token is an asset then this displays the account selected
    fromImageSmartIdenticon.asset.name: "filled-account"
    fromImageSmartIdenticon.asset.emoji: root.accountEmoji
    fromImageSmartIdenticon.asset.color: root.accountColor
    fromImageSmartIdenticon.asset.isLetterIdenticon: !!root.accountEmoji

    // In case if selected token is an asset then this displays the token selected
    toImageSource: Constants.tokenIcon(root.tokenSymbol)

    // Collectible data in header in case a collectible is selected
    collectibleMedia.backgroundColor: root.collectibleBackgroundColor
    collectibleMedia.isMetadataValid: root.collectibleIsMetadataValid
    collectibleMedia.mediaUrl: root.collectibleMediaUrl
    collectibleMedia.mediaType: root.collectibleMediaType
    collectibleMedia.fallbackImageUrl: root.collectibleFallbackImageUrl

    /** In case if selected token is an collectible then
    this displays the account selected as badge **/
    accountSmartIdenticon.asset.name: "filled-account"
    accountSmartIdenticon.asset.emoji: root.accountEmoji
    accountSmartIdenticon.asset.color: root.accountColor
    accountSmartIdenticon.asset.isLetterIdenticon: !!root.accountEmoji
    accountSmartIdenticon.asset.isImage: root.isCollectible

    //: e.g. "Send 100 DAI to recipient on <network chain name>"
    headerMainText: {
        const tokenToSend = root.isCollectible ? root.collectibleName:
                               "%1 %2".arg(root.tokenAmount).arg(root.tokenSymbol)
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
        primaryText: "%1 %2".arg(root.tokenAmount).arg(root.tokenSymbol)
        secondaryText: root.tokenSymbol !== Constants.ethToken ?
                           SQUtils.Utils.elideAndFormatWalletAddress(root.tokenContractAddress) : ""
        icon: Constants.tokenIcon(root.tokenSymbol)
        badge: root.networkIconPath
        highlighted: contractInfoButtonWithMenu.hovered
        components: [
            ContractInfoButtonWithMenu {
                id: contractInfoButtonWithMenu

                objectName: "contractInfoButtonWithMenu"
                visible: root.tokenSymbol !== Constants.ethToken
                symbol: root.tokenSymbol
                contractAddress: root.tokenContractAddress
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
            loading: root.isCollectibleLoading
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
