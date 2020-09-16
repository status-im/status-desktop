import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"
import "./Sections"

SplitView {
    property int contentMargin: 120

    id: profileView
    Layout.fillHeight: true
    Layout.fillWidth: true

    handle: SplitViewHandle {}

    Connections {
        target: applicationWindow
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
        id: profileContainer
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.left: leftTab.right
        anchors.leftMargin: Style.current.padding
        currentIndex: leftTab.currentTab

        // This list needs to match LeftTab/constants.js
        // Would be better if we could make them match automatically
        MyProfileContainer {
           username: profileModel.profile.username
           ensName: profileModel.ens.preferredUsername
           identicon: profileModel.profile.identicon
           pubkey: profileModel.profile.pubKey
        }

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
