import QtQuick

import utils

import StatusQ.Core
import StatusQ.Core.Theme

Rectangle {
    id: root

    z: 100 // NOTE: workaround for message overlay
    implicitWidth: childrenRect.width + Theme.smallPadding * 2
    implicitHeight: visible ? 24 : 0
    radius: height / 2
    border.width: 1
    border.color: Theme.palette.directColor7
    color: StatusColors.colors.transparent
}
