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

    id: popup
    height: 325

    header: Item {
        height: childrenRect.height
        width: parent.width

        StyledText {
            id: nicknameTitle
            text:  qsTr("Nickname")
            anchors.top: parent.top
            anchors.topMargin: 18
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            font.bold: true
            font.pixelSize: 14
        }

        StyledText {
            text: isEnsVerified ? alias : fromAuthor
            width: 160
            elide: !isEnsVerified ? Text.ElideMiddle : Text.ElideNone
            anchors.left: nicknameTitle.left
            anchors.top: nicknameTitle.bottom
            anchors.topMargin: 2
            font.pixelSize: 14
            color: Style.current.secondaryText
        }
    }

    StyledText {
        id: descriptionText
        text: qsTr("Nicknames help you identify others in Status. Only you can see the nicknames you’ve added")
        font.pixelSize: 15
        wrapMode: Text.WordWrap
        color: Style.current.secondaryText
        width: parent.width
    }

    Input {
        id: nicknameInput
        placeholderText: qsTr("Nickname")
        text: nickname
        anchors.top: descriptionText.bottom
        anchors.topMargin: Style.current.padding
        validationError: popup.nicknameTooLong ? qsTr("Your nickname is too long") : ""
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
        label: qsTr("Done")
        anchors.bottom: parent.bottom
        disabled: popup.nicknameLength === 0 || popup.nicknameTooLong
        onClicked: {
            if (!userName.startsWith("@")) {
                // Replace username only if it was not an ENS name
                userName = nicknameInput.textField.text
            }
            nickname = nicknameInput.textField.text
            profileModel.changeContactNickname(fromAuthor, nicknameInput.textField.text)
            popup.close()
        }
    }
}
