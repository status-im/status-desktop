import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"

Rectangle {
    implicitWidth: 1.2
    color: SplitHandle.pressed ? Theme.darkGrey
                : (SplitHandle.hovered ? Qt.darker(Theme.grey, 1.1) : Theme.grey)
}
