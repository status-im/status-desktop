import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1

ColumnLayout {
    id: root

    property color color: Theme.palette.primaryColor1

    signal pick()

    spacing: 8

    implicitHeight: childrenRect.height
    StatusBaseText {
        text: qsTr("Community colour")
        font.pixelSize: 15
    }

    StatusPickerButton {
        Layout.fillWidth: true

        property string validationError: ""

        bgColor: root.color
        contentColor: Theme.palette.white
        text: root.color.toString()
        onClicked: root.pick()

        onTextChanged: {
            validationError = Utils.validateAndReturnError(
                        text,
                        Utils.Validate.NoEmpty | Utils.Validate.TextHexColor)
        }
    }
}
