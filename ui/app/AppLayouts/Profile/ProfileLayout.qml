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

    property alias changeProfileSection: leftTab.changeProfileSection

    property RootStore store: RootStore { }
    property var globalStore
    property var systemPalette
    property bool networkGuarded: false

    QtObject {
        id: _internal
        readonly property int contentMaxWidth: 624
        readonly property int contentMinWidth: 450
        property int profileContentWidth: Math.max(contentMinWidth, Math.min(profileContainer.width * 0.8, contentMaxWidth))
    }

    leftPanel: LeftTabView {
        id: leftTab
        store: profileView.store
        anchors.fill: parent
    }

    rightPanel: StackLayout {
        id: profileContainer

        anchors.fill: parent

        currentIndex: Global.currentMenuTab

        onCurrentIndexChanged: {
            if(visibleChildren[0] === ensContainer){
                ensContainer.goToStart();
            }
        }

        MyProfileView {
            store: profileView.store
            profileContentWidth: _internal.profileContentWidth
        }

        ContactsView {
            store: profileView.store
            profileContentWidth: _internal.profileContentWidth
        }

        EnsView {
            id: ensContainer
            store: profileView.store
            messageStore: profileView.globalStore.messageStore
            networkGuarded: profileView.networkGuarded
            profileContentWidth: _internal.profileContentWidth
        }

        PrivacyView {
            store: profileView.store
            profileContentWidth: _internal.profileContentWidth
        }

        AppearanceView {
            store: profileView.store
            globalStore: profileView.globalStore
            profileContentWidth: _internal.profileContentWidth
            systemPalette: profileView.systemPalette
        }

        SoundsView {
            profileContentWidth: _internal.profileContentWidth
        }

        LanguageView {
            store: profileView.store
            profileContentWidth: _internal.profileContentWidth
        }

        NotificationsView {
            store: profileView.store
            profileContentWidth: _internal.profileContentWidth
        }

        SyncView {
            store: profileView.store
            profileContentWidth: _internal.profileContentWidth
        }

        DevicesView {
            store: profileView.store
        }

        BrowserView {
            store: profileView.store
            profileContentWidth: _internal.profileContentWidth
        }

        AdvancedView {
            store: profileView.store
            profileContentWidth: _internal.profileContentWidth
        }

        HelpView {
            profileContentWidth: _internal.profileContentWidth
        }

        AboutView {
            store: profileView.store
            profileContentWidth: _internal.profileContentWidth
        }
    }
}







