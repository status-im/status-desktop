import QtQuick 2.12
import QtQuick.Controls 2.12
import StatusQ.Core.Theme 0.1

import utils 1.0

TabButton {
    id: root
    property int index: 0
    property int currentIndex: 0
    implicitWidth: Style.dp(59)
    implicitHeight: Style.dp(4)
    enabled: false
    background: Rectangle {
        anchors.fill: parent
        radius: Style.dp(4)
        color: (root.currentIndex === index) || (root.currentIndex > index) ?
               Theme.palette.primaryColor1 : Theme.palette.primaryColor2
    }
}
