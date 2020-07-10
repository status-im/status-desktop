import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"
import "./Sections"

SplitView {
    property var appSettings

    id: profileView
    Layout.fillHeight: true
    Layout.fillWidth: true

    handle: SplitViewHandle {}

    Component.onCompleted: this.restoreState(appSettings.profileSplitView)
    Component.onDestruction: appSettings.profileSplitView = this.saveState()

    LeftTab {
        id: leftTab
        SplitView.preferredWidth: Style.current.leftTabPrefferedSize
        SplitView.minimumWidth: Style.current.leftTabMinimumWidth
        SplitView.maximumWidth: Style.current.leftTabMaximumWidth
    }

    StackLayout {
        id: profileContainer
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: leftTab.right
        anchors.leftMargin: 0
        currentIndex: leftTab.currentTab

        EnsContainer {}

        ContactsContainer {}

        PrivacyContainer {}

        DevicesContainer {}

        SyncContainer {}

        LanguageContainer {}

        NotificationsContainer {}

        AdvancedContainer {
          appSettings: profileView.appSettings
        }

        HelpContainer {}

        AboutContainer {}

        SignoutContainer {}
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
