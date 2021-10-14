import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

Rectangle {
    implicitWidth: 0
    color: SplitHandle.pressed ? Style.current.darkGrey
                : (SplitHandle.hovered ? Qt.darker(Style.current.border, 1.1) : Style.current.transparent)
}
