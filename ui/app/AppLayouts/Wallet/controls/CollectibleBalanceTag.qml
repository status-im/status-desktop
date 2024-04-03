import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

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
        font.pixelSize: 10
        font.family: Theme.palette.baseFont.name
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
