import QtQuick 2.13
import "../../../../../shared"

import utils 1.0

MouseArea {
    enabled: !placeholderMessage
    cursorShape: chatText.hoveredLink ? Qt.PointingHandCursor : undefined
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    z: 50
    onClicked: {
        if (activityCenterMessage) {
            return clickMessage(false, isSticker, false)
        }
        if(mouse.button === Qt.RightButton) {
            // Set parent, X & Y positions for the messageContextMenu
            messageContextMenu.parent = root
            messageContextMenu.setXPosition = function() { return (mouse.x)}
            messageContextMenu.setYPosition = function() { return (mouse.y)}
            clickMessage(false, isSticker, false)
            if (typeof isMessageActive !== "undefined") {
                setMessageActive(messageId, true)
            }
            return;
        }
        if (mouse.button === Qt.LeftButton && isSticker && stickersLoaded) {
            if (isHovered) {
                isHovered = false
            }
            
            openPopup(statusStickerPackClickPopup, {packId: stickerPackId} )
            return;
        }
    }
}
