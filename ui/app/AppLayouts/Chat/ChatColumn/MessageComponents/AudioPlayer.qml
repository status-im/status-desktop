import QtQuick 2.3
import QtMultimedia 5.14
import "../../../../../shared"
import "../../../../../imports"

Item {
    property string audioSource: ""

    height: 20
    width: 350

    Audio {
        id: audioMessage
        source: audioSource
        notifyInterval: 150
    }

    SVGImage {
        id: playButton
        source: audioMessage.playbackState == Audio.PlayingState ? "../../../../img/icon-pause.svg" : "../../../../img/icon-play.svg"
        width: 15
        height: 15
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
        MouseArea {
              id: playArea
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onPressed: {
                  if(audioMessage.playbackState === Audio.PlayingState){
                      audioMessage.pause();
                  } else {
                      audioMessage.play();
                  }
                  
              }
          }
    }
    
    Rectangle {
        height: 2
        width: 300
        color: Style.current.grey
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: playButton.right
        anchors.leftMargin: 20
        Rectangle {
            id: progress
            height: 2
            width: {
                if(audioMessage.duration === 0) return 0;
                if(audioMessage.playbackState === Audio.StoppedState) return 0;
                return parent.width * audioMessage.position / audioMessage.duration;
            }
            color: Style.current.black
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: handle
            width: 10
            height: 10
            color: Style.current.black
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
                    if(audioMessage.playbackState === Audio.PlayingState){
                        audioMessage.pause();
                    }
                }
                onReleased: {
                    handle.state = "default"
                    audioMessage.seek(audioMessage.duration * handle.x / parent.parent.width);
                }
            }
        }
    }
}