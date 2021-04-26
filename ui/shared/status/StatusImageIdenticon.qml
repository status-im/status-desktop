import QtQuick 2.13
import "../../imports"
import "../../shared"

RoundedImage {
    id: root
    noHover: true
    source:"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAg0lEQVR4nOzXwQmAMBAFURV7sQybsgybsgyr0QYUlE1g+Mw7ioQMe9lMQwhDaAyhMYTGEJqYkPnrj/t5XE/ft2UdW1yken7MRAyhMYTGEBpDaAyhKe9JbzvSX9WdLWYihtAYQuMLkcYQGkPUScxEDKExhMYQGkNoDKExhMYQmjsAAP//ZfIUZgXTZXQAAAAASUVORK5CYII="
    width: 40 * scaleAction.factor
    height: 40 * scaleAction.factor
    border.width: 1 * scaleAction.factor
    border.color: Style.current.borderSecondary
    smooth: false
    antialiasing: true
}
