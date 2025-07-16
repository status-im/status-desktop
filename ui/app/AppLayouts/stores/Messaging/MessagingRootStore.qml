import QtQuick 2.15

import AppLayouts.stores.Messaging.Community 1.0

QtObject {
    id: root

    readonly property MessagingSettingsStore messagingSettingsStore: MessagingSettingsStore {}

    // Dynamic `CommunityRootStore` instance creation logic.
    // Each `CommunityRootStore` is owned by the delegate that needs it and gets destroyed with it (clear ownership).
    function createCommunityRootStore(parent, communityId) {
        console.log("Creating `CommunityRootStore` for community ID:", communityId)
        return communityRootStoreComponent.createObject(parent, { communityId: communityId })
    }

    property Component communityRootStoreComponent: Component {
        CommunityRootStore {
            Component.onCompleted: console.log("Store created for", communityId)
            Component.onDestruction: console.log("Store for", communityId, "destroyed")
        }
    }
}
