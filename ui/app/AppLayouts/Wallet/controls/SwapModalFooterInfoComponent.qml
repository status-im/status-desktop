import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

ColumnLayout {
    id: root

    property alias titleText: titleText.text
    property alias infoText: infoText.text
    property alias loading: infoText.loading

    StatusBaseText {
        id: titleText
        Layout.fillWidth: true
        elide: Text.ElideRight
        color: Theme.palette.baseColor1
        font.pixelSize: 13
    }
    StatusTextWithLoadingState {
        id: infoText
        Layout.fillWidth: true
        elide: Text.ElideRight
        font.pixelSize: 13
    }
}
