import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Controls 0.1

import AppLayouts.Communities.layouts 1.0
import AppLayouts.Communities.views 1.0

import utils 1.0

StackView {
    id: root

    // id, name, image, color, owner properties expected
    required property var communityDetails

    // User profiles
    required property bool isOwner
    required property bool isTokenMasterOwner
    required property bool isAdmin
    readonly property bool isPrivilegedTokenOwnerProfile: root.isOwner || root.isTokenMasterOwner

    // Owner and TMaster token related properties:
    readonly property bool arePrivilegedTokensDeployed: root.isOwnerTokenDeployed && root.isTMasterTokenDeployed
    property bool isOwnerTokenDeployed: false
    property bool isTMasterTokenDeployed: false

    // Token models:
    required property var assetsModel
    required property var collectiblesModel

    required property var membersModel

    // JS object specifing fees for the airdrop operation, should be set to
    // provide response to airdropFeesRequested signal.
    // Refer EditAirdropView::airdropFees for details.
    property var airdropFees: null

    property int viewWidth: 560 // by design
    property string previousPageName: depth > 1 ? qsTr("Airdrops") : ""

    signal airdropClicked(var airdropTokens, var addresses, var membersPubKeys)
    signal airdropFeesRequested(var contractKeysAndAmounts, var addresses)
    signal navigateToMintTokenSettings(bool isAssetType)

    function navigateBack() {
        pop(StackView.Immediate)
    }

    function selectToken(key, amount, type) {
        if (depth > 1)
            pop(StackView.Immediate)

        root.push(newAirdropView, StackView.Immediate)
        d.selectToken(key, amount, type)
    }

    function addAddresses(addresses) {
        d.addAddresses(addresses)
    }

    QtObject {
        id: d

        readonly property bool isAdminOnly: root.isAdmin && !root.isPrivilegedTokenOwnerProfile

        signal selectToken(string key, int amount, int type)
        signal addAddresses(var addresses)
    }

    initialItem: SettingsPage {
        implicitWidth: 0
        title: qsTr("Airdrops")

        buttons: [
            // TO BE REMOVED when Owner and TMaster backend is integrated. This is just to keep the airdrop flow available somehow
            StatusButton {

                text: qsTr("TEMP Airdrop")

                onClicked: root.push(newAirdropView, StackView.Immediate)

                StatusToolTip {
                    visible: parent.hovered
                    text: "TO BE REMOVED when Owner and TMaster backend is integrated. This is just to keep the airdrop flow available somehow"
                    orientation: StatusToolTip.Orientation.Bottom
                    y: parent.height + 12
                    maxWidth: 300
                }
            },
            StatusButton {

                objectName: "addNewItemButton"

                text: qsTr("New Airdrop")
                enabled: !d.isAdminOnly && root.arePrivilegedTokensDeployed

                onClicked: root.push(newAirdropView, StackView.Immediate)
            }

        ]

        contentItem: WelcomeSettingsView {
            viewWidth: root.viewWidth
            image: Style.png("community/airdrops8_1")
            title: qsTr("Airdrop community tokens")
            subtitle: qsTr("You can mint custom tokens and collectibles for your community")
            checkersModel: [
                qsTr("Reward individual members with custom tokens for their contribution"),
                qsTr("Incentivise joining, retention, moderation and desired behaviour"),
                qsTr("Require holding a token or NFT to obtain exclusive membership rights")
            ]
            infoBoxVisible: d.isAdminOnly || (root.isPrivilegedTokenOwnerProfile && !root.arePrivilegedTokensDeployed)
            infoBoxTitle: qsTr("Get started")
            infoBoxText: d.isAdminOnly ? qsTr("Token airdropping can only be performed by admins that hodl the Community’s TokenMaster token. If you would like this permission, contact the Community founder (they will need to mint the Community Owner token before they can airdrop this to you)."):
                                         qsTr("In order to Mint, Import and Airdrop community tokens, you first need to mint your Owner token which will give you permissions to access the token management features for your community.")
            buttonText: qsTr("Mint Owner token")
            buttonVisible: root.isOwner
            onClicked: root.navigateToMintTokenSettings(false)
        }
    }

    Component {
        id: newAirdropView

        SettingsPage {
            title: qsTr("New airdrop")

            contentItem: EditAirdropView {
                id: view

                padding: 0

                communityDetails: root.communityDetails
                assetsModel: root.assetsModel
                collectiblesModel: root.collectiblesModel
                membersModel: root.membersModel

                Binding on airdropFees {
                    value: root.airdropFees
                }

                onAirdropClicked: {
                    root.airdropClicked(airdropTokens, addresses, membersPubKeys)
                    root.pop(StackView.Immediate)
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
}
