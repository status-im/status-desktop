import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import "../../shared"
import "../../shared/panels"

Item {
    id: root
    property bool selected: false
    property bool useIconInsteadOfImage: false
    property url source: Style.svg("history_icon")
    signal clicked
    height: 24
    width: 24

    RoundedImage {
        visible: !useIconInsteadOfImage
        id: iconImage
        width: parent.width
        height: parent.height
        source: root.source
        onClicked: {
            root.clicked()
        }
    }
    RoundedIcon {
        id: iconIcon
        visible: useIconInsteadOfImage
        width: parent.width
        height: parent.height
        iconWidth: 6
        color: Style.current.darkGrey
        source: root.source
        onClicked: {
            root.clicked()
        }
    }
    Rectangle {
        id: packIndicator
        visible: root.selected
        border.color: Style.current.blue
        border.width: 1
        height: 2
        width: 16
        x: 4
        y: root.y + root.height + 6
    }
}
