import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared 1.0

Item {
    property string name: "permission-name-here"

    height: 50
    anchors.right: parent.right
    anchors.left: parent.left

    signal removeBtnClicked(string permission)

    StatusBaseText {
        id: dappText
        text: name
        elide: Text.ElideRight
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        font.pixelSize: 17
        anchors.top: parent.top
        anchors.topMargin: Style.current.smallPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
    }

    
    StatusBaseText {
        //% "Revoke access"
        text: qsTrId("revoke-access")
        color: Theme.palette.dangerColor1
        anchors.top: parent.top
        anchors.topMargin: Style.current.smallPadding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding

        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: removeBtnClicked(name)
        }
    }
    
}
