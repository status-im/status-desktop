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

    spacing: 8

    StatusBaseText {
        text: qsTr("Community colour")
        font.pixelSize: 15
        color: Theme.palette.directColor1
    }

    StatusPickerButton {
        Layout.fillWidth: true

        property string validationError: ""

        bgColor: root.color
        contentColor: Theme.palette.indirectColor1
        text: root.color.toString()

        onClicked: {
            colorDialog.color = root.color
            colorDialog.open()
        }
        onTextChanged: {
            validationError = Utils.validateAndReturnError(
                        text,
                        Utils.Validate.NoEmpty | Utils.Validate.TextHexColor)
        }

        StatusColorDialog {
            id: colorDialog
            anchors.centerIn: parent
            header.title: qsTr("Community Colour")
            previewText: qsTr("White text should be legable on top of this colour")
            acceptText: qsTr("Select Community Colour")
            onAccepted: {
                root.color = color
            }
        }
    }
}
