import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusInput {
    id: root

    property bool interactive: true
    property bool checkMarkVisible

    signal clearClicked()
    signal validateInputRequested()

    placeholderText: qsTr("Enter an ENS name or address")
    input.background.color: Theme.palette.indirectColor1
    input.background.border.width: 0
    input.implicitHeight: 56
    rightPadding: 12
    input.clearable: false // custom button below
    input.edit.readOnly: !root.interactive
    multiline: false
    input.edit.textFormat: TextEdit.RichText

    input.rightComponent: RowLayout {
        StatusButton {
            objectName: "pasteButton"
            font.weight: Font.Normal
            borderColor: Theme.palette.primaryColor1
            borderWidth: 1
            size: StatusBaseButton.Size.Tiny
            text: qsTr("Paste")
            visible: root.input.edit.length === 0 && root.input.edit.canPaste
            focusPolicy: Qt.NoFocus
            onClicked: {
                root.input.edit.forceActiveFocus()
                root.text = QClipboardProxy.text // paste plain text
                root.input.edit.cursorPosition = root.input.edit.length
                root.validateInputRequested()
            }
        }
        StatusIcon {
            objectName: "checkmarkIcon"
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            icon: "tiny/checkmark"
            color: Theme.palette.primaryColor1
            visible: root.checkMarkVisible
        }
        StatusClearButton {
            objectName: "clearButton"
            visible: root.input.edit.length !== 0 && root.interactive
            onClicked: {
                root.input.edit.clear()
                root.clearClicked()
            }
        }
    }

    Connections {
        target: root.input
        function onKeyPressed(event) {
            if (event.matches(StandardKey.Paste)) {
                event.accepted = true
                root.text = QClipboardProxy.text // paste plain text
            }
        }
    }

    Keys.onTabPressed: event.accepted = true
    Keys.onReleased: root.validateInputRequested()
}
