import QtQuick 2.13
import QtQuick.Controls 2.13
import Qt.labs.settings 1.0
import "../../../imports"
import "../../../shared"
import "."

SplitView {
    property var appSettings

    id: chatView
    handle: SplitViewHandle {}

    Component.onCompleted: this.restoreState(appSettings.chatSplitView)
    Component.onDestruction: appSettings.chatSplitView = this.saveState()

    ContactsColumn {
        id: contactsColumn
        SplitView.preferredWidth: Style.current.leftTabPrefferedSize
        SplitView.minimumWidth: Style.current.leftTabMinimumWidth
        SplitView.maximumWidth: Style.current.leftTabMaximumWidth
    }

    ChatColumn {
        id: chatColumn
        chatGroupsListViewCount: contactsColumn.chatGroupsListViewCount
        appSettings: chatView.appSettings
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25;height:770;width:1152}
}
##^##*/
