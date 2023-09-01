import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Controls 0.1

import AppLayouts.Communities.layouts 1.0
import AppLayouts.Communities.views 1.0
import AppLayouts.Communities.helpers 1.0

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
    required property var accountsModel

    property int viewWidth: 560 // by design
    property string previousPageName: depth > 1 ? qsTr("Airdrops") : ""

    signal airdropClicked(var airdropTokens, var addresses, string feeAccountAddress)
    signal navigateToMintTokenSettings(bool isAssetType)
    signal registerAirdropFeeSubscriber(var feeSubscriber)

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
        property AirdropFeesSubscriber aidropFeeSubscriber: null
        signal selectToken(string key, string amount, int type)
        signal addAddresses(var addresses)
    }

    initialItem: SettingsPage {
        implicitWidth: 0
        title: qsTr("Airdrops")

        buttons: [
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
                accountsModel: root.accountsModel
                totalFeeText: feesSubscriber.totalFee
                feeErrorText: feesSubscriber.feesError
                feesPerSelectedContract: feesSubscriber.feesPerContract
                feesAvailable: !!feesSubscriber.airdropFeesResponse

                onAirdropClicked: {
                    root.airdropClicked(airdropTokens, addresses, feeAccountAddress)
                    root.pop(StackView.Immediate)
                }

                onNavigateToMintTokenSettings: root.navigateToMintTokenSettings(isAssetType)

                Component.onCompleted: {
                    d.selectToken.connect(view.selectToken)
                    d.addAddresses.connect(view.addAddresses)
                }

                AirdropFeesSubscriber {
                    id: feesSubscriber
                    enabled: view.visible && view.showingFees
                    communityId: view.communityDetails.id
                    contractKeysAndAmounts: view.selectedContractKeysAndAmounts
                    addressesToAirdrop: view.selectedAddressesToAirdrop
                    feeAccountAddress: view.selectedFeeAccount
                    Component.onCompleted: root.registerAirdropFeeSubscriber(feesSubscriber)
                }
            }
        }
    }
}
