import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

Loader {
    active: isMessage
    height: active ? item.height : 0

    sourceComponent: Component {
        Item {
            id: chatImage
            width: identiconImage.width
            height: identiconImage.height

            RoundedImage {
                id: identiconImage
                width: 36 * scaleAction.factor
                height: 36 * scaleAction.factor
                border.width: 1 * scaleAction.factor
                border.color: Style.current.border
                source: {
                    if (profileImageSource) {
                        return profileImageSource
                    }
                    identiconImage.showLoadingIndicator = false
                    return !isCurrentUser ? identicon : profileModel.profile.identicon
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
