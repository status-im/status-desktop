import QtQuick 2.14

import "../../layouts"
import "../../views/communities"

SettingsPageLayout {
    id: root

    QtObject {
        id: d

        readonly property string welcomeViewState: "WELCOME"
        readonly property string newPermissionViewState: "NEWPERMISSION"
    }

    state: d.welcomeViewState // Initial state
    states: [
        State {
            name: d.welcomeViewState
            PropertyChanges {target: root; title: qsTr("Permissions")}
            PropertyChanges {target: root; previousPage: ""}
            PropertyChanges {target: root; content: welcomeView}
        },
        State {
            name: d.newPermissionViewState
            PropertyChanges {target: root; title: qsTr("New permission")}
            PropertyChanges {target: root; previousPage: qsTr("Permissions")}
            PropertyChanges {target: root; content: newPermissionView}
        }
    ]

    onPreviousPageClicked: {
        if(root.state === d.newPermissionViewState) {
            root.state = d.welcomeViewState
        }
    }

    // Community Permissions possible view contents:
    Component {
        id: welcomeView
        CommunityWelcomePermissionsView {
            onAddPermission: root.state = d.newPermissionViewState
        }
    }

    Component {
        id: newPermissionView
        CommunityNewPermissionView {}
    }
}
