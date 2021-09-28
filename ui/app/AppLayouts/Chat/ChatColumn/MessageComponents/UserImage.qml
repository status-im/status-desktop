import QtQuick 2.3
import "../../../../../shared"

import utils 1.0

Loader {
    property int imageHeight: 36
    property int imageWidth: 36
    property string identiconImageSource: identicon
    property string profileImage: profileImageSource
    property bool isReplyImage: false

    id: root
    active: isMessage
    height: active ? item.height : 0

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
                    if (root.profileImage) {
                        return root.profileImage
                    }
                    identiconImage.showLoadingIndicator = false
                    return !isCurrentUser || isReplyImage ? root.identiconImageSource : profileModel.profile.identicon
                }
                smooth: false
                antialiasing: true

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    anchors.fill: parent
                    onClicked: {
                        // Set parent, X & Y positions for the messageContextMenu
                        messageContextMenu.parent = root
                        messageContextMenu.setXPosition = function() { return root.width + 4}
                        messageContextMenu.setYPosition = function() { return root.height/2 + 4}
                        clickMessage(true, false, false, null, false, false, isReplyImage)
                    }
                }
            }
        }
    }
}
