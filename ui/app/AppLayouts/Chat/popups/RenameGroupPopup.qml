import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import "../../../../shared/controls"

StatusModal {

    id: popup
    height: 210
    anchors.centerIn: parent

    //% "Group name"
    header.title: qsTrId("group-name")

    property string activeChannelName
    signal doRename(string groupName)

    onOpened: {
        groupName.forceActiveFocus(Qt.MouseFocusReason)
        groupName.text = popup.activeChannelName;
    }

    contentItem: Item {
        width: popup.width 
        implicitHeight: childrenRect.height
        Input {
            id: groupName
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding
            //% "Group name"
            placeholderText: qsTrId("group-name")
            Keys.onEnterPressed: doRename()
            Keys.onReturnPressed: doRename()
        }
    }

    rightButtons: [
        StatusButton {
            id: saveBtn
            //% "Save"
            text: qsTrId("save")
            onClicked : { doRename(groupName.text); }
        }
    ]
}
