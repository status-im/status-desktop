import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../imports"
import "../../shared"

Item {
    id: root
    property bool selected: false
    property bool useIconInsteadOfImage: false
    property url source: "../../app/img/history_icon.svg"
    signal clicked
    height: 24 * scaleAction.factor
    width: 24 * scaleAction.factor

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
        iconWidth: 6 * scaleAction.factor
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
        height: 2 * scaleAction.factor
        width: 16 * scaleAction.factor
        x: 4
        y: root.y + root.height + 6
    }
}
