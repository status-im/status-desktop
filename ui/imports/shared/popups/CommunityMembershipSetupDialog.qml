import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import utils 1.0

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Communities.panels 1.0
import AppLayouts.Communities.controls 1.0
import AppLayouts.Communities.helpers 1.0

import SortFilterProxyModel 0.2

StatusStackModal {
    id: root

    destroyOnClose: true
    property bool isEditMode: false

    required property string communityId
    required property string communityName
    required property string communityIcon
    required property bool requirementsCheckPending

    property bool joinPermissionsCheckSuccessful

    property string introMessage

    property bool isInvitationPending: false

    required property var walletAccountsModel // name, address, emoji, colorId

    required property var walletAssetsModel
    required property var walletCollectiblesModel

    required property var permissionsModel  // id, key, permissionType, holdingsListModel, channelsListModel, isPrivate, tokenCriteriaMet
    required property var assetsModel
    required property var collectiblesModel

    property var keypairSigningModel

    property var currentSharedAddresses: []
    onCurrentSharedAddressesChanged: d.reEvaluateModels()
    property string currentAirdropAddress: ""
    onCurrentAirdropAddressChanged: d.reEvaluateModels()

    property var getCurrencyAmount: function (balance, symbol){}

    property var canProfileProveOwnershipOfProvidedAddressesFn: function(addresses) { return false }

    readonly property bool profileProvesOwnershipOfSelectedAddresses: {
        d.selectedSharedAddressesMap // needed for binding
        const obj = d.getSelectedAddresses()
        return root.canProfileProveOwnershipOfProvidedAddressesFn(obj.addresses)
    }

    readonly property bool allAddressesToRevealBelongToSingleNonProfileKeypair: {
        const keyUids = new Set()
        for (const [key, value] of d.selectedSharedAddressesMap) {
            keyUids.add(value.keyUid)
        }
        return keyUids.size === 1 && !keyUids.has(userProfile.keyUid)
    }

    signal prepareForSigning(string airdropAddress, var sharedAddresses)
    signal joinCommunity()
    signal editRevealedAddresses()
    signal signProfileKeypairAndAllNonKeycardKeypairs()
    signal signSharedAddressesForKeypair(string keyUid)
    signal cancelMembershipRequest()
    signal sharedAddressesUpdated(var sharedAddresses)

    width: 640 // by design
    padding: 0
    stackTitle: d.accessType === Constants.communityChatOnRequestAccess ?
                    qsTr("Request to join %1").arg(root.communityName)
                  : qsTr("Welcome to %1").arg(root.communityName)

    rightButtons: [d.shareButton, finishButton]

    finishButton: StatusButton {
        interactive: {
            if (root.isInvitationPending)
                return true

            if (root.requirementsCheckPending && !root.joinPermissionsCheckSuccessful)
                return false

            if (root.joinPermissionsCheckSuccessful || d.accessType !== Constants.communityChatOnRequestAccess)
                return true

            return d.eligibleToJoinAs !== PermissionTypes.Type.None
        }
        loading: root.requirementsCheckPending && !root.joinPermissionsCheckSuccessful && !root.isInvitationPending
        tooltip.text: {
            if (interactive)
                return ""

            if (root.requirementsCheckPending && !root.joinPermissionsCheckSuccessful)
                return qsTr("Requirements check pending")

            if (!root.joinPermissionsCheckSuccessful)
                return qsTr("Checking permissions to join failed")

            return ""
        }
        text: {
            if (root.isInvitationPending) {
                return qsTr("Cancel Membership Request")
            }
            if (d.selectedSharedAddressesCount === d.totalNumOfAddressesForSharing) {
                return qsTr("Share all addresses to join")
            }
            return qsTr("Share %n address(s) to join", "", d.selectedSharedAddressesCount)
        }
        type: root.isInvitationPending ? StatusBaseButton.Type.Danger
                                       : StatusBaseButton.Type.Normal

        icon.name: {
            if (root.isInvitationPending)
                return ""

            if (root.profileProvesOwnershipOfSelectedAddresses) {
                if (userProfile.usingBiometricLogin) {
                    return "touch-id"
                }

                if (userProfile.isKeycardUser) {
                    return "keycard"
                }

                return "password"
            }
            if (root.allAddressesToRevealBelongToSingleNonProfileKeypair) {
                return "keycard"
            }

            return ""
        }

        onClicked: {
            if (root.isInvitationPending) {
                root.cancelMembershipRequest()
                root.close()
                return
            }

            d.proceedToSigningOrSubmitRequest(d.communityIntroUid)
        }
    }

    backButton: StatusBackButton {
        visible: !!root.replaceLoader.item
                 && !(root.replaceLoader.item.componentUid === d.shareAddressesUid && root.isEditMode)

        onClicked: {
            if (d.backActionGoesTo === d.communityIntroUid) {
                if (root.replaceItem) {
                    root.replaceItem = undefined
                }
                return
            }

            if (d.backActionGoesTo === d.shareAddressesUid) {
                d.backActionGoesTo = d.communityIntroUid
                root.replace(sharedAddressesPanelComponent)

                return
            }
        }

        Layout.minimumWidth: implicitWidth
    }

    QtObject {
        id: d

        readonly property string communityIntroUid: "community-intro"
        readonly property string shareAddressesUid: "shared-addresses"
        readonly property string signingPanelUid: "signing-panel"
        property string backActionGoesTo: d.communityIntroUid

        readonly property int totalNumOfAddressesForSharing: root.walletAccountsModel.count

        property var currentSharedAddressesMap: new Map() // Map[address, [keyUid, selected, isAirdrop]] - used in edit mode only
        property var selectedSharedAddressesMap: new Map() // Map[address, [keyUid, selected, isAirdrop]]

        readonly property int selectedSharedAddressesCount: d.selectedSharedAddressesMap.size

        readonly property int accessType: d.eligibleToJoinAs !== -1 ? Constants.communityChatOnRequestAccess
                                                                    : Constants.communityChatPublicAccess
        property int eligibleToJoinAs: PermissionsHelpers.isEligibleToJoinAs(root.permissionsModel)
        readonly property var _con: Connections {
            target: root.permissionsModel
            function onTokenCriteriaUpdated() {
                d.eligibleToJoinAs = PermissionsHelpers.isEligibleToJoinAs(root.permissionsModel)
            }
        }

        readonly property var initialAddressesModel: SortFilterProxyModel {
            sourceModel: root.walletAccountsModel
        }

        function proceedToSigningOrSubmitRequest(uidOfComponentThisFunctionIsCalledFrom) {
            const selected = d.getSelectedAddresses()
            root.prepareForSigning(selected.airdropAddress, selected.addresses)
            if (root.profileProvesOwnershipOfSelectedAddresses) {
                root.signProfileKeypairAndAllNonKeycardKeypairs()
                return
            }
            if (root.allAddressesToRevealBelongToSingleNonProfileKeypair) {
                if (d.selectedSharedAddressesMap.size === 0) {
                    console.error("selected shared addresses must not be empty")
                    return
                }
                const keyUid = d.selectedSharedAddressesMap.values().next().value.keyUid
                root.signSharedAddressesForKeypair(keyUid)
                return
            }

            d.backActionGoesTo = uidOfComponentThisFunctionIsCalledFrom
            root.replace(sharedAddressesSigningPanelComponent)
        }

        // This function deletes/adds it the address from/to the map.
        function toggleAddressSelection(keyUid, address) {
            const tmpMap = d.selectedSharedAddressesMap

            const lAddress = address.toLowerCase()
            const obj = tmpMap.get(lAddress)
            if (!!obj) {
                if (tmpMap.size === 1) {
                    console.error("cannot remove the last selected address")
                }
                tmpMap.delete(lAddress)
                if (obj.isAirdrop) {
                    d.selectAirdropAddressForTheFirstSelectedAddress()
                }
            } else {
                tmpMap.set(lAddress, {keyUid: keyUid, selected: true, isAirdrop: false})
            }

            d.selectedSharedAddressesMap = tmpMap
        }

        // This function selects new airdrop address, invalidating old airdrop address selection.
        function selectAirdropAddressForTheFirstSelectedAddress() {
            const tmpMap = d.selectedSharedAddressesMap

            // clear previous airdrop address
            for (const [key, value] of tmpMap) {
                if (!value.isAirdrop) {
                    d.selectedSharedAddressesMap.set(key, {keyUid: value.keyUid, selected: value.selected, isAirdrop: true})
                    break
                }
            }

            d.selectedSharedAddressesMap = tmpMap
        }

        // This function selects new airdrop address, invalidating old airdrop address selection.
        function selectAirdropAddress(address) {
            const tmpMap = d.selectedSharedAddressesMap

            // clear previous airdrop address
            for (const [key, value] of tmpMap) {
                if (value.isAirdrop) {
                    tmpMap.set(key, {keyUid: value.keyUid, selected: value.selected, isAirdrop: false})
                    break
                }
            }

            // set new airdrop address
            const lAddress = address.toLowerCase()
            const obj = tmpMap.get(lAddress)
            if (!obj) {
                console.error("cannot set airdrop address for unselected address")
                return
            }
            obj.isAirdrop = true
            tmpMap.set(lAddress, obj)

            d.selectedSharedAddressesMap = tmpMap
        }

        // Returns an object containing all selected addresses and selected airdrop address
        function getSelectedAddresses() {
            const result = {addresses: [], airdropAddress: ""}
            for (const [key, value] of d.selectedSharedAddressesMap) {
                if (value.selected) {
                    result.addresses.push(key)
                }
                if (value.isAirdrop) {
                    result.airdropAddress = key
                }
            }
            return result
        }

        function reEvaluateModels() {
            const tmpSharedAddressesMap = new Map()
            const tmpCurrentSharedAddressesMap = new Map()
            for (let i=0; i < d.initialAddressesModel.count; ++i){
                const obj = d.initialAddressesModel.get(i)

                if (!!obj) {
                    const lAddress = obj.address.toLowerCase()

                    let isAirdrop = i === 0
                    if (root.isEditMode) {
                        if (root.currentSharedAddresses.indexOf(obj.address) === -1) {
                            continue
                        }
                        isAirdrop = lAddress === root.currentAirdropAddress.toLowerCase()
                    }
                    tmpSharedAddressesMap.set(lAddress, {keyUid: obj.keyUid, selected: true, isAirdrop: isAirdrop})
                    tmpCurrentSharedAddressesMap.set(lAddress, {keyUid: obj.keyUid, selected: true, isAirdrop: isAirdrop})
                }
            }

            d.selectedSharedAddressesMap = tmpSharedAddressesMap
            if (root.isEditMode) {
                d.currentSharedAddressesMap = new Map(tmpCurrentSharedAddressesMap)
            }
        }

        readonly property var shareButton: StatusFlatButton {
            height: finishButton.height
            visible: !root.isInvitationPending && !root.replaceItem
            borderColor: "transparent"
            text: qsTr("Select addresses to share")
            onClicked: {
                d.backActionGoesTo = d.communityIntroUid
                root.replace(sharedAddressesPanelComponent)
            }
        }
    }

    Component.onCompleted: {
        d.reEvaluateModels()

        if (root.isEditMode) {
            d.backActionGoesTo = d.shareAddressesUid
            root.replace(sharedAddressesPanelComponent)
        }
    }

    Component {
        id: sharedAddressesPanelComponent
        SharedAddressesPanel {
            componentUid: d.shareAddressesUid
            isEditMode: root.isEditMode

            communityId: root.communityId
            communityName: root.communityName
            communityIcon: root.communityIcon
            requirementsCheckPending: root.requirementsCheckPending
            joinPermissionsCheckSuccessful: root.joinPermissionsCheckSuccessful

            walletAccountsModel: d.initialAddressesModel

            selectedSharedAddressesMap: d.selectedSharedAddressesMap
            currentSharedAddressesMap: d.currentSharedAddressesMap

            totalNumOfAddressesForSharing: d.totalNumOfAddressesForSharing
            eligibleToJoinAs: d.eligibleToJoinAs

            profileProvesOwnershipOfSelectedAddresses: root.profileProvesOwnershipOfSelectedAddresses
            allAddressesToRevealBelongToSingleNonProfileKeypair: root.allAddressesToRevealBelongToSingleNonProfileKeypair

            walletAssetsModel: root.walletAssetsModel
            walletCollectiblesModel: root.walletCollectiblesModel

            permissionsModel: root.permissionsModel
            assetsModel: root.assetsModel
            collectiblesModel: root.collectiblesModel

            onClose: {
                root.close()
            }

            onToggleAddressSelection: {
                d.toggleAddressSelection(keyUid, address)

                const obj = d.getSelectedAddresses()
                root.sharedAddressesUpdated(obj.addresses)
            }

            onAirdropAddressSelected: {
                d.selectAirdropAddress(address)
            }

            onShareSelectedAddressesClicked: {
                d.proceedToSigningOrSubmitRequest(d.shareAddressesUid)
            }

            getCurrencyAmount: function (balance, symbol){
                return root.getCurrencyAmount(balance, symbol)
            }
        }
    }

    Component {
        id: sharedAddressesSigningPanelComponent
        SharedAddressesSigningPanel {
            componentUid: d.signingPanelUid
            isEditMode: root.isEditMode
            totalNumOfAddressesForSharing: d.totalNumOfAddressesForSharing
            selectedSharedAddressesMap: d.selectedSharedAddressesMap

            communityName: root.communityName
            keypairSigningModel: root.keypairSigningModel

            onSignProfileKeypairAndAllNonKeycardKeypairs: {
                root.signProfileKeypairAndAllNonKeycardKeypairs()
            }

            onSignSharedAddressesForKeypair: {
                root.signSharedAddressesForKeypair(keyUid)
            }

            onJoinCommunity: {
                if (root.isEditMode) {
                    root.editRevealedAddresses()
                } else {
                    root.joinCommunity()
                }
                root.close()
            }
        }
    }

    stackItems: [
        Item {
            implicitHeight: scrollView.contentHeight + scrollView.bottomPadding + eligibilityTag.anchors.bottomMargin

            StatusScrollView {
                id: scrollView
                anchors.fill: parent
                contentWidth: availableWidth
                bottomPadding: 80

                ColumnLayout {
                    spacing: Style.current.bigPadding
                    width: parent.width

                    StatusRoundedImage {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 64
                        Layout.preferredHeight: Layout.preferredWidth
                        visible: ((image.status == Image.Loading) ||
                                  (image.status == Image.Ready)) &&
                                 !image.isError
                        image.source: root.communityIcon
                    }

                    StatusBaseText {
                        Layout.fillWidth: true
                        text: root.introMessage || qsTr("Community <b>%1</b> has no intro message...").arg(root.communityName)
                        color: Theme.palette.directColor1
                        wrapMode: Text.WordWrap
                    }
                }
            }

            CommunityEligibilityTag {
                id: eligibilityTag
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Style.current.bigPadding
                eligibleToJoinAs: d.eligibleToJoinAs
                isEditMode: root.isEditMode
                visible: !root.isInvitationPending && !root.requirementsCheckPending && root.joinPermissionsCheckSuccessful &&
                         d.accessType === Constants.communityChatOnRequestAccess
            }
        }
    ]
}
