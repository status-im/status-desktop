import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0

import "../popups"
import "../stores"

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

Item {
    id: root

    property ProfileStore profileStore

    property int profileContentWidth

    clip: true
    height: parent.height
    Layout.fillWidth: true

    Item {
        id: profileImgNameContainer
        anchors.top: parent.top
        anchors.topMargin: 64
        width: profileContentWidth

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
                source: root.profileStore.icon
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
                    Global.openChangeProfilePicPopup()
                }
            }
        }

        StatusBaseText {
            id: profileName
            text: root.profileStore.name
            anchors.left: profileImgContainer.right
            anchors.leftMargin: Style.current.halfPadding
            anchors.top: profileImgContainer.top
            anchors.topMargin: 4
            font.weight: Font.Bold
            font.pixelSize: 20
            color: Theme.palette.directColor1
        }

        Address {
            id: pubkeyText
            text: root.profileStore.ensName !== "" ? root.profileStore.username : root.profileStore.pubkey
            anchors.bottom: profileImgContainer.bottom
            anchors.left: profileName.left
            anchors.bottomMargin: 4
            width: 200
            font.pixelSize: 15
        }

        StatusFlatRoundButton {
            id: qrCodeButton
            width: 32
            height: 32
            anchors.right: parent.right
            anchors.verticalCenter: profileImgContainer.verticalCenter
            icon.name: "qr"
            type: StatusFlatRoundButton.Type.Quaternary
            onClicked: qrCodePopup.open()
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
            source: root.profileStore.getQrCodeSource(root.profileStore.pubkey)
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
            subTitle: root.profileStore.ensName
            tooltip.text: qsTr("Copy to clipboard")
            icon.name: "copy"
            visible: !!root.profileStore.ensName
            iconButton.onClicked: {
                root.profileStore.copyToClipboard(root.profileStore.ensName)
                tooltip.visible = !tooltip.visible
            }
            width: parent.width
        }

        StatusDescriptionListItem {
            title: qsTr("Chat key")
            subTitle: root.profileStore.pubkey
            subTitleComponent.elide: Text.ElideMiddle
            subTitleComponent.width: 320
            subTitleComponent.font.family: Theme.palette.monoFont.name
            tooltip.text: qsTr("Copy to clipboard")
            icon.name: "copy"
            iconButton.onClicked: {
                root.profileStore.copyToClipboard(root.profileStore.pubkey)
                tooltip.visible = !tooltip.visible
            }
            width: parent.width
        }

        StatusDescriptionListItem {
            title: qsTr("Share Profile URL")
            subTitle: `${Constants.userLinkPrefix}${root.profileStore.ensName !== "" ? root.profileStore.ensName : (root.profileStore.pubkey.substring(0, 5) + "..." + root.profileStore.pubkey.substring(root.profileStore.pubkey.length - 5))}`
            tooltip.text: qsTr("Copy to clipboard")
            icon.name: "copy"
            iconButton.onClicked: {
                root.profileStore.copyToClipboard(Constants.userLinkPrefix + (root.profileStore.ensName !== "" ? root.profileStore.ensName : root.profileStore.pubkey))
                tooltip.visible = !tooltip.visible
            }
            width: parent.width
        }
    }
}

