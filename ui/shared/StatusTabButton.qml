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
        color: Style.current.transparent
        border.color: Style.current.transparent
    }

    StyledText {
        id: tabBtnText
        text: btnText
        font.weight: Font.Medium
        font.pixelSize: 15
        color: parent.checked ? Style.current.textColor : Style.current.darkGrey
    }

    Rectangle {
        visible: parent.checked
        color: Style.current.blue
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
