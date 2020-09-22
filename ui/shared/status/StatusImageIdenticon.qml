import QtQuick 2.13
import "../../imports"
import "../../shared"

Rectangle {
    id: root
    property url source:"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAg0lEQVR4nOzXwQmAMBAFURV7sQybsgybsgyr0QYUlE1g+Mw7ioQMe9lMQwhDaAyhMYTGEJqYkPnrj/t5XE/ft2UdW1yken7MRAyhMYTGEBpDaAyhKe9JbzvSX9WdLWYihtAYQuMLkcYQGkPUScxEDKExhMYQGkNoDKExhMYQmjsAAP//ZfIUZgXTZXQAAAAASUVORK5CYII="
    width: 40
    height: 40
    color: Style.current.background
    radius: width / 2
    border.width: 1
    border.color: Style.current.borderSecondary

    Image {
        width: parent.width
        height: parent.height
        fillMode: Image.PreserveAspectFit
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: root.source
        mipmap: true
        smooth: false
        antialiasing: true
    }
}
