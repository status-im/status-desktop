import QtQuick 2.15

import utils 1.0

import shared.controls.chat 1.0
import shared.status 1.0

import StatusQ.Core 0.1

CalloutCard {
    id: root
    
    required property string link
    required property bool playAnimation
    required property bool isOnline

    readonly property bool isPlaying: linkImage.playing
    readonly property alias imageAlias: linkImage.imageAlias


    signal clicked(var mouse)
    
    implicitWidth: linkImage.width
    implicitHeight: linkImage.height
    
    StatusChatImageLoader {
        id: linkImage

        property bool localAnimationEnabled: true

        objectName: "LinksMessageView_unfurledImageComponent_linkImage"
        anchors.centerIn: parent
        source: root.link
        imageWidth: 300
        playing: root.playAnimation && localAnimationEnabled
        isOnline: root.isOnline
        asynchronous: true
        isAnimated: true
        onClicked: {
            if (isAnimated && !playing)
                localAnimationEnabled = true
            else
                root.clicked(mouse)
        }
        imageAlias.cache: localAnimationEnabled // GIFs can only loop/play properly with cache enabled
        Loader {
            width: 45
            height: 38
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12
            active: linkImage.isAnimated && !linkImage.playing
            sourceComponent: Item {
                anchors.fill: parent
                Rectangle {
                    anchors.fill: parent
                    color: "black"
                    radius: Style.current.radius
                    opacity: .4
                }
                StatusBaseText {
                    anchors.centerIn: parent
                    text: "GIF"
                    font.pixelSize: 13
                    color: "white"
                }
            }
        }
        Timer {
            id: animationPlayingTimer
            interval: 10000
            running: linkImage.isAnimated && linkImage.playing
            onTriggered: { linkImage.localAnimationEnabled = false }
        }
    }
}
