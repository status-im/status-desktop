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

    property ProfileSectionStore store
    property var globalStore
    property var systemPalette

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
            profileStore: profileView.store.profileStore
            profileContentWidth: _internal.profileContentWidth
        }

        ContactsView {
            contactsStore: profileView.store.contactsStore
            profileContentWidth: _internal.profileContentWidth
        }

        EnsView {
            id: ensContainer
            ensUsernamesStore: profileView.store.ensUsernamesStore
            contactsStore: profileView.store.contactsStore
            profileContentWidth: _internal.profileContentWidth
        }

        PrivacyView {
            privacyStore: profileView.store.privacyStore
            profileContentWidth: _internal.profileContentWidth
        }

        AppearanceView {
            appearanceStore: profileView.store.appearanceStore
            profileContentWidth: _internal.profileContentWidth
            systemPalette: profileView.systemPalette
        }

        SoundsView {
            profileContentWidth: _internal.profileContentWidth
        }

        LanguageView {
            languageStore: profileView.store.languageStore
            profileContentWidth: _internal.profileContentWidth
        }

        NotificationsView {
            notificationsStore: profileView.store.notificationsStore
            profileContentWidth: _internal.profileContentWidth
        }

        SyncView {
            syncStore: profileView.store.syncStore
            profileContentWidth: _internal.profileContentWidth
        }

        DevicesView {
            devicesStore: profileView.store.devicesStore
        }

        BrowserView {
            store: profileView.store
            profileContentWidth: _internal.profileContentWidth
        }

        AdvancedView {
            advancedStore: profileView.store.advancedStore
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
