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
import AppLayouts.Chat.popups.community 1.0

import utils 1.0
import SortFilterProxyModel 0.2

SettingsPageLayout {
    id: root

    // Models:
    property var tokensModel
    property var holdersModel
    property string feeText
    property string errorText
    property bool isFeeLoading: true

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

    signal signMintTransactionOpened(int chainId, string accountAddress)

    function setFeeLoading() {
        root.isFeeLoading = true
        root.feeText = ""
        root.errorText = ""
    }

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
        property string accountAddress
        readonly property var initialItem: (root.tokensModel && root.tokensModel.count > 0) ? mintedTokensView : welcomeView
        onInitialItemChanged: updateInitialStackView()

        function updateInitialStackView() {
            if(stackManager.stackView) {
                if(initialItem === welcomeView)
                    stackManager.stackView.replace(mintedTokensView, welcomeView, StackView.Immediate)
                if(initialItem === mintedTokensView)
                    stackManager.stackView.replace(welcomeView, mintedTokensView, StackView.Immediate)
            }
        }
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
            PropertyChanges {target: root; previousPageName: d.backButtonText}
            PropertyChanges {target: root; headerButtonVisible: false}
            PropertyChanges {target: root; headerWidth: 0}
        },
        State {
            name: d.collectibleViewState
            PropertyChanges {target: root; previousPageName: d.backTokensText}
            PropertyChanges {target: root; headerButtonVisible: false}
            PropertyChanges {target: root; headerWidth: 0}
            PropertyChanges {target: root; footer: mintTokenFooter}
            PropertyChanges {target: d; preview: false}
        }
    ]

    onHeaderButtonClicked: stackManager.push(d.newCollectibleViewState, newCollectiblesView, null, StackView.Immediate)

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
                d.accountAddress = accountAddress
                stackManager.push(d.previewCollectibleViewState,
                                  previewCollectibleView,
                                  {
                                      preview: true,
                                      name,
                                      artworkSource,
                                      symbol,
                                      description,
                                      supplyAmount,
                                      infiniteSupply,
                                      transferable: !notTransferable,
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
        id: previewCollectibleView

        CommunityCollectibleView {
            id: preview

            function signMintTransaction() {
                root.setFeeLoading()
                root.mintCollectible(artworkSource,
                                     name,
                                     symbol,
                                     description,
                                     supplyAmount,
                                     infiniteSupply,
                                     transferable,
                                     selfDestruct,
                                     chainId,
                                     accountName,
                                     d.accountAddress)

                stackManager.clear(d.initialViewState, StackView.Immediate)
            }

            viewWidth: root.viewWidth
            holdersModel: root.holdersModel

            onMintCollectible: popup.open()

            Binding {
                target: root
                property: "title"
                value: preview.name
            }

            SignMintTokenTransactionPopup {
                id: popup

                anchors.centerIn: Overlay.overlay
                collectibleName: parent.name
                accountName: parent.accountName
                networkName: parent.chainName
                feeText: root.feeText
                errorText: root.errorText
                isFeeLoading: root.isFeeLoading

                onOpened: {
                    root.setFeeLoading()
                    root.signMintTransactionOpened(parent.chainId, d.accountAddress)
                }
                onCancelClicked: close()
                onSignTransactionClicked: parent.signMintTransaction()
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
                stackManager.push(d.collectibleViewState,
                                  collectibleView,
                                  {
                                      preview: false,
                                      index
                                  },
                                  StackView.Immediate)
            }
        }
    }

    Component {
        id: collectibleView

        CommunityCollectibleView {
            id: view

            property int index // TODO: Update it to key when model has role key implemented

            viewWidth: root.viewWidth
            holdersModel: root.holdersModel

            Binding {
                target: root
                property: "title"
                value: view.name
            }

            Instantiator {
                id: instantiator

                model: SortFilterProxyModel {
                    sourceModel: root.tokensModel
                    filters: IndexFilter {
                        minimumIndex: view.index
                        maximumIndex: view.index
                    }
                }
                delegate: QtObject {
                    component Bind: Binding { target: view }
                    readonly property list<Binding> bindings: [
                        Bind { property: "deployState"; value: model.deployState },
                        Bind { property: "name"; value: model.name },
                        Bind { property: "artworkSource"; value: model.image },
                        Bind { property: "symbol"; value: model.symbol },
                        Bind { property: "description"; value: model.description },
                        Bind { property: "supplyAmount"; value: model.supply },
                        Bind { property: "infiniteSupply"; value: model.infiniteSupply },
                        Bind { property: "selfDestruct"; value: model.remoteSelfDestruct },
                        Bind { property: "chainId"; value: model.chainId },
                        Bind { property: "chainName"; value: model.chainName },
                        Bind { property: "chainIcon"; value: model.chainIcon },
                        Bind { property: "accountName"; value: model.accountName }
                    ]
                }
            }
        }
    }
}
