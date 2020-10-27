import QtQuick 2.13
import "../../../../shared"
import "../../../../shared/status"
import "../../../../imports"

Item {
    property url source: "../../../img/globe.svg"
    property string text
    signal clicked

    id: root
    width: 74
    height: bookmarkImage.height + bookmarkName.height + Style.current.halfPadding

    SVGImage {
        id: bookmarkImage
        source: root.source
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
        onClicked: root.clicked()
    }
}
