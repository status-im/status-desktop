import QtQuick 2.15
import QtQml.Models 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ 0.1
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

Control {
    id: root

    required property string componentUid
    required property bool isEditMode
    required property var selectedSharedAddressesMap // Map[address, [keyUid, selected, isAirdrop]
    property var currentSharedAddressesMap // Map[address, [keyUid, selected, isAirdrop]
    required property int totalNumOfAddressesForSharing
    required property bool profileProvesOwnershipOfSelectedAddresses
    required property bool allAddressesToRevealBelongToSingleNonProfileKeypair
    required property int /*PermissionTypes.Type*/ eligibleToJoinAs

    property bool requirementsCheckPending: false
    property bool joinPermissionsCheckSuccessful

    required property string communityId
    required property string communityName
    required property string communityIcon

    required property var walletAssetsModel
    required property var walletCollectiblesModel

    required property var walletAccountsModel // name, address, emoji, colorId
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

        property var tokenCountMap: new Map()
        function getTokenCount(address) {
            if (d.tokenCountMap.has(address))
                return d.tokenCountMap.get(address)
            return 0
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

        readonly property string tooltipText: {
            if (root.requirementsCheckPending)
                return qsTr("Requirements check pending")

            if (!root.joinPermissionsCheckSuccessful)
                return qsTr("Checking permissions to join failed")

            return ""
        }

        readonly property var saveButton: StatusButton {
            visible: root.isEditMode
            interactive: d.dirty && !root.requirementsCheckPending && root.joinPermissionsCheckSuccessful
            loading: root.requirementsCheckPending
            type: d.lostCommunityPermission || d.lostChannelPermissions ? StatusBaseButton.Type.Danger : StatusBaseButton.Type.Normal
            tooltip.text: {
                if (interactive)
                    return ""

                return d.tooltipText
            }
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
            interactive: root.eligibleToJoinAs !== PermissionTypes.Type.None && root.joinPermissionsCheckSuccessful
            loading: root.requirementsCheckPending
            tooltip.text: {
                if (interactive)
                    return ""

                return d.tooltipText
            }
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
        anchors.fill: parent
        spacing: 0

        // warning panel
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            color: Theme.palette.dangerColor1
            visible: d.lostCommunityPermission || d.lostChannelPermissions

            StatusBaseText {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Qt.AlignHCenter
                elide: Text.ElideRight
                text: d.lostCommunityPermission ? qsTr("Selected addresses have insufficient tokens to maintain %1 membership").arg(root.communityName) :
                                                  d.lostChannelPermissions ? qsTr("By deselecting these addresses, you will lose channel permissions") :
                                                                             ""
                font.pixelSize: Style.current.additionalTextSize
                font.weight: Font.Medium
                color: Theme.palette.indirectColor1
            }
        }

        // addresses
        SharedAddressesAccountSelector {
            id: accountSelector
            hasPermissions: d.hasPermissions

            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight + topMargin + bottomMargin
            Layout.maximumHeight: hasPermissions ? permissionsView.implicitHeight > root.availableHeight / 2 ? root.availableHeight / 2 : root.availableHeight : -1
            Layout.fillHeight: !hasPermissions
            implicitHeight: contentHeight

            uniquePermissionAssetsKeys:
                PermissionsHelpers.getUniquePermissionTokenKeys(
                    root.permissionsModel, Constants.TokenType.ERC20)

            uniquePermissionCollectiblesKeys:
                PermissionsHelpers.getUniquePermissionTokenKeys(
                    root.permissionsModel, Constants.TokenType.ERC721)

            model: SortFilterProxyModel {
                sourceModel: root.walletAccountsModel
                proxyRoles: FastExpressionRole {
                    name: "tokenCount"
                    expression: {
                        d.tokenCountMap
                        return d.getTokenCount(model.address.toLowerCase())
                    }
                    expectedRoles: ["address"]
                }

                sorters: [
                    // FIXME add sort token-relevant accounts first; https://github.com/status-im/status-desktop/issues/14192
                    RoleSorter {
                        roleName: "tokenCount"
                        sortOrder: Qt.DescendingOrder
                    },
                    RoleSorter {
                        roleName: "name"
                    }
                ]
            }
            walletAssetsModel: root.walletAssetsModel
            walletCollectiblesModel: root.walletCollectiblesModel

            communityId: root.communityId
            communityCollectiblesModel: root.collectiblesModel

            selectedSharedAddressesMap: root.selectedSharedAddressesMap

            onToggleAddressSelection: {
                root.toggleAddressSelection(keyUid, address)
            }

            onAirdropAddressSelected: {
                root.airdropAddressSelected(address)
            }

            getCurrencyAmount: function (balance, symbol) {
                return root.getCurrencyAmount(balance, symbol)
            }

            Component.onCompleted: {
                const tmpTokenCountMap = new Map()
                for (let i = 0; i < accountSelector.count; i++) {
                    const item = accountSelector.itemAtIndex(i)
                    if (!!item) {
                        tmpTokenCountMap.set(item.address.toLowerCase(), item.tokenCount)
                    }
                }
                d.tokenCountMap = tmpTokenCountMap
            }
        }

        // divider with top rounded corners + drop shadow
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.current.padding * 2
            color: permissionsView.color
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
            isDirty: d.dirty
            permissionsModel: root.permissionsModel
            assetsModel: root.assetsModel
            collectiblesModel: root.collectiblesModel
            requirementsCheckPending: root.requirementsCheckPending
            joinPermissionsCheckSuccessful: root.joinPermissionsCheckSuccessful
            communityName: root.communityName
            communityIcon: root.communityIcon
            eligibleToJoinAs: root.eligibleToJoinAs

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.topMargin: -Style.current.padding // compensate for the half-rounded divider above
            visible: permissionsView.hasAnyVisiblePermission
        }
    }
}
