import QtQuick 2.15

// TO REVIEW: Instead of `Chat` domain that indeed includes `Chat and Communities`, why not naming it as:
// ** Social Domain
// ** Comms Domain
// ** Messaging Domain
// ** Conversations Domain
// ** Interaction Domain
// SocialStoresFactory instead?

// There's ONLY one instance in all the project of this object: In `AppMain.qml`
QtObject {
    id: root

    // TO REVIEW: It can be needed an instance per community (now the dynamic instantiation of communities happen on a Repeater inside the `AppMain.qml`.
    readonly property MessagingStore mmessagingStore: MessagingStore {} // Could be named as `Chat`?

    // TO REVIEW: It can be needed an instance per community (now the dynamic instantiation of communities happen on a Repeater inside the `AppMain.qml`.
    readonly property CommunityStore communityStore: CommunityStore {}

    readonly property MessageStore messageStore: MessageStore {}

    readonly property StickersStore stickersStore: StickersStore {}

    readonly property UsersStore usersStore: UsersStore{}
}
