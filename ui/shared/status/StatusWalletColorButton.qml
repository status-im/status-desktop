import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../imports"
import "../../shared"
import "../../shared/status"

StatusIconButton {
    id: control
    property bool selected: false
    icon.name: "walletIcon"
    icon.width: 24
    icon.height: 24
    highlightedBackgroundColor: control.icon.color
    highlightedBackgroundOpacity: 0.1
    implicitWidth: 44
    implicitHeight: 44

    Rectangle {
        width: 16
        height: 16
        anchors.top: parent.top
        anchors.topMargin: 2
        anchors.right: parent.right
        anchors.rightMargin: 2
        visible: control.selected
        radius: width / 2
        color: Style.current.green
        SVGImage {
            id: checkmark
            source: "../img/checkmark.svg"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            height: 10
            fillMode: Image.PreserveAspectFit
        }
    }

}
