import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

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
                        clickMessage(true)
                    }
                }
            }
        }
    }
}
