import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import utils

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Popups
import StatusQ.Controls

ColumnLayout {
    id: root

    property color color: Theme.palette.primaryColor1
    property string title: qsTr("Community colour")

    signal pick()

    spacing: 8

    StatusBaseText {
        Layout.fillWidth: true
        text: root.title
    }

    StatusPickerButton {
        Layout.fillWidth: true
        Layout.preferredHeight: 44

        property string validationError: ""

        bgColor: root.color
        contentColor: StatusColors.colors.white
        text: root.color.toString()
        font.weight: Font.Normal
        icon.width: 24
        icon.height: 24
        onClicked: root.pick()

        onTextChanged: {
            validationError = Utils.validateAndReturnError(
                        text,
                        Utils.Validate.NoEmpty | Utils.Validate.TextHexColor)
        }
    }
}
