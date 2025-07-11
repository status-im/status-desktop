import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Popups.Dialog

import utils
import shared.controls
import shared.popups
import shared.controls.chat

StatusDialog {
    id: root

    required property string publicKey
    required property string qrCode
    required property string linkToProfile
    required property var emojiHash
    required property int colorId

    required property string displayName
    required property bool usesDefaultName
    required property string largeImage

    footer: null

    width: 500

    topPadding: Theme.padding
    bottomPadding: Theme.xlPadding
    horizontalPadding: 0

    StatusScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.right: parent.right
            anchors.rightMargin: 40
            spacing: Theme.halfPadding

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: width
                color: Theme.palette.white

                Image {
                    objectName: "profileQRCodeImage"
                    anchors.fill: parent
                    asynchronous: true
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    smooth: false
                    source: root.qrCode

                    StatusUserImage {
                        anchors.centerIn: parent

                        name: root.displayName
                        usesDefaultName: root.usesDefaultName
                        image: root.largeImage
                        userColor: Utils.colorForColorId(root.colorId)

                        interactive: false
                        imageWidth: 78
                        imageHeight: 78

                        // show a hardcoded white ring
                        showRing: true
                        colorHash: JSON.stringify([{colorId: 4, segmentLength: 32}])
                    }

                    StatusMouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: qrContextMenu.popup()
                    }

                    ImageContextMenu {
                        id: qrContextMenu
                        imageSource: root.qrCode
                    }
                }
            }

            StatusBaseText {
                Layout.topMargin: Theme.smallPadding
                Layout.fillWidth: true
                text: qsTr("Profile link")
            }

            StatusBaseInput {
                objectName: "profileLinkInput"
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                leftPadding: Theme.padding
                rightPadding: Theme.halfPadding
                topPadding: 0
                bottomPadding: 0
                placeholder.rightPadding: Theme.halfPadding
                placeholder.elide: Text.ElideMiddle
                placeholderText: root.linkToProfile
                placeholderTextColor: Theme.palette.directColor1
                edit.readOnly: true
                background.color: "transparent"
                background.border.color: Theme.palette.baseColor2
                rightComponent: CopyButton {
                    textToCopy: root.linkToProfile
                    StatusToolTip {
                        text: qsTr("Copy link")
                        visible: parent.hovered
                    }
                }
            }

            StatusBaseText {
                Layout.topMargin: Theme.halfPadding
                Layout.fillWidth: true
                text: qsTr("Emoji hash")
            }

            StatusBaseInput {
                objectName: "emojiHashInput"
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                leftPadding: Theme.padding
                rightPadding: Theme.halfPadding
                topPadding: 0
                bottomPadding: 0
                edit.readOnly: true
                background.color: "transparent"
                background.border.color: Theme.palette.baseColor2
                leftComponent: EmojiHash {
                    emojiHash: root.emojiHash
                    oneRow: true
                }
                rightComponent: CopyButton {
                    textToCopy: emojiHash.join("")
                    StatusToolTip {
                        text: qsTr("Copy emoji hash")
                        visible: parent.hovered
                    }
                }
            }
        }
    }
}
