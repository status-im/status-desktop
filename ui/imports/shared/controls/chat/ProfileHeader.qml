import QtQuick 2.14
import QtQuick.Layouts 1.14

import utils 1.0
import shared.panels 1.0
import shared.controls 1.0

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
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
    property url previewIcon: icon
    property int trustStatus
    property bool isContact: false
    property bool isCurrentUser
    property bool userIsEnsVerified
    property rect cropRect

    property int imageSize: ProfileHeader.ImageSize.Compact
    property bool displayNameVisible: true
    property bool displayNamePlusIconsVisible: false
    property bool pubkeyVisible: true
    property bool pubkeyVisibleWithCopy: false
    property bool emojiHashVisible: true
    property bool editImageButtonVisible: false
    property bool editButtonVisible: displayNamePlusIconsVisible
    property bool loading: false
    readonly property bool compact: root.imageSize === ProfileHeader.ImageSize.Compact

    signal clicked()
    signal editClicked()

    Binding on previewIcon {
        value: icon
    }

    implicitWidth: contentContainer.implicitWidth
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

    Item {
        id: tmpCroppedImageHelper

        visible: false

        Image {
            id: tmpImage
            mipmap: true
            cache: false
        }

        property var keepGrabResultAlive;

        function setCroppedTmpIcon(source, x, y, width, height) {
            tmpCroppedImageHelper.width = width
            tmpCroppedImageHelper.height = height

            tmpImage.x = -x
            tmpImage.y = -y
            tmpImage.source = source

            tmpCroppedImageHelper.grabToImage(result => {
                keepGrabResultAlive = result
                root.previewIcon = result.url
                tmpImage.source = ""
            })
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
                objectName: "ProfileHeader_userImage"
                name: root.displayName
                pubkey: root.pubkey
                image: root.previewIcon
                interactive: false
                imageWidth: d.getSize(36, 64, 170)
                imageHeight: imageWidth
                ensVerified: root.userIsEnsVerified
                loading: root.loading
            }

            StatusRoundButton {
                id: editButton
                visible: root.editImageButtonVisible
                anchors.top: userImage.top
                anchors.right: userImage.right
                anchors.rightMargin: Math.round(userImage.width / 10)

                width: d.getSize(10, 24, 40)
                height: width

                type: StatusRoundButton.Type.Secondary
                icon.name: "edit_pencil"
                icon.width: d.getSize(8, 12, 24)
                icon.height: d.getSize(8, 12, 24)

                onClicked: {
                    if (!!root.store.profileLargeImage)
                        Global.openMenu(editImageMenuComponent, this)
                    else
                        Global.openChangeProfilePicPopup(tempIcon);
                }

                function tempIcon(image, aX, aY, bX, bY) {
                    root.icon = image
                    root.cropRect = Qt.rect(aX, aY, bX - aX, bY - aY)

                    tmpCroppedImageHelper.setCroppedTmpIcon(
                                image, aX, aY, bX - aX, bY - aY)
                }
            }
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: displayNameLabel.implicitHeight
            visible: root.displayNameVisible

            StyledText {
                id: displayNameLabel
                width: parent.width
                height: parent.height
                text: root.displayName
                visible: !root.loading
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                maximumLineCount: 3
                wrapMode: Text.Wrap
                font {
                    bold: true
                    pixelSize: 17
                }
            }

            Loader {
                anchors.centerIn: parent
                height: parent.height
                width: 100
                visible: root.loading
                active: visible

                sourceComponent: LoadingComponent {
                    radius: 4
                }
            }
        }

        RowLayout {
            spacing: compact ? 4 : Style.current.halfPadding
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            visible: root.displayNamePlusIconsVisible

            StyledText {
                objectName: "ProfileHeader_displayName"
                Layout.maximumWidth: root.width - Style.current.xlPadding
                text: root.displayName
                elide: Text.ElideRight
                font {
                    weight: Font.Medium
                    pixelSize: Style.current.primaryTextFontSize
                }
            }

            StatusContactVerificationIcons {
                Layout.alignment: Qt.AlignVCenter
                visible: !root.isCurrentUser
                isContact: root.isContact
                trustIndicator: root.trustStatus
            }

            Loader {
                sourceComponent: SVGImage {
                    objectName: "ProfileHeader_displayNameEditIcon"
                    height: compact ? 10 : 16
                    width: compact ? 10 : 16
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
                active: root.editButtonVisible
                visible: active
            }
        }

        StyledText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            visible: root.pubkeyVisible
            text: Utils.getElidedCompressedPk(pubkey)
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 13
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
                onCopyClicked: root.store.copyToClipboard(textToCopy)
            }
        }

        EmojiHash {
            id: emojiHash
            Layout.alignment: Qt.AlignHCenter
            visible: root.emojiHashVisible
            compact: root.compact
            publicKey: root.pubkey
        }
    }

    Component {
        id: editImageMenuComponent

        StatusMenu {

            StatusAction {
                text: qsTr("Select different image")
                assetSettings.name: "image"
                onTriggered: Global.openChangeProfilePicPopup(editButton.tempIcon)
            }

            StatusAction {
                text: qsTr("Use an NFT")
                assetSettings.name: "nft-profile"
                onTriggered: Global.openChangeProfilePicPopup(editButton.tempIcon)
                enabled: false // TODO enable this with the profile showcase
            }

            StatusMenuSeparator {}

            StatusAction {
                text: qsTr("Remove image")
                type: StatusAction.Danger
                assetSettings.name: "delete"
                onTriggered: root.icon = ""
            }
        }
    }
}
