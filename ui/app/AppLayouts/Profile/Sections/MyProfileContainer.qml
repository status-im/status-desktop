import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import "../../../../shared"
import "../../../../shared/status"

import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

Item {
    property string ensName: profileModel.ens.preferredUsername ||
        profileModel.ens.firstEnsUsername || ""
    property string username: profileModel.profile.username
    property string pubkey: profileModel.profile.pubKey

    id: profileHeaderContent
    clip: true
    height: parent.height
    Layout.fillWidth: true

    Component {
        id: changeProfileModalComponent
        ChangeProfilePicModal {}
    }

    Item {
        id: profileImgNameContainer
        anchors.top: parent.top
        anchors.topMargin: 64
        width: profileContainer.profileContentWidth

        anchors.horizontalCenter: parent.horizontalCenter

        height: this.childrenRect.height

        Item {
            id: profileImgContainer
            width: profileImg.width
            height: profileImg.height

            RoundedImage {
                id: profileImg
                width: 64
                height: 64
                border.width: 1
                border.color: Style.current.border
                source: profileModel.profile.thumbnailImage || ""
                smooth: false
                antialiasing: true
            }

            RoundedIcon {
                source: Style.svg("pencil")
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -3
                anchors.right: parent.right
                anchors.rightMargin: -3
                width: 24
                height: 24
                border.width: 1
                border.color: Style.current.background
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const popup = changeProfileModalComponent.createObject(profileHeaderContent);
                    popup.open()
                }
            }
        }

        StyledText {
            id: profileName
            text: ensName !== "" ? ensName : username
            anchors.left: profileImgContainer.right
            anchors.leftMargin: Style.current.halfPadding
            anchors.top: profileImgContainer.top
            anchors.topMargin: 4
            font.weight: Font.Bold
            font.pixelSize: 20
        }

        Address {
            id: pubkeyText
            text: ensName !== "" ? username : pubkey
            anchors.bottom: profileImgContainer.bottom
            anchors.left: profileName.left
            anchors.bottomMargin: 4
            width: 200
            font.pixelSize: 15
        }

        StatusIconButton {
            id: qrCodeButton
            anchors.right: parent.right
            height: 32
            width: 32
            radius: 8
            anchors.verticalCenter: profileImgContainer.verticalCenter
            icon.name: "qr-code-icon"
            iconColor: Style.current.textColor
            onClicked: {
                qrCodePopup.open()
            }
        }

        Separator {
            id: lineSeparator
            anchors.top: profileImgContainer.bottom
            anchors.topMargin: 36

        }
    }

    ModalPopup {
        id: qrCodePopup
        width: 420
        height: 420
        Image {
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            source: profileModel.qrCode(pubkey)
            anchors.verticalCenterOffset: 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            height: 312
            width: 312
            mipmap: true
            smooth: false
        }
    }

    Column {
        anchors.right: profileImgNameContainer.right
        anchors.left: profileImgNameContainer.left
        anchors.top: profileImgNameContainer.bottom
        anchors.topMargin: 16

        StatusDescriptionListItem {
            title: qsTr("ENS username")
            subTitle: ensName
            tooltip.text: qsTr("Copy to clipboard")
            icon.name: "copy"
            visible: !!ensName
            iconButton.onClicked: {
                chatsModel.copyToClipboard(ensName)
                tooltip.visible = !tooltip.visible
            }
            width: parent.width
        }

        StatusDescriptionListItem {
            title: qsTr("Chat key")
            subTitle: pubkey
            subTitleComponent.elide: Text.ElideMiddle
            subTitleComponent.width: 320
            subTitleComponent.font.family: Theme.palette.monoFont.name
            tooltip.text: qsTr("Copy to clipboard")
            icon.name: "copy"
            iconButton.onClicked: {
                chatsModel.copyToClipboard(pubkey)
                tooltip.visible = !tooltip.visible
            }
            width: parent.width
        }

        StatusDescriptionListItem {
            title: qsTr("Share Profile URL")
            subTitle: `${Constants.userLinkPrefix}${ensName !== "" ? ensName : (pubkey.substring(0, 5) + "..." + pubkey.substring(pubkey.length - 5))}`
            tooltip.text: qsTr("Copy to clipboard")
            icon.name: "copy"
            iconButton.onClicked: {
                chatsModel.copyToClipboard(Constants.userLinkPrefix + (ensName !== "" ? ensName : pubkey))
                tooltip.visible = !tooltip.visible
            }
            width: parent.width
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff"}
}
##^##*/
