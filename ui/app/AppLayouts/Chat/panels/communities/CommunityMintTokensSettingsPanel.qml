import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml 2.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Chat.layouts 1.0
import AppLayouts.Chat.views.communities 1.0

import utils 1.0

SettingsPageLayout {
    id: root

    // Models:
    property var tokensModel
    property var holdersModel

    // Network related properties:
    property var layer1Networks
    property var layer2Networks
    property var testNetworks
    property var enabledNetworks
    property var allNetworks

    // Account expected roles: address, name, color, emoji
    property var accounts

    property int viewWidth: 560 // by design

    signal mintCollectible(url artworkSource,
                           string name,
                           string symbol,
                           string description,
                           int supply,
                           bool infiniteSupply,
                           bool transferable,
                           bool selfDestruct,
                           int chainId,
                           string accountName,
                           string accountAddress)

    function navigateBack() {
        stackManager.pop(StackView.Immediate)
    }

    QtObject {
        id: d

        readonly property string initialViewState: "WELCOME_OR_LIST_COLLECTIBLES"
        readonly property string newCollectibleViewState: "NEW_COLLECTIBLE"
        readonly property string previewCollectibleViewState: "PREVIEW_COLLECTIBLE"
        readonly property string collectibleViewState: "VIEW_COLLECTIBLE"

        readonly property string welcomePageTitle: qsTr("Mint tokens")
        readonly property string newCollectiblePageTitle: qsTr("Create new collectible")
        readonly property string newTokenButtonText: qsTr("Create new token")
        readonly property string backButtonText: qsTr("Back")
        readonly property string backTokensText: qsTr("Tokens")

        property bool preview: false
        property string collectibleName
        property string accountAddress
        readonly property var initialItem: (root.tokensModel && root.tokensModel.count > 0) ? mintedTokensView : welcomeView
    }

    content: StackView {
        anchors.fill: parent
        initialItem: d.initialItem

        Component.onCompleted: stackManager.pushInitialState(d.initialViewState)
    }

    state: stackManager.currentState
    states: [
        State {
            name: d.initialViewState
            PropertyChanges {target: root; title: d.welcomePageTitle}
            PropertyChanges {target: root; previousPageName: ""}
            PropertyChanges {target: root; headerButtonVisible: true}
            PropertyChanges {target: root; headerButtonText: d.newTokenButtonText}
            PropertyChanges {target: root; headerWidth: root.viewWidth}
        },
        State {
            name: d.newCollectibleViewState
            PropertyChanges {target: root; title: d.newCollectiblePageTitle}
            PropertyChanges {target: root; previousPageName: d.welcomePageTitle}
            PropertyChanges {target: root; headerButtonVisible: false}
            PropertyChanges {target: root; headerWidth: 0}
        },
        State {
            name: d.previewCollectibleViewState
            PropertyChanges {target: root; title: d.collectibleName}
            PropertyChanges {target: root; previousPageName: d.backButtonText}
            PropertyChanges {target: root; headerButtonVisible: false}
            PropertyChanges {target: root; headerWidth: 0}
            PropertyChanges {target: d; preview: true}
        },
        State {
            name: d.collectibleViewState
            PropertyChanges {target: root; title: d.collectibleName}
            PropertyChanges {target: root; previousPageName: d.backTokensText}
            PropertyChanges {target: root; headerButtonVisible: false}
            PropertyChanges {target: root; headerWidth: 0}
            PropertyChanges {target: root; footer: mintTokenFooter}
            PropertyChanges {target: d; preview: false}
        }
    ]

    onHeaderButtonClicked: stackManager.push(d.newCollectibleViewState, newCollectiblesView, null, StackView.Immediate)
    onTokensModelChanged: {
        if(root.tokensModel && root.tokensModel.count === 1) {
            stackManager.stackView.replace(welcomeView, d.initialItem, StackView.Immediate)
        }
    }

    StackViewStates {
        id: stackManager

        stackView: root.contentItem
    }

    // Mint tokens possible view contents:
    Component {
        id: welcomeView

        CommunityWelcomeSettingsView {
            viewWidth: root.viewWidth
            image: Style.png("community/mint2_1")
            title: qsTr("Mint community tokens")
            subtitle: qsTr("You can mint custom tokens and collectibles for your community")
            checkersModel: [
                qsTr("Reward individual members with custom tokens for their contribution"),
                qsTr("Incentivise joining, retention, moderation and desired behaviour"),
                qsTr("Monetise your community by selling exclusive tokens")
            ]
        }
    }

    Component {
        id: newCollectiblesView

        CommunityNewCollectibleView {
            viewWidth: root.viewWidth
            layer1Networks: root.layer1Networks
            layer2Networks: root.layer2Networks
            testNetworks: root.testNetworks
            enabledNetworks: root.testNetworks
            allNetworks: root.allNetworks
            accounts: root.accounts

            onPreviewClicked: {
                d.collectibleName = name
                d.accountAddress = accountAddress
                stackManager.push(d.previewCollectibleViewState,
                                  collectibleView,
                                  {
                                      name,
                                      artworkSource,
                                      symbol,
                                      description,
                                      supplyText,
                                      infiniteSupply,
                                      transferable,
                                      selfDestruct,
                                      chainId,
                                      chainName,
                                      chainIcon,
                                      accountName
                                  },
                                  StackView.Immediate)
            }
        }
    }

    Component {
        id: collectibleView

        CommunityCollectibleView {
            viewWidth: root.viewWidth
            preview: d.preview
            holdersModel: root.holdersModel

            onMintCollectible: {
                d.collectibleName = name
                root.mintCollectible(artworkSource,
                                     name,
                                     symbol,
                                     description,
                                     supply,
                                     infiniteSupply,
                                     transferable,
                                     selfDestruct,
                                     chainId,
                                     accountName,
                                     d.accountAddress)

                stackManager.clear(d.initialViewState, StackView.Immediate)
            }
        }
    }

    Component {
        id: mintTokenFooter

        MintTokensFooterPanel {
            airdropEnabled: false
            retailEnabled: false
            remotelySelfDestructEnabled: false
            burnEnabled: false
        }
    }

    Component {
        id: mintedTokensView

        CommunityMintedTokensView {
            viewWidth: root.viewWidth
            model: root.tokensModel
            onItemClicked: {
                d.collectibleName = name
                stackManager.push(d.collectibleViewState,
                                  collectibleView,
                                  {
                                      deployState: Qt.binding(() => deployState),
                                      name,
                                      artworkSource,
                                      symbol,
                                      description,
                                      supplyText: supply.toString(),
                                      infiniteSupply,
                                      transferable,
                                      remoteSelfDestruct,
                                      chainId,
                                      chainName,
                                      chainIcon,
                                      accountName
                                  },
                                  StackView.Immediate)
            }
        }
    }
}
