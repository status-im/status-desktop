import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Controls.Universal 2.12
import "../../imports"
import "../../shared"
import "./"

Rectangle {
    id: root
    
    property int padding: Style.current.padding
    property alias control: radioControl
    property alias image: img

    width: 312
    height: 258
    color: radioControl.checked ? Style.current.secondaryBackground : Style.current.transparent

    radius: Style.current.radius

    SVGImage {
        id: img
        anchors.top: parent.top
        anchors.topMargin: root.padding
        anchors.left: parent.left
        anchors.leftMargin: root.padding
        anchors.right: parent.right
        anchors.rightMargin: root.padding
    }

    StatusRadioButton {
        id: radioControl
        anchors.top: img.bottom
        anchors.topMargin: root.padding
        anchors.left: parent.left
        anchors.leftMargin: root.padding
    }
}
