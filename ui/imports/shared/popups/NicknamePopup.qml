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
import utils 1.0

CommonContactDialog {
    id: root

    property string nickname: ""

    signal editDone(string newNickname)
    signal removeNicknameRequested()

    title: d.editMode ? qsTr("Edit nickname") : qsTr("Add nickname")

    onOpened: {
        nicknameInput.input.edit.forceActiveFocus()
    }

    readonly property var d: QtObject {
        id: d
        readonly property bool editMode: root.nickname !== ""
    }

    StatusInput {
        Layout.fillWidth: true
        id: nicknameInput
        label: qsTr("Nickname")
        input.clearable: true
        text: root.nickname
        charLimit: Constants.keypair.nameLengthMax
        validators: [
            StatusValidator {
                validatorObj: RXValidator { regularExpression: /^[\w\d_ -\.]*$/u }
                validate: (value) => validatorObj.test(value)
                errorMessage: qsTr("Invalid characters (use A-Z and 0-9, hyphens and underscores only)")
            },
            StatusMinLengthValidator {
                minLength: Constants.keypair.nameLengthMin
                errorMessage: qsTr("Nicknames must be at least %n character(s) long", "", minLength)
            },
            StatusValidator {
                name: "startsWithSpaceValidator"
                validate: function (t) { return !(t.startsWith(" ") || t.endsWith(" "))}
                errorMessage: qsTr("Nicknames can’t start or end with a space")
            },
            StatusValidator {
                name: "endsWith-ethValidator"
                validate: function (t) { return !(t.endsWith("-eth") || t.endsWith("_eth") || t.endsWith(".eth")) }
                errorMessage: qsTr("Nicknames can’t end in “.eth”, “_eth” or “-eth”")
            },
            StatusValidator {
                name: "isAliasValidator"
                validate: function (t) { return !Utils.isAlias(t) }
                errorMessage: qsTr("Adjective-animal nickname formats are not allowed")
            }
        ]
        onKeyPressed: {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (root.nickname !== nicknameInput.text && nicknameInput.valid)
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
