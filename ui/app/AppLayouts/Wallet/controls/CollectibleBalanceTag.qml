import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

Control {
    id: root

    property int balance: 1

    implicitHeight: 24
    horizontalPadding: 8

    background: Rectangle {
        color: Theme.palette.indirectColor2
        radius: height / 2
    }

    contentItem: StatusBaseText {
        color: Theme.palette.directColor1
        font.pixelSize: Theme.asideTextFontSize
        font.family: Theme.baseFont.name
        text: {
            if (root.balance > 99) {
                return "99+"
            } else {
                return root.balance
            }
        }
        verticalAlignment: Text.AlignVCenter
    }
}
