import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Chat.layouts 1.0
import AppLayouts.Chat.views.communities 1.0

import utils 1.0

SettingsPageLayout {
    id: root

    // Token models:
    required property var assetsModel
    required property var collectiblesModel

    required property var membersModel

    property int viewWidth: 560 // by design

    signal airdropClicked(var airdropTokens, var addresses, var membersPubKeys)
    signal navigateToMintTokenSettings


    function navigateBack() {
        stackManager.pop(StackView.Immediate)
    }

    function selectCollectible(key, amount) {
        d.selectCollectible(key, amount)
    }

    QtObject {
        id: d

        readonly property string welcomeViewState: "WELCOME"
        readonly property string newAirdropViewState: "NEW_AIRDROP"

        readonly property string welcomePageTitle: qsTr("Airdrops")
        readonly property string newAirdropViewPageTitle: qsTr("New airdrop")

        signal selectCollectible(string key, int amount)
    }

    content: StackView {
        anchors.fill: parent
        initialItem: welcomeView

        Component.onCompleted: stackManager.pushInitialState(d.welcomeViewState)
    }

    state:  stackManager.currentState
    states: [
        State {
            name: d.welcomeViewState
            PropertyChanges {target: root; title: d.welcomePageTitle}
            PropertyChanges {target: root; previousPageName: ""}
            PropertyChanges {target: root; primaryHeaderButton.visible: true}
            PropertyChanges {target: root; primaryHeaderButton.text: qsTr("New Airdrop")}
        },
        State {
            name: d.newAirdropViewState
            PropertyChanges {target: root; title: d.newAirdropViewPageTitle}
            PropertyChanges {target: root; previousPageName: d.welcomePageTitle}
            PropertyChanges {target: root; primaryHeaderButton.visible: false}
        }
    ]

    onPrimaryHeaderButtonClicked: stackManager.push(d.newAirdropViewState, newAirdropView, null, StackView.Immediate)

    StackViewStates {
        id: stackManager

        stackView: root.contentItem
    }

    // Mint tokens possible view contents:
    Component {
        id: welcomeView

        CommunityWelcomeSettingsView {
            viewWidth: root.viewWidth
            image: Style.png("community/airdrops8_1")
            title: qsTr("Airdrop community tokens")
            subtitle: qsTr("You can mint custom tokens and collectibles for your community")
            checkersModel: [
                qsTr("Reward individual members with custom tokens for their contribution"),
                qsTr("Incentivise joining, retention, moderation and desired behaviour"),
                qsTr("Require holding a token or NFT to obtain exclusive membership rights")
            ]
        }
    }

    Component {
        id: newAirdropView

        CommunityNewAirdropView {
            id: view

            assetsModel: root.assetsModel
            collectiblesModel: root.collectiblesModel
            membersModel: root.membersModel

            onAirdropClicked: {
                root.airdropClicked(airdropTokens, addresses, membersPubKeys)
                stackManager.clear(d.welcomeViewState, StackView.Immediate)
            }
            onNavigateToMintTokenSettings: root.navigateToMintTokenSettings()

            Component.onCompleted: d.selectCollectible.connect(view.selectCollectible)
        }
    }
}
