import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qt.labs.settings 1.0

import StatusQ.Core.Theme 0.1

import shared.controls 1.0
import shared.controls.chat 1.0
import utils 1.0

SplitView {
    id: root

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        layer.enabled: true
        layer.samples: 4
        background: Rectangle {
            color: Theme.palette.statusChatInput.secondaryBackgroundColor
        }

        LinkPreviewMiniCard {
            id: previewMiniCard
            anchors.centerIn: parent
            type: previewTypeInput.currentIndex
            previewState: stateInput.currentIndex
            linkData {
                title: titleInput.text
                description: ""
                domain: domainInput.text
                thumbnail: externalImageInput.text
                image: faviconInput.text
            }
            userData {
                name: userNameInput.text
                publicKey: "zQ3shgmVJjmwwhkfAemjDizYJtv9nzot7QD4iRJ52ZkgdU6Ci"
                image: faviconInput.text
                ensVerified: false
            }
            communityData {
                name: communityNameInput.text
                banner: externalImageInput.text
                image: faviconInput.text
                color: "orchid"
            }
            channelData {
                name: channelNameInput.text
                emoji: ""
                color: "blue"
                communityData {
                    name: communityNameInput.text
                    banner: externalImageInput.text
                    image: faviconInput.text
                    color: "orchid"
                }
            }
            transactionData {
                txType: txTypeInput.currentValue
                address: addressInput.text
                amount: amountInput.text
                asset: symbolInput.text
                toAsset: toSymbolInput.text
                chainId: networkInput.currentValue
            }
        }
    }

    Pane {
        SplitView.preferredWidth: 300
        SplitView.fillHeight: true
        Flickable {
            anchors.fill: parent
            contentHeight: dataColumn.height
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AlwaysOn }
            ColumnLayout {
                id: dataColumn
                Label {
                    text: "State"
                }
                ComboBox {
                    id: stateInput
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    model: ["invalid", "loading", "loading failed", "loaded"]
                }
                Label {
                    text: "Preview type"
                }
                ComboBox {
                    id: previewTypeInput
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    model: ["unknown", "standard", "user profile", "community", "channel", "transaction"]
                }
                Label {
                    text: "Community name"
                }
                TextField {
                    id: communityNameInput
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: "Socks"
                }

                Label {
                    text: "Channel name"
                }
                TextField {
                    id: channelNameInput
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: "General"
                }

                Label {
                    text: "User name"
                }
                TextField {
                    id: userNameInput
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: "John Doe"
                }

                Label {
                    text: "Title"
                }

                TextField {
                    id: titleInput
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: "What Is Web3? A Decentralized Internet Via Blockchain Technology That Will Revolutionise All Sectors- Decrypt (@decryptmedia) August 31 2021"
                }

                Label {
                    text: "Domain"
                }
                TextField {
                    id: domainInput
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: "rarible.com"
                }
                Label {
                    text: "Favicon URL"
                }
                TextField {
                    id: faviconInput
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: "https://rarible.com/public/favicon.png"
                }
                Label {
                    text: "External image URL"
                }
                TextField {
                    id: externalImageInput
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: "https://rarible.com/public/favicon.png"
                }
                Label {
                    text: "\nTransaction preview:\n"
                    font.bold: true
                }
                Label {
                    text: "Transaction type"
                }
                ComboBox {
                    id: txTypeInput
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    textRole: "text"
                    valueRole: "value"
                    model: [
                        { value: Constants.SendType.Transfer, text: "Send" },
                        { value: Constants.SendType.Bridge, text: "Bridge" },
                        { value: Constants.SendType.Swap, text: "Swap" }
                    ]
                }
                Label {
                    text: "Address"
                }
                TextField {
                    id: addressInput
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: "0x60f80121c31a0d46b5279700f9df786054aa5ee5"
                }
                Label {
                    text: "Amount"
                }
                TextField {
                    id: amountInput
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: "0.1"
                }
                Label {
                    text: "Symbol"
                }
                TextField {
                    id: symbolInput
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: "ETH"
                }
                Label {
                    text: "toSymbol"
                }
                TextField {
                    id: toSymbolInput
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: "DAI"
                }
                Label {
                    text: "Network"
                }
                ComboBox {
                    id: networkInput
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    textRole: "text"
                    valueRole: "value"
                    model: [
                        { value: Constants.chains.mainnetChainId, text: "Mainet" },
                        { value: Constants.chains.optimismChainId, text: "Optimism" },
                        { value: Constants.chains.arbitrumChainId, text: "Arbitrum" }
                    ]
                }
            }
        }
    }
    Settings {
        property alias linkPreviewMiniCardState: stateInput.currentIndex
        property alias linkPreviewMiniCardCommunityName: communityNameInput.text
        property alias linkPreviewMiniCardChannelName: channelNameInput.text
        property alias linkPreviewMiniCardTitle: titleInput.text
        property alias linkPreviewMiniCardDomain: domainInput.text
        property alias linkPreviewMiniCardFavIconUrl: faviconInput.text
        property alias linkPreviewMiniCardThumbnailImageUrl: externalImageInput.text
        property alias linkPreviewMiniCardType: previewTypeInput.currentIndex
    }
}

//Category: Controls

//"https://www.figma.com/file/Mr3rqxxgKJ2zMQ06UAKiWL/💬-Chat⎜Desktop?type=design&node-id=22341-184809&mode=design&t=VWBVK4DOUxr1BmTp-0"
