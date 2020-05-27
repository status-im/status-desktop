import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../imports"
import "."

SplitView {
    id: chatView
    x: 0
    y: 0
    Layout.fillHeight: true
    Layout.fillWidth: true

    handleDelegate: Rectangle {
        implicitWidth: 1
        implicitHeight: 4
        color: Theme.grey
    }

    ContactsColumn {
        id: contactsColumn
    }

    ChatColumn {
        id: chatColumn
        chatGroupsListViewCount: contactsColumn.chatGroupsListViewCount
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.5;height:770;width:1152}
}
##^##*/
