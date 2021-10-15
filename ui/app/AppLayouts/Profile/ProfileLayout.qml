import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared 1.0

import "stores"
import "popups"
import "views"

import StatusQ.Layout 0.1

StatusAppTwoPanelLayout {

    id: profileView

    property RootStore store
    property var globalStore
    property int contentMaxWidth: 624
    property int contentMinWidth: 450
    property alias changeProfileSection: leftTab.changeProfileSection

    leftPanel: LeftTabView {
        id: leftTab
        store: profileView.store
        anchors.fill: parent
    }

    rightPanel: StackLayout {
        id: profileContainer
        property int profileContentWidth: Math.max(contentMinWidth, Math.min(profileContainer.width * 0.8, contentMaxWidth))
        anchors.fill: parent

        currentIndex: Config.currentMenuTab

        onCurrentIndexChanged: {
            if(visibleChildren[0] === ensContainer){
                ensContainer.goToStart();
            }
        }

        MyProfileView {
            store: profileView.store
        }

        ContactsView {
            store: profileView.store
        }

        EnsView {
            id: ensContainer
            store: profileView.store
            messageStore: profileView.globalStore.messageStore
        }

        PrivacyView {
            store: profileView.store
        }

        AppearanceView {
            store: profileView.store
            globalStore: profileView.globalStore
        }

        SoundsView {}

        LanguageView {
            store: profileView.store
        }

        NotificationsView {
            store: profileView.store
        }

        SyncView {
            store: profileView.store
        }

        DevicesView {
            store: profileView.store
        }

        BrowserView {
            store: profileView.store
        }

        AdvancedView {
            store: profileView.store
        }

        HelpView {}

        AboutView {
            store: profileView.store
        }
    }
}







