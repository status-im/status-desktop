import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.panels 1.0

Item {
    id: root

    property bool selected: false
    property bool useIconInsteadOfImage: false
    property url source: Style.svg("history")
    signal clicked

    implicitHeight: 24
    implicitWidth: 24

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
        visible: root.selected
        width: parent.width
        height: 2
        radius: 1
        color: Theme.palette.primaryColor1
        y: root.y + root.height + 6
    }
}
