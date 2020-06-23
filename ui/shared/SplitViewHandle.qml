import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"

Rectangle {
    // FIXME setting this 1 is prettier, but makes the handle complety unusable (too small to grab)
    implicitWidth: 2
    color: SplitHandle.pressed ? Theme.darkGrey
                : (SplitHandle.hovered ? Qt.darker(Theme.grey, 1.1) : Theme.grey)
}
