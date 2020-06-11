import QtQuick 2.3
import "../imports"

Rectangle {
    id: roundedImage
    property url source:"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAg0lEQVR4nOzXwQmAMBAFURV7sQybsgybsgyr0QYUlE1g+Mw7ioQMe9lMQwhDaAyhMYTGEJqYkPnrj/t5XE/ft2UdW1yken7MRAyhMYTGEBpDaAyhKe9JbzvSX9WdLWYihtAYQuMLkcYQGkPUScxEDKExhMYQGkNoDKExhMYQmjsAAP//ZfIUZgXTZXQAAAAASUVORK5CYII="
    width: 40
    height: 40
    color: Theme.white
    radius: 50
    border.width: 1
    border.color: Theme.darkGrey

    Image {
        width: parent.width
        height: parent.height
        fillMode: Image.PreserveAspectFit
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: roundedImage.source

    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#4c4e50";formeditorZoom:2}
}
##^##*/
