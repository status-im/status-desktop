import QtQuick 2.15
import QtQuick.Controls 2.15

import AppLayouts.Communities.controls 1.0
import AppLayouts.Communities.layouts 1.0
import AppLayouts.Communities.views 1.0

import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

import shared.popups 1.0

StackView {
    id: root

    required property var permissionsModel
    required property var assetsModel
    required property var collectiblesModel
    required property var channelsModel

    // id, name, image, color, owner properties expected
    required property var communityDetails

    property int viewWidth: 560 // by design
    property string previousPageName: depth > 1 ? qsTr("Permissions") : ""

    signal createPermissionRequested(int permissionType, var holdings,
                                     var channels, bool isPrivate)
    signal updatePermissionRequested(string key, int permissionType,
                                     var holdings, var channels, bool isPrivate)
    signal removePermissionRequested(string key)
    signal navigateToMintTokenSettings(bool isAssetType)

    function navigateBack() {
        if (depth === 2 && currentItem.toast.active)
            currentItem.toast.notifyDirty()
        else
            pop(StackView.Immediate)
    }

    // Community Permissions possible view contents:
    initialItem: SettingsPage {
        implicitWidth: 0

        title: qsTr("Permissions")

        buttons: StatusButton {
            objectName: "addNewItemButton"

            text: qsTr("Add new permission")

            onClicked: root.push(newPermissionView, StackView.Immediate)
        }

        contentItem: PermissionsView {
            permissionsModel: root.permissionsModel
            assetsModel: root.assetsModel
            collectiblesModel: root.collectiblesModel
            channelsModel: root.channelsModel
            communityDetails: root.communityDetails

            viewWidth: root.viewWidth

            onEditPermissionRequested: {
                const item = ModelUtils.get(root.permissionsModel, index)

                const properties = {
                    permissionKeyToEdit: item.key,
                    holdingsToEditModel: item.holdingsListModel,
                    channelsToEditModel: item.channelsListModel,
                    permissionTypeToEdit: item.permissionType,
                    isPrivateToEditValue: item.isPrivate
                }

                root.push(newPermissionView, properties, StackView.Immediate)
            }

            onDuplicatePermissionRequested: {
                const item = ModelUtils.get(root.permissionsModel, index)

                const properties = {
                    holdingsToEditModel: item.holdingsListModel,
                    channelsToEditModel: item.channelsListModel,
                    permissionTypeToEdit: item.permissionType,
                    isPrivateToEditValue: item.isPrivate
                }

                root.push(newPermissionView, properties, StackView.Immediate)
            }

            onRemovePermissionRequested: {
                const key = ModelUtils.get(root.permissionsModel, index, "key")
                root.removePermissionRequested(key)
            }
        }
    }

    Component {
        id: newPermissionView

        SettingsPage {
            id: newPermissionViewPage

            implicitWidth: 0

            title: isEditState ? qsTr("Edit permission") : qsTr("New permission")

            property alias holdingsToEditModel: editPermissionView.selectedHoldingsModel
            property alias channelsToEditModel: editPermissionView.selectedChannelsModel
            property alias permissionTypeToEdit: editPermissionView.permissionType
            property alias isPrivateToEditValue: editPermissionView.isPrivate

            property string permissionKeyToEdit
            readonly property bool isEditState: !!permissionKeyToEdit
            readonly property alias toast: settingsDirtyToastMessage

            contentItem: EditPermissionView {
                id: editPermissionView

                viewWidth: root.viewWidth

                assetsModel: root.assetsModel
                collectiblesModel: root.collectiblesModel
                channelsModel: root.channelsModel
                communityDetails: root.communityDetails

                isEditState: newPermissionViewPage.isEditState
                holdingsRequired: selectedHoldingsModel
                                  ? selectedHoldingsModel.count > 0 : false

                permissionDuplicated: {
                    // dependencies
                    holdingsTracker.revision
                    channelsTracker.revision
                    editPermissionView.dirtyValues.permissionType
                    editPermissionView.dirtyValues.isPrivate
                    const model = root.permissionsModel
                    const count = model.rowCount()

                    for (let i = 0; i < count; i++) {
                        const item = ModelUtils.get(model, i)

                        if (newPermissionViewPage.permissionKeyToEdit === item.key)
                            continue

                        const holdings = item.holdingsListModel
                        const channels = item.channelsListModel
                        const permissionType = item.permissionType

                        const same = (a, b) => ModelUtils.checkEqualitySet(a, b, ["key"])

                        if (holdings.rowCount() === 0)
                            if (dirtyValues.holdingsRequired)
                                continue
                            else
                                return true

                        if (holdings.rowCount() !== 0 && !dirtyValues.holdingsRequired)
                            continue

                        if (same(dirtyValues.selectedHoldingsModel, holdings)
                                && same(dirtyValues.selectedChannelsModel, channels)
                                && dirtyValues.permissionType === permissionType)
                            return true
                    }

                    return false
                }

                permissionTypeLimitReached: {
                    const type = dirtyValues.permissionType
                    const limit = PermissionTypes.getPermissionsCountLimit(type)

                    if (limit === -1)
                        return false

                    const model = root.permissionsModel
                    const count = model.rowCount()
                    let sameTypeCount = 0

                    for (let i = 0; i < count; i++)
                        if (type === ModelUtils.get(model, i, "permissionType"))
                            sameTypeCount++

                    return limit <= sameTypeCount
                }

                onCreatePermissionClicked: {
                    const holdings = dirtyValues.holdingsRequired ?
                                       ModelUtils.modelToArray(
                                           dirtyValues.selectedHoldingsModel,
                                           ["key", "type", "amount"]) : []

                    const channels = ModelUtils.modelToArray(
                                       dirtyValues.selectedChannelsModel, ["key"])

                    root.createPermissionRequested(
                                dirtyValues.permissionType, holdings, channels,
                                dirtyValues.isPrivate)

                    root.pop(StackView.Immediate)
                }

                onNavigateToMintTokenSettings: root.navigateToMintTokenSettings(isAssetType)

                function saveChanges() {
                    const holdings = dirtyValues.holdingsRequired ?
                                       ModelUtils.modelToArray(
                                           dirtyValues.selectedHoldingsModel,
                                           ["key", "type", "amount"])
                                     : []

                    const channels = ModelUtils.modelToArray(
                                       dirtyValues.selectedChannelsModel, ["key"])

                    root.updatePermissionRequested(
                                newPermissionViewPage.permissionKeyToEdit,
                                dirtyValues.permissionType, holdings, channels,
                                dirtyValues.isPrivate)
                }

                ModelChangeTracker {
                    id: holdingsTracker

                    model: editPermissionView.dirtyValues.selectedHoldingsModel
                }

                ModelChangeTracker {
                    id: channelsTracker

                    model: editPermissionView.dirtyValues.selectedChannelsModel
                }
            }

            SettingsDirtyToastMessage {
                id: settingsDirtyToastMessage

                z: 1
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                    bottomMargin: 16
                }

                saveChangesText: qsTr("Update permission")
                cancelChangesText: qsTr("Revert changes")

                saveChangesButtonEnabled:
                    !editPermissionView.permissionDuplicated
                    && !editPermissionView.permissionTypeLimitReached
                    && editPermissionView.isFullyFilled

                onSaveChangesClicked: {
                    editPermissionView.saveChanges()
                    root.pop(StackView.Immediate)
                }

                onResetChangesClicked: editPermissionView.resetChanges()

                Component.onCompleted: {
                    // delay to avoid toast blinking on entry
                    settingsDirtyToastMessage.active = Qt.binding(
                                     () => editPermissionView.isEditState &&
                                           editPermissionView.dirty)
                }
            }
        }
    }
}
