import QtQuick 2.13
import "../../../imports"
import "../../../shared"
import "./LeftTab"

Rectangle {
    property alias changeProfileSection: profileMenu.changeProfileSection

    id: profileInfoContainer
    color: Style.current.secondaryMenuBackground

    StyledText {
        id: title
        //% "Profile"
        text: qsTrId("profile")
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        font.weight: Font.Bold
        font.pixelSize: 17
    }

    Menu {
        id: profileMenu
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        anchors.top: title.bottom
        anchors.topMargin: Style.current.padding
        anchors.bottom: parent.bottom
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:600;width:340}
}
##^##*/
