import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"
import "./Sections"

import StatusQ.Layout 0.1

StatusAppTwoPanelLayout {

    id: profileView

    property int contentMaxWidth: 624
    property int contentMinWidth: 450
    property int topMargin: 46
    property alias changeProfileSection: leftTab.changeProfileSection

    leftPanel: LeftTab {
        id: leftTab
        anchors.fill:parent
    }

    rightPanel: StackLayout {
        id: profileContainer
        property int profileContentWidth: Math.max(contentMinWidth, Math.min(profileContainer.width * 0.8, contentMaxWidth))
        anchors.fill: parent

        currentIndex: leftTab.currentTab

        onCurrentIndexChanged: {
            if(visibleChildren[0] === ensContainer){
                ensContainer.goToStart();
            }
        }

        // This list needs to match LeftTab/constants.js
        // Would be better if we could make them match automatically
        MyProfileContainer {}

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
