import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import shared 1.0
import shared.panels 1.0

Item {
    id: root
    property bool selected: false
    property bool useIconInsteadOfImage: false
    property url source: Style.svg("history")
    signal clicked
    height: Style.dp(24)
    width: Style.dp(24)

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
        iconWidth: Style.dp(6)
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
        border.width: Style.dp(1)
        height: Style.dp(2)
        width: Style.dp(16)
        x: Style.dp(4)
        y: root.y + root.height + Style.dp(6)
    }
}
