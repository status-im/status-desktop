import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

ColumnLayout {
    StatusBaseText {
        text: qsTr("Est. time:")
        font.pixelSize: 12
        color: Theme.palette.directColor1
    }
    StatusBaseText {
        text: root.estimatedTimeText
        font.pixelSize: 16
        font.weight: Font.DemiBold
    }
}
