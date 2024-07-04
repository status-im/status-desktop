import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

ColumnLayout {
    id: root

    property alias estimatedTimeText: contentText.text

    StatusBaseText {
        text: qsTr("Est. time:")
        font.pixelSize: 12
        color: Theme.palette.directColor1
    }
    StatusBaseText {
        id: contentText

        font.pixelSize: 16
        font.weight: Font.DemiBold
    }
}
