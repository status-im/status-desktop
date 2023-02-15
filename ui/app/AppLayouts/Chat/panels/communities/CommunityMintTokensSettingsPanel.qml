import QtQuick 2.14

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
            root.state = d.welcomeViewState
        }
    }

    QtObject {
        id: d

        readonly property string welcomeViewState: "WELCOME"
        readonly property string newCollectibleViewState: "NEW_COLLECTIBLE"
    }

    state: d.welcomeViewState
    states: [
        State {
            name: d.welcomeViewState
            PropertyChanges {target: root; title: qsTr("Mint tokens")}
            PropertyChanges {target: root; previousPageName: ""}
            PropertyChanges {target: root; content: welcomeView}
            PropertyChanges {target: root; headerButtonVisible: true}
            PropertyChanges {target: root; headerButtonText: qsTr("Create new token")}
            PropertyChanges {target: root; headerWidth: root.viewWidth}
        },
        State {
            name: d.newCollectibleViewState
            PropertyChanges {target: root; title: qsTr("Create new collectible")}
            PropertyChanges {target: root; previousPageName: qsTr("Mint tokens")}
            PropertyChanges {target: root; content: newCollectiblesView}
            PropertyChanges {target: root; headerButtonVisible: false}
            PropertyChanges {target: root; headerWidth: 0}
        }
    ]

    onHeaderButtonClicked: {
        if(root.state === d.welcomeViewState) {
            root.state = d.newCollectibleViewState
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
            tokensModel: root.tokensModel
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
            }
        }
    }
}
