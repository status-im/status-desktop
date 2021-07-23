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
        }
        ListElement {
            chatId: "1"
            name: "status-desktop"
            chatType: StatusChatListItem.Type.PublicChat
            muted: false
            color: "red"
            unreadMessagesCount: 1
            mentionsCount: 1
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
        }
        ListElement {
            chatId: "3"
            name: "Black Ops"
            chatType: StatusChatListItem.Type.GroupChat
            muted: false
            color: "purple"
            unreadMessagesCount: 0
        }
        ListElement {
            chatId: "4"
            name: "Spectacular Growing Otter"
            chatType: StatusChatListItem.Type.OneToOneChat
            muted: true
            color: "Orange"
            unreadMessagesCount: 0
        }
        ListElement {
            chatId: "5"
            name: "channel-with-a-super-duper-long-name"
            chatType: StatusChatListItem.Type.PublicChat
            muted: false
            color: "green"
            unreadMessagesCount: 0
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
        }
        ListElement {
            chatId: "1"
            name: "random"
            chatType: StatusChatListItem.Type.CommunityChat
            muted: false
            unreadMessagesCount: 0
            color: "orange"
            categoryId: "public"
        }
        ListElement {
            chatId: "2"
            name: "watercooler"
            chatType: StatusChatListItem.Type.CommunityChat
            muted: false
            unreadMessagesCount: 0
            color: "orange"
            categoryId: "public"
        }
        ListElement {
            chatId: "3"
            name: "language-design"
            chatType: StatusChatListItem.Type.CommunityChat
            muted: false
            unreadMessagesCount: 0
            color: "orange"
            categoryId: "dev"
        }
    }

    property var demoCommunityCategoryItems: ListModel {
        id: demoCommunityCategoryItems
        ListElement {
            categoryId: "public"
            name: "Public"
        }
        ListElement {
            categoryId: "dev"
            name: "Development"
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
        ListElement { name: "@Flea"; sectionName: "Messages"; time: "18:55 AM"; content: "lorem ipsum <font color='#4360DF'>@Nick</font> dolor sit amet";
            badgeImage: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg";
            badgePrimaryText: "CryptoKities";
            badgeSecondaryText: "";
            badgeIdenticonColor: "";
            isLetterIdenticon: false }
        ListElement { name: "core"; sectionName: "Channels"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIdenticonColor: ""; isLetterIdenticon: false }
        ListElement { name: "communities-phase3"; sectionName: "Channels"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIdenticonColor: ""; isLetterIdenticon: false }
        ListElement { name: "core-ui"; sectionName: "Channels"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIdenticonColor: ""; isLetterIdenticon: false }
        ListElement { name: "desktop"; sectionName: "Channels"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIdenticonColor: ""; isLetterIdenticon: false }
        ListElement { name: "Crocodile Vanilla Bird"; sectionName: "Chat"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIdenticonColor: ""; isLetterIdenticon: false }
        ListElement { name: "carmen eth"; sectionName: "Chat"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIdenticonColor: ""; isLetterIdenticon: false }
        ListElement { name: "CryptoKitties"; sectionName: "Communities"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIdenticonColor: ""; isLetterIdenticon: false }
        ListElement { name: "MyCommunity"; sectionName: "Communities"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIdenticonColor: ""; isLetterIdenticon: false }
        ListElement { name: "Foo"; sectionName: "Communities"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIdenticonColor: ""; isLetterIdenticon: false }
    }
    property var searchResultsB: ListModel {
        ListElement { name: "@Ant"; sectionName: "Messages"; time: "11:43 AM"; content: "<font color='#4360DF'>@John</font>, lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum ";
            badgeImage: "";
            badgePrimaryText: "CryptoKities";
            badgeSecondaryText: "#design";
            badgeIdenticonColor: "pink"; isLetterIdenticon: true }
        ListElement { name: "support"; sectionName: "Channels"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIdenticonColor: ""; isLetterIdenticon: false }
        ListElement { name: "desktop-ui"; sectionName: "Channels"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIdenticonColor: ""; isLetterIdenticon: false }
        ListElement { name: "climate-change"; sectionName: "Chat"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIdenticonColor: ""; isLetterIdenticon: false }
        ListElement { name: "food"; sectionName: "Chat"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIdenticonColor: "pink"; isLetterIdenticon: true }
        ListElement { name: "CryptoKitties"; sectionName: "Communities"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIdenticonColor: ""; isLetterIdenticon: false }
        ListElement { name: "CryptoRangers"; sectionName: "Communities"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIdenticonColor: ""; isLetterIdenticon: false }
        ListElement { name: "Foo"; sectionName: "Communities"; time: ""; content: ""; badgeImage: ""; badgePrimaryText: ""; badgeSecondaryText: ""; badgeIdenticonColor: "orange"; isLetterIdenticon: true }
    }

    property ListModel optionsModel: ListModel {
        ListElement {
            title: "Item with icon";
            imageSource: ""
            iconName: "chat"
            iconColor: ""
            isIdenticon: false
            subItems: [
                ListElement {
                    text: "Profile image item"
                    imageSource: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
                    iconName: ""
                    iconColor: ""
                    isIdenticon: false
                },
                ListElement {
                    text: "identicon item"
                    imageSource: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
                    iconName: ""
                    iconColor: ""
                    isIdenticon: true
                }]}
        ListElement {
            title: "Community item";
            imageSource: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
            iconName: ""
            iconColor: ""
            isIdenticon: false
            subItems: [
                ListElement {
                    text: "welcome"
                    imageSource: ""
                    iconName: "channel"
                    iconColor: ""
                    isIdenticon: false
                },
                ListElement {
                    text: "support"
                    imageSource: ""
                    iconName: "channel"
                    iconColor: ""
                    isIdenticon: false
                },
                ListElement {
                    text: "news"
                    imageSource: ""
                    iconName: "channel"
                    iconColor: ""
                    isIdenticon: false
                }]}
        ListElement {
            title: "Other";
            imageSource: "";
            iconName: "info"
            iconColor: ""
            isIdenticon: false
            subItems: [
                ListElement {
                    text: "news"
                    imageSource: ""
                    iconName: "channel"
                    iconColor: ""
                    isIdenticon: false
                }]}
        ListElement {
            title: "Letter identicon";
            imageSource: "";
            iconName: ""
            iconColor: "red"
            isIdenticon: false
            subItems: [
                ListElement {
                    text: "news"
                    imageSource: ""
                    iconName: "channel"
                    iconColor: ""
                    isIdenticon: false
                }]}
    }
}
