import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups.Dialog 0.1

import shared.controls 1.0

CommonContactDialog {
    id: root

    readonly property string nickname: contactDetails.localNickname

    signal editDone(string newNickname)
    signal removeNicknameRequested()

    title: d.editMode ? qsTr("Edit nickname") : qsTr("Add nickname")

    onOpened: {
        nicknameInput.input.edit.forceActiveFocus()
    }

    readonly property var d: QtObject {
        id: d
        readonly property bool editMode: root.nickname !== ""
        readonly property int maxNicknameLength: 32
    }

    StatusInput {
        Layout.fillWidth: true
        id: nicknameInput
        label: qsTr("Nickname")
        input.clearable: true
        text: root.nickname
        charLimit: d.maxNicknameLength
        validationMode: StatusInput.ValidationMode.IgnoreInvalidInput
        validators: [
            StatusValidator {
                validatorObj: RXValidator { regularExpression: /^[\w\d_ -]*$/u }
                validate: (value) => validatorObj.test(value)
            }
        ]
        Keys.onReleased: {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.editDone(nicknameInput.text)
            }
        }
    }

    StatusBaseText {
        Layout.fillWidth: true
        text: qsTr("Nicknames help you identify others and are only visible to you")
        wrapMode: Text.WordWrap
        color: Theme.palette.baseColor1
        font.pixelSize: Theme.tertiaryTextFontSize
    }

    rightButtons: ObjectModel {
        StatusFlatButton {
            visible: !d.editMode
            text: qsTr("Cancel")
            onClicked: root.close()
        }
        StatusFlatButton {
            visible: d.editMode
            borderColor: "transparent"
            type: StatusBaseButton.Type.Danger
            text: qsTr("Remove nickname")
            onClicked: root.removeNicknameRequested()
        }
        StatusButton {
            enabled: root.nickname !== nicknameInput.text && nicknameInput.valid
            text: d.editMode ? qsTr("Change nickname") : qsTr("Add nickname")
            onClicked: root.editDone(nicknameInput.text)
        }
    }
}
