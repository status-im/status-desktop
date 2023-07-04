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

import SortFilterProxyModel 0.2

import AppLayouts.Profile.controls 1.0
import AppLayouts.Communities.controls 1.0
import AppLayouts.Communities.views 1.0
import AppLayouts.Communities.helpers 1.0

import utils 1.0

Control {
    id: root

    property bool isEditMode

    required property string communityName
    required property string communityIcon
    property int loginType: Constants.LoginType.Password

    required property var walletAccountsModel // name, address, emoji, colorId, assets
    required property var permissionsModel  // id, key, permissionType, holdingsListModel, channelsListModel, isPrivate, tokenCriteriaMet
    required property var assetsModel
    required property var collectiblesModel

    readonly property string title: isEditMode ? qsTr("Edit which addresses you share with %1").arg(communityName)
                                               : qsTr("Select addresses to share with %1").arg(communityName)

    readonly property var buttons: ObjectModel {
        StatusFlatButton {
            visible: root.isEditMode
            borderColor: Theme.palette.baseColor2
            text: qsTr("Cancel")
            onClicked: root.close()
        }
        StatusButton {
            enabled: root.selectedSharedAddresses.length && root.selectedAirdropAddress
            visible: root.isEditMode
            icon.name: Constants.authenticationIconByType[root.loginType]
            text: qsTr("Save changes")
            onClicked: {
                // TODO connect to backend
                root.close()
            }
        }
        StatusButton {
            visible: !root.isEditMode
            enabled: root.selectedAirdropAddress && root.selectedSharedAddresses.length
            text: qsTr("Share selected addresses to join")
            onClicked: {
                root.shareSelectedAddressesClicked(root.selectedAirdropAddress, root.selectedSharedAddresses)
                root.close()
            }
        }
        // NB no more buttons after this, see property `rightButtons` below
    }

    readonly property var rightButtons: [buttons.get(buttons.count-1)] // "magically" used by CommunityIntroDialog StatusStackModal impl

    readonly property string selectedAirdropAddress: accountSelector.selectedAirdropAddress
    readonly property var selectedSharedAddresses: accountSelector.selectedSharedAddresses

    signal close()
    signal shareSelectedAddressesClicked(string airdropAddress, var sharedAddresses)

    spacing: Style.current.padding

    QtObject {
        id: d

        // internal logic
        readonly property bool hasPermissions: root.permissionsModel && root.permissionsModel.count
    }

    padding: 0

    contentItem: ColumnLayout {
        spacing: 0
        // addresses
        SharedAddressesAccountSelector {
            id: accountSelector
            hasPermissions: d.hasPermissions
            uniquePermissionTokenKeys: PermissionsHelpers.getUniquePermissionTokenKeys(root.permissionsModel)
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight + topMargin + bottomMargin
            Layout.maximumHeight: hasPermissions ? permissionsView.implicitHeight > root.availableHeight / 2 ? root.availableHeight / 2 : root.availableHeight : -1
            Layout.fillHeight: !hasPermissions
            model: SortFilterProxyModel {
                sourceModel: root.walletAccountsModel
                filters: ValueFilter {
                    roleName: "walletType"
                    value: Constants.watchWalletType
                    inverted: true
                }
                sorters: [
                    ExpressionSorter {
                        function isGenerated(modelData) {
                            return modelData.walletType === Constants.generatedWalletType
                        }

                        expression: {
                            return isGenerated(modelLeft)
                        }
                    },
                    RoleSorter {
                        roleName: "position"
                    },
                    RoleSorter {
                        roleName: "name"
                    }
                ]
            }
        }

        // divider with top rounded corners + drop shadow
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.current.padding * 2
            color: Theme.palette.baseColor2
            radius: Style.current.padding
            border.width: 1
            border.color: Theme.palette.baseColor3
            visible: d.hasPermissions

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
            permissionsModel: root.permissionsModel
            assetsModel: root.assetsModel
            collectiblesModel: root.collectiblesModel
            communityName: root.communityName
            communityIcon: root.communityIcon

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.topMargin: -Style.current.padding // compensate for the half-rounded divider above
            visible: d.hasPermissions
        }
    }
}
