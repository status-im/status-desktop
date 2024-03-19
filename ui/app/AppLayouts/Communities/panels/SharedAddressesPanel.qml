import QtQuick 2.15
import QtQml.Models 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Internal 0.1 as SQInternal

import SortFilterProxyModel 0.2

import AppLayouts.Profile.controls 1.0
import AppLayouts.Communities.controls 1.0
import AppLayouts.Communities.views 1.0
import AppLayouts.Communities.helpers 1.0

import utils 1.0
import shared.panels 1.0

Control {
    id: root

    required property string componentUid
    required property bool isEditMode
    required property var selectedSharedAddressesMap // Map[address, [keyUid, selected, isAirdrop]
    property var currentSharedAddressesMap // Map[address, [keyUid, selected, isAirdrop]
    required property int totalNumOfAddressesForSharing
    required property bool profileProvesOwnershipOfSelectedAddresses
    required property bool allAddressesToRevealBelongToSingleNonProfileKeypair

    property bool requirementsCheckPending: false

    required property string communityName
    required property string communityIcon

    required property var walletAssetsModel
    required property var walletAccountsModel // name, address, emoji, colorId, assets
    required property var permissionsModel  // id, key, permissionType, holdingsListModel, channelsListModel, isPrivate, tokenCriteriaMet
    required property var assetsModel
    required property var collectiblesModel

    readonly property string title: isEditMode ? qsTr("Edit which addresses you share with %1").arg(root.communityName)
                                               : qsTr("Select addresses to share with %1").arg(root.communityName)

    readonly property var rightButtons: root.isEditMode? [d.cancelButton, d.saveButton] : [d.shareAddressesButton]

    property var getCurrencyAmount: function (balance, symbol){}

    signal toggleAddressSelection(string keyUid, string address)
    signal airdropAddressSelected (string address)
    signal shareSelectedAddressesClicked()
    signal close()

    padding: 0
    spacing: Style.current.padding

    QtObject {
        id: d

        // internal logic
        readonly property bool hasPermissions: root.permissionsModel && root.permissionsModel.count
        readonly property int selectedSharedAddressesCount: root.selectedSharedAddressesMap.size

        readonly property bool dirty: {
            if (root.currentSharedAddressesMap.size !== root.selectedSharedAddressesMap.size) {
                return true
            }
            for (const [key, value] of root.currentSharedAddressesMap) {
                const obj = root.selectedSharedAddressesMap.get(key)
                if (!obj || value.selected !== obj.selected || value.isAirdrop !== obj.isAirdrop) {
                    return true
                }
            }
            return false
        }

        // warning states
        readonly property bool lostCommunityPermission: root.isEditMode && permissionsView.lostPermissionToJoin
        readonly property bool lostChannelPermissions: root.isEditMode && permissionsView.lostChannelPermissions

        readonly property var cancelButton: StatusFlatButton {
            visible: root.isEditMode
            borderColor: Theme.palette.baseColor2
            text: qsTr("Cancel")
            onClicked: root.close()
        }

        readonly property var saveButton: StatusButton {
            enabled: d.dirty
            type: d.lostCommunityPermission || d.lostChannelPermissions ? StatusBaseButton.Type.Danger : StatusBaseButton.Type.Normal
            visible: root.isEditMode

            text: {
                if (d.lostCommunityPermission) {
                    return qsTr("Save changes & leave %1").arg(root.communityName)
                }
                if (d.lostChannelPermissions) {
                    return qsTr("Save changes & update my permissions")
                }
                if (d.selectedSharedAddressesCount === root.totalNumOfAddressesForSharing) {
                    return qsTr("Reveal all addresses")
                }
                return qsTr("Reveal %n address(s)", "", d.selectedSharedAddressesCount)
            }

            icon.name: {
                if (!d.lostCommunityPermission
                        && !d.lostChannelPermissions
                        && root.profileProvesOwnershipOfSelectedAddresses) {
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
                root.shareSelectedAddressesClicked()
            }
        }

        readonly property var shareAddressesButton: StatusButton {
            visible: !root.isEditMode
            text: {
                if (d.selectedSharedAddressesCount === root.totalNumOfAddressesForSharing) {
                    return qsTr("Share all addresses to join")
                }
                return qsTr("Share %n address(s) to join", "", d.selectedSharedAddressesCount)
            }

            icon.name: {
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
                root.shareSelectedAddressesClicked()
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 0

        // warning panel
        ModuleWarning {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            text: d.lostCommunityPermission ? qsTr("Selected addresses have insufficient tokens to maintain %1 membership").arg(root.communityName) :
                                              d.lostChannelPermissions ? qsTr("By deselecting these addresses, you will lose channel permissions") :
                                                                         ""
            visible: d.lostCommunityPermission || d.lostChannelPermissions
            closeBtnVisible: false
        }

        // addresses
        SharedAddressesAccountSelector {
            id: accountSelector
            hasPermissions: d.hasPermissions
            uniquePermissionTokenKeys: PermissionsHelpers.getUniquePermissionTokenKeys(root.permissionsModel)
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight + topMargin + bottomMargin
            Layout.maximumHeight: hasPermissions ? permissionsView.implicitHeight > root.availableHeight / 2 ? root.availableHeight / 2 : root.availableHeight : -1
            Layout.fillHeight: !hasPermissions
            model: root.walletAccountsModel
            walletAssetsModel: root.walletAssetsModel
            selectedSharedAddressesMap: root.selectedSharedAddressesMap

            onToggleAddressSelection: {
                root.toggleAddressSelection(keyUid, address)
            }

            onAirdropAddressSelected: {
                root.airdropAddressSelected(address)
            }

            getCurrencyAmount: function (balance, symbol){
                return root.getCurrencyAmount(balance, symbol)
            }
        }

        RequirementsCheckPendingLoader {
            visible: root.requirementsCheckPending
            Layout.alignment: Qt.AlignHCenter
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.current.padding
        }

        // divider with top rounded corners + drop shadow
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.current.padding * 2
            color: Theme.palette.baseColor2
            radius: Style.current.padding
            border.width: 1
            border.color: Theme.palette.baseColor3
            visible: permissionsView.hasAnyVisiblePermission

            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: -9
                radius: 14
                samples: 29
                color: Qt.rgba(0, 0, 0, 0.04)
            }
        }

        // permissions
        SharedAddressesPermissionsPanel {
            id: permissionsView
            isEditMode: root.isEditMode
            permissionsModel: root.permissionsModel
            assetsModel: root.assetsModel
            collectiblesModel: root.collectiblesModel
            communityName: root.communityName
            communityIcon: root.communityIcon

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.topMargin: -Style.current.padding // compensate for the half-rounded divider above
            visible: permissionsView.hasAnyVisiblePermission
        }
    }
}
