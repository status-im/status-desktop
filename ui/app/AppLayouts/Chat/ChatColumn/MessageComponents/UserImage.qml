import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

Loader {
    active: isMessage && authorCurrentMsg !== authorPrevMsg
    height: active ? item.height : 0

    sourceComponent: Component {
        Rectangle {
            id: chatImage
            width: identiconImage.width
            height: identiconImage.height
            border.width: 1
            border.color: Style.current.border
            radius: 50

            Image {
                id: identiconImage
                width: 36
                height: 36
                fillMode: Image.PreserveAspectFit
                source: !isCurrentUser ? identicon : profileModel.profile.identicon
                mipmap: true
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
