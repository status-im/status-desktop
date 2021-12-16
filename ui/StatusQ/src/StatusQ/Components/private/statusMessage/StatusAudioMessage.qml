import QtQuick 2.3
import QtMultimedia 5.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

// To-do update as per latest design -> Audio graphs. Also the player should ideally be in the BE?
Rectangle {
    id: audioChatMessage

    property string audioMessageInfoText: ""
    property bool isPreview: false
    property bool hovered: false
    property string audioSource: ""

    width: 320
    height: 32
    radius: 20

    color: hovered ? Theme.palette.directColor8 : Theme.palette.baseColor2

    Audio {
        id: audioMessage
        source: audioSource
        notifyInterval: 150
    }

    RowLayout {
        id: preview
        visible: isPreview
        spacing: 5
        anchors.centerIn: parent
        StatusIcon {
            id: icon
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 14
            Layout.preferredHeight: 14
            icon: "audio"
            color: Theme.palette.baseColor1
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            color: Theme.palette.baseColor1
            text: audioMessageInfoText
            font.pixelSize: 13
        }
    }

    StatusFlatRoundButton {
        id: playButton
        width: 15
        height: 15
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        visible: !isPreview

        type: StatusFlatRoundButton.Type.Tertiary
        color: "transparent"
        icon.name: audioMessage.playbackState == Audio.PlayingState ? "pause-filled" : "play-filled"
        icon.color: Theme.palette.directColor1

        onClicked: {
            if(audioMessage.playbackState === Audio.PlayingState){
                audioMessage.pause();
            } else {
                audioMessage.play();
            }

        }
    }
    
    Rectangle {
        height: 2
        width: 240
        color: Theme.palette.directColor5
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: playButton.right
        anchors.leftMargin: 10
        visible: !isPreview
        Rectangle {
            id: progress
            height: 2
            width: {
                if(audioMessage.duration === 0) return 0;
                if(audioMessage.playbackState === Audio.StoppedState) return 0;
                return parent.width * audioMessage.position / audioMessage.duration;
            }
            color: Theme.palette.directColor5
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: handle
            width: 10
            height: 10
            color: Theme.palette.directColor1
            radius: 10
            anchors.verticalCenter: parent.verticalCenter
            x: progress.width
            state: "default"

            states: State {
                name: "pressed"
                when: handleMouseArea.pressed
                PropertyChanges {
                    target: handle;
                    scale: 1.2
                }
            }
            transitions: Transition {
                NumberAnimation {
                    properties: "scale";
                    duration: 100;
                    easing.type: Easing.InOutQuad
                }
            }

            MouseArea {
                id: handleMouseArea
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                drag.target: parent
                drag.axis: Drag.XAxis
                drag.minimumX: 0
                drag.maximumX: parent.parent.width
                onPressed: {
                    handle.state = "pressed"
                    if(audioMessage.playbackState === Audio.PlayingState) {
                        audioMessage.pause();
                    }
                }
                onReleased: {
                    handle.state = "default"
                    audioMessage.seek(audioMessage.duration * handle.x / parent.parent.width)
                    audioMessage.play()
                }
            }
        }
    }
}
