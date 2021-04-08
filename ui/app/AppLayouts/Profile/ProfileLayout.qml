import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"
import "./Sections"

SplitView {
    property int contentMaxWidth: 624
    property int contentMinWidth: 450
    property int topMargin: 46
    property alias changeProfileSection: leftTab.changeProfileSection

    id: profileView
    Layout.fillHeight: true
    Layout.fillWidth: true

    handle: SplitViewHandle {}

    Connections {
        target: appMain
        onSettingsLoaded: {
            // Add recent
            profileView.restoreState(appSettings.profileSplitView)
        }
    }
    Component.onDestruction: appSettings.profileSplitView = this.saveState()

    LeftTab {
        id: leftTab
        SplitView.preferredWidth: Style.current.leftTabPrefferedSize
        SplitView.minimumWidth: Style.current.leftTabMinimumWidth
        SplitView.maximumWidth: Style.current.leftTabMaximumWidth
    }

    StackLayout {
        property int profileContentWidth: Math.max(contentMinWidth, Math.min(profileContainer.width * 0.8, contentMaxWidth))

        id: profileContainer
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        currentIndex: leftTab.currentTab

        // This list needs to match LeftTab/constants.js
        // Would be better if we could make them match automatically
        MyProfileContainer {}

        onCurrentIndexChanged: {
            if(visibleChildren[0] === ensContainer){
                ensContainer.goToStart();
            }
        }

        ContactsContainer {}

        EnsContainer {
            id: ensContainer
        }

        PrivacyContainer {}

        AppearanceContainer {}

        SoundsContainer {}

        LanguageContainer {}

        NotificationsContainer {}

        SyncContainer {}

        DevicesContainer {}

        BrowserContainer {}

        AdvancedContainer {}

        HelpContainer {}

        AboutContainer {}
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
