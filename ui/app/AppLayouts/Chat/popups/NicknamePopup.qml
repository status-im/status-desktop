import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import "../../../../shared/controls"

StatusModal {
    anchors.centerIn: parent

    id: popup
    width: 400
    height: 390
    header.title: qsTr("Nickname")
    header.subTitle: isEnsVerified ? alias : fromAuthor
    header.subTitleElide: !isEnsVerified ? Text.ElideMiddle : Text.ElideNone

    property int nicknameLength: nicknameInput.textField.text.length
    readonly property int maxNicknameLength: 32
    property bool nicknameTooLong: nicknameLength > maxNicknameLength
    signal doneClicked(string newUsername, string newNickname)

    onOpened: {
        nicknameInput.forceActiveFocus(Qt.MouseFocusReason);
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
                //% "Nicknames help you identify others in Status. Only you can see the nicknames you’ve added"
                text: qsTrId("nicknames-help-you-identify-others-in-status--only-you-can-see-the-nicknames-you-ve-added")
                font.pixelSize: 15
                wrapMode: Text.WordWrap
                color: Theme.palette.baseColor1
                width: parent.width
            }

            Input {
                id: nicknameInput
                //% "Nickname"
                placeholderText: qsTrId("nickname")
                text: nickname
                //% "Your nickname is too long"
                validationError: popup.nicknameTooLong ? qsTrId("your-nickname-is-too-long") : ""
                Keys.onReleased: {
                    if (event.key === Qt.Key_Return) {
                        doneBtn.onClicked();
                    }
                }

                StatusBaseText {
                    id: lengthLimitText
                    text: popup.nicknameLength + "/" + popup.maxNicknameLength
                    font.pixelSize: 15
                    anchors.top: parent.bottom
                    anchors.topMargin: 12
                    anchors.right: parent.right
                    color: popup.nicknameTooLong ? Theme.palette.dangerColro1 : Theme.palette.baseColor1
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
            onClicked: {
                // If we removed the nickname, go back to showing the alias
                doneClicked(nicknameInput.textField.text === "" ? alias : nicknameInput.textField.text, nicknameInput.textField.text);
            }
        }
    ]
}
