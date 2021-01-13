import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "./"

ModalPopup {
    property int nicknameLength: nicknameInput.textField.text.length
    readonly property int maxNicknameLength: 32
    property bool nicknameTooLong: nicknameLength > maxNicknameLength
    property var changeUsername: function () {}
    property var changeNickname: function () {}

    id: popup
    width: 400
    height: 390

    noTopMargin: true

    onOpened: {
        nicknameInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    header: Item {
        height: 78
        width: parent.width

        StyledText {
            id: nicknameTitle
            //% "Nickname"
            text:  qsTrId("nickname")
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            font.bold: true
            font.pixelSize: 17
        }

        StyledText {
            text: isEnsVerified ? alias : fromAuthor
            width: 160
            elide: !isEnsVerified ? Text.ElideMiddle : Text.ElideNone
            anchors.left: nicknameTitle.left
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Style.current.padding
            font.pixelSize: 15
            color: Style.current.secondaryText
        }

        Separator {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
        }
    }

    StyledText {
        id: descriptionText
        //% "Nicknames help you identify others in Status. Only you can see the nicknames you’ve added"
        text: qsTrId("nicknames-help-you-identify-others-in-status--only-you-can-see-the-nicknames-you-ve-added")
        font.pixelSize: 15
        wrapMode: Text.WordWrap
        color: Style.current.secondaryText
        width: parent.width
    }

    Input {
        id: nicknameInput
        //% "Nickname"
        placeholderText: qsTrId("nickname")
        text: nickname
        anchors.top: descriptionText.bottom
        anchors.topMargin: Style.current.padding
        //% "Your nickname is too long"
        validationError: popup.nicknameTooLong ? qsTrId("your-nickname-is-too-long") : ""
        Keys.onReleased: {
            if (event.key === Qt.Key_Return) {
                doneBtn.onClicked();
            }
        }
    }

    StyledText {
        id: lengthLimitText
        text: popup.nicknameLength + "/" + popup.maxNicknameLength
        font.pixelSize: 15
        anchors.top: nicknameInput.bottom
        anchors.topMargin: 12
        anchors.right: parent.right
        color: popup.nicknameTooLong ? Style.current.danger : Style.current.secondaryText
    }

    footer: StyledButton {
        id: doneBtn
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        //% "Done"
        label: qsTrId("done")
        anchors.bottom: parent.bottom
        disabled: popup.nicknameTooLong
        onClicked: {
            if (!isEnsVerified) {
                // Change username title only if it was not an ENS name
                 if (nicknameInput.textField.text === "") {
                     // If we removed the nickname, go back to showing the alias
                     popup.changeUsername(alias)
                 } else {
                     popup.changeUsername(nicknameInput.textField.text)
                 }
            }
            popup.changeNickname(nicknameInput.textField.text)
            profileModel.contacts.changeContactNickname(fromAuthor, nicknameInput.textField.text)
            popup.close()
        }
    }
}
