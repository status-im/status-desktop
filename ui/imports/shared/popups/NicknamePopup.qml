import QtQuick 2.13
import QtQuick.Controls 2.13

import DotherSide 0.1

import utils 1.0
import shared.controls 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: popup

    width: 400
    height: 340
    anchors.centerIn: parent

    header.title: qsTr("Nickname")
    header.subTitleElide: Text.ElideMiddle

    /*required*/ property string publicKey
    property string nickname

    readonly property int nicknameLength: nicknameInput.text.length
    readonly property int maxNicknameLength: 32

    signal editDone(string newNickname)

    onOpened: {
        nicknameInput.input.edit.forceActiveFocus()
    }

    contentItem: Item {
        width: popup.width
        height: childrenRect.height

        Column {
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 32
            spacing: 16

            StatusBaseText {
                id: descriptionText
                text: qsTr("Nicknames help you identify others in Status. Only you can see the nicknames you’ve added")
                wrapMode: Text.WordWrap
                color: Theme.palette.baseColor1
                width: parent.width
            }

            StatusInput {
                id: nicknameInput
                placeholderText: qsTr("Nickname")
                input.clearable: true
                width: parent.width
                text: popup.nickname
                charLimit: maxNicknameLength
                validationMode: StatusInput.ValidationMode.IgnoreInvalidInput
                validators: [
                    StatusRegularExpressionValidator {
                        validatorObj: RXValidator { regularExpression: /^[\w\d_ -]*$/u }
                        validate: function (value) {
                            return validatorObj.test(value)
                        }
                    }
                ]
                Keys.onReleased: {
                    if (event.key === Qt.Key_Return) {
                        editDone(nicknameInput.text)
                    }
                }
            }
        }
    }

    rightButtons: [
        StatusButton {
            id: doneBtn
            text: qsTr("Done")
            enabled: nicknameInput.valid
            onClicked: editDone(nicknameInput.text)
        }
    ]
}
