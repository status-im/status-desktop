import QtQuick 2.14

import AppLayouts.Chat.layouts 1.0
import AppLayouts.Chat.views.communities 1.0
import AppLayouts.Chat.stores 1.0

import utils 1.0

SettingsPageLayout {
    id: root

    property var rootStore
    property var store: CommunitiesStore {}
    property int viewWidth: 560 // by design

    function navigateBack() {
        if (root.state === d.newPermissionViewState) {
            root.state = d.getInitialState()
        } else if(root.state === d.permissionsViewState) {
            root.state = d.newPermissionViewState
        } else if(root.state === d.editPermissionViewState) {
            if (root.dirty) {
                root.notifyDirty()
            } else {
                root.state = d.getInitialState()
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
        property var permissionsToEditObject
        property ListModel channelsToEditModel: ListModel {}
        property bool isPrivateToEditValue: false

        onPermissionsExistChanged: {
            // Navigate back to welcome permissions view if all existing permissions are removed.
            if(root.state === d.permissionsViewState && !permissionsExist) {
                root.state =  d.welcomeViewState;
            }
        }

        function getInitialState() {
            return root.store.permissionsModel.count > 0 ? d.permissionsViewState : d.welcomeViewState
        }

        function initializeData() {
            holdingsToEditModel = defaultListObject.createObject(d)
            permissionsToEditObject = null
            channelsToEditModel = defaultListObject.createObject(d)
            isPrivateToEditValue = false
        }
    }

    saveChangesButtonEnabled: true
    saveChangesText: qsTr("Update permission")
    cancelChangesText: qsTr("Revert changes")
    state: d.getInitialState()
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
            id: newPermissionViewItem

            viewWidth: root.viewWidth
            rootStore: root.rootStore
            store: root.store
            onPermissionCreated: root.state = d.permissionsViewState
            isEditState: root.state === d.editPermissionViewState
            permissionIndex: d.permissionIndexToEdit
            holdingsModel: d.holdingsToEditModel
            permissionObject: d.permissionsToEditObject
            channelsModel: d.channelsToEditModel
            isPrivate: d.isPrivateToEditValue

            Connections {
                target: d

                function onSaveChanges() {
                    newPermissionViewItem.saveChanges()
                }

                function onResetChanges() {
                    newPermissionViewItem.resetChanges()
                }
            }

            Component.onCompleted: {
                root.dirty = Qt.binding(() => newPermissionViewItem.isEditState && newPermissionViewItem.dirty)
            }
        }
    }

    Component {
        id: permissionsView
        CommunityPermissionsView {
            viewWidth: root.viewWidth
            rootStore: root.rootStore
            store: root.store
            onEditPermission: {
                d.permissionIndexToEdit = index
                d.holdingsToEditModel = holidings
                d.permissionsToEditObject = permission
                d.channelsToEditModel = channels
                d.isPrivateToEditValue = isPrivate
                root.state = d.editPermissionViewState
            }
        }
    }

    Component {
        id: defaultListObject
        ListModel {}
    }
}
