import QtQuick 2.14

import AppLayouts.Chat.controls.community 1.0
import AppLayouts.Chat.layouts 1.0
import AppLayouts.Chat.stores 1.0
import AppLayouts.Chat.views.communities 1.0

import StatusQ.Core.Utils 0.1
import utils 1.0

SettingsPageLayout {
    id: root

    property var rootStore
    property var store: CommunitiesStore {}
    property int viewWidth: 560 // by design

    function navigateBack() {
        if (root.state === d.newPermissionViewState) {
            root.state = d.initialState
        } else if(root.state === d.permissionsViewState) {
            root.state = d.newPermissionViewState
        } else if(root.state === d.editPermissionViewState) {
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
        readonly property bool permissionsExist: store.permissionsModel.count > 0

        signal saveChanges
        signal resetChanges

        property int permissionIndexToEdit
        property ListModel holdingsToEditModel: ListModel {}
        property int permissionTypeToEdit: PermissionTypes.Type.None
        property ListModel channelsToEditModel: ListModel {}
        property bool isPrivateToEditValue: false

        onPermissionsExistChanged: {
            // Navigate back to welcome permissions view if all existing permissions are removed.
            if(root.state === d.permissionsViewState && !permissionsExist) {
                root.state =  d.welcomeViewState;
            }
        }

        readonly property string initialState: root.store.permissionsModel.count > 0
                                               ? d.permissionsViewState : d.welcomeViewState

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
            PropertyChanges {target: root; headerButtonVisible: true}
            PropertyChanges {target: root; headerButtonText: qsTr("Add new permission")}
            PropertyChanges {target: root; headerWidth: root.viewWidth}
        },
        State {
            name: d.newPermissionViewState
            PropertyChanges {target: root; title: qsTr("New permission")}
            PropertyChanges {target: root; previousPageName: qsTr("Permissions")}
            PropertyChanges {target: root; content: newPermissionView}
            PropertyChanges {target: root; headerButtonVisible: false}
            PropertyChanges {target: root; headerWidth: 0}
        },
        State {
            name: d.permissionsViewState
            PropertyChanges {target: root; title: qsTr("Permissions")}
            PropertyChanges {target: root; previousPageName: ""}
            PropertyChanges {target: root; content: permissionsView}
            PropertyChanges {target: root; headerButtonVisible: true}
            PropertyChanges {target: root; headerButtonText: qsTr("Add new permission")}
            PropertyChanges {target: root; headerWidth: root.viewWidth}
        },
        State {
            name: d.editPermissionViewState
            PropertyChanges {target: root; title: qsTr("Edit permission")}
            PropertyChanges {target: root; previousPageName: qsTr("Permissions")}
            PropertyChanges {target: root; content: newPermissionView}
            PropertyChanges {target: root; headerButtonVisible: false}
            PropertyChanges {target: root; headerWidth: 0}
        }
    ]

    onHeaderButtonClicked: {
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
            image: Style.png("community/permissions21_3_1")
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

            rootStore: root.rootStore
            store: root.store

            isEditState: root.state === d.editPermissionViewState

            holdingsModel: d.holdingsToEditModel
            channelsModel: d.channelsToEditModel

            permissionType: d.permissionTypeToEdit
            isPrivate: d.isPrivateToEditValue

            duplicationWarningVisible: {
                // dependencies
                holdingsTracker.revision
                channelsTracker.revision
                communityNewPermissionView.dirtyValues.permissionType
                communityNewPermissionView.dirtyValues.isPrivate

                const model = root.store.permissionsModel
                const count = model.rowCount()

                for (let i = 0; i < count; i++) {
                    if (root.state === d.editPermissionViewState
                            && d.permissionIndexToEdit === i)
                        continue

                    const item = ModelUtils.get(model, i)

                    const holdings = item.holdingsListModel
                    const channels = item.channelsListModel
                    const permissionType = item.permissionType

                    const same = (a, b) => ModelUtils.checkEqualitySet(a, b, ["key"])

                    if (same(dirtyValues.holdingsModel, holdings)
                            && same(dirtyValues.channelsModel, channels)
                            && dirtyValues.permissionType === permissionType)
                        return true
                }

                return false
            }

            onCreatePermissionClicked: {
                root.store.createPermission(dirtyValues.holdingsModel,
                                            dirtyValues.permissionType,
                                            dirtyValues.isPrivate,
                                            dirtyValues.channelsModel)

                root.state = d.permissionsViewState
            }

            Connections {
                target: d

                function onSaveChanges() {
                    root.store.editPermission(
                                d.permissionIndexToEdit,
                                dirtyValues.holdingsModel,
                                dirtyValues.permissionType,
                                dirtyValues.channelsModel,
                                dirtyValues.isPrivate)
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

                model: communityNewPermissionView.dirtyValues.holdingsModel
            }

            ModelChangeTracker {
                id: channelsTracker

                model: communityNewPermissionView.dirtyValues.channelsModel
            }

            Binding {
                target: root
                property: "saveChangesButtonEnabled"
                value: !communityNewPermissionView.duplicationWarningVisible
                       && communityNewPermissionView.isFullyFilled
            }
        }
    }

    Component {
        id: permissionsView

        CommunityPermissionsView {
            viewWidth: root.viewWidth
            rootStore: root.rootStore
            store: root.store

            function setInitialValuesFromIndex(index) {
                const item = ModelUtils.get(root.store.permissionsModel, index)

                d.holdingsToEditModel = item.holdingsListModel
                d.channelsToEditModel = item.channelsListModel
                d.permissionTypeToEdit = item.permissionType
                d.isPrivateToEditValue = item.isPrivate
            }

            onEditPermissionRequested: {
                setInitialValuesFromIndex(index)
                d.permissionIndexToEdit = index
                root.state = d.editPermissionViewState
            }

            onDuplicatePermissionRequested: {
                setInitialValuesFromIndex(index)
                root.state = d.newPermissionViewState
            }

            onRemovePermissionRequested: {
                root.store.removePermission(index)
            }
        }
    }

    ListModel {
        id: emptyModel
    }
}
