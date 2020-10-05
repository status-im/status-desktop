import QtQuick 2.13
import "../../../imports"
import "../../../shared"
import "./LeftTab"

Item {
    property alias currentTab: profileMenu.profileCurrentIndex

    id: profileInfoContainer

    StyledText {
        id: title
        //% "Profile"
        text: qsTrId("profile")
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        font.weight: Font.Bold
        font.pixelSize: Style.current.altTitleTextFontSize
    }

    Menu {
        id: profileMenu
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        anchors.top: title.bottom
        anchors.topMargin: Style.current.bigPadding
        anchors.bottom: parent.bottom
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:600;width:340}
}
##^##*/
