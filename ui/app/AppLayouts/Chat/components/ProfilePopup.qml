import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "./"

ModalPopup {
    id: popup
    property var identicon: ""
    property var userName: ""
    property string nickname: ""
    property var fromAuthor: ""
    property var text: ""
    property var alias: ""
    
    property bool showQR: false
    property bool isEnsVerified: false
    property bool noFooter: false

    signal blockButtonClicked(name: string, address: string)
    signal removeButtonClicked(address: string)

    function setPopupData(userNameParam, fromAuthorParam, identiconParam, textParam, nicknameParam) {
        showQR = false
        userName = userNameParam || ""
        nickname = nicknameParam || ""
        fromAuthor = fromAuthorParam || ""
        identicon = identiconParam || ""
        text = textParam || ""
        isEnsVerified = chatsModel.isEnsVerified(this.fromAuthor)
        alias = chatsModel.alias(this.fromAuthor) || ""
    }

    function openPopup(userNameParam, fromAuthorParam, identiconParam, textParam, nicknameParam) {
        setPopupData(userNameParam, fromAuthorParam, identiconParam, textParam, nicknameParam)
        popup.open()
    }

    header: Item {
        height: children[0].height
        width: parent.width
        Rectangle {
            id: profilePic
            width: 40
            height: 40
            radius: 30
            border.color: "#10000000"
            border.width: 1
            color: Style.current.transparent
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding
            SVGImage {
                width: parent.width
                height: parent.height
                fillMode: Image.PreserveAspectFit
                source: identicon
            }
        }

        StyledTextEdit {
            id: profileName
            text:  Utils.removeStatusEns(userName)
            anchors.top: parent.top
            anchors.topMargin: 18
            anchors.left: profilePic.right
            anchors.leftMargin: Style.current.smallPadding
            font.bold: true
            font.pixelSize: 14
            readOnly: true
            wrapMode: Text.WordWrap
        }

        StyledText {
            text: isEnsVerified ? alias : fromAuthor
            width: 160
            elide: !isEnsVerified ? Text.ElideMiddle : Text.ElideNone
            anchors.left: profilePic.right
            anchors.leftMargin: Style.current.smallPadding
            anchors.top: profileName.bottom
            anchors.topMargin: 2
            font.pixelSize: 14
            color: Style.current.secondaryText
        }

        Rectangle {
            id: qrCodeButton
            height: 32
            width: 32
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: 32 + Style.current.smallPadding
            radius: 8

            SVGImage {
                source: "../../../img/qr-code-icon.svg"
                width: 25
                height: 25
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onExited: {
                    qrCodeButton.color = Style.current.white
                }
                onEntered: {
                    qrCodeButton.color = Style.current.grey
                }
                onClicked: {
                    showQR = true
                }
            }
        }
    }

    Item {
        anchors.fill: parent
        visible: showQR
        Image {
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            source: profileModel.qrCode(fromAuthor)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            height: 212
            width: 212
            mipmap: true
            smooth: false
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: Style.current.smallPadding
        visible: !showQR

        StyledText {
            id: labelEnsUsername
            height: isEnsVerified ? 20 : 0
            visible: isEnsVerified
            //% "ENS username"
            text: qsTrId("ens-username")
            font.pixelSize: 13
            font.weight: Font.Medium
            color: Style.current.secondaryText
            anchors.top: parent.top
            anchors.topMargin: Style.current.smallPadding
        }

        StyledText {
            id: valueEnsName
            visible: isEnsVerified
            height: isEnsVerified ? 20 : 0
            text: userName.substr(1)
            font.pixelSize: 14
            anchors.top: labelEnsUsername.bottom
            anchors.topMargin: Style.current.smallPadding
        }

        CopyToClipBoardButton {
            visible: isEnsVerified
            height: isEnsVerified ? 20 : 0
            anchors.top: labelEnsUsername.bottom
            anchors.left: valueEnsName.right
            textToCopy: valueEnsName.text
        }

        StyledText {
            id: labelChatKey
            //% "Chat key"
            text: qsTrId("chat-key")
            font.pixelSize: 13
            font.weight: Font.Medium
            color: Style.current.secondaryText
            anchors.top: isEnsVerified ? valueEnsName.bottom : parent.top
            anchors.topMargin: Style.current.padding
        }

        Address {
            id: valueChatKey
            text: fromAuthor
            width: 160
            maxWidth: parent.width - (3 * Style.current.smallPadding) - copyBtn.width
            color: Style.current.textColor
            font.pixelSize: 14
            anchors.top: labelChatKey.bottom
            anchors.topMargin: Style.current.smallPadding
        }

        CopyToClipBoardButton {
            id: copyBtn
            anchors.top: labelChatKey.bottom
            anchors.left: valueChatKey.right
            textToCopy: valueChatKey.text
        }

        Separator {
            id: separator
            anchors.top: valueChatKey.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
        }

        StyledText {
            id: labelShareURL
            //% "Share Profile URL"
            text: qsTrId("share-profile-url")
            font.pixelSize: 13
            font.weight: Font.Medium
            color: Style.current.secondaryText
            anchors.top: separator.bottom
            anchors.topMargin: Style.current.padding
        }

        StyledText {
            id: valueShareURL
            text: "https://join.status.im/u/" + fromAuthor.substr(
                      0, 4) + "..." + fromAuthor.substr(fromAuthor.length - 5)
            font.pixelSize: 14
            anchors.top: labelShareURL.bottom
            anchors.topMargin: Style.current.smallPadding
        }

        CopyToClipBoardButton {
            anchors.top: labelShareURL.bottom
            anchors.left: valueShareURL.right
            textToCopy: "https://join.status.im/u/" + fromAuthor
        }

        Separator {
            id: separator2
            anchors.top: valueShareURL.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
        }

        StyledText {
            id: chatSettings
            //% "Chat settings"
            text: qsTrId("chat-settings")
            font.pixelSize: 13
            font.weight: Font.Medium
            color: Style.current.secondaryText
            anchors.top: separator2.bottom
            anchors.topMargin: Style.current.padding
        }

        StyledText {
            id: nicknameTitle
            //% "Nickname"
            text: qsTrId("nickname")
            font.pixelSize: 14
            anchors.top: chatSettings.bottom
            anchors.topMargin: Style.current.smallPadding
        }

        SVGImage {
            id: nicknameCaret
            source: "../../../img/caret.svg"
            rotation: -90
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            anchors.verticalCenter: nicknameTitle.verticalCenter
            width: 13
            fillMode: Image.PreserveAspectFit
            ColorOverlay {
                anchors.fill: parent
                source: parent
                color: Style.current.secondaryText
            }
        }

        StyledText {
            id: nicknameText
            //% "None"
            text: nickname ? nickname : qsTrId("none")
            anchors.right: nicknameCaret.left
            anchors.rightMargin: Style.current.padding
            anchors.verticalCenter: nicknameTitle.verticalCenter
            color: Style.current.secondaryText
        }

        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.left: nicknameTitle.left
            anchors.right: nicknameCaret.right
            anchors.top: nicknameTitle.top
            anchors.bottom: nicknameTitle.bottom
            onClicked: {
                nicknamePopup.open()
            }
        }

        NicknamePopup {
            id: nicknamePopup
            changeUsername: function (newUsername) {
                popup.userName = newUsername
            }
            changeNickname: function (newNickname) {
                popup.nickname = newNickname
            }
        }
    }

    footer: Item {
        id: footerContainer
        visible: !noFooter
        width: parent.width
        height: children[0].height

        StyledButton {
            anchors.left: parent.left
            anchors.leftMargin: 20
            //% "Send Message"
            label: qsTrId("send-message")
            anchors.bottom: parent.bottom
            onClicked: {
                profilePopup.close()
                if (tabBar.currentIndex !== 0)
                    tabBar.currentIndex = 0
                chatsModel.joinChat(fromAuthor, Constants.chatTypeOneToOne)
            }
        }

        StyledButton {
            anchors.right: parent.right
            anchors.rightMargin: addToContactsButton.width + 32
            btnColor: Style.current.lightRed
            btnBorderWidth: 1
            btnBorderColor: Style.current.grey
            textColor: Style.current.red
            //% "Block User"
            label: qsTrId("block-user")
            anchors.bottom: parent.bottom
            onClicked: popup.blockButtonClicked(userName, fromAuthor)
        }

        StyledButton {
            id: addToContactsButton
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            label: profileModel.isAdded(fromAuthor) ?
            //% "Remove Contact"
            qsTrId("remove-contact") :
            //% "Add to contacts"
            qsTrId("add-to-contacts")
            anchors.bottom: parent.bottom
            onClicked: {
                if (profileModel.isAdded(fromAuthor)) {
                    popup.removeButtonClicked(fromAuthor)
                } else {
                    profileModel.addContact(fromAuthor)
                }
                profilePopup.close()
            }
        }
    }
}
