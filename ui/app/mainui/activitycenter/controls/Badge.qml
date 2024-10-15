import QtQuick 2.15

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    z: 100 // NOTE: workaround for message overlay
    implicitWidth: childrenRect.width + Theme.smallPadding * 2
    implicitHeight: visible ? 24 : 0
    radius: height / 2
    border.width: 1
    border.color: Theme.palette.directColor7
    color: Theme.palette.transparent
}
