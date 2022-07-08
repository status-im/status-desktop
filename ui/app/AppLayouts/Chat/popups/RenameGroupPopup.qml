import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared.controls 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: root

    property string activeChannelName
    signal doRename(string groupName)

    width: 400
    title: qsTr("Group name")
    standardButtons: Dialog.Save

    onOpened: {
        groupName.forceActiveFocus(Qt.MouseFocusReason)
        groupName.text = root.activeChannelName
    }

    onAccepted: root.doRename(groupName.text)

    Input {
        id: groupName

        anchors.fill: parent

        placeholderText: qsTr("Group name")
        Keys.onEnterPressed: doRename(groupName.text)
        Keys.onReturnPressed: doRename(groupName.text)
    }
}
