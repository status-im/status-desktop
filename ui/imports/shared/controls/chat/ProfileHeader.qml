import QtQuick 2.14
import QtQuick.Layouts 1.14

import utils 1.0
import shared.panels 1.0
import shared.controls 1.0

import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

Item {
    id: root

    property string displayName
    property string pubkey
    property string icon

    property bool compact: true
    property bool displayNameVisible: true
    property bool pubkeyVisible: true
    property bool emojiHashVisible: true

    property alias imageOverlay: imageOverlay.sourceComponent

    signal clicked()

    implicitWidth: contentContainer.implicitWidth
    implicitHeight: contentContainer.implicitHeight

    ColumnLayout {
        id: contentContainer

        spacing: root.compact ? 4 : 12

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
            image: root.icon
            interactive: false
            imageWidth: root.compact ? 36 : 80
            imageHeight: imageWidth

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

        StyledText {
            Layout.fillWidth: true

            visible: root.pubkeyVisible

            text: Utils.getElidedCompressedPk(pubkey)

            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Style.current.asideTextFontSize
            color: Style.current.secondaryText
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
