import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core

ColumnLayout {
    id: root

    required property var accountSettings

    StatusBaseText {
        text: qsTr("Open links in")
    }

    ButtonGroup {
        exclusive: true
    }

    StatusRadioButton {
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 10
        checked: accountSettings.openLinksInStatus
        text: qsTr("Status Browser (default)")
        onToggled: {
            if (checked) {
                accountSettings.openLinksInStatus = true
            }
        }
    }

    StatusRadioButton {
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 10
        checked: !accountSettings.openLinksInStatus
        text: qsTr("System Browser")
        onToggled: {
            if (checked) {
                accountSettings.openLinksInStatus = false
            }
        }
    }
}
