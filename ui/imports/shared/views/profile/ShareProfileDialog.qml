import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0
import shared.controls 1.0
import shared.views.chat 1.0
import shared.controls.chat 1.0

StatusDialog {
    id: root

    required property string publicKey
    required property string qrCode
    required property string linkToProfile

    required property string displayName
    required property string largeImage

    footer: null

    width: 500

    topPadding: Style.current.padding
    bottomPadding: Style.current.xlPadding
    horizontalPadding: 0

    StatusScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.right: parent.right
            anchors.rightMargin: 40
            spacing: Style.current.halfPadding

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: width
                color: Theme.palette.white

                Image {
                    anchors.fill: parent
                    asynchronous: true
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    smooth: false
                    source: root.qrCode

                    UserImage {
                        anchors.centerIn: parent
                        name: root.displayName
                        pubkey: root.publicKey
                        image: root.largeImage
                        interactive: false
                        imageWidth: 78
                        imageHeight: 78

                        // show a hardcoded white ring
                        showRing: true
                        colorHash: JSON.stringify([{colorId: 4, segmentLength: 32}])
                    }

                    MouseArea {
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
                Layout.topMargin: Style.current.smallPadding
                Layout.fillWidth: true
                text: qsTr("Profile link")
            }

            StatusBaseInput {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                leftPadding: Style.current.padding
                rightPadding: Style.current.halfPadding
                topPadding: 0
                bottomPadding: 0
                placeholder.rightPadding: Style.current.halfPadding
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
                Layout.topMargin: Style.current.halfPadding
                Layout.fillWidth: true
                text: qsTr("Emoji hash")
            }

            StatusBaseInput {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                leftPadding: Style.current.padding
                rightPadding: Style.current.halfPadding
                topPadding: 0
                bottomPadding: 0
                edit.readOnly: true
                background.color: "transparent"
                background.border.color: Theme.palette.baseColor2
                leftComponent: EmojiHash {
                    publicKey: root.publicKey
                    oneRow: true
                }
                rightComponent: CopyButton {
                    textToCopy: Utils.getEmojiHashAsJson(root.publicKey).join("").toString()
                    StatusToolTip {
                        text: qsTr("Copy emoji hash")
                        visible: parent.hovered
                    }
                }
            }
        }
    }
}
