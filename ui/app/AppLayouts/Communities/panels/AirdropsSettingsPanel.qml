import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Communities.layouts 1.0
import AppLayouts.Communities.views 1.0

import utils 1.0

SettingsPageLayout {
    id: root

    // id, name, image, color, owner properties expected
    required property var communityDetails

    // Token models:
    required property var assetsModel
    required property var collectiblesModel

    required property var membersModel

    // JS object specifing fees for the airdrop operation, should be set to
    // provide response to airdropFeesRequested signal.
    // Refer EditAirdropView::airdropFees for details.
    property var airdropFees: null

    property int viewWidth: 560 // by design

    signal airdropClicked(var airdropTokens, var addresses, var membersPubKeys)

    signal airdropFeesRequested(var contractKeysAndAmounts, var addresses)

    signal navigateToMintTokenSettings(bool isAssetType)

    function navigateBack() {
        stackManager.pop(StackView.Immediate)
    }

    function selectToken(key, amount, type) {
        d.selectToken(key, amount, type)
    }

    function addAddresses(addresses) {
        d.addAddresses(addresses)
    }

    QtObject {
        id: d

        readonly property string welcomeViewState: "WELCOME"
        readonly property string newAirdropViewState: "NEW_AIRDROP"

        readonly property string welcomePageTitle: qsTr("Airdrops")
        readonly property string newAirdropViewPageTitle: qsTr("New airdrop")

        signal selectToken(string key, int amount, int type)
        signal addAddresses(var addresses)
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

    onPrimaryHeaderButtonClicked: {
        if(root.state !== d.newAirdropViewState)
            stackManager.push(d.newAirdropViewState, newAirdropView, null, StackView.Immediate)
    }

    StackViewStates {
        id: stackManager

        stackView: root.contentItem
    }

    // Mint tokens possible view contents:
    Component {
        id: welcomeView

        WelcomeSettingsView {
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

        EditAirdropView {
            id: view

            communityDetails: root.communityDetails
            assetsModel: root.assetsModel
            collectiblesModel: root.collectiblesModel
            membersModel: root.membersModel

            Binding on airdropFees {
                value: root.airdropFees
            }

            onAirdropClicked: {
                root.airdropClicked(airdropTokens, addresses, membersPubKeys)
                stackManager.clear(d.welcomeViewState, StackView.Immediate)
            }
            onNavigateToMintTokenSettings: root.navigateToMintTokenSettings(isAssetType)

            Component.onCompleted: {
                d.selectToken.connect(view.selectToken)
                d.addAddresses.connect(view.addAddresses)
                airdropFeesRequested.connect(root.airdropFeesRequested)
            }
        }
    }
}
