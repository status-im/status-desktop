import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

ColumnLayout {
    id: root

    signal displayConnectedDapps(string title)
    signal displayApprovals(string title)
    signal displayTrustLevels(string title)
    signal displaySecurity(string title)

    spacing: Constants.settingsSection.itemSpacing

    QtObject {
        id: d
    }

    StatusListItem {
        Layout.fillWidth: true
        title: qsTr("Connected")
        components: [
            StatusIcon {
                icon: "next"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.displayConnectedDapps(title)
        }
    }

    StatusListItem {
        Layout.fillWidth: true
        title: qsTr("Approvals")
        components: [
            StatusIcon {
                icon: "next"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.displayApprovals(title)
        }
    }

    StatusListItem {
        Layout.fillWidth: true
        title: qsTr("Trust levels")
        components: [
            StatusIcon {
                icon: "next"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.displayTrustLevels(title)
        }
    }

    StatusListItem {
        Layout.fillWidth: true
        title: qsTr("Security")
        components: [
            StatusIcon {
                icon: "next"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.displaySecurity(title)
        }
    }
}
