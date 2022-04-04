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
    
    property var store
    property string displayName
    property string pubkey
    property string icon
    property int trustStatus
    property bool isContact: false
    property bool isIdenticon: false

    property bool displayNameVisible: true
    property bool displayNamePlusIconsVisible: false
    property bool pubkeyVisible: true
    property bool pubkeyVisibleWithCopy: false

    property alias imageWidth: userImage.imageWidth
    property alias imageHeight: userImage.imageHeight
    property alias emojiSize: emojihash.size

    property alias imageOverlay: imageOverlay.sourceComponent

    signal clicked()
    signal editClicked()

    height: visible ? contentContainer.height : 0
    implicitHeight: contentContainer.implicitHeight

    ColumnLayout {
        id: contentContainer

        anchors {
            left: parent.left
            right: parent.right
            leftMargin: Style.current.smallPadding
            rightMargin: Style.current.smallPadding
        }

        UserImage {
            id: userImage

            Layout.alignment: Qt.AlignHCenter

            name: root.displayName
            pubkey: root.pubkey
            icon: root.icon
            isIdenticon: root.isIdenticon
            showRing: true
            interactive: false

            Loader {
                id: imageOverlay
                anchors.fill: parent
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

        Row {
            width: 380
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
                active: isContact
            }

            Loader {
                sourceComponent: VerificationLabel {
                    id: trustStatus
                    trustStatus: root.trustStatus
                    height: 16
                    width: 16
                }
                active: root.trustStatus !== Constants.trustStatus.unknown
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
            visible: root.pubkeyVisible
            text: pubkey.substring(0, 10) + "..." + pubkey.substring(pubkey.length - 4)
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Style.current.asideTextFontSize
            color: Style.current.secondaryText
        }

        Row {
            width: 380
            Layout.alignment: Qt.AlignHCenter
            visible: root.pubkeyVisibleWithCopy
            StyledText {
                id: txtChatKey
                text: qsTr("Chatkey:%1...").arg(pubkey.substring(0, 32))
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Style.current.primaryTextFontSize
                color: Style.current.secondaryText
                width: 360
            }


            CopyToClipBoardButton {
                id: copyBtn
                width: 20
                height: 20
                color: Style.current.transparent
                textToCopy: pubkey
                store: root.store
            }

        }

        Text {
            id: emojihash

            property string size: "14x14"

            Layout.fillWidth: true

            text: {
                const emojiHash = Utils.getEmojiHashAsJson(root.pubkey)
                var emojiHashFirstLine = ""
                var emojiHashSecondLine = ""
                for (var i = 0; i < 7; i++) {
                    emojiHashFirstLine += emojiHash[i]
                }
                for (var i = 7; i < emojiHash.length; i++) {
                    emojiHashSecondLine += emojiHash[i]
                }

                return StatusQUtils.Emoji.parse(emojiHashFirstLine, size) + "<br>" +
                       StatusQUtils.Emoji.parse(emojiHashSecondLine, size)
            }

            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 1 // make sure there is no padding for emojis due to 'style: "vertical-align: top"'
        }
    }
}
