import QtQuick 2.12
import QtQuick.Controls 2.12
import StatusQ.Core.Theme 0.1

TabButton {
    id: root
    property int index: 0
    property int currentIndex: 0
    implicitWidth: 59
    implicitHeight: 4
    enabled: false
    background: Rectangle {
        anchors.fill: parent
        radius: 4
        color: (root.currentIndex === index) || (root.currentIndex > index) ?
               Theme.palette.primaryColor1 : Theme.palette.primaryColor2
    }
}
