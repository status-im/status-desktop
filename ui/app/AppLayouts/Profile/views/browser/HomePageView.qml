import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core
import StatusQ.Core.Theme

ColumnLayout {
    id: root

    property var accountSettings

    spacing: 0

    StatusBaseText {
        text: qsTr("Homepage")
        color: Theme.palette.directColor1
    }

    ButtonGroup {
        id: homepageGroup
        buttons: [defaultRadioButton, customRadioButton]
        exclusive: true
    }

    StatusRadioButton {
        id: defaultRadioButton
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 10
        checked: root.accountSettings.browserHomepage === ""
        text: qsTr("System default")
    }

    StatusRadioButton {
        id: customRadioButton
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 10
        checked: root.accountSettings.browserHomepage !== ""
        text: qsTr("Other")
    }

    StatusInput {
        id: customUrlInput
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 10
        visible: customRadioButton.checked
        placeholderText: qsTr("Example: duckduckgo.com")
        text: root.accountSettings.browserHomepage
        onTextChanged: {
            root.accountSettings.browserHomepage = text
        }
    }
}
