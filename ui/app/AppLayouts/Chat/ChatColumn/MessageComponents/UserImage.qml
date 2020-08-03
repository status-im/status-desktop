import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"

Rectangle {
    id: chatImage
    visible: isMessage  && authorCurrentMsg != authorPrevMsg
    width: identiconImage.width
    height: identiconImage.height
    border.width: 1
    border.color: Style.current.border
    radius: 50

    Image {
        id: identiconImage
        width: 36
        height: chatImage.visible ? 36 : 0
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
