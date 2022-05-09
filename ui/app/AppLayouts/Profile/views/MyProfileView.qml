import QtQuick 2.13
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.controls.chat 1.0

import "../popups"
import "../stores"

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

SettingsContentBase {
    id: root

    property ProfileStore profileStore

    ColumnLayout {
        spacing: Constants.settingsSection.itemSpacing
        width: root.contentWidth

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding

            StatusBaseText {
                id: profileName
                text: root.profileStore.name
                font.weight: Font.Bold
                font.pixelSize: 20
                color: Theme.palette.directColor1
            }

            StatusButton {
                text: "Edit"
                onClicked: Global.openPopup(displayNamePopupComponent)
            }

            Item {
                Layout.fillWidth: true
            }

            StatusFlatRoundButton {
                id: qrCodeButton

                Layout.preferredWidth: 32
                Layout.preferredHeight: 32

                icon.name: "qr"
                type: StatusFlatRoundButton.Type.Quaternary
                onClicked: qrCodePopup.open()
            }
        }

        Separator {
            Layout.fillWidth: true
        }

        ProfileHeader {
            id: profileImgNameContainer

            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding

            displayName: profileStore.name
            pubkey: profileStore.pubkey
            icon: profileStore.icon

            displayNameVisible: false
            pubkeyVisible: false

            imageWidth: 80
            imageHeight: 80
            emojiSize: Qt.size(20,20)
            supersampling: true

            imageOverlay: Item {
                StatusFlatRoundButton {
                    width: 24
                    height: 24

                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                        rightMargin: -8
                    }

                    type: StatusFlatRoundButton.Type.Secondary
                    icon.name: "pencil"
                    icon.color: Theme.palette.directColor1
                    icon.width: 12.5
                    icon.height: 12.5

                    onClicked: Global.openChangeProfilePicPopup()
                }
            }
        }

        StatusDescriptionListItem {
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding

            title: qsTr("ENS username")
            subTitle: root.profileStore.ensName
            tooltip.text: qsTr("Copy to clipboard")
            icon.name: "copy"
            visible: !!root.profileStore.ensName
            iconButton.onClicked: {
                root.profileStore.copyToClipboard(root.profileStore.ensName)
                tooltip.visible = !tooltip.visible
            }
        }

        StatusDescriptionListItem {
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding

            title: qsTr("Chat key")
            subTitle: Utils.getCompressedPk(root.profileStore.pubkey)
            subTitleComponent.elide: Text.ElideMiddle
            subTitleComponent.width: 320
            subTitleComponent.font.family: Theme.palette.monoFont.name
            tooltip.text: qsTr("Copy to clipboard")
            icon.name: "copy"
            iconButton.onClicked: {
                root.profileStore.copyToClipboard(subTitle)
                tooltip.visible = !tooltip.visible
            }
        }

        StatusDescriptionListItem {
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding

            title: qsTr("Share Profile URL")
            subTitle: `${Constants.userLinkPrefix}${root.profileStore.ensName !== "" ? root.profileStore.ensName : (root.profileStore.pubkey.substring(0, 5) + "..." + root.profileStore.pubkey.substring(root.profileStore.pubkey.length - 5))}`
            tooltip.text: qsTr("Copy to clipboard")
            icon.name: "copy"
            iconButton.onClicked: {
                root.profileStore.copyToClipboard(Constants.userLinkPrefix + (root.profileStore.ensName !== "" ? root.profileStore.ensName : root.profileStore.pubkey))
                tooltip.visible = !tooltip.visible
            }
        }

        Component {
            id: displayNamePopupComponent
            DisplayNamePopup {
                profileStore: root.profileStore
                anchors.centerIn: Overlay.overlay
                onClosed: { destroy() }
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
    }
}
