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

    property bool displayNameVisible: true
    property bool pubkeyVisible: true

    property alias imageWidth: userImage.imageWidth
    property alias imageHeight: userImage.imageHeight
    property size emojiSize: Qt.size(14, 14)
    property bool supersampling: true

    property alias imageOverlay: imageOverlay.sourceComponent

    signal clicked()

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
            image: root.icon
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

        StyledText {
            Layout.fillWidth: true

            visible: root.pubkeyVisible

            text: Utils.getElidedCompressedPk(pubkey)

            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Style.current.asideTextFontSize
            color: Style.current.secondaryText
        }

        EmojiHash {
            id: emojihash
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            publicKey: root.pubkey
            readonly property size finalSize: supersampling ? Qt.size(emojiSize.width * 2, emojiSize.height * 2) : emojiSize
            size: `${finalSize.width}x${finalSize.height}`
            scale: supersampling ? 0.5 : 1
        }
    }
}
