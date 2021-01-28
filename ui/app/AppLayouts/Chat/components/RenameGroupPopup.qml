import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "./"

ModalPopup {
    function doRename(){
        chatsModel.groups.rename(groupName.text)
        popup.close();
    }

    id: popup
    height: 210

    //% "Group name"
    title: qsTrId("group-name")

    onOpened: {
        groupName.forceActiveFocus(Qt.MouseFocusReason)
        groupName.text = chatsModel.activeChannel.name
    }

    Input {
        id: groupName
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        //% "Group name"
        placeholderText: qsTrId("group-name")
        Keys.onEnterPressed: doRename()
        Keys.onReturnPressed: doRename()
    }

    footer: StatusButton {
        id: saveBtn
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        //% "Save"
        text: qsTrId("save")
        onClicked : doRename()
    }
}
