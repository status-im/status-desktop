import QtQuick 2.14

import AppLayouts.Chat.controls.community 1.0
import AppLayouts.Chat.layouts 1.0
import AppLayouts.Chat.stores 1.0
import AppLayouts.Chat.views.communities 1.0

import StatusQ.Core.Utils 0.1
import utils 1.0

SettingsPageLayout {
    id: root

    required property var permissionsModel
    required property var assetsModel
    required property var collectiblesModel
    required property var channelsModel

    // name, image, color properties expected
    required property var communityDetails

    property bool isOwner: false

    property int viewWidth: 560 // by design

    // TODO: temporary property, to be removed when no need to hide the switch
    // in the app
    property bool showWhoHoldsSwitch: false

    signal createPermissionRequested(
        int permissionType, var holdings, var channels, bool isPrivate)

    signal updatePermissionRequested(
        string key, int permissionType, var holdings, var channels, bool isPrivate)

    signal removePermissionRequested(string key)

    signal navigateToMintTokenSettings

    function navigateBack() {
        if (root.state === d.newPermissionViewState) {
            root.state = d.initialState
        } else if (root.state === d.permissionsViewState) {
            root.state = d.newPermissionViewState
        } else if (root.state === d.editPermissionViewState) {
            if (root.dirty) {
                root.notifyDirty()
            } else {
                root.state = d.initialState
            }
        }
    }

    QtObject {
        id: d

        readonly property string welcomeViewState: "WELCOME"
        readonly property string newPermissionViewState: "NEW_PERMISSION"
        readonly property string permissionsViewState: "PERMISSIONS"
        readonly property string editPermissionViewState: "EDIT_PERMISSION"
        readonly property bool permissionsExist: root.permissionsModel.count > 0

        signal saveChanges
        signal resetChanges

        property string permissionKeyToEdit

        property var holdingsToEditModel
        property int permissionTypeToEdit: PermissionTypes.Type.None
        property var channelsToEditModel
        property bool isPrivateToEditValue: false

        onPermissionsExistChanged: {
            // Navigate back to welcome permissions view if all existing permissions are removed.
            if(root.state === d.permissionsViewState && !permissionsExist) {
                root.state = d.welcomeViewState;
            }
        }

        readonly property string initialState: d.permissionsExist ? d.permissionsViewState : d.welcomeViewState

        function initializeData() {
            holdingsToEditModel = emptyModel
            channelsToEditModel = emptyModel
            permissionTypeToEdit = PermissionTypes.Type.None
            isPrivateToEditValue = false
        }
    }

    saveChangesButtonEnabled: true
    saveChangesText: qsTr("Update permission")
    cancelChangesText: qsTr("Revert changes")
    state: d.initialState
    states: [
        State {
            name: d.welcomeViewState
            PropertyChanges {target: root; title: qsTr("Permissions")}
            PropertyChanges {target: root; previousPageName: ""}
            PropertyChanges {target: root; content: welcomeView}
            PropertyChanges {target: root; primaryHeaderButton.visible: true}
            PropertyChanges {target: root; primaryHeaderButton.text: qsTr("Add new permission")}
        },
        State {
            name: d.newPermissionViewState
            PropertyChanges {target: root; title: qsTr("New permission")}
            PropertyChanges {target: root; previousPageName: qsTr("Permissions")}
            PropertyChanges {target: root; content: newPermissionView}
            PropertyChanges {target: root; primaryHeaderButton.visible: false}
        },
        State {
            name: d.permissionsViewState
            PropertyChanges {target: root; title: qsTr("Permissions")}
            PropertyChanges {target: root; previousPageName: ""}
            PropertyChanges {target: root; content: permissionsView}
            PropertyChanges {target: root; primaryHeaderButton.visible: true}
            PropertyChanges {target: root; primaryHeaderButton.text: qsTr("Add new permission")}
        },
        State {
            name: d.editPermissionViewState
            PropertyChanges {target: root; title: qsTr("Edit permission")}
            PropertyChanges {target: root; previousPageName: qsTr("Permissions")}
            PropertyChanges {target: root; content: newPermissionView}
            PropertyChanges {target: root; primaryHeaderButton.visible: false}
        }
    ]

    onPrimaryHeaderButtonClicked: {
        if(root.state === d.welcomeViewState || root.state === d.permissionsViewState) {
            d.initializeData()
            root.state = d.newPermissionViewState
        }
    }

    onSaveChangesClicked: {
        d.saveChanges()
        d.resetChanges()

        root.navigateBack()
    }

    onResetChangesClicked: {
        d.resetChanges()

        root.navigateBack()
    }

    // Community Permissions possible view contents:
    Component {
        id: welcomeView

        CommunityWelcomeSettingsView {
            viewWidth: root.viewWidth
            image: Style.png("community/permissions2_3")
            title: qsTr("Permissions")
            subtitle: qsTr("You can manage your community by creating and issuing membership and access permissions")
            checkersModel: [
                qsTr("Give individual members access to private channels"),
                qsTr("Monetise your community with subscriptions and fees"),
                qsTr("Require holding a token or NFT to obtain exclusive membership rights")
            ]
        }
    }

    Component {
        id: newPermissionView

        CommunityNewPermissionView {
            id: communityNewPermissionView

            viewWidth: root.viewWidth

            assetsModel: root.assetsModel
            collectiblesModel: root.collectiblesModel
            channelsModel: root.channelsModel
            communityDetails: root.communityDetails
            isOwner: root.isOwner

            isEditState: root.state === d.editPermissionViewState

            selectedHoldingsModel: d.holdingsToEditModel
            selectedChannelsModel: d.channelsToEditModel

            permissionType: d.permissionTypeToEdit
            isPrivate: d.isPrivateToEditValue
            holdingsRequired: selectedHoldingsModel ? selectedHoldingsModel.count > 0
                                                    : false

            showWhoHoldsSwitch: root.showWhoHoldsSwitch

            permissionDuplicated: {
                // dependencies
                holdingsTracker.revision
                channelsTracker.revision
                communityNewPermissionView.dirtyValues.permissionType
                communityNewPermissionView.dirtyValues.isPrivate
                const model = root.permissionsModel
                const count = model.rowCount()

                for (let i = 0; i < count; i++) {
                    const item = ModelUtils.get(model, i)

                    if (root.state === d.editPermissionViewState
                            && d.permissionKeyToEdit === item.key)
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
                                       ["key", "type", "amount"])
                                 : []

                const channels = ModelUtils.modelToArray(
                                   dirtyValues.selectedChannelsModel, ["key"])

                root.createPermissionRequested(
                            dirtyValues.permissionType, holdings, channels,
                            dirtyValues.isPrivate)

                root.state = d.permissionsViewState
            }

            onNavigateToMintTokenSettings: root.navigateToMintTokenSettings()

            Connections {
                target: d

                function onSaveChanges() {
                    const holdings = dirtyValues.holdingsRequired ?
                                       ModelUtils.modelToArray(
                                           dirtyValues.selectedHoldingsModel,
                                           ["key", "type", "amount"])
                                     : []

                    const channels = ModelUtils.modelToArray(
                                       dirtyValues.selectedChannelsModel, ["key"])

                    root.updatePermissionRequested(
                                d.permissionKeyToEdit, dirtyValues.permissionType,
                                holdings, channels, dirtyValues.isPrivate)
                }

                function onResetChanges() {
                    resetChanges()
                }
            }

            Binding {
                target: root
                property: "dirty"
                value: isEditState && dirty
            }

            ModelChangeTracker {
                id: holdingsTracker

                model: communityNewPermissionView.dirtyValues.selectedHoldingsModel
            }

            ModelChangeTracker {
                id: channelsTracker

                model: communityNewPermissionView.dirtyValues.selectedChannelsModel
            }

            Binding {
                target: root
                property: "saveChangesButtonEnabled"
                value: !communityNewPermissionView.permissionDuplicated
                       && !communityNewPermissionView.permissionTypeLimitReached
                       && communityNewPermissionView.isFullyFilled
            }
        }
    }

    Component {
        id: permissionsView

        CommunityPermissionsView {
            permissionsModel: root.permissionsModel
            assetsModel: root.assetsModel
            collectiblesModel: root.collectiblesModel
            channelsModel: root.channelsModel
            communityDetails: root.communityDetails

            viewWidth: root.viewWidth

            function setInitialValuesFromIndex(index) {
                const item = ModelUtils.get(root.permissionsModel, index)

                d.holdingsToEditModel = item.holdingsListModel
                d.channelsToEditModel = item.channelsListModel
                d.permissionTypeToEdit = item.permissionType
                d.isPrivateToEditValue = item.isPrivate
            }

            onEditPermissionRequested: {
                setInitialValuesFromIndex(index)
                d.permissionKeyToEdit = ModelUtils.get(
                            root.permissionsModel, index, "key")
                root.state = d.editPermissionViewState
            }

            onDuplicatePermissionRequested: {
                setInitialValuesFromIndex(index)
                root.state = d.newPermissionViewState
            }

            onRemovePermissionRequested: {
                const key = ModelUtils.get(root.permissionsModel, index, "key")
                root.removePermissionRequested(key)
            }
        }
    }

    ListModel {
        id: emptyModel
    }
}
