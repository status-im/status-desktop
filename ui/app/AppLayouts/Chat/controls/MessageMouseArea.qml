import QtQuick 2.13

import utils 1.0
import shared 1.0

MouseArea {
    z: 50
    enabled: !placeholderMessage

    property bool isHovered: false
    property bool isSticker: false
    property bool placeholderMessage: false
    property bool isActivityCenterMessage: false
    property var isMessageActive
    property var messageContextMenu
    signal setMessageActive(string messageId, bool active)
    signal clickMessage(bool isProfileClick, bool isSticker, bool isImage)

    cursorShape: !enabled ? Qt.PointingHandCursor : undefined

    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: {
        if (isActivityCenterMessage) {
            return clickMessage(false, isSticker, false)
        }
        if (mouse.button === Qt.RightButton) {
            if (!!messageContextMenu) {
                // Set parent, X & Y positions for the messageContextMenu
                //TODO remove dynamic scoping
                messageContextMenu.parent = root
                messageContextMenu.setXPosition = function() { return (mouse.x)};
                messageContextMenu.setYPosition = function() { return (mouse.y)};
            }
            clickMessage(false, isSticker, false)
            if (typeof isMessageActive !== "undefined") {
                setMessageActive(messageId, true)
            }
            return;
        }
        //TODO remove dynamic scoping
        if (mouse.button === Qt.LeftButton && isSticker && stickersLoaded) {
            if (isHovered) {
                isHovered = false;
            }
            //TODO remove dynamic scoping
            openPopup(statusStickerPackClickPopup, {packId: stickerPackId} )
            return;
        }
    }
}
