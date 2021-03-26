import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"

Rectangle {
    implicitWidth: 1.2
    color: SplitHandle.pressed ? Style.current.darkGrey
                : (SplitHandle.hovered ? Qt.darker(Style.current.border, 1.1) : Style.current.transparent)
}
