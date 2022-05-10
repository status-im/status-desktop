import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0

import "views"
import "stores"
import "popups/community"

StackLayout {
    id: root

    property var contactsStore
    property RootStore rootStore: RootStore {
        contactsStore: root.contactsStore
    }

    property alias chatView: chatView
    signal importCommunityClicked()
    signal createCommunityClicked()

    clip: true

    Component {
        id: membershipRequestPopupComponent
        MembershipRequestsPopup {
            anchors.centerIn: parent
            store: root.rootStore
            communityData: store.mainModuleInst ? store.mainModuleInst.activeSection || {} : {}
            onClosed: {
                destroy()
            }
        }
    }

    ChatView {
        id: chatView
        contactsStore: root.contactsStore
        rootStore: root.rootStore
        membershipRequestPopup: membershipRequestPopupComponent

        onCommunityInfoButtonClicked: root.currentIndex = 1
        onCommunityManageButtonClicked: root.currentIndex = 1

        onImportCommunityClicked: {
            root.importCommunityClicked();
        }
        onCreateCommunityClicked: {
            root.createCommunityClicked();
        }
    }

    Loader {
        active: root.rootStore.chatCommunitySectionModule.isCommunity()

        sourceComponent: CommunitySettingsView {
            membershipRequestPopup: membershipRequestPopupComponent
            rootStore: root.rootStore
            hasAddedContacts: root.contactsStore.myContactsModel.count > 0
            chatCommunitySectionModule: root.rootStore.chatCommunitySectionModule
            community: root.rootStore.mainModuleInst ? root.rootStore.mainModuleInst.activeSection
                                                       || {} : {}

        onBackToCommunityClicked: root.currentIndex = 0

        // TODO: remove me when migration to new settings is done
        onOpenLegacyPopupClicked: Global.openPopup(Global.communityProfilePopup, {
                                                       "store": root.rootStore,
                                                       "community": community,
                                                       "communitySectionModule": chatCommunitySectionModule
                                                   })
        }
    }
}
