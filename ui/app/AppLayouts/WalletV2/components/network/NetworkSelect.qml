import QtQuick 2.13
import "../../../../../shared"
import "../../../../../imports"

Item {
    id: root
    width: selectRectangle.width
    height: childrenRect.height

    Rectangle {
        id: selectRectangle
        border.width: 1
        border.color: Style.current.border
        radius: Style.current.radius
        width: text.width + Style.current.padding * 4
        height: text.height + Style.current.padding

        StyledText {
            id: text
            text: qsTr("All networks")
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Style.current.primaryTextFontSize
        }

        SVGImage {
            id: caretImg
            width: 10
            height: 6
            source: "../../../../../app/img/caret.svg"
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
        }
    }

    MouseArea {
        anchors.fill: selectRectangle
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (selectPopup.opened) {
                selectPopup.close()
                return
            }
            selectPopup.open()
        }
    }

    NetworkFilter {
        id: networkFilter
        anchors.topMargin: Style.current.halfPadding
        anchors.top: selectRectangle.bottom
        width: root.width
    }

    NetworkSelectPopup {
        id: selectPopup
        x: (parent.width - width)
        y: (root.height - networkFilter.height)
    }
}
