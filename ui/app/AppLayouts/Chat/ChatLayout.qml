import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../imports"
import "../../../shared"
import "."

SplitView {
    id: chatView

    handle: SplitViewHandle {}

    ContactsColumn {
        id: contactsColumn
        SplitView.preferredWidth: Theme.leftTabPrefferedSize
        SplitView.minimumWidth: Theme.leftTabMinimumWidth
        SplitView.maximumWidth: Theme.leftTabMaximumWidth
    }

    ChatColumn {
        id: chatColumn
        chatGroupsListViewCount: contactsColumn.chatGroupsListViewCount
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25;height:770;width:1152}
}
##^##*/
