import QtQuick 2.14

import AppLayouts.Chat.layouts 1.0
import AppLayouts.Chat.views.communities 1.0
import AppLayouts.Chat.stores 1.0

SettingsPageLayout {
    id: root

    property var store: CommunitiesStore {}
    property int viewWidth: 560 // by design

    function navigateBack() {
        if (root.state === d.newPermissionViewState) {
            root.state = d.getInitialState()
        }
        else if(root.state === d.permissionsViewState) {
            root.state = d.newPermissionViewState;
        }
    }

    QtObject {
        id: d

        readonly property string welcomeViewState: "WELCOME"
        readonly property string newPermissionViewState: "NEWPERMISSION"
        readonly property string permissionsViewState: "PERMISSIONS"

        function getInitialState() {
            return root.store.permissionsModel.count > 0 ? d.permissionsViewState : d.welcomeViewState
        }
    }

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
        }
    ]

    onHeaderButtonClicked: {
        if(root.state === d.welcomeViewState)
            root.state = d.newPermissionViewState

        else if (root.state === d.permissionsViewState)
            root.state = d.newPermissionViewState
    }

    // Community Permissions possible view contents:
    Component {
        id: welcomeView
        CommunityWelcomePermissionsView {
            viewWidth: root.viewWidth
        }
    }

    Component {
        id: newPermissionView
        CommunityNewPermissionView {
            viewWidth: root.viewWidth
            store: root.store
            onPermissionCreated: root.state = d.permissionsViewState
        }
    }

    Component {
        id: permissionsView
        CommunityPermissionsView {
            viewWidth: root.viewWidth
            store: root.store
        }
    }
}
