import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../../../imports"
import "../../../../../shared"

Rectangle {
    property url source: "../../../../img/emojiBtn.svg"
    property bool hovered: false
    property bool opened: false
    property var close: function () {}
    property var open: function () {}

    id: root
    width: this.visible ? buttonIcon.width + 4 + chatButtonsContainer.iconPadding * 2 : 0
    height: this.visible ? buttonIcon.height + chatButtonsContainer.iconPadding * 2 : 0
    radius: Style.current.radius
    color: hovered ? Style.current.secondaryBackground : Style.current.transparent
    anchors.verticalCenter: parent.verticalCenter

    SVGImage {
        id: buttonIcon
        visible: txtData.length === 0
        source: root.source
        width: 20
        height: 20
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }
    ColorOverlay {
        anchors.fill: buttonIcon
        source: buttonIcon
        color: root.hovered || root.opened ? Style.current.blue : Style.current.darkGrey
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
          root.hovered = true
        }
        onExited: {
          root.hovered = false
        }
        onClicked: {
            if (root.opened) {
                root.close()
            } else {
                root.open()
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:1.5}
}
##^##*/
