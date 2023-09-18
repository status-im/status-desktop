import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import shared.status 1.0
import shared.controls 1.0
import shared.controls.chat 1.0

import utils 1.0


CalloutCard {
    id: root

    required property string userName
    required property string userPublicKey
    required property string userBio
    required property var    userImage
    required property bool   ensVerified

    signal clicked()

    implicitWidth: 305
    implicitHeight: 187

    padding: 12

    contentItem: ColumnLayout {
        spacing: 0
        UserImage {
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            name: root.userName
            pubkey: root.userPublicKey
            image: root.userImage
            interactive: false
            imageWidth: 58
            imageHeight: imageWidth
            ensVerified: root.ensVerified
        }

        StatusBaseText {
            id: contactName
            Layout.fillWidth: true
            Layout.topMargin: 12
            font.pixelSize: Style.current.additionalTextSize
            font.weight: Font.Medium
            elide: Text.ElideRight
            text: root.userName
        }

        EmojiHash {
            Layout.fillWidth: true
            Layout.topMargin: 4
            publicKey: root.userPublicKey
            oneRow: true
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 15
            font.pixelSize: Style.current.tertiaryTextFontSize
            color: Theme.palette.baseColor1
            text: root.userBio
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
        }
    }

    MouseArea {
        anchors.fill: root
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}