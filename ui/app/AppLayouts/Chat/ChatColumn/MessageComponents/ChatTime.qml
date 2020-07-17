import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

StyledTextEdit {
    id: chatTime
    visible: (isEmoji || isMessage || isSticker || isImage)
    color: Style.current.darkGrey
    text: {
        let messageDate = new Date(Math.floor(timestamp))
        let minutes = messageDate.getMinutes();
        let hours = messageDate.getHours();
        return (hours < 10 ? "0" + hours : hours) + ":" + (minutes < 10 ? "0" + minutes : minutes)
    }
    font.pixelSize: 10
    readOnly: true
    selectByMouse: true
}
