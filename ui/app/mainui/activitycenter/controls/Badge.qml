import QtQuick 2.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    z: 100 // NOTE: workaround for message overlay
    implicitWidth: childrenRect.width + Style.current.smallPadding * 2
    implicitHeight: visible ? 24 : 0
    radius: height / 2
    border.width: 1
    border.color: Style.current.borderSecondary
    color: Style.current.transparent
}
