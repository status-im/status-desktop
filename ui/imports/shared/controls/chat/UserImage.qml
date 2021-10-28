import QtQuick 2.3
import shared 1.0
import shared.panels 1.0

import utils 1.0

Loader {
    id: root
    active: isMessage
    height: active ? item.height : 0
    property int imageHeight: 36
    property int imageWidth: 36
//    property string profileImage: ""
//    property string identiconImageSource: ""
    property bool isReplyImage: false
//    property var messageContextMenu
//    property bool isCurrentUser: false
//    property bool isMessage: false
    signal clickMessage(bool isProfileClick, bool isSticker, bool isImage, var image, bool emojiOnly, bool hideEmojiPicker, bool isReply)

    sourceComponent: Component {
        Item {
            id: chatImage
            width: identiconImage.width
            height: identiconImage.height

            RoundedImage {
                id: identiconImage
                width: root.imageWidth
                height: root.imageHeight
                border.width: 1
                border.color: Style.current.border
                source: {
                    if (profileImageSource) {
                        return profileImageSource
                    }
                    identiconImage.showLoadingIndicator = false
                    return !isCurrentUser || isReplyImage ? identicon : userProfile.thumbnailImage
                }
                smooth: false
                antialiasing: true

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    anchors.fill: parent
                    onClicked: {
                        if (!!messageContextMenu) {
                            // Set parent, X & Y positions for the messageContextMenu
                            messageContextMenu.parent = root
                            messageContextMenu.setXPosition = function() { return root.width + 4}
                            messageContextMenu.setYPosition = function() { return root.height/2 + 4}
                        }
                        root.clickMessage(true, false, false, null, false, false, isReplyImage)
                    }
                }
            }
        }
    }
}
