import QtQuick 2.14
import QtQuick.Layouts 1.14

import utils 1.0
import shared.panels 1.0
import shared.controls 1.0

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

Item {
    id: root

    enum ImageSize {
        Compact,
        Middle,
        Big
    }

    property var store
    property string displayName
    property string pubkey
    property string icon
    property int trustStatus
    property bool isContact: false
    property bool isCurrentUser

    property int imageSize: ProfileHeader.ImageSize.Compact
    property bool displayNameVisible: true
    property bool displayNamePlusIconsVisible: false
    property bool pubkeyVisible: true
    property bool pubkeyVisibleWithCopy: false
    property bool emojiHashVisible: true
    property bool editImageButtonVisible: false
    readonly property bool compact: root.imageSize === ProfileHeader.ImageSize.Compact

    signal clicked()
    signal editClicked()

    height: visible ? contentContainer.height : 0
    implicitHeight: contentContainer.implicitHeight

    QtObject {
        id: d
        function getSize(compact, normal, big) {
            switch(root.imageSize) {
                case ProfileHeader.ImageSize.Compact: return compact;
                case ProfileHeader.ImageSize.Middle: return normal;
                case ProfileHeader.ImageSize.Big: return big;
            }
        }
    }

    ColumnLayout {
        id: contentContainer

        spacing: root.compact ? 4 : 12

        anchors {
            left: parent.left
            right: parent.right
            leftMargin: Style.current.smallPadding
            rightMargin: Style.current.smallPadding
        }

        Item {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: userImage.width
            implicitHeight: userImage.height

            UserImage {
                id: userImage
                name: root.displayName
                pubkey: root.pubkey
                image: root.icon
                interactive: false
                imageWidth: d.getSize(36, 80, 160)
                imageHeight: imageWidth
            }

            StatusRoundButton {
                visible: root.editImageButtonVisible
                anchors.bottom: userImage.bottom
                anchors.right: userImage.right
                anchors.rightMargin: Math.round(userImage.width / 10)

                width: d.getSize(10, 24, 40)
                height: width

                type: StatusRoundButton.Type.Secondary
                icon.name: "edit_pencil"
                icon.width: d.getSize(8, 12, 20)
                icon.height: d.getSize(8, 12, 20)

                onClicked: Global.openChangeProfilePicPopup()
            }
        }

        StyledText {
            Layout.fillWidth: true

            visible: root.displayNameVisible

            text: root.displayName

            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            maximumLineCount: 3
            wrapMode: Text.Wrap
            font {
                weight: Font.Medium
                pixelSize: Style.current.primaryTextFontSize
            }
        }

        RowLayout {
            spacing: Style.current.halfPadding
            Layout.alignment: Qt.AlignHCenter
            visible: root.displayNamePlusIconsVisible
            StyledText {
                text: root.displayName
                font {
                    weight: Font.Medium
                    pixelSize: Style.current.primaryTextFontSize
                }
            }

            Loader {
                sourceComponent: SVGImage {
                    height: 16
                    width: 16
                    source: Style.svg("contact")
                }
                active: isContact && !root.isCurrentUser
                visible: active
            }

            Loader {
                sourceComponent: VerificationLabel {
                    id: trustStatus
                    trustStatus: root.trustStatus
                    height: 16
                    width: 16
                }
                active: root.trustStatus !== Constants.trustStatus.unknown && !root.isCurrentUser
                visible: active
            }

            SVGImage {
                height: 16
                width: 16
                source: Style.svg("edit-message")
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton
                    onClicked: {
                        root.editClicked()
                    }
                }
            }
        }

        StyledText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            visible: root.pubkeyVisible

            text: Utils.getElidedCompressedPk(pubkey)

            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Style.current.asideTextFontSize
            color: Style.current.secondaryText
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            visible: root.pubkeyVisibleWithCopy
            StyledText {
                id: txtChatKey
                text: qsTr("Chatkey:%1...").arg(pubkey.substring(0, 32))
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Style.current.primaryTextFontSize
                color: Style.current.secondaryText
            }

            CopyToClipBoardButton {
                id: copyBtn
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                color: Style.current.transparent
                textToCopy: pubkey
                store: root.store
            }
        }

        EmojiHash {
            id: emojiHash
            Layout.alignment: Qt.AlignHCenter
            visible: root.emojiHashVisible
            publicKey: root.pubkey
            size: root.compact ? 16 : 20
        }
    }
}
