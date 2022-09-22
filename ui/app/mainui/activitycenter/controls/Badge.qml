import QtQuick 2.14
import QtQuick.Layouts 1.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    height: visible ? 24 : 0
    width: childrenRect.width + Style.current.smallPadding * 2
    radius: height / 2
    border.width: 1
    border.color: Style.current.borderSecondary
    color: Style.current.transparent
}

