import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"

TabButton {
    property string btnText: "Default Button"

    id: tabButton
    width: tabBtnText.width
    height: tabBtnText.height + 11
    text: ""
    padding: 0
    background: Rectangle {
        color: Theme.transparent
        border.color: Theme.transparent
    }

    Text {
        id: tabBtnText
        text: btnText
        font.weight: Font.Medium
        font.pixelSize: 15
        color: parent.checked ? Theme.black : Theme.darkGrey
    }

    Rectangle {
        color: Theme.blue
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.left: parent.left
        anchors.leftMargin: 4
        height: 3
        radius: 4
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.75}
}
##^##*/
