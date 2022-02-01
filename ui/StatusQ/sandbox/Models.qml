import QtQuick 2.14
import StatusQ.Components 0.1

QtObject {

    property var demoChatListItems: ListModel {
        id: demoChatListItems
        ListElement {
            chatId: "0"
            name: "#status"
            chatType: StatusChatListItem.Type.PublicChat
            muted: false
            unreadMessagesCount: 0
            mentionsCount: 0
            color: "blue"
            position: 0
        }
        ListElement {
            chatId: "1"
            name: "status-desktop"
            chatType: StatusChatListItem.Type.PublicChat
            muted: false
            color: "red"
            unreadMessagesCount: 1
            mentionsCount: 1
            position: 1
        }
        ListElement {
            chatId: "2"
            name: "Amazing Funny Squirrel"
            chatType: StatusChatListItem.Type.OneToOneChat
            muted: false
            color: "green"
            identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0Bh
CExPynn1gWf9bx498P7/nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
            unreadMessagesCount: 0
            position: 2
        }
        ListElement {
            chatId: "3"
            name: "Black Ops"
            chatType: StatusChatListItem.Type.GroupChat
            muted: false
            color: "purple"
            unreadMessagesCount: 0
            position: 3
        }
        ListElement {
            chatId: "4"
            name: "Spectacular Growing Otter"
            chatType: StatusChatListItem.Type.OneToOneChat
            muted: true
            color: "Orange"
            unreadMessagesCount: 0
            position: 4
        }
        ListElement {
            chatId: "5"
            name: "channel-with-a-super-duper-long-name"
            chatType: StatusChatListItem.Type.PublicChat
            muted: false
            color: "green"
            unreadMessagesCount: 0
            position: 5
        }
    }

    property var demoCommunityChatListItems: ListModel {
        id: demoCommunityChatListItems
        ListElement {
            chatId: "0"
            name: "general"
            chatType: StatusChatListItem.Type.CommunityChat
            muted: false
            unreadMessagesCount: 0
            color: "orange"
            position: 0
        }
        ListElement {
            chatId: "1"
            name: "random"
            chatType: StatusChatListItem.Type.CommunityChat
            muted: false
            unreadMessagesCount: 0
            color: "orange"
            categoryId: "public"
            position: 0
        }
        ListElement {
            chatId: "2"
            name: "watercooler"
            chatType: StatusChatListItem.Type.CommunityChat
            muted: false
            unreadMessagesCount: 0
            color: "orange"
            categoryId: "public"
            position: 1
        }
        ListElement {
            chatId: "3"
            name: "language-design"
            chatType: StatusChatListItem.Type.CommunityChat
            muted: false
            unreadMessagesCount: 0
            color: "orange"
            categoryId: "dev"
            position: 0
        }
    }

    property var demoCommunityCategoryItems: ListModel {
        id: demoCommunityCategoryItems
        ListElement {
            categoryId: "public"
            name: "Public"
            position: 0
        }
        ListElement {
            categoryId: "dev"
            name: "Development"
            position: 1
        }
    }

    property var demoProfileGeneralMenuItems: ListModel {
        id: demoProfileGeneralMenuItems

        ListElement {
            title: "My Profile"
            icon: "profile"
        }

        ListElement {
            title: "Contacts"
            icon: "contact"
        }

        ListElement {
            title: "ENS Usernames"
            icon: "username"
        }

    }

    property var demoProfileSettingsMenuItems: ListModel {
        id: demoProfileSettingsMenuItems

        ListElement {
            title: "Privacy & Security"
            icon: "security"
        }

        ListElement {
            title: "Appearance"
            icon: "appearance"
        }

        ListElement {
            title: "Browser"
            icon: "browser"
        }

        ListElement {
            title: "Sounds"
            icon: "sound"
        }

        ListElement {
            title: "Language"
            icon: "language"
        }

        ListElement {
            title: "Notifications"
            icon: "notification"
        }

        ListElement {
            title: "Sync settings"
            icon: "mobile"
        }

        ListElement {
            title: "Advanced"
            icon: "settings"
        }

    }

    property var demoProfileOtherMenuItems: ListModel {
        id: demoProfileOtherMenuItems

        ListElement {
            title: "Need help?"
            icon: "help"
        }

        ListElement {
            title: "About"
            icon: "info"
        }

        ListElement {
            title: "Sign out & Quit"
            icon: "logout"
        }
    }

    //dummy search popup models
    property var searchResultsA: ListModel {
        ListElement { itemId: "i1"; titleId: "t1"; title: "@Flea"; sectionName: "Messages"; time: "18:55 AM"; content: "lorem ipsum <font color='#4360DF'>@Nick</font> dolor sit amet";
            image: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg";
            color: "orange";
            badgeImage: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg";
            badgePrimaryText: "CryptoKities";
            badgeSecondaryText: "";
            badgeIconColor: "";
            badgeIsLetterIdenticon: false }
        ListElement { itemId: "i2"; titleId: "t2"; image: ""; color: "blue"; title: "core"; sectionName: "Channels"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIconColor: ""; badgeIsLetterIdenticon: false }
        ListElement { itemId: "i3"; titleId: "t3"; image: ""; color: "yellow"; title: "communities-phase3"; sectionName: "Channels"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIconColor: ""; badgeIsLetterIdenticon: false }
        ListElement { itemId: "i4"; titleId: "t4"; image: ""; color: "black"; title: "core-ui"; sectionName: "Channels"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIconColor: ""; badgeIsLetterIdenticon: false }
        ListElement { itemId: "i5"; titleId: "t5"; image: ""; color: "green"; title: "desktop"; sectionName: "Channels"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIconColor: ""; badgeIsLetterIdenticon: false }
        ListElement { itemId: "i6"; titleId: "t6"; image: ""; color: "red"; title: "Crocodile Vanilla Bird"; sectionName: "Chat"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIconColor: ""; badgeIsLetterIdenticon: false }
        ListElement { itemId: "i7"; titleId: "t7"; image: ""; color: "purple"; title: "carmen eth"; sectionName: "Chat"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIconColor: ""; badgeIsLetterIdenticon: false }
        ListElement { itemId: "i8"; titleId: "t8"; image: ""; color: "red"; title: "CryptoKitties"; sectionName: "Communities"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIconColor: ""; badgeIsLetterIdenticon: false }
        ListElement { itemId: "i9"; titleId: "t9"; image: ""; color: "blue"; title: "MyCommunity"; sectionName: "Communities"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIconColor: ""; badgeIsLetterIdenticon: false }
        ListElement { itemId: "i10"; titleId: "t10"; image: ""; color: "green"; title: "Foo"; sectionName: "Communities"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIconColor: ""; badgeIsLetterIdenticon: false }
    }
    property var searchResultsB: ListModel {
        ListElement { itemId: "i1"; titleId: "t1"; title: "@Ant"; sectionName: "Messages"; time: "11:43 AM"; content: "<font color='#4360DF'>@John</font>, lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum ";
            image: "";
            color: "orange";
            badgeImage: "";
            badgePrimaryText: "CryptoKities";
            badgeSecondaryText: "#design";
            badgeIconColor: "pink"; badgeIsLetterIdenticon: true }
        ListElement { itemId: "i2"; titleId: "t2"; image: ""; color: "blue"; title: "support"; sectionName: "Channels"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIconColor: ""; badgeIsLetterIdenticon: false }
        ListElement { itemId: "i3"; titleId: "t3"; image: ""; color: "red"; title: "desktop-ui"; sectionName: "Channels"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIconColor: ""; badgeIsLetterIdenticon: false }
        ListElement { itemId: "i4"; titleId: "t4"; image: ""; color: "orange"; title: "climate-change"; sectionName: "Chat"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIconColor: ""; badgeIsLetterIdenticon: false }
        ListElement { itemId: "i5"; titleId: "t5"; image: ""; color: "black"; title: "food"; sectionName: "Chat"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIconColor: "pink"; badgeIsLetterIdenticon: true }
        ListElement { itemId: "i6"; titleId: "t6"; image: ""; color: "green"; title: "CryptoKitties"; sectionName: "Communities"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIconColor: ""; badgeIsLetterIdenticon: false }
        ListElement { itemId: "i7"; titleId: "t7"; image: ""; color: "purple"; title: "CryptoRangers"; sectionName: "Communities"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIconColor: ""; badgeIsLetterIdenticon: false }
        ListElement { itemId: "i8"; titleId: "t8"; image: ""; color: "yellow"; title: "Foo"; sectionName: "Communities"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIconColor: "orange"; badgeIsLetterIdenticon: true }
    }

    property ListModel optionsModel: ListModel {
        ListElement {
            value: "item_1"
            title: "Item with icon"
            imageSource: ""
            iconName: "chat"
            iconColor: ""
            isIdenticon: false
            subItems: [
                ListElement {
                    value: "sub_item_1_1"
                    text: "Profile image item"
                    imageSource: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
                    iconName: ""
                    iconColor: ""
                    isIdenticon: false
                },
                ListElement {
                    value: "sub_item_1_2"
                    text: "identicon item"
                    imageSource: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
                    iconName: ""
                    iconColor: ""
                    isIdenticon: true
                }]}
        ListElement {
            value: "item_2"
            title: "Community item";
            imageSource: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
            iconName: ""
            iconColor: ""
            isIdenticon: false
            subItems: [
                ListElement {
                    value: "sub_item_2_1"
                    text: "welcome"
                    imageSource: ""
                    iconName: "channel"
                    iconColor: ""
                    isIdenticon: false
                },
                ListElement {
                    value: "sub_item_2_2"
                    text: "support"
                    imageSource: ""
                    iconName: "channel"
                    iconColor: ""
                    isIdenticon: false
                },
                ListElement {
                    value: "sub_item_2_3"
                    text: "news"
                    imageSource: ""
                    iconName: "channel"
                    iconColor: ""
                    isIdenticon: false
                }]}
        ListElement {
            value: "item_3"
            title: "Other";
            imageSource: "";
            iconName: "info"
            iconColor: ""
            isIdenticon: false
            subItems: [
                ListElement {
                    value: "sub_item_3_1"
                    text: "news"
                    imageSource: ""
                    iconName: "channel"
                    iconColor: ""
                    isIdenticon: false
                }]}
        ListElement {
            value: "item_4"
            title: "Letter identicon";
            imageSource: "";
            iconName: ""
            iconColor: "red"
            isIdenticon: false
            subItems: [
                ListElement {
                    value: "sub_item_4_1"
                    text: "news"
                    imageSource: ""
                    iconName: "channel"
                    iconColor: ""
                    isIdenticon: false
                }]}
    }

    //    App Section Types:
    //    chat: 0
    //    community: 1
    //    wallet: 2
    //    browser: 3
    //    timeline: 4
    //    nodeManagement: 5
    //    profileSettings: 6
    //    apiDocumentation: 100
    //    demoApp: 101

    property ListModel mainAppSectionsModel: ListModel {
        ListElement {
            sectionId: "mainApp"
            sectionType: 100
            name: "API Documentation"
            active: true
            image: ""
            icon: "edit"
            color: ""
            hasNotification: false
            notificationsCount: 0
        }
        ListElement {
            sectionId: "demoApp"
            sectionType: 101
            name: "Demo Application"
            active: false
            image: ""
            icon: "status"
            color: ""
            hasNotification: false
            notificationsCount: 0
        }
    }

    property ListModel demoAppSectionsModel: ListModel {
        ListElement {
            sectionId: "chat"
            sectionType: 0
            name: "Chat"
            active: true
            image: ""
            icon: "chat"
            color: ""
            hasNotification: false
            notificationsCount: 0
        }
        ListElement {
            sectionId: "0x123456789"
            sectionType: 1
            name: "Status Community"
            active: false
            image: "https://assets.brandfetch.io/51a495de903c46a.png"
            icon: ""
            color: ""
            hasNotification: false
            notificationsCount: 0
        }
        ListElement {
            sectionId: "wallet"
            sectionType: 2
            name: "Wallet"
            active: false
            image: ""
            icon: "wallet"
            color: ""
            hasNotification: false
            notificationsCount: 0
        }
        ListElement {
            sectionId: "browser"
            sectionType: 3
            name: "Browser"
            active: false
            image: ""
            icon: "bigger/browser"
            color: ""
            hasNotification: false
            notificationsCount: 0
        }
        ListElement {
            sectionId: "timeline"
            sectionType: 4
            name: "Timeline"
            active: false
            image: ""
            icon: "bigger/status-update"
            color: ""
            hasNotification: false
            notificationsCount: 0
        }
        ListElement {
            sectionId: "profile"
            sectionType: 6
            name: "Profile"
            active: false
            image: ""
            icon: "bigger/settings"
            color: ""
            hasNotification: true
            notificationsCount: 0
        }
    }
}
