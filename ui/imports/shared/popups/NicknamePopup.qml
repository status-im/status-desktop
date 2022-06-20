import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared.controls 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

StatusModal {
    anchors.centerIn: parent

    id: popup
    width: Style.dp(400)
    height: Style.dp(340)
    header.title: qsTr("Nickname")

    property string nickname: ""
    property int nicknameLength: nicknameInput.text.length
    readonly property int maxNicknameLength: 32
    property bool nicknameTooLong: nicknameLength > maxNicknameLength
    signal editDone(string newNickname)

    onOpened: {
        nicknameInput.forceActiveFocus(Qt.MouseFocusReason);
    }

    contentItem: Item {
        width: popup.width
        height: childrenRect.height

        Column {
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - Style.dp(32)
            spacing: Style.dp(16)

            StatusBaseText {
                id: descriptionText
                //% "Nicknames help you identify others in Status. Only you can see the nicknames you’ve added"
                text: qsTrId("nicknames-help-you-identify-others-in-status--only-you-can-see-the-nicknames-you-ve-added")
                font.pixelSize: Style.current.primaryTextFontSize
                wrapMode: Text.WordWrap
                color: Theme.palette.baseColor1
                width: parent.width
            }

            StatusInput {
                id: nicknameInput
                //% "Nickname"
                input.placeholderText: qsTrId("nickname")
                text: nickname

                width: parent.width

                charLimit: maxNicknameLength
                validationMode: StatusInput.ValidationMode.IgnoreInvalidInput
                validators: [
                    StatusRegularExpressionValidator {
                        regularExpression: /^[0-9A-Za-z_-]*$/
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
            //% "Done"
            text: qsTrId("done")
            enabled: !popup.nicknameTooLong
            onClicked: editDone(nicknameInput.text)
        }
    ]
}
