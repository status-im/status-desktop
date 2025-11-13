import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Theme

ColumnLayout {
    id: root

    required property var accountSettings

    StatusBaseText {
        Layout.fillWidth: true
        text: qsTr("Open links in")
        wrapMode: Text.WordWrap
    }

    StatusBaseText {
        Layout.fillWidth: true
        text: qsTr("Choose which browser to use for opening links in Status")
        color: Theme.palette.baseColor1
        wrapMode: Text.WordWrap
    }

    StatusRadioButton {
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 10
        checked: accountSettings.openLinksInStatus
        text: qsTr("Status browser")
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
        text: qsTr("User device default browser")
        onToggled: {
            if (checked) {
                accountSettings.openLinksInStatus = false
            }
        }
    }
}
