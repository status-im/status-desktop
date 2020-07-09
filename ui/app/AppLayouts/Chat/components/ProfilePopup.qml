import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "./"

ModalPopup {
    id: popup
    property var identicon: ""
    property var userName: ""
    property var fromAuthor: ""
    property bool showQR: false
    property bool isEnsVerified: false

    function openPopup(userNameParam, fromAuthorParam, identiconParam) {
        this.showQR = false
        this.userName = userNameParam
        this.fromAuthor = fromAuthorParam
        this.identicon = identiconParam
        this.isEnsVerified = chatsModel.isEnsVerified(this.fromAuthor)
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
            text: userName
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
            text: fromAuthor
            width: 160
            elide: Text.ElideMiddle
            anchors.left: profilePic.right
            anchors.leftMargin: Style.current.smallPadding
            anchors.top: profileName.bottom
            anchors.topMargin: 2
            font.pixelSize: 14
            color: Style.current.darkGrey
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
        visible: !showQR

        StyledText {
            id: labelEnsUsername
            height: isEnsVerified ? 20 : 0
            visible: isEnsVerified
            //% "ENS username"
            text: qsTrId("ens-username")
            font.pixelSize: 13
            font.weight: Font.Medium
            color: Style.current.darkGrey
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.top: parent.top
            anchors.topMargin: Style.current.smallPadding
        }

        StyledText {
            id: valueEnsName
            visible: isEnsVerified
            height: isEnsVerified ? 20 : 0
            text: userName
            font.pixelSize: 14
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.top: labelEnsUsername.bottom
            anchors.topMargin: Style.current.smallPadding
        }

        CopyToClipBoardButton {
            visible: isEnsVerified
            height: isEnsVerified ? 20 : 0
            anchors.top: labelEnsUsername.bottom
            anchors.left: valueEnsName.right
            anchors.leftMargin: Style.current.smallPadding
            textToCopy: valueEnsName.text
        }

        StyledText {
            id: labelChatKey
            //% "Chat key"
            text: qsTrId("chat-key")
            font.pixelSize: 13
            font.weight: Font.Medium
            color: Style.current.darkGrey
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.top: isEnsVerified ? valueEnsName.bottom : parent.top
            anchors.topMargin: Style.current.padding
        }

        StyledText {
            id: valueChatKey
            text: fromAuthor
            width: 160
            elide: Text.ElideMiddle
            font.pixelSize: 14
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.top: labelChatKey.bottom
            anchors.topMargin: Style.current.smallPadding
        }

        CopyToClipBoardButton {
            anchors.top: labelChatKey.bottom
            anchors.left: valueChatKey.right
            anchors.leftMargin: Style.current.smallPadding
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
            color: Style.current.darkGrey
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.top: separator.bottom
            anchors.topMargin: Style.current.padding
        }

        StyledText {
            id: valueShareURL
            text: "https://join.status.im/u/" + fromAuthor.substr(
                      0, 4) + "..." + fromAuthor.substr(fromAuthor.length - 5)
            font.pixelSize: 14
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.top: labelShareURL.bottom
            anchors.topMargin: Style.current.smallPadding
        }

        CopyToClipBoardButton {
            anchors.top: labelShareURL.bottom
            anchors.left: valueShareURL.right
            anchors.leftMargin: Style.current.smallPadding
            textToCopy: "https://join.status.im/u/" + fromAuthor
        }
    }

    footer: Item {
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
            btnColor: "white"
            btnBorderWidth: 1
            btnBorderColor: Style.current.grey
            textColor: Style.current.red
            //% "Block User"
            label: qsTrId("block-user")
            anchors.bottom: parent.bottom
            onClicked: {
                chatsModel.blockContact(fromAuthor)
                // TODO(pascal): Change block user button state based
                // on :contact/blocked state
                profilePopup.close()
            }
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
                    chatsModel.removeContact(fromAuthor)
                } else {
                    chatsModel.addContact(fromAuthor)
                }
                profilePopup.close()
            }
        }
    }
}
