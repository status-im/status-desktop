import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0

import "views"
import "stores"

StackLayout {
    id: root

    property var contactsStore
    property RootStore rootStore: RootStore {
        contactsStore: root.contactsStore
    }

    property alias chatView: chatView

    clip: true

    ChatView {
        id: chatView
        contactsStore: root.contactsStore
        rootStore: root.rootStore

        onCommunityInfoButtonClicked: root.currentIndex = 1
        onCommunityManageButtonClicked: root.currentIndex = 1
    }

    Loader {
        active: root.rootStore.chatCommunitySectionModule.isCommunity()

        sourceComponent: CommunitySettingsView {
            rootStore: root.rootStore
            hasAddedContacts: root.contactsStore.myContactsModel.count > 0
            chatCommunitySectionModule: root.rootStore.chatCommunitySectionModule
            community: root.rootStore.mainModuleInst ? root.rootStore.mainModuleInst.activeSection
                                                       || {} : {}

            onBackToCommunityClicked: root.currentIndex = 0

            // TODO: remove me when migration to new settings is done
            onOpenLegacyPopupClicked: Global.openPopup(communityProfilePopup, {
                                                           "store": root.rootStore,
                                                           "community": community,
                                                           "communitySectionModule": chatCommunitySectionModule
                                                       })
        }
    }
}
