import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

MouseArea {
    cursorShape: chatText.hoveredLink ? Qt.PointingHandCursor : undefined
    acceptedButtons: Qt.RightButton | Qt.LeftButton
    z: 50
    onClicked: {
        if(mouse.button & Qt.RightButton) {
            clickMessage(false, isSticker, false);
            return;
        }
        if (mouse.button & Qt.LeftButton) {                
            return;
        }
    }
}

