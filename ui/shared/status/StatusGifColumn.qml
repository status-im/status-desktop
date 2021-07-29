import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3


Column {
    id: root
    spacing: 4
    property alias gifList: repeater
    property var gifWidth: 0
    property var gifSelected: function () {}

    Repeater {
        id: repeater

        delegate: Rectangle {
            height: animation.height
            width: root.gifWidth

            AnimatedImage {
                id: animation
                source: model.url
                width: root.gifWidth
                fillMode: Image.PreserveAspectFit
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
