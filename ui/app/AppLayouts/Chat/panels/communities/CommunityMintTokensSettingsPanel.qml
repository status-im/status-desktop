import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Chat.layouts 1.0
import AppLayouts.Chat.views.communities 1.0

import utils 1.0

SettingsPageLayout {
    id: root

    property string communityId
    property var tokensModel
    property var communitiesStore
    property var transactionStore
    property int viewWidth: 560 // by design

    function navigateBack() {
        if (root.state === d.newCollectibleViewState) {
            root.state = d.initialState
        } else if (root.state === d.previewCollectibleViewState) {
            root.state = d.newCollectibleViewState
        } else if (root.state === d.collectibleViewState) {
            root.state = d.mintedCollectibleViewState
        }
    }

    QtObject {
        id: d

        readonly property string welcomeViewState: "WELCOME"
        readonly property string newCollectibleViewState: "NEW_COLLECTIBLE"
        readonly property string previewCollectibleViewState: "PREVIEW_COLLECTIBLE"
        readonly property string mintedCollectibleViewState: "MINTED_COLLECTIBLE"
        readonly property string collectibleViewState: "VIEW_COLLECTIBLE"

        readonly property string welcomePageTitle: qsTr("Mint tokens")
        readonly property string newCollectiblePageTitle: qsTr("Create new collectible")
        readonly property string backButtonText: qsTr("Back")
        readonly property string backTokensText: qsTr("Tokens")

        property bool preview: false

        readonly property string initialState: root.tokensModel.count > 0 ? d.mintedCollectibleViewState : d.welcomeViewState
    }

    QtObject {
        id: collectibleItem

        property int deployState
        property url artworkSource
        property string collectibleName
        property string symbol
        property string description
        property string supplyText
        property bool infiniteSupply: true
        property bool transferable: true
        property bool selfDestruct: true
        property int chainId
        property string chainName
        property string chainIcon

        function initialize() {
            deployState = 1
            artworkSource = ""
            collectibleName = ""
            symbol = ""
            description = ""
            supplyText = ""
            infiniteSupply = true
            transferable = true
            selfDestruct = true
            chainId = -1
            chainName = ""
            chainIcon = ""
        }

        function loadData(model) {
            deployState = model.deployState
            collectibleName = model.name
            description = model.description
            supplyText = model.supply.toString()
            infiniteSupply = model.infiniteSupply
            transferable = model.transferable
            chainName = communitiesStore.getChainName(model.chainId)
            chainIcon = communitiesStore.getChainIcon(model.chainId)
            artworkSource = model.image
            symbol = model.symbol
            selfDestruct = model.remoteSelfDestruct
            chainId = model.chainId
        }
    }

    state:  d.initialState
    states: [
        State {
            name: d.welcomeViewState
            PropertyChanges {target: root; title: d.welcomePageTitle}
            PropertyChanges {target: root; previousPageName: ""}
            PropertyChanges {target: root; content: welcomeView}
            PropertyChanges {target: root; headerButtonVisible: true}
            PropertyChanges {target: root; headerButtonText: qsTr("Create new token")}
            PropertyChanges {target: root; headerWidth: root.viewWidth}
        },
        State {
            name: d.newCollectibleViewState
            PropertyChanges {target: root; title: d.newCollectiblePageTitle}
            PropertyChanges {target: root; previousPageName: d.welcomePageTitle}
            PropertyChanges {target: root; content: newCollectiblesView}
            PropertyChanges {target: root; headerButtonVisible: false}
            PropertyChanges {target: root; headerWidth: 0}
        },
        State {
            name: d.previewCollectibleViewState
            PropertyChanges {target: root; title: collectibleItem.collectibleName}
            PropertyChanges {target: root; previousPageName: d.backButtonText}
            PropertyChanges {target: root; content: collectibleView}
            PropertyChanges {target: root; headerButtonVisible: false}
            PropertyChanges {target: root; headerWidth: 0}
            PropertyChanges {target: d; preview: true}
        },
        State {
            name: d.mintedCollectibleViewState
            PropertyChanges {target: root; title: d.welcomePageTitle}
            PropertyChanges {target: root; previousPageName: ""}
            PropertyChanges {target: root; content: mintedTokensView}
            PropertyChanges {target: root; headerButtonVisible: true}
            PropertyChanges {target: root; headerButtonText: qsTr("Create new token")}
            PropertyChanges {target: root; headerWidth: root.viewWidth}
            PropertyChanges {target: d; preview: false}
        },
        State {
            name: d.collectibleViewState
            PropertyChanges {target: root; title: collectibleItem.collectibleName}
            PropertyChanges {target: root; previousPageName: d.backTokensText}
            PropertyChanges {target: root; content: collectibleView}
            PropertyChanges {target: root; headerButtonVisible: false}
            PropertyChanges {target: root; headerWidth: 0}
            PropertyChanges {target: root; footer: mintTokenFooter}
            PropertyChanges {target: d; preview: false}
        }
    ]

    onHeaderButtonClicked: {
        if(root.state === d.welcomeViewState || root.state === d.mintedCollectibleViewState) {
            root.state = d.newCollectibleViewState
            collectibleItem.initialize()
        }
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
            anchors.fill: parent
            store: root.communitiesStore
            name: collectibleItem.collectibleName
            artworkSource: collectibleItem.artworkSource
            symbol: collectibleItem.symbol
            description: collectibleItem.description
            supplyText: collectibleItem.supplyText
            infiniteSupply: collectibleItem.infiniteSupply
            transferable: collectibleItem.transferable
            selfDestruct: collectibleItem.selfDestruct
            chainId: collectibleItem.chainId
            chainName: collectibleItem.chainName
            chainIcon: collectibleItem.chainIcon

            onNameChanged: collectibleItem.collectibleName = name
            onArtworkSourceChanged: collectibleItem.artworkSource = artworkSource
            onSymbolChanged: collectibleItem.symbol = symbol
            onDescriptionChanged: collectibleItem.description = description
            onSupplyTextChanged: collectibleItem.supplyText = supplyText
            onInfiniteSupplyChanged: collectibleItem.infiniteSupply = infiniteSupply
            onTransferableChanged: collectibleItem.transferable = transferable
            onSelfDestructChanged: collectibleItem.selfDestruct = selfDestruct
            onChainIdChanged: collectibleItem.chainId = chainId
            onChainNameChanged: collectibleItem.chainName = chainName
            onChainIconChanged: collectibleItem.chainIcon = chainIcon
            onPreviewClicked: root.state = d.previewCollectibleViewState
        }
    }

    Component {
        id: collectibleView

        CommunityCollectibleView {
            anchors.fill: parent
            preview: d.preview
            holdersModel: root.communitiesStore.holdersModel
            deployState: collectibleItem.deployState
            name: collectibleItem.collectibleName
            artworkSource: collectibleItem.artworkSource
            symbol: collectibleItem.symbol
            description: collectibleItem.description
            supplyText: collectibleItem.supplyText
            infiniteSupply: collectibleItem.infiniteSupply
            transferable: collectibleItem.transferable
            selfDestruct: collectibleItem.selfDestruct
            chainId: collectibleItem.chainId
            chainName: collectibleItem.chainName
            chainIcon: collectibleItem.chainIcon

            onMintCollectible: {
                root.communitiesStore.mintCollectible(root.communityId,
                                                      root.transactionStore.currentAccount.address, /*TODO use address from SendModal*/
                                                      name,
                                                      symbol,
                                                      description,
                                                      supply,
                                                      infiniteSupply,
                                                      transferable,
                                                      selfDestruct,
                                                      chainId,
                                                      artworkSource)

                root.state = d.mintedCollectibleViewState
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

    // TEMPORAL:
    Component {
        id: mintedTokensView

        // TEMPORAL:
        Item {
            anchors.fill: parent

            ColumnLayout {
                id: backendChecker
                width: parent.width

                StatusBaseText {
                    text: qsTr("Collectibles")
                    font.pixelSize: Theme.primaryTextFontSize
                    color: Theme.palette.baseColor1
                }

                // TODO: We can probably use some wallet components (i.e. CollectibleView.qml)
                ListView {
                    Layout.preferredWidth: 560
                    Layout.preferredHeight: childrenRect.height
                    model: root.tokensModel
                    delegate: StatusListItem {
                        width: parent.width
                        title: model.name + " - " + model.symbol
                        subTitle: model.description
                        titleAsideText: model.supply
                        label: model.deployState
                        onClicked: {
                            root.state = d.collectibleViewState
                            collectibleItem.loadData(model)
                        }
                    }
                }
            }
        }
    }
}
