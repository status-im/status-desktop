import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

StyledText {
    id: sentMessage
    color: Style.current.darkGrey
    //% "Sending..."
    text: qsTrId("sending")
    font.pixelSize: 10
}
