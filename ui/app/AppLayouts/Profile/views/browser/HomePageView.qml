import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

ColumnLayout {
    id: root

    property string homepage: ""

    spacing: 0

    StatusBaseText {
        text: qsTr("homepage")
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
        checked: root.homepage == ""
        text: qsTr("System default")
    }

    StatusRadioButton {
        id: customRadioButton
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 10
        checked: root.homepage !== ""
        text: qsTr("Other")
    }

    StatusBaseInput {
        id: customUrlInput
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 10
        visible: customRadioButton.checked
        placeholderText: qsTr("Example: duckduckgo.com")
        text: root.homepage
        onTextChanged: {
            root.homepage = text
        }
    }

} // Column
