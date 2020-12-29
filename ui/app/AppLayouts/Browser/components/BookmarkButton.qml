import QtQuick 2.13
import "../../../../shared"
import "../../../../shared/status"
import "../../../../imports"

Item {
    property url source
    property string text
    signal clicked(mouse: var)
    signal rightClicked(mouse: var)

    id: root
    width: 74
    height: bookmarkImage.height + bookmarkName.height + Style.current.halfPadding

    SVGImage {
        id: bookmarkImage
        source: !!root.source && !!root.source.toString() ? root.source :"../../../img/compassActive.svg"
        anchors.horizontalCenter: parent.horizontalCenter
        width: 48
        height: 48
    }

    StyledText {
        id: bookmarkName
        text: root.text
        width: parent.width
        anchors.top: bookmarkImage.bottom
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        anchors.topMargin: Style.current.halfPadding
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (mouse.button === Qt.RightButton) {
                root.rightClicked(mouse)
            } else {
                root.clicked(mouse)
            }
        }
    }
}
