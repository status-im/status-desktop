import QtQuick 2.13

import StatusQ.Components 0.1
import "../../../imports"
import "./LeftTab"

Item {
    property alias changeProfileSection: profileMenu.changeProfileSection

    id: profileInfoContainer

    StatusNavigationPanelHeadline {
        id: title
        text: qsTr("Profile")
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
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
