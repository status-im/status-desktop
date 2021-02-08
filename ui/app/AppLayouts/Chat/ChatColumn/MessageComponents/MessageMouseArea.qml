import QtQuick 2.13
import "../../../../../shared"
import "../../../../../imports"

MouseArea {
    enabled: !placeholderMessage
    cursorShape: chatText.hoveredLink ? Qt.PointingHandCursor : undefined
    acceptedButtons: Qt.RightButton | Qt.LeftButton
    z: 50
    onClicked: {
        if(mouse.button & Qt.RightButton) {
            clickMessage(false, isSticker, false);
            if (typeof isMessageActive !== "undefined") {
                isMessageActive = true
            }
            return;
        }
        if (mouse.button & Qt.LeftButton) {                
            return;
        }
    }
}
