import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import "../../imports"


Column {
    id: root
    spacing: 8
    property alias gifList: repeater
    property var gifWidth: 0
    property var gifSelected: function () {}

    Repeater {
        id: repeater

        delegate: Rectangle {
            height: animation.status != Image.Ready ? loader.height : animation.height
            width: root.gifWidth
            color: Style.current.background
            border.color: Style.current.border

            Rectangle {
                id: loader
                height: 100
                width: root.gifWidth
                visible: animation.status != Image.Ready
                radius: Style.current.radius
                rotation: 90
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: "#E6EEF2" }
                }
            }

            AnimatedImage {
                id: animation
                visible: animation.status == Image.Ready
                source: model.tinyUrl
                width: root.gifWidth
                fillMode: Image.PreserveAspectFit
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: animation.width
                        height: animation.height
                        radius: Style.current.radius
                        color: Style.current.background
                        border.color: Style.current.border
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: function (event) {
                    root.gifSelected(event, model.url)
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:440;width:360}
}
##^##*/
