import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

Rectangle {
    id: root
    property string chatId: ""
    property string name: "channelName"
    property string message: qsTr("My latest message\n with a return")
    property string identicon: ""

    // TODO: what about dark theme?
    color: "#F7F7F7"
    width: 366
    height: 75

    radius: 8

    Loader {
        id: identicon
        sourceComponent: root.identicon === "" ?  statusIdenticon : userOrChannelIdenticon
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        height: 40
        width: 40
    }

    Component {
        id: userOrChannelIdenticon
        StatusSmartIdenticon {
            id: contactImage
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            asset: StatusAssetSettings {
                width: 40
                height: 40
                name: root.identicon
                letterSize: 15
                color: Theme.palette.miscColor5
                imgIsIdenticon: true
            }
            name: root.name
        }
    }

    Component {
        id: statusIdenticon
        Image {
            source: "../../assets/img/status-logo-icon.svg"
            width: 40
            height: 40
            sourceSize.width: width * 2
            sourceSize.height: height * 2
            cache: true
            fillMode: Image.PreserveAspectFit
        }
        /* SVGImage { */
        /*     source: Style.svg("status-logo-icon") */
        /*     width: 40 */
        /*     height: 40 */
        /* } */
    }

    StatusBaseText {
        id: name
        anchors.bottom: messagePreview.top
        anchors.bottomMargin: 2
        anchors.left: identicon.right
        anchors.leftMargin: 8
        anchors.right: openButton.left
        anchors.rightMargin: 8
        elide: Text.ElideRight
        text: root.name
        font.weight: Font.Medium
        font.pixelSize: 15
        color: "#4b4b4b"
    }

    StatusBaseText {
        id: messagePreview
        anchors.bottom: identicon.bottom
        anchors.bottomMargin: 2
        anchors.left: identicon.right
        anchors.leftMargin: 8
        anchors.right: openButton.left
        anchors.rightMargin: 16
        elide: Text.ElideRight
        clip: true // This is needed because emojis don't ellide correctly
        font.pixelSize: 14
        color: "#4b4b4b"
        text: root.message
    }

    Rectangle {
        id: openButton
        anchors.right: parent.right
        height: parent.height
        width: 85
        color: "transparent"

        Rectangle {
            height: parent.height
            width: 1.2
            anchors.left: parent.left
            color: "#D9D9D9"
        }

        StatusBaseText {
            font.weight: Font.Medium
            font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Open")
            color: "black"
        }
    }
}


