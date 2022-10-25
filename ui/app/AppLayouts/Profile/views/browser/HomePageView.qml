import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

ColumnLayout {
    id: root

    property var accountSettings

    spacing: 0

    StatusBaseText {
        text: qsTr("Homepage")
        font.pixelSize: 15
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

} // Column
