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

    property bool isEditMode

    property bool requirementsCheckPending: false

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
            enabled: d.dirty
            type: d.lostCommunityPermission || d.lostChannelPermissions ? StatusBaseButton.Type.Danger : StatusBaseButton.Type.Normal
            visible: root.isEditMode
            icon.name: type === StatusBaseButton.Type.Normal && d.selectedAddressesDirty?
                           !root.isEditMode? Constants.authenticationIconByType[root.loginType] : ""
                            : ""
            text: d.lostCommunityPermission ? qsTr("Save changes & leave %1").arg(root.communityName) :
                                              d.lostChannelPermissions ? qsTr("Save changes & update my permissions")
                                                                       : qsTr("Prove ownership")
            onClicked: {
                root.prepareForSigning(root.selectedAirdropAddress, root.selectedSharedAddresses)
            }
        }
        StatusButton {
            visible: !root.isEditMode
            text: qsTr("Share selected addresses to join")
            onClicked: {
                root.shareSelectedAddressesClicked(root.selectedAirdropAddress, root.selectedSharedAddresses)
                root.close()
            }
        }
        // NB no more buttons after this, see property `rightButtons` below
    }

    readonly property var rightButtons: [buttons.get(buttons.count-1)] // "magically" used by CommunityIntroDialog StatusStackModal impl

    property var selectedSharedAddresses: []
    property string selectedAirdropAddress

    signal sharedAddressesChanged(string airdropAddress, var sharedAddresses)
    signal shareSelectedAddressesClicked(string airdropAddress, var sharedAddresses)
    signal prepareForSigning(string airdropAddress, var sharedAddresses)

    signal close()

    padding: 0
    spacing: Style.current.padding

    QtObject {
        id: d

        // internal logic
        readonly property bool hasPermissions: root.permissionsModel && root.permissionsModel.count

        // initial state (not bindings, we want a static snapshot of the initial state)
        property var initialSelectedSharedAddresses: []
        property string initialSelectedAirdropAddress

        // dirty state handling
        readonly property bool selectedAddressesDirty: !SQInternal.ModelUtils.isSameArray(d.initialSelectedSharedAddresses, root.selectedSharedAddresses)
        readonly property bool selectedAirdropAddressDirty: root.selectedAirdropAddress !== d.initialSelectedAirdropAddress
        readonly property bool dirty: selectedAddressesDirty || selectedAirdropAddressDirty

        // warning states
        readonly property bool lostCommunityPermission: root.isEditMode && permissionsView.lostPermissionToJoin
        readonly property bool lostChannelPermissions: root.isEditMode && permissionsView.lostChannelPermissions
    }

    Component.onCompleted: {
        // initialize the state
        d.initialSelectedSharedAddresses = root.selectedSharedAddresses.length ? root.selectedSharedAddresses
                                                                               : filteredAccountsModel.count ? ModelUtils.modelToFlatArray(filteredAccountsModel, "address")
                                                                                                             : []
        d.initialSelectedAirdropAddress = !!root.selectedAirdropAddress ? root.selectedAirdropAddress
                                                                        : d.initialSelectedSharedAddresses.length ? d.initialSelectedSharedAddresses[0] : ""
        root.selectedSharedAddresses = accountSelector.selectedSharedAddresses
        root.selectedAirdropAddress = accountSelector.selectedAirdropAddress
    }

    function setOldSharedAddresses(oldSharedAddresses) {
        d.initialSelectedSharedAddresses = oldSharedAddresses
        accountSelector.selectedSharedAddresses = Qt.binding(() => d.initialSelectedSharedAddresses)
        accountSelector.applyChange()
    }

    function setOldAirdropAddress(oldAirdropAddress) {
        d.initialSelectedAirdropAddress = oldAirdropAddress
        accountSelector.selectedAirdropAddress = Qt.binding(() => d.initialSelectedAirdropAddress)
        accountSelector.applyChange()
    }

    SortFilterProxyModel {
        id: filteredAccountsModel
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
            selectedSharedAddresses: d.initialSelectedSharedAddresses
            selectedAirdropAddress: d.initialSelectedAirdropAddress
            onAddressesChanged: accountSelector.applyChange()
            function applyChange() {
                root.selectedSharedAddresses = selectedSharedAddresses
                root.selectedAirdropAddress = selectedAirdropAddress
                root.sharedAddressesChanged(selectedAirdropAddress, selectedSharedAddresses)
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
            isEditMode: root.isEditMode
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
