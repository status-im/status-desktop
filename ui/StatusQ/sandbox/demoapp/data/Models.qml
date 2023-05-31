pragma Singleton
import QtQuick 2.14
import StatusQ.Components 0.1

QtObject {

    property var demoChatListItems: ListModel {
        id: demoChatListItems
        ListElement {
            itemId: "x012340000"
            name: "#status"
            icon: ""
            emoji: ""
            isIdenticon: false
            colorHash: []
            color: "blue"
            description: ""
            type: StatusChatListItem.Type.PublicChat
            hasUnreadMessages: true
            notificationsCount: 0
            muted: false
            active: false
            position: 0
            isCategory: false
            hasSubItems: false
            subItems: []
        }
        ListElement {
            itemId: "x012340001"
            name: "status-desktop"
            icon: ""
            emoji: ""
            isIdenticon: false
            colorHash: []
            color: "red"
            description: ""
            type: StatusChatListItem.Type.PublicChat
            hasUnreadMessages: true
            notificationsCount: 1
            muted: false
            active: false
            position: 1
            isCategory: false
            hasSubItems: false
            subItems: []
        }
        ListElement {
            itemId: "x012340002"
            name: "Amazing Funny Squirrel"
            icon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/
                          nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
            emoji: ""
            isIdenticon: true
            colorHash: []
            color: "green"
            description: ""
            type: StatusChatListItem.Type.OneToOneChat
            hasUnreadMessages: false
            notificationsCount: 0
            muted: false
            active: true
            position: 2
            isCategory: false
            hasSubItems: false
            subItems: []
        }
        ListElement {
            itemId: "x012340003"
            name: "Black Ops"
            icon: ""
            emoji: ""
            isIdenticon: false
            colorHash: []
            color: "purple"
            description: ""
            type: StatusChatListItem.Type.OneToOneChat
            hasUnreadMessages: false
            notificationsCount: 0
            muted: false
            active: false
            position: 3
            isCategory: false
            hasSubItems: false
            subItems: []
        }
        ListElement {
            itemId: "x012340004"
            name: "Spectacular Growing Otter"
            icon: ""
            emoji: ""
            isIdenticon: false
            colorHash: []
            color: "orange"
            description: ""
            type: StatusChatListItem.Type.OneToOneChat
            hasUnreadMessages: false
            notificationsCount: 0
            muted: false
            active: false
            position: 4
            isCategory: false
            hasSubItems: false
            subItems: []
        }
        ListElement {
            itemId: "x012340005"
            name: "channel-with-a-super-duper-long-name"
            icon: ""
            emoji: ""
            isIdenticon: false
            colorHash: []
            color: "green"
            description: ""
            type: StatusChatListItem.Type.PublicChat
            hasUnreadMessages: false
            notificationsCount: 0
            muted: false
            active: false
            position: 5
            isCategory: false
            hasSubItems: false
            subItems: []
        }
    }

    property var demoCommunityChatListItems: ListModel {
        id: demoCommunityChatListItems
        ListElement {
            itemId: "x012340000"
            name: "general"
            icon: ""
            isIdenticon: false
            color: "orange"
            description: ""
            type: StatusChatListItem.Type.Unknown0
            hasUnreadMessages: true
            notificationsCount: 0
            muted: false
            active: false
            position: 0
            isCategory: true
            hasSubItems: false
            subItems: []
        }
        ListElement {
            itemId: "x0125340000"
            name: "Pink Channel"
            icon: ""
            isIdenticon: false
            color: "pink"
            description: ""
            type: StatusChatListItem.Type.CommunityChat
            hasUnreadMessages: true
            notificationsCount: 0
            muted: false
            active: false
            position: 0
            isCategory: false
            hasSubItems: false
            subItems: []
        }
        ListElement {
            itemId: "x012340001"
            name: "Public"
            icon: ""
            isIdenticon: false
            color: "orange"
            description: ""
            type: StatusChatListItem.Type.Unknown0
            hasUnreadMessages: false
            notificationsCount: 0
            muted: false
            active: true
            position: 1
            isCategory: true
            hasSubItems: true
            subItems: [
                ListElement {
                    itemId: "x012340002"
                    parentItemId: "x012340001"
                    name: "random"
                    icon: ""
                    isIdenticon: false
                    color: "orange"
                    description: ""
                    hasUnreadMessages: true
                    notificationsCount: 4
                    muted: false
                    active: false
                    position: 0
                },
                ListElement {
                    itemId: "x012340003"
                    parentItemId: "x012340001"
                    name: "watercooler"
                    icon: ""
                    isIdenticon: false
                    color: "orange"
                    description: ""
                    hasUnreadMessages: false
                    notificationsCount: 0
                    muted: false
                    active: true
                    position: 1
                }
            ]
        }
        ListElement {
            itemId: "x012340004"
            name: "Development"
            icon: ""
            isIdenticon: false
            color: "orange"
            description: ""
            type: StatusChatListItem.Type.Unknown0
            hasUnreadMessages: false
            notificationsCount: 0
            muted: false
            active: false
            position: 2
            isCategory: true
            hasSubItems: true
            subItems: [
                ListElement {
                    itemId: "x012340005"
                    parentItemId: "x012340004"
                    name: "language-design"
                    icon: ""
                    isIdenticon: false
                    color: "orange"
                    description: ""
                    hasUnreadMessages: false
                    notificationsCount: 0
                    muted: true
                    active: false
                    position: 0
                }
            ]
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
            image: "qrc:/demoapp/data/profile-image-1.jpeg";
            color: "orange";
            badgeImage: "qrc:/demoapp/data/profile-image-1.jpeg";
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
            hasSubItems: true
            subItems: [
                ListElement {
                    value: "sub_item_1_1"
                    text: "Profile image item"
                    imageSource: "qrc:/demoapp/data/profile-image-1.jpeg"
                    iconName: ""
                    iconColor: ""
                },
                ListElement {
                    value: "sub_item_1_2"
                    text: "identicon item"
                    imageSource: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/
                                  nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
                    iconName: ""
                    iconColor: ""
                }]}
        ListElement {
            value: "item_1"
            title: "No submenu"
            imageSource: ""
            iconName: "airdrop"
            isIdenticon: false
            hasSubItems: false
            subItems: []
        }
        ListElement {
            value: "item_2"
            title: "Community item";
            imageSource: "qrc:/demoapp/data/profile-image-1.jpeg"
            iconName: ""
            iconColor: ""
            isIdenticon: false
            hasSubItems: true
            subItems: [
                ListElement {
                    value: "sub_item_2_1"
                    text: "welcome"
                    imageSource: ""
                    iconName: "channel"
                    iconColor: ""
                },
                ListElement {
                    value: "sub_item_2_2"
                    text: "support"
                    imageSource: ""
                    iconName: "channel"
                    iconColor: ""
                },
                ListElement {
                    value: "sub_item_2_3"
                    text: "news"
                    imageSource: ""
                    iconName: "channel"
                    iconColor: ""
                }]}
        ListElement {
            value: "item_3"
            title: "Other";
            imageSource: "";
            iconName: "info"
            iconColor: ""
            isIdenticon: false
            hasSubItems: true
            subItems: [
                ListElement {
                    value: "sub_item_3_1"
                    text: "news"
                    imageSource: ""
                    iconName: "channel"
                    iconColor: ""
                }]}
        ListElement {
            value: "item_4"
            title: "Letter identicon";
            imageSource: "";
            iconName: ""
            iconColor: "red"
            isIdenticon: false
            hasSubItems: true
            subItems: [
                ListElement {
                    value: "sub_item_4_1"
                    text: "news"
                    imageSource: ""
                    iconName: "channel"
                    iconColor: ""
                }]}
    }

    property var chatMessagesModel: ListModel {
        id: messageData
        ListElement {
            timestamp: "1656937930"
            amIsender: false
            senderId: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04"
            senderDisplayName: "Ferocious Herringbone Sinewave"
            senderOptionalName: ""
            profileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/
                          nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
            contentType: StatusMessage.ContentType.Text
            message: '<p>Long message<br>Adapted from &quot;The Colors of Animals&quot; by Sir John Lubbock in A Book of Natural History (1902, ed. David Starr Jordan)</p><p>The color of animals is by no means a matter of chance; it depends on many considerations, but in the majority of cases tends to protect the animal from danger by rendering it less conspicuous. Perhaps it may be said that if coloring is mainly protective, there ought to be but few brightly colored animals. There are, however, not a few cases in which vivid colors are themselves protective. The kingfisher itself, though so brightly colored, is by no means easy to see. The blue harmonizes with the water, and the bird as it darts along the stream looks almost like a flash of sunlight.</p><p>Desert animals are generally the color of the desert. Thus, for instance, the lion, the antelope, and the wild donkey are all sand-colored. “Indeed,” says Canon Tristram, “in the desert, where neither trees, brushwood, nor even undulation of the surface afford the slightest protection to its foes, a modification of color assimilated to that of the surrounding country is absolutely necessary. Hence, without exception, the upper plumage of every bird, and also the fur of all the smaller mammals and the skin of all the snakes and lizards, is of one uniform sand color.”</p><p>The next point is the color of the mature caterpillars, some of which are brown. This probably makes the caterpillar even more conspicuous among the green leaves than would otherwise be the case. Let us see, then, whether the habits of the insect will throw any light upon the riddle. What would you do if you were a big caterpillar? Why, like most other defenseless creatures, you would feed by night, and lie concealed by day. So do these caterpillars. When the morning light comes, they creep down the stem of the food plant, and lie concealed among the thick herbage and dry sticks and leaves, near the ground, and it is obvious that under such circumstances the brown color really becomes a protection. It might indeed be argued that the caterpillars, having become brown, concealed themselves on the ground, and that we were reversing the state of things. But this is not so, because, while we may say as a general rule that large caterpillars feed by night and lie concealed by day, it is by no means always the case that they are brown; some of them still retaining the green color. We may then conclude that the habit of concealing themselves by day came first, and that the brown color is a later adaptation.</p><p>The example of the mature caterpillar in the third paragraph is primarily intended to demonstrate _____________.</p>'
            messageContent: ""
            isContact: true
            trustIndicator: StatusContactVerificationIcons.TrustedType.None
            hasMention: false
            editMode: false
            isReply: false
            replySenderId: ""
            replySenderName: ""
            replyProfileImage: ""
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Text
            replyMessageContent: ""
            isPinned: false
            pinnedBy: ""
            hasExpired: false
        }
        ListElement {
            timestamp: "1657937930"
            amIsender: false
            senderId: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04"
            senderDisplayName: "Teenage Mutant Turtle"
            senderOptionalName: ""
            profileImage: ""
            contentType: StatusMessage.ContentType.Text
            message: 'Simple text message'
            messageContent: ""
            isContact: false
            trustIndicator: StatusContactVerificationIcons.TrustedType.None
            hasMention: false
            editMode: false
            isReply: false
            replySenderId: ""
            replySenderName: ""
            replyProfileImage: ""
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Text
            replyMessageContent: ""
            isPinned: false
            pinnedBy: ""
            hasExpired: false
        }
        ListElement {
            timestamp: "1657937930"
            amIsender: false
            senderId: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04"
            senderDisplayName: "Bro from work"
            senderOptionalName: "Teenage Mutant Turtle"
            profileImage: ""
            contentType: StatusMessage.ContentType.Text
            message: '<code>Renamed, contact</code>'
            messageContent: ""
            isContact: true
            trustIndicator: StatusContactVerificationIcons.TrustedType.None
            hasMention: false
            editMode: false
            isReply: false
            replySenderId: ""
            replySenderName: ""
            replyProfileImage: ""
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Text
            replyMessageContent: ""
            isPinned: false
            pinnedBy: ""
            hasExpired: false
        }
        ListElement {
            timestamp: "1657937930"
            amIsender: false
            senderId: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04"
            senderOptionalName: "@turtle.statusofus.eth"
            senderDisplayName: "Bro from work"
            profileImage: ""
            contentType: StatusMessage.ContentType.Text
            message: '<code>ENS, Renamed, Contact, Untrustworthy</code>'
            messageContent: ""
            isContact: true
            trustIndicator: StatusContactVerificationIcons.TrustedType.Untrustworthy
            hasMention: false
            editMode: false
            isReply: false
            replySenderId: ""
            replySenderName: ""
            replyProfileImage: ""
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Text
            replyMessageContent: ""
            isPinned: false
            pinnedBy: ""
            hasExpired: false
        }
        ListElement {
            timestamp: "1658937930"
            senderId: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04"
            amIsender: false
            senderOptionalName: "@turtle.statusofus.eth"
            senderDisplayName: "Bro from work"
            profileImage: ""
            message: '<code>ENS, renamed, contact, verified</code>'
            contentType: StatusMessage.ContentType.Text
            messageContent: ""
            isContact: true
            trustIndicator: StatusContactVerificationIcons.TrustedType.Verified
            hasMention: false
            editMode: false
            isReply: false
            replySenderId: ""
            replySenderName: ""
            replyProfileImage: ""
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Text
            replyMessageContent: ""
            isPinned: false
            pinnedBy: ""
            hasExpired: false
        }
        ListElement {
            timestamp: "1658937930"
            senderId: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04"
            amIsender: false
            senderOptionalName: "Teenage Mutant Turtle"
            senderDisplayName: "Bro from work"
            profileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDKExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg="
            message: 'With profile image, no ENS'
            contentType: StatusMessage.ContentType.Text
            messageContent: ""
            isContact: true
            trustIndicator: StatusContactVerificationIcons.TrustedType.Verified
            hasMention: false
            editMode: false
            isReply: false
            replySenderId: ""
            replySenderName: ""
            replyProfileImage: ""
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Text
            replyMessageContent: ""
            isPinned: false
            pinnedBy: ""
            hasExpired: false
        }
        ListElement {
            timestamp: "1658937930"
            senderId: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04"
            amIsender: false
            senderOptionalName: "@turtle.statusofus.eth"
            senderDisplayName: "Bro from work"
            profileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDKExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg="
            message: 'With profile image and ENS'
            contentType: StatusMessage.ContentType.Text
            messageContent: ""
            isContact: true
            trustIndicator: StatusContactVerificationIcons.TrustedType.Verified
            hasMention: false
            editMode: false
            isReply: false
            replySenderId: ""
            replySenderName: ""
            replyProfileImage: ""
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Text
            replyMessageContent: ""
            isPinned: false
            pinnedBy: ""
            hasExpired: false
        }
        ListElement {
            timestamp: "1658937930"
            senderId: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04"
            amIsender: true
            senderDisplayName: "You"
            senderOptionalName: "@ghd.statusofus.eth"
            profileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDKExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg="
            message: 'Message with image'
            contentType: StatusMessage.ContentType.Image
            messageContent: "https://placekitten.com/400/400"
            isContact: false
            trustIndicator: StatusContactVerificationIcons.TrustedType.None
            hasMention: false
            editMode: false
            isReply: false
            replySenderId: ""
            replySenderName: ""
            replyProfileImage: ""
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Text
            replyMessageContent: ""
            isPinned: false
            pinnedBy: ""
            hasExpired: false
        }
        ListElement {
            timestamp: "1658937930"
            senderId: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04"
            amIsender: true
            senderDisplayName: "You"
            senderOptionalName: "@ghd.statusofus.eth"
            profileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDKExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg="
            message: '👍'
            contentType: StatusMessage.ContentType.Emoji
            messageContent: "👍"
            isContact: false
            trustIndicator: StatusContactVerificationIcons.TrustedType.None
            hasMention: false
            editMode: false
            isReply: false
            replySenderId: ""
            replySenderName: ""
            replyProfileImage: ""
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Text
            replyMessageContent: ""
            isPinned: false
            pinnedBy: ""
            hasExpired: false
        }
        ListElement {
            timestamp: "1658937930"
            senderId: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04"
            amIsender: true
            senderDisplayName: "You"
            senderOptionalName: "@ghd.statusofus.eth"
            profileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDKExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg="
            message: 'Message with sticker'
            contentType: StatusMessage.ContentType.Sticker
            messageContent: "https://ipfs.infura.io/ipfs/QmW4rVW3BXYHiDHzD6cDwVZtuvEa6aPyb1bbEnitEA6Hhg"
            isContact: false
            trustIndicator: StatusContactVerificationIcons.TrustedType.None
            hasMention: false
            editMode: false
            isReply: false
            replySenderId: ""
            replySenderName: ""
            replyProfileImage: ""
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Text
            replyMessageContent: ""
            isPinned: false
            pinnedBy: ""
            hasExpired: false
        }
        ListElement {
            timestamp: "1660937930"
            senderId: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04"
            amIsender: true
            senderDisplayName: "You"
            senderOptionalName: "@ghd.statusofus.eth"
            message: ""
            isCurrentUser: true
            contentType: StatusMessage.ContentType.Audio
            messageContent: "/home/khushboo/Music/SymphonyNo6.mp3"
            repeatMessageInfo: true
            profileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDKExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg=="
            isContact: true
            trustIndicator: StatusContactVerificationIcons.TrustedType.None
            hasMention: false
            editMode: false
            isReply: false
            replySenderId: ""
            replySenderName: ""
            replyProfileImage: ""
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Text
            replyMessageContent: ""
            isPinned: false
            pinnedBy: ""
            hasExpired: false
        }
        ListElement {
            timestamp: "1660937930"
            senderId: "0x04d1bed19c523299cbd07ddec7b8949ad7dd923819a68e0b733c9c0bc38cde276bd256f098e755f8f028395c2c91f438a22adaff6caded060b7cc0ef3f470f1234"
            amIsender: true
            senderDisplayName: "You"
            senderOptionalName: "@ghd.statusofus.eth"
            message: "Hi Johnny"
            isCurrentUser: true
            contentType: StatusMessage.ContentType.Text
            messageContent: ""
            repeatMessageInfo: true
            profileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDKExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg=="
            isContact: true
            trustIndicator: StatusContactVerificationIcons.TrustedType.None
            hasMention: false
            editMode: false
            isReply: false
            replySenderId: ""
            replySenderName: ""
            replyProfileImage: ""
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Text
            replyMessageContent: ""
            isPinned: false
            pinnedBy: ""
            hasExpired: true
        }
        ListElement {
            timestamp: "1660937930"
            senderId: "0x04d1bed19c523299cbd07ddec7b8949ad7dd923819a68e0b733c9c0bc38cde276bd256f098e755f8f028395c2c91f438a22adaff6caded060b7cc0ef3f470f1234"
            amIsender: false
            senderDisplayName: "Pompie"
            senderOptionalName: "@ghd.statusofus.eth"
            message: '<p>Do you have a Bitcoin wallet or Coinbase wallet?<br />You can earn up to 0.06021BTC every 3 hours with your phone or PC...<br />Without referrals nor registration fee...<br />If you are interested ask me “HOW”<br /><a href="https://t.me/Markstones455">https://t.me/Markstones455</a></p>'
            isCurrentUser: true
            contentType: StatusMessage.ContentType.Text
            messageContent: ""
            repeatMessageInfo: true
            profileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDKExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg=="
            isContact: false
            trustIndicator: StatusContactVerificationIcons.TrustedType.Untrustworthy
            hasMention: false
            editMode: false
            isReply: false
            replySenderId: ""
            replySenderName: ""
            replyProfileImage: ""
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Text
            replyMessageContent: ""
            isPinned: true
            pinnedBy: "Teenage Mutant Turtle"
            hasExpired: false
        }
        ListElement {
            timestamp: "1660937930"
            senderId: "0x04d1bed19c523299cbd07ddec7b8949ad7dd923819a68e0b733c9c0bc38cde276bd256f098e755f8f028395c2c91f438a22adaff6caded060b7cc0ef3f470f1234"
            amIsender: false
            senderDisplayName: "Pompie"
            senderOptionalName: "@ghd.statusofus.eth"
            message: '<p><a href="//0x0431859bd00be79baef9617f4719ce73d2d261a2496f9a861f447a2f8ba34bf7ba03e572bb39fcf2df43564d39f6364bfe9be0a1fca3bf741e8f4b9492f86db427" class="mention">Uniform Dark Pike</a></p>'
            isCurrentUser: true
            contentType: StatusMessage.ContentType.Text
            messageContent: ""
            repeatMessageInfo: true
            profileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDKExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg=="
            isContact: false
            trustIndicator: StatusContactVerificationIcons.TrustedType.Untrustworthy
            hasMention: true
            editMode: false
            isReply: false
            replySenderId: ""
            replySenderName: ""
            replyProfileImage: ""
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Text
            replyMessageContent: ""
            isPinned: false
            pinnedBy: ""
            hasExpired: false
        }
        ListElement {
            timestamp: "1660937930"
            senderId: "0x04d1bed19c523299cbd07ddec7b8949ad7dd923819a68e0b733c9c0bc38cde276bd256f098e755f8f028395c2c91f438a22adaff6caded060b7cc0ef3f470f1234"
            amIsender: false
            senderDisplayName: "Pompie"
            senderOptionalName: "@ghd.statusofus.eth"
            message: "Replying to text message"
            isCurrentUser: true
            contentType: StatusMessage.ContentType.Text
            messageContent: ""
            repeatMessageInfo: true
            profileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDKExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg=="
            isContact: false
            trustIndicator: StatusContactVerificationIcons.TrustedType.Untrustworthy
            hasMention: false
            editMode: false
            isReply: true
            replySenderId: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486dsfkjghyu2cf04"
            replySenderName: "You"
            replySenderEnsName: ""
            replyProfileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDKExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg=="
            replyMessageText: "Hi Johnny"
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Text
            replyMessageContent: ""
            isPinned: false
            pinnedBy: ""
            hasExpired: false
        }
        ListElement {
            timestamp: "1660937930"
            senderId: "0x04d1bed19c523299cbd07ddec7b8949ad7dd923819a68e0b733c9c0bc38cde276bd256f098e755f8f028395c2c91f438a22adaff6caded060b7cc0ef3f470f1234"
            amIsender: false
            senderDisplayName: "Pompie"
            senderOptionalName: "@ghd.statusofus.eth"
            message: "Replying to a Image Message"
            isCurrentUser: true
            contentType: StatusMessage.ContentType.Text
            messageContent: ""
            repeatMessageInfo: true
            profileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDKExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg=="
            isContact: false
            trustIndicator: StatusContactVerificationIcons.TrustedType.Untrustworthy
            hasMention: false
            editMode: false
            isReply: true
            replySenderId: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486dsfkjghyu2cf04"
            replySenderName: "You"
            replySenderEnsName: ""
            replyProfileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDKExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg=="
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Image
            replyMessageContent: "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/4gIoSUNDX1BST0ZJTEUAAQEAAAIYAAAAAAIQAABtbnRyUkdCIFhZWiAAAAAAAAAAAAAAAABhY3NwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAA9tYAAQAAAADTLQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlkZXNjAAAA8AAAAHRyWFlaAAABZAAAABRnWFlaAAABeAAAABRiWFlaAAABjAAAABRyVFJDAAABoAAAAChnVFJDAAABoAAAAChiVFJDAAABoAAAACh3dHB0AAAByAAAABRjcHJ0AAAB3AAAADxtbHVjAAAAAAAAAAEAAAAMZW5VUwAAAFgAAAAcAHMAUgBHAEIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFhZWiAAAAAAAABvogAAOPUAAAOQWFlaIAAAAAAAAGKZAAC3hQAAGNpYWVogAAAAAAAAJKAAAA+EAAC2z3BhcmEAAAAAAAQAAAACZmYAAPKnAAANWQAAE9AAAApbAAAAAAAAAABYWVogAAAAAAAA9tYAAQAAAADTLW1sdWMAAAAAAAAAAQAAAAxlblVTAAAAIAAAABwARwBvAG8AZwBsAGUAIABJAG4AYwAuACAAMgAwADEANv/bAEMADQkKCwoIDQsKCw4ODQ8TIBUTEhITJxweFyAuKTEwLiktLDM6Sj4zNkY3LC1AV0FGTE5SU1IyPlphWlBgSlFST//bAEMBDg4OExETJhUVJk81LTVPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT//AABEIAw4DsgMBIgACEQEDEQH/xAAbAAACAwEBAQAAAAAAAAAAAAAAAQIDBAUGB//EAEQQAAICAQMCBQIDBwMDAgUCBwECAAMRBBIhMUEFEyJRYTJxFFWTBhYjQoGRoRVSsTNiwSRyNDVT0eFDkvDxVKIlRIL/xAAYAQEBAQEBAAAAAAAAAAAAAAAAAQIDBP/EACIRAQEBAAMAAwEAAwEBAAAAAAABEQIhMQMSQVEiMmEEcf/aAAwDAQACEQMRAD8A9V+73gn5Vo/0hD93vBPyrR/pCdOE8211xy/3e8E/KtH+kI/3e8E/KtH+kJ0o42mRy/3e8E/KtJ+kIfu94J+VaT9ITpwjamOZ+73gn5Vo/wBIQ/d7wT8q0f6QnThJtMcz93vBPyrSfpCH7v8Agn5VpP0xOnDEbVyOX+73gn5XpP0hH+7/AIJ+VaT9ITpQHSNpkc393/BPyrSfpCL93/BPyrSfpCdOEm1cjmfu/wCCflWk/SEP3f8ABPyrSfpCdLEI2mRzf3f8E/KtJ+kIfu/4L+VaT9ITpQjaZHN/d/wX8q0f6Qi/d/wX8q0n6QnThG0yOZ+7/gv5XpP0hD93/BPyvSfpCdKEbTI5v7v+C/lek/SEP3f8F/KtJ+kJ0o42mRzP3f8ABfyvR/pCH7v+C/lej/SE6cUn2pkcz93/AAX8r0n6Qj/d/wAE/K9J+kJ0ocRt/p05v7v+C/lek/SEP3f8E/K9J+kJ0oS7TI5n7v8Agv5XpP0hD/QPBfyrSfpCdOEbTI5n+geC/lWk/TEP9A8F/KtJ+mJ0sQjadOb+7/gv5XpP0hD93/BfyvSfpCdKEm06c393/BfyvSfpCH7v+C/lek/SE6UI2/1cjm/6B4L+VaT9IQ/d/wAF/K9J+kJ04o2/0yOaP2f8F/K9J+kIfu/4L+V6T9ITpwjb/TI5n+geC/lWk/TEP3f8F/K9J+kJ0oRt/pkc3/QPBfyrSfpiH7v+C/lek/SE6UI2/wBMjm/u/wCC/lek/SEP3f8ABfyvSfpCdKEbf6ZHM/0DwX8r0n6Qh/oHgv5XpP0hOniEbf6ZHN/d/wAF/K9J+kIfu/4L+V6T9ITpQjb/AEyOb+7/AIL+V6T9IQ/d/wAF/K9J+kJ0oRtMjm/u/wCC/lek/SEP3f8ABfyvSfpCdKEbf6ZHN/d/wX8r0n6Qh+7/AIL+V6T9ITpQjb/TI5v7v+C/lek/SEP3f8F/K9J+kJ0oRtMjm/u/4L+V6T9IQ/d/wX8r0n6QnShG3+mRzf3f8F/K9J+kIv8AQPBfyvSfpCdMwjb/AEyOZ+7/AIL+V6T9IR/u/wCC/lek/SE6UI2/0yOb+7/gv5XpP0hD93/BfyvSfpCdKGY2/wBMjmfu/wCC/lek/SEf7v8Agv5XpP0hOjH/AMR9qZHN/d/wX8r0n6Qh+7/gv5XpP0hOlD3zG1Mjm/u/4L+V6T9IQ/d/wX8q0n6QnSjjauRzP3f8F/K9J+kIfu/4L+V6T9ITpQj7UyOb+7/gv5XpP0hD93/BfyvSfpCdIQjaZHN/0DwX8q0n6Yh/oHgv5VpP0xOlCNqdOb+7/gv5XpP0hD93/BfyvSfpidKEbTpzf9A8F/KtJ+mIfu/4L+V6T9ITpwjb/TI5v7v+CflWk/SEX+geC/lWk/TE6cUu0yOd+7/gv5XpP0hD93/BfyvSfpidKOTb/TpzP3f8E/K9J+kIfu/4L+V6P9ITpQjb/Tpzf3f8F/K9J+kIfu/4L+V6T9ITpxRt/p05v7v+C/lWj/SEP3f8F/K9J+kJ0odpdpkc393/AAX8r0n6Qh+7/gv5XpP0hOlHG0xzP3f8F/KtJ+kIfu/4J+V6T9ITpxRtMjm/u/4L+V6T9IQ/d/wX8r0n6QnShG0yOb+7/gv5VpP0hD93/BfyrSfpCdKEbTI5v7v+CflWj/SEP3f8E/KtJ+kJ0o42mRzP3e8E/KtJ+kIfu/4L+V6T9ITpwjaZHM/d/wAF/K9J+kI/3f8ABPyrSfpCdKEbTI5v7v8Agn5VpP0hH+7/AIJ+VaT9ITo4jjaZHN/d7wT8q0f6Qh+73gn5Vo/0hOl/WGJdqZHN/d7wT8q0f6Qh+73gn5Vo/wBITpwjaZHM/d7wT8q0n6Qh+73gn5VpP0hOnCNpkc393vBPyrR/pCH7veCflWj/AEhOnDvG0yOb+73gn5Vo/wBIQnTzCNpkIwhCFEIQgKHfErvvq06b7Wx7D3nKv8VubikBF7HvEiO1j2iOR1Bnm21Woc5a5z/XEE1WoTlbnH9cy4mvSQnGo8WtU4vUWD3HBnVourvTfUwI7/ElirIo4YkqiEIQFFCEAhCOAoQxCAu8cMQgKOEUgIQjxFCEI4pFEI4oQQhCARRwhShCEAhHCACEUcAijigEI4oBCEIBCEIBCEIAIQhAIQjgKEIQCEIQCEIQCOKOAoQhAIYhCAQhCAf06iZbtZWLfJrO6wD1Y7S3V2+Tp7HHUKcTheGoyeZa5y1h5YzHK9t8OOx3qSzVgseTJWOK62c/yjMhp2ygA9hOf4tr1Si2mkhrFBz/ANstvROPbborbbqzbZjk8CaPacT9n9Zv0CizO7PE6upvFVBYfUeB95JdiWZUvMBsKKclRHvBXd7dZRpa/JTLnc78sfeZLtalb2AAsWbCqO5j7H1dUEEZEJVp9wpUP9WOZb1m5UsEIQhBHCLtAcIQlQQhCQEcQjhShAwgOKOKAQ7Q5mXWa2vTDbw1h6LnpLiNLMFGWIAHXJmS3xLTVnAJc/8AaJyL9Tde2bHJHYdAJVNTiOq3jA/lpJ+7QXxgZ9VJH2acqEYmu5X4npnOGJQ/9wmtWVhlSCPcGeXltOotobNTke46g/0ixXpITJo9dXqRtOFsHUe81zIO8cUcoIQhAISF1qUoXsYAD/M42q8QtuJVCa6/YdTEmmurfrdPTw9gz7DmZX8YrBwlTH7nE48c1kTXV/1g96P/AO6W1+L0E4sRk+es4kcYa9NVfVcM1OG/rLJ5ZWZG3KSp7Edp09H4ocivUkcnh+n94sNdaEQIIyDkEZzHMqcUICUShCEAiMcUAlWpvTT1Gx+3Qe5ls4ni95e/ygfSg/zERkvvsvsL2HJPQdhKoTr6bw/Tavw8Gh/445JPY+32m5NZtciElZW9VhSxSrKeQY6q3tsWutSzN0Ak7EJZp7309oes9Oo9xOlq/DtPpPD91tmLzyCOcn2+05MthK9Np7kvqWxOh6j2MsnG8HvK3NST6X5HwZ2ZitDEUcDIqMI8QxAUcDFAIQhAIQhAIQhAIQxCSghgQhIowIQhAIozFAIQhAUcIQCEIQCEIQCKOEAixHCAoRxQHFHFAIQhAI4o4BCEIChHCAoQMIBCEIDhCEBQhCAQhCAQhAyjneOFvwQVersAftMNDqi+W/AzgfE6uvq86g15weqn5nn9e5f0Niu1RyPecr67cZ07Wl1KqWUkdODPNa+y46ixU5W8+oDqMSpNZZVlbjznjmT/ABVJvVwRuHSFzHc8D8utGQgBgeQe81eJ7kqVk6q2cTjX6n8EwewEBhkNKbvGRYApbdnrLIzZ261niDFRgBQR1mTTWLVqW1OVc4wq9ZjOdQofdhAOB8zV4UtR1IWzqvQRYuO3ptUupO5PoVfVmWU6l7Cf4R8sHG6cvVaupdYKKCFBPrxN76hK6glDKcfUc9IlZvFs3DGY1IYZU8TmX+KaWtWVTl8dczVo7N+mDZ6jMusXi1QkEbcoJ7yQIIyOZpDhCEqCEIdpFEcUIBHCEAxFHmIkAZPbrAza7VDTU5GN7fSJwWZnYsxySeT7yzV3nUahnPTOF+BKpuIIQhKgAJIAGSenzAgqSCCCDgg9p3/CvDkoVNReQbW+gZ6Z/wDMl4r4empDXUEC5R6h7/f2M39LjP27eehFCYaNWKsGUkEdDO9oNWNTVhseYvX5+Z5+XaW5qL1sHbr8iLB6QRyKsGUEHIIyJKZUSNjrWhdzhVHMlOX4vfyNOp4xloiMWr1T6mzceFH0r7TPCE0ghN3h3h51pclyla8E4zzN/wDodH/9Q39hNzjU1w4p3f8AQ6P/AOob+wh/oVJ4GofJ6cCPrTXDil2q07abUNS5BKnr7iVTKuj4ZrSjCi0+k/ST2nZnlZ6Hw/UefplJPqX0mSq0wEISKlCKEgcUZhKFPMXsXvsY92P/ADPTzzFylLnU9mliVCW6bU26W0W1HnuD0MqkqqnusWupSzMeAJqeo7ttVHi+mFtJC3KP/wCAY6qtP4RpjZYQ1zDHyfgfEEXT+EaQux3Wt1/7j/4EV1VPi+lFlR22oOBnp8Tow4uq1NmquNlp57AdAJTJWVvVY1dilWU8gyM531tbpWKaqph2cf8AM9LPM6Zd2qqA/wB4/wCZ6aZqwRRwkURRxDpICEcICxFiSiMgUIQlBF3jMBAICEJAQhCQEIQhRFCEIIQhKCEIQCEISKIQhAIQhAIQhAIQhAIo4QEIRxQCOEIBCEIBCEIBFHFAIQEcAhCEBQjhAIoRM6oMuQBFocO3MqTU02ZCWDgcyp9bSvJLY/3YjYuVZbUrLgsfieW8XIS0+b9gZ6k31tV5gYFSMgieN/aHUb9Q+CDXjrMfrfDXKvqtsctWwKj5mNrLkuC7DkdJWLwCQ5IBPYy3e1N9dtTeYoOSGnSTovLtLU+K3akrU7elBjBltL0vSVJKuOnMqHlW63FiBVc9fmLW1nTajySu3PIb3lkTbru6XUrXQBkdOZbpbCQbkyLAePmea89q7MBsg9/adB9StFO2uw8jk56mSxZT1WqtGpcoCMnMuq8QvcbKxuLDke85C6ix33AnI6fM1ac6hctQMN3PtJ9V12KNHqHK3XkbQc7fed2nxCsKK2G3A6LPMjVaiqsBrssf90u0FiO7WW2n5mPqvr1LeJ0pVioEtjgSOk8TrC7LAUIyST3JnI/EUr66rA+OmZbpfEKGBXUqGbqOJLsPrHo6rFsr3o2QZOYdFrtNb/CqXZjoMTf9xNyuXKZSjhCVBCEIDhFCA5l8Rs8vRuQeW9P95qnO8aOKKx7tLEcaOEJpBOhV4Nq7K1f+Gm4dGJBnPHWd7x662nyPKsevO7O0kZ6e03xkztLayaRL6PFqNLc+7yjwATgZElr1ut8Ws01Nm3zQARkgHiZ/DHezxSp7GLMTySeZPxdmTxR2RirADBB5HEu9J+pWeC6tELA1vgdFJyf8Tmzu+A3XXWXC217MAY3EnGczh2fW3/uMlkzpZahHFCQd/wAMsNmjTPVSV/tNk5ngp/hWj2YTpzFaE83qLDbqLHPdp6G47abD7Kf+J5mWJRCEJpHe8B/+Bv8A/d/4nCyfc/3nd8B/+Cv/APd/4nCmr5Egyfc/3m3wfJ8Rqyc9ev2mGbvB/wD5jV/X/iJbpUvG/wD5i3/tEwTf43/8xb/2j/ic+S+k8E6Pg1m3UNXnh1z/AGnPmjw8411Py2JL4seihCEy0cIQhDMIGEKU4fi1Jr1PmAcWc/1ndlGq066mk1tx3B9jLKjzc7Wiv0ei0Hnqwe1uCOhz7fAnItqemw12DDCVzcuM2LdTqLNTcbbTknp8fEel1NmluFtR6dR2IlMI3vR2vELdFrNCNRuC2jgDvn2nFh8yymp77BXWMsf8CS3SNfhFBfUG0jiscfeduVaahdPSta9up95bMVoQhCFEQjiEgcIQgEUcWYChCEAMBCEAhCEAhCEgIQhIpQjzFCCEId4BCEJQQhCAQhCRRCEIBCEIBFHCAQhCARRwgKOKOAQhCAQhCAQhCAhHCEAhCEBEhQSTwJkfxCqt8WK6KejEHBmo/P8A/OU3NSU2Wuu3vnkTNa4xPzVI3KwIPTHeUuuSHtTcPac+63SaJS1OpA/7SZydT43qbH2VOpHvmSdrJjq+IX6eqxL6wF28MucZm2vWaW+kBSvI5ngrbL9TqSjsTnuDLgNRTQVrsJz0JMs4Vp27/Ea9JZZSSDW3BAPeea1lvmu4ydhP9pjv8/czOxZs5yYrtaV06F1GW6jE3PjScmiunTfhrS43WsMJzMvlKv8A1Ldr44xzIK66hSTZgjoo7y9gaFxYo4HA95udM6xv5vmGvO7HQzb5j2JWNVl9g4OOkKzn1rWAe01aS1Fb/wBQ6pmLSRlt06MA9Sk/EglLMDZcSK1GT8zrWX6bpWS3/dOdqbQ7bVyVPXEmrjTpdT4aKCXGCBxBdSzLt0ykZPGR0nOaqtLE27Tg8zu6e9QiBUU5HOJrElcrWnUuVPO7u00aa7U0aZ2urD19JLXXEX4Ayf8AaJXdfqLafK2ge3xJho0toYsA39Pma1f1D18jqDOBTu0+oxbuGTyZ3xSNVp1dLUJXpjtM8p03xruaDU+YyU2uKgfpbH/mel07Ns2O29l/m9xPHaHUChPIuVXBPtPTeFkKhBsVmbnaD9PxOM6q8/HRhF8xzq4iEISAjihAc53jK5orb2adAdJn19Xm6SxR1AyPuJZ6jz8IoTaGOs7X7Rf/AOv/AP8AX/icX2nc8frss/D7EZsbs7RnHT2m54zfXK0NyafWV22Z2qecSXiOoTVaxrawdpAxkSr8Pf8A/Rs//aYfh7//AKNn/wC0zPeYvWur+zn/AFb/ALL/AOZx7Prb/wBxna/Z+uyuy/ejLkLjIxnrOK/1t9zNXxJ6hHFHMNOx4IuKrW92x/adKZfDa/K0aA9W9RmmYvqo2ruqdfdT/meZnqZ5zVV+VqbEx0J/tLEqmEMwzNo73gP/AMFf/wC7/wAThTveADOiuA7vj/EVfhej0i+ZrLQ2OxOB/bqZvNjO9uDN3g//AMyq/r/xOl+M8K1H8B1UKPpLLjP29pPTeF106pNTp7d1Yzx1/wAxOPZa5vjf/wAxb/2ic+dDxv8A+Yt/7R/xOdM31Z4c0+HLu11XwczLOl4NVuue0/yjA+5kvix2YRRzLRwhCEMwgYGFEIo4FGp01WpTbYOR0I6ici/wzUVnNf8AEXtjrO7CXUx5dqrEOGrZfuCIJVY/CIzfYEz1H2h16xqY4en8LvsObMVr3zyZ1tPp6tOm2pfuT1MtjkChCENCEDFAcQjikDhCEAiMUcBQhCAQhCAQhCAQhCZBCEIUQijhC7whCUEIRQHCEJAQhCFEIQgEIQgEIQgEIQgEIQgEIQgEIQgEIQgEIo4BCKEBxfPMfv7TzniXieru1D0aNlrqQ4Zv90zeUjXHjeTqa7W+Su1CB8kzgv5upZnsuGwdR7zLqtQ3l7WO9vfMwfjLFO1lJHuOJnLXacZGt9NXqMrZkKfpMpu0i0J5dKEk9STKBqbvMzVlyf5TI3eJaitctTtYdNw4nWRm0/I8vaq9T1m4vTpNKXt9VnZZzE1jWp5nG89eZGhzczC1tzDpn+WajFJNHqNTYb94UDkqfac/xip8KTjC+0u1OtOiJSl3YHq0ma7db4d5tBDdj8Gakxis/guiNha8sMIRidDXU+YgvGeOCPaYfDbn01N1dw2rnDH2myrxTTlGotPbBI7iWwjnva3/AEV4Y95nu8hAE80lu7E5my7QWODdp2Dq3cdpnXwffWXtdi3ftiWRLUq2tCYRyymbNJYQSAMEdSZg02qOks8l63KL3M2NrdPa+ahjjlfeZsalQ8Xtp89La1GCvqA7GZ9HqVL53kEHsZr1OkZ9ICuMnmca7SvRhs8kTUjNr1eyq4JYhzYfmC0MrFrGE8xpNfZQ4DMTj/E6R1TalM1W+r2kxZVj2UV+M+TqyHqYcMJ0rtHps50bMgzzgzC2kTVadQ1JDr0eFTPpqW+trM4GYsWOwpQVit2JIH1Tb4ZqBo2Lq3p7nrmefpvttADAhv8AmWVa/wAsGmxXVgcdZzvGNyvb6LxujUsQwIIm+vUVvYVVgeJ4HTWqGLUq7KRztPKn7zv+E6nUZH4mnfvOFfOOPmcrbKt4vS9o4lztEc3HKiEIQCHaEIR57X6c6fUsAPS2SszT0er0y6mooeCOVPsZ5+2t6rClgww/zNy6iPadSnxvU11qjIj7RjceMzl9opqWxLHY/wBfv/8Ao1/3MP8AX7//AKNf9zOPCX7UyOrZ47qXQqtaKSPq9py89zCElukmFNGi051GoVMekHLfAlVdbWuEQZYzv6PSrpqto5Y/UZm3FaBgDAHTpCEJlTnM8X0+5Reo5Xhvt7zpQZQylWGQeo95YPLwmrXaNtM+5cmsng+3xMk1KzjXptffpaWqoIXcclsZMoex7W3Wuzn3Y5kIS6YP/Mv0+qv07ZptZfcdj/SUQiUX6rUvqrvNsADEAHEohCNDAJIAGSTxPRaKj8PplQj1dW+8xeGaIqRfaOf5VM6hmasEIQkVKEIQGYGBgZQjCEIBCEIBCEIBCEIQoQhCiIwhIHCEIBCKEBRxQgEIQgEIQgEIo4BiEMwmQQhCFKEISoIQhAIo4QCEISKIQhAIdoQgEIo4BCEIBCEUBwijgEIo4BCEIBCEIBDtCEBQhIv9JAOOIJGbxC9Ur2NZtz9WDyZ47V3Nvby6yiZ7956PVV6eklrCbLT2Pecm9Usy1oGeoXpOV7d+HThOz2tiokmVWNZXkXtjj6Z1UWuhW2gbm/xONqDfq9Y1VVW5u7f7QJ14TpOVbdOrHSfiUYek8j2m5NZTqqBXYEJHcjrOXprG0uofRMyspHrz0llmirU/9Q7T7TbLF4lUarf4YXB9jIUJbpqvxOrztP0r7zc2o8M0q4trZ2HUsxnK8R8Rs19wAISivhVAxNSMVY34jxFH2VBaxxnGIaPS6rQ2EUWnB6gjIm/wq/8AhbHZQgH9pC6w227NO+R3x2M1rOMx0tursatlxnrzJfu274xcAV6fE1fiadKuThrMYMz1+KFbt2cZ7SWrIifDtXoK2O9mAH8veUpdqrVNljkBei4xmdqvXJYwAbOesrspra3FpAQ9GESljyt1uptsaxhk5446TXpKWuKttP3nqa/2cLrikgoRkk9ojoalpGk0a5cfW5HSXUxz7KHVAqsCSMTh6oO9pqcFSo5ns6PD9mFbl/mYtRotK+uR72ChgQx+wzEqWPJPQFGADk/HWPR3LpNSpY7lzzOhrfFag7U6bR/w1JAZh9QnPN2mtGWTY2eRNYkr0n46pEHl3AVnoMZlH+oiy0sqb8e84SlsYrc4++Zu8Hrs1GsZOmFyM95nFld+m2y5QaFrBAyQRzJ21sXDMgLHrKvLpqbFpatwO3eQ1NgNQGnYkg9+8y6SrvLFb7q9qk8kA4zN+htsLBSfUBxg5xOTUBZWX1B2bOg95t8O8S0lJNeopYgdGXqJz5xuPT6HUalWC21tj3951pw9D4rU/r37lA9NYHqE6ul1A1Ck7WT/ALWnPjsZ5xohFATbBwhCASjU6WvUphxyOjdx/wDiXRyo8/qdDdpySV3KOjATNPUyi3R6a3l6hn3HEsqY87CdpvCtOejWL/WIeFacdWsP9Zdg4006fRX3n0qVXux4nYq0Wmq5WoZ9zzNHwJLVUaXSVaZMKMserHv/APiXwikDhFHAIQhATorqUcBlI5BnI1fhjoS2nyy/7e4nYillHmGBU4YEH5GIT0llNVoxZWG+cczM3helblQ6/Yy7ExxITsjwmju9h/tLa/DtKnJQsf8AuMuwxxaqbLm21IWJ+J1dH4atRFl2Gf27D/7zeqqi7UUKPYCOTTDEIRSKYhFH3gOEISiUUcRgEIQgEIQhBCEIUoQhCCEUYhQYQMJAQhCAoo+8RgPMUIQCEIQDMIoQCAhAQHCEJmghCKFEIQlQQhCQEIo5Qo4o5FEIQgEIQgEIQgEIQgEUIQCEIQCAhAQHFCEBiEXaOAoRxQD4lGrs8ulio56CXEkDjrPN+OeIupFFe4sewEzyuNcJtVXasaZ28/1WE8Z7TNrNRXs3EFmPQATPVSbjutJOwZJMtSwANivI98YxHCOtjmN59hJ+ljwvxN+j8ipfIr5YKWdvdpjv1YZmTTY/7rOuJnOpOl2LUMknn5nSM1xtWS+qt9ZWwt/eVnU69GCVu20nj5nRs0dNlxufLk8hf9spRR+JDbuF7TpscrrP+G1N1gFoNrgcgdFmpdG6V4enAPVupE6mj1KpV5Gnr6nJc9WM21kYNdwCNjIBPWNMcWr8Hpq/WpIPU9f6S9rawFFFQV7OAMdB7yNo03n+ofSfp7QuuRKXepArEYLk5gcrWNi81qxJHU9szOu4gnPTrE5sZjtGRnJ46yANmdrqyk+4IzL0y6/grCzVDzD6TO3ZpPxFooYlTnKmef8AD9PZ5ytXk454nsNNauxHK5dBjpJY1K3Bra61pXgBcMw74mZLfJBcADJ+nEvbUFMFwAWHA9pUcOpGZjWpEbL0DjLZB74mHxHQJqKHNTnLdD/tmlkV6yir0PEhpia7NjH0kRLhY43i41Oq0um0y6Cqk08eavV/vOXd4Q1wAUYfHOB1ns76F1DAknAH1CVrp0HpqG1R1Y95u86k4x4mjwTVIMvYEJPTrOj4f4f4jp7g7Vbq8/UJ6Q6U15YbT9xjESWsrZfGO24yXmTiyX22BfUinHdhmZE11PmEMqZHX4nee7TW1gGtf7dZydb4FRqyW0z+TYRkA9DM/ZbFN1lFyegDcBn0mYkuTPmFLQoOCccZioofRXMmvqZWXgMvQzVbpbDpm1Wgs3LjFlZ5BH2lvhPXZ8I8TSmwJp9CHJGSyjPE9Potb+KG56DWc4z7Tw37Pax9MyMrbWU+oe4Jnv6VRv4yD/qDOPmcc7a5Lv8AxCGPmGZpzEIQgEIQhBCEIUQEIQHCKEBxRxQhxQhAcIQlBCEUB5hFHAI4oQHmGYof1gOGYoSh5hFH3kDzCLEJROBhAyoIQgYBFHEIBHFHAUIQhQYRGGZA4RRwCEIoBFCEAhCEAhCEgRhCEoIQhICEIQHFCHaFEIQkQQhCFKOKEIcIoQpwijgEIQgEIRQCEIQCEIQCEIQCEIQCEIQDtHCIwHFCECu1XKHa209p5XxDSalbbL9VairWew+qetY4BJ9p5L9pdTuIQYx1M58nX49ccaqxrCqkhD0HtBqbbGPm2+XV7Z6zDZbsGU+rPMnZrM0BcBsjvOnGdNWrL9RoqcLVnjj7mVhGbkEHcckzl10HUatVJOwHJnTtdFHLbFU4X5nTOnPV2paunTgVfVj1HE4l+8Oti1t8gToi6/V8Jp2NanG8950UNOn0pLoHsbhR8yxmuTotUGcE/wAPn+adPW6xHQB2UOo4M4niradtSEsuKbeiqPpk209r6ZbEYWL2PXdLiaTDzr8M+CepzNWopRqkVSQidfkzFpdJZa+7GNvUfM1azUpVpTUD6w394iIjU6TQ04eoPZ7Tbp7NT4lp/J1HhJCH1JaikED/AMzzTV2WguQSSZ63wbx3xLytKNS+2vSOBXxjIxjma6Ttl0V/ls9VYCAdMjBna8OtCIBbk5747x+KaOpvF9RqqQvluBjA6mTrV1xudVA7TneTpIu1lqvXhRuIHSY1exqwSrejpOgtlJH/AHdyJk1d6V/S2fYSbqo+e+0sa2BIx0lPnBj6h6geJFNZaOHOPaMnfZkrjPtKmr/9R2DDgBe/Epv8VW2vZpkyR3g1aWDL454lB0u1soPTmXDWnShzWbNVYzN2z0EV+xVLZBPfPeSsYpUoUBjjp0xOZfqWp9OAzHqT2jDTfVXeZlhhe3M2aXU1sQr2FTnrmctF8w7tRu5OQoHUTSlYUEmvA7AmY5RqV1fEKBqaA6EWbR36zj06g0M1YyoYepZ0NHaK2UknaeoMWu8PSy3zkO1W6MPf2mZa1ZGI6MPWL9M2GU5IzPb/ALP64a3w9QeLavS4954kVW1FghPI952v2OFzedcc5B2ke8nL1mzp6+OLORnpASuZwhCAQhCAZhCGYBCEBAIZhmEAhDMMwCEMwgEIQhDihCAQhCA4QhAIs/EcUoI4uY4BDMIoEoQxCUWRQhKggYQMBQhCAQjigEUcUKIozFICEIQHFCEAhCEAhmEJAo4o8CAoQhAIRRwCEIQCEUIU4RQkDhCKAQhCAQhCAQhCAQhCAQhmEAhCGYBmGYQgGYQigPMMwhAMwzCEAzCEIBI9eM9OslKb6zYuUYo46GS1ZGLxC7UhNibQD1M8n4hcqlmsO/tOz4vqbqP4eqwcj04HWeU8QuFgLAETEm124zIq2Va0+m7yz/tIlGoQUrsD7yTxt7SygmusmoDzD7jMXlGsLa54LAH4zO8jFR0QYWsC2DnBPsJrOjNl+9+a06H3lLUsN5UjAYYI7y7U+JImmSkDB9x2ErMdWu9RUPKQEqOOOk4uu1mzdYSNy8DHaa7bhRoEFT828k+wnN0/h76tmLkisH1EyxLWbXVJqKm1FeCVHPHWUaXX36bAqUbCPp9hOm61Vg0U8VHhnPeR0/h/magooyJqViztS3itnlEbQgI5wOs51dzW6xS2SueR8TuWeBo75tu5zwAJF/BRQMq4Ix0l6Xs9DXSNwDq9bHK84KzpafTi+xaFYNjk/A+Z578Ow1GBkfPSen8LoWjR5BPmWHk57TFjcrdrHRKKUqOQo5b5nLtax2AJOSek6eqNdNOWw1jDCr7TjF2e3YpIJ7jvMfrTcmpTTJgcseozKrNXRe+11K5kqdPRUu4tvYjv2lL2AtuU5YdMDE1GbV60Io3ISynqOssU7QQoyuP7TH+K2NjecnqoGJE3sG2qckjgSstJvG7hf7yJtewkAlh8SzSaVrhlz1PM3jT0adckgEf5msNYhXcwxkYx/aZL9M4Ybsc9TidDU66hEYqcYHM4N3izXnaoBCnr8SWEbPMrqIrrB+Wl2nTUl+FrC/7mOZjS17ApAHI6S5fNAywA/rMWukbbbVrUgsp/pHovEBU2x9r1v1HWcbV23JyuDj3EprsDncq7W789ZmxZXb19T6e3zqPXQ3UHkieh/ZzYNMzKRlzk4nlqtQRUpJLIeGBnovAbSibEVWGeOcYnG3tqzp6SOULvc+psD/aBLl445m4404QzASoIQhABHFHAUYihKHCEJNBCKEocIoQHDMIQCEMwgEIZjgKEcUAhCEAhHFCCOKECUIswl0WGEUJpDihCQEMxZhmA8wzFDMqnFDMIBFHFICEMwxAIQhAIoQkBCEMQFCOKAQhCTQRxQgEIQgEIQhRCEIBCEIBFCEAhCEAhCKQOEUcBwihAcIoQHCKEBxQigOEUIDhmKHeA4ZihAcTsFUsx4A5jmbW+aaSK1DKTyOkl8WeuB4rnWWtazbVztGfb4nmNWA9xqGAo6T1niddjHzLalStF67v8zxvidgWtmUYLfSJnh3Xa3pFTlcpw3QzFZqX3PSTlLDtP/aZopby9MqsdzE5JMnqfwdFKW2AtY5yB8z0T1zqxDgJp6yWCjr7mcXWWNUzZOTnAnQ0FrW6wljtwvAEyppW1OuJYFlVsfeanrN8dXS6a9vDU1F3YAKvvOnpLqE0m11+vIPyZg02p9T1OfRX0Eou1ZttXYMLWOB7yCXh1QfVWBhuUknntib0rOnp21H+NceT7TNRfSOKCDbZ1/wC33mfxXxAh8VdVwo5xL+o6LVJW2LNRuYdcdpctem1FZNdpLDr8Ti6Q+gIWIB5I7n+s6+l0yBd5JUZ9+kUnrK/h71P524MM9J6AaRE01TA4VU5HuZUooxmnD+7GLWapV0ThTwqzHKt8Y5Bvs1OqYIcsBx8TRofCxUhNlhLk5Zz/AOJT4NVvv2opKry7f7pu8T1Q04wzAMBg/AmVRsCVqQijHYTFclm4+rHwBFVexO6sFgerNLPN1FrEoEUDq81Cuda9tXq2scfEv0lqUJljue0ZJ9pfZyvqsZuOTicFrzRa1ZztU+ma1ix3dV4zVpqdteQcczBX40NW23Jzn3mD8Nb4q22hVTaOWY4zJ0+F/hLM3ONw9jmX87S7rRrXa2l1rJ3H5mOjwvUrp/Ma4IpONueTLwT5r56dpPT2PZcgySoPJknJcbPxJ0+nWuxTuXgESynVlhlqzj3PeTuVbOCAB2MqIKKarDuUj+0xe63Oossau1CP/wCDOZdWVbKEiRZ3ps2sxI7GWq/mfUOD0jMOqv0N+GKWn0sMETq6c2VoBVneD2PUTk1oMBsd8Ga79QaqhgkEdCPac+U1vjcj0Xh+v1gfyn3EjsZ2tH4h5jmq1SrjrnieS8L1VrbfMO5Qfq7ieitK3UrYOLKzw3uJi7Klkx2vjrGJCsk1IT1IkpueOVOEIsygjizDMB5hFCExKKEIXBCEUBwihCHmEUcocIoQHCKEBxQhAcUI4BCEIAYRQzAcIQhFhhFDM2gMUIQoxCOKQEIQgEMwigPMIo4BFHF3gOKEJAQhCAQhFAIQhIohCEAhDMIBCEIBFHFAI4o4CiMcR6wDJhzCEgI4oZgEcUIBmEI8QohCEAhCEAihzCAQhCEEIQhRCGYQCEIZgOQfkdMgDnMlOd4nqq9LSWLHOOBnrJavGbXD8f1huu/DocKgyeepnkb3XUX5PKr/AJM6uosa6xmY+qw4C+0zaymjTaMu/bIUDuZr443yvTkF38xnB9IPE0alE1OkruB3bR/aTWlW0u+wbeJTo7QjYT6GOD8zq5yqKrTRqa2IO0nAIm6/V16bUUogAG7LEfMLtOK8kqNqncvyJzTcHfNvBckgyztLMb7yKrWOfqP+IzX5diWk4BGSJBltfRopB3qMqfcSbagWeHOpGHUY6SSDLSTT4lXbUDtdvp9wZ1/FPD0N5fHQZEp8O06iyu18fwlBAPedLWF7SCMeoDasumMaaeuthYclQM4xNdZt1rJWqFEYgD5l9TABaUUE5wWI6n4m2wCmrKEFkHbvM2tSdsmvVKLl0mnbIrXLEe8za18eFM6/zHEWkDanUNQmTY532v7D2zJXZu8GuRV5rsxM1qNHg9R01Jdhyy7pw7vM12tsutYhA063h+qA1C02HItQqsz3ItL+Sq4wc/cxBUxc7a68+rsJ0KtKa60rbDWHkr7SjTPVp63utIyvP3M3aS4Jpzeyjfbyc9pYVIaWtKmLc44Y/M854ppahZuRsnM7Grueypa1OOpJnK1ahalBOSeSI1FNKgVhUOO/3lbrcThQOZWbCh479fiWJcxHJwPeUQKv04MsU111kZKN8DrKdTqq6iWUBlHHBmQa8McY4lktTY6NeqdeAdw+ZN9QGXcvUTmDUq3APWOu0NlScZMl41ZyjZqXWx1ZfbpIVPizaDz2EpLEphupPEu06ZvVivQcyVf1ur+vAHbJ+8k1qpqkSzBBGCDHp1G5yxwJQV8+21uh6qftMSdrfHZ0SDQ27TzS/T4M9F4adx2WfRnIPuJ49NUzUqr9P+CJ6nwqzbUgchhjg56zn8nrU8elHTg8CEpoPp9JwO49pdnMsvTjfThCE0ghCEAhCEKIQhCCEICAQhCFEIQhDhFCAQhCARxQgEcUIDhmEUocIo4DhCEgmYozFNoIQhAIQhAIQhICKEJQQhCQKOGIQCEIpA4RQgEI4oBCEIUQijzAIo4oDhFHAUIQkBFHFAIQjgKEMwhRCEIQZhCEBwzFCA4oQgEIQgEIQgEIQhRCEIQQhFAIRxQBjgEnp3nA1+js1zM4bacHH2ncZdwIznjpOH4rq3rDUUD1AfxG/wBonPm6cHlL08m97FJcKcfczPqrjfdXp7APSNx+DOsl1BqZmA9AJHyZ56nzNRq7bcYJHCz0cJ0ckvELCqmoH0gTFp2C1MD26Td4jpbK0qTlnYEn4ExaSoWWFG+nqftNVzbKtRaujpsuXcu7aM9wZifThb7S49IOVU9gZvs1W/WUVmoeQnRcdveR1SqNVddg7CcD7RGr4iuqNmkRQQGQ8SFbG+9k28HriX6fQKdr16lAnXn3gw02nDeXYTg+pvcysxqGKsvYRvYYSsc8Dv8A4mzwx1ussv1JwgGF+0weHOlossAAdhtUnmaLWFLJo0PRRke0lWOjoyl/iJsA21VqQi/PvIU3m/UWVA4DKR9jMFeqGmtYBsfyr8w09/lB9QPqV+nxMtY2+GldJr7UYgMy4B95pKipBpyObEL/AGP/APBnJ8Vtzqq9RSeHH9jNmm1Y12n7DUVcY9xIrFpASqkfWj5X4E2eI4K/jVHpC+oexmXU50pSwcFeDx1k79Qa9M11ID1v9SHpF9JOnMssfUGtXPDNlv6Ts2MqUJlvSo/zOPUK3dbEyMnIX2l75vbDE7Qc/wBY1O14crpiXPIOfuJg1NhJBHPHWX2Wb7CD9IHMw3sPL25xzxLFsZ7H4y2OT/eUXahhXsXv1lV9p3kY6dJUrZGDOvHiygHIDA5IIlYzLSCDIEc8Toxyl0bjkfHSX01uzDPvKCMH3l9DgDGTzM8vEjfWhuvz/Inf3nQr2VguTkATnhwFCZ2j2+ZJrWFRWrlQOZxstdZcbLLGdPT37ZkA7hVwTyTiZaLAcox9R6NO3oalu01lLAb25q+4mb/jD2qaq2NQYjgnH9Z1tBcNIfI1qOueVb2l34BqtIiV+tGG8ccq3tOpbTT4h4OlhUebUMMO88/LlrtOmnRa0o4AbcuOM+07CWI4HlnM5Gg0yt4em9fXX0PuJ1q0AVcdhLw1z54nHCE25CGYQgEIQgEIQlBCEIBCEIBCEIUQhCAQhCEGYQh3hRCEIQQEMwgEIZhmA4RwlE4jCE0gzCKEAhCLMCUjCEgIQhIHCEUAhCEAhCEKIQigOEIQFCEJAQhFAeYoQgEIQzCiGYcwgEIQgGYZhCDBCEIBCKORBCEUBwhCAZhCEAhCEAhCKUOEIpA4RQhThFHCCRbpJRHpCser19Ojq32gk5wFHczztll2r89gnk1WnksZ2m0r63VPc4xWPSpx2nD/AGi1NNTfhaSERByVOd0xltdeOR57xC6tbvKpJ2KMZ9zM3hzmzXsBxlf8SzyG1DhthrqHc9WhTpjXcLlcYz6j0wJ6OPjFu1p112yl7mGWZdq/acjw1gdQeRhR6pp1OoGssWmvPlg4U+4lS6ZKLbCrYVpueM31dVhL2vYHDHA+06BWgXWUvgo9e5PvONdqf/VqScpjaR8Syx2R1wfp6fAmbFlK+krYxVwB12zARe9uCOD0wOBNt1oclhncOv2kW1AasYtXjtiajNd1NPTVqPD9JWuARusPvIeIoK/FbbxyHcKsuvtqZadUhG7ywODMOqvF2kYswDI+Rz3mbVxi1NhW3cex5+80OTWrKT9a5mHXtuVHA4sOT95Ymo3Iq2fy9DGKeo1BrrrOcjoYLa3mpfUxRlMqtQWI1ecY6fMz0uUJqPXqufeM6JXc1usOr0+yxdtijOR3leksNmmwTlccrMdF6WABu3Evr3UWHacqeTMWNypVjZfwpA6S3hBjPf8AvM+o1Kq+8dO4mVteHbC4OePtE42rsabbghK55Y/3mHUWHC89+fiQvR7WFiN6gOkjbgrhgQxHM68eOJlrK+dxxzIBWJ4BnU0fhrXkEggH4nc03gqLg7czep9K81RpXuGQpzNtfhLN1H+J6Ovw0VvkLwevE6lWgG3gf4k1ucHmdL4NVj11hh34nP8AGfB28OsW9VPkWHj4M99VplU7iuQO3vIePaCvVeBajqCq7h9xJL21z4THzVCS/PJmqhQBhj6mlFIxtbE1O4rr8wLll/xJe688ipMpYwIHwZ1PDbh+Kp3HblsAzlj6A2eZ0tCgsC1nqDkfMxz8a4evo1Va2aHaRyrYMq/Cis2BAdrrzj3i8JudtLULerDCv7/BnURQCczzZrVuVm0DDyvLI5HE2iVilRbvUY95Z3m+MZt2nCEJWBCKOFEIQgEIQgKOEIQQihAICOEAijigEIQgOEUJQ4QhClHCEAhCEBwihKLIoHrCVkQhCARQhAIQhICEIQohCEAhmEIBF3ji7wHFCEAzCKEgIQhAIQhCiEIQAwigTjrAcJEsB3A+TMFvi2kW0VC1TZnpJqyOiZHeAwUMJ5vxfxKxiK9Hea3Xk/Mz0+J2PpSXfDg4ZveTdXHqW1NKsUNq7x1XMpt8QpqxuPE8Fa1j6+y42sT3bM2Jqy67HsLdxmW8bhJHsqtfpbjtW0Z9poU7uhBnzwsyliGO49CO00Jr9Unr89gwHv0iSmPef2/vDjGTjj5nia/FPEbk3eeSuePmLVazUtWVTUvscYIz0MuUx7UWIRlXU464PSRF9Rs8sWDef5Z43SvZ4aENbGwnlwWzxI3a4ajxKrVI5r8v6h7iTKY9xmGfvPLXeP3XuBp8Vop57yk+Jasv5q6ghQeV947Pq9fkdYtw65nl28Z1JJA+kDk+0uXxEtpy7sRjpz1js+r0QYHjPJjzPKJrXWw2eYxBH056Tp1eLBa1D4yesmr9XYhMFviFQpDqwYscDEsXWVgFQw3gdDLrP1rXCZaddTbWzFgpU4YSrUeJJSnmbC9YPLKc4k0xvhKK9TVbUttbAhukBeGYqQQRGmVcCDxkRzFZdWjhuhA5ibxLT00+ZqGCjtEplbsyjU3001E22BcjicS/9o6w2AnpzwQes4uu8Vtu1vmsuVIwqk5EvayO/wCIeJhNIK9M2XII4PSeQe5dz2/Xg43HnJmzWPt0Zav6rBgY9zMrKg09OkQZI5Y+56zfDit8SrFuprZ2HrI9I7Cc3Vv5f8BDuZhz8TqHKE1DK5GfvOdTSNTatanFljHc3+0Tf6n4r06CqnzH+o9PmR1ddw0+4qenE2pWja6wMc1UDC/Jl2ovrvoNQUBjxn2moxXnMsHrdxznp7ze6izT3X54Q4EyaywC1QcDZ0msbk8LyeWY5aKcVenw+juYgb6zn7icm5XFmbFwG6TsaWtVDbjivUrtVvZhJaiiuzw0pau3UVHg+4llLGPRaw+R5Dtjb0z7TVhbKyTyCJx7FyA44I4MdWptqAAOVJ6ReOk5OkuGo8l/qU5WU2qUT2wcypNWWfYVGT0MvFgsBrc8zOWLLEy29QxOCJmuJFqs3Y4lwXKlfboZB1DrgjnGD8xF/ECyrayn0kjgzZVrEICWNhh395jKG1NjcOvQ+8rIx6bUOR7S2SkuOjYq2Dkj49pgv0bKd1bD+8pew1jFbNg9s9JH+I31P/manHEt1ZXca2As7ToaJtJbqE82wDJxzOSwBzzkytQc5l+px+Syvqmi8NRalNYDAjPHOZqXThTgjE8b4B+0d3hu1LybdOeozyJ72nU6bxKhdRpHV0xyB1WY7eqcpyVDTBgSJfUgwMDn2k6gcc95bWmMsD/SWFlU3Iqlcj0k8yvVhW8K1eOFCEj7TRbgrj+8537RagaD9m9QxI3X+hf6yHK5xfNPLITIPGf8ydmRpWsPRjj7y+momsqMEgcD3kL8qgXHp6kTO9vPYKqDbTt/nAyBOt+z+lbUXshJDVjM52hJa0W/zMMY9p6DwEnT+NI2BscYI95n5PDhLr03hJD6SxQOjZI9jOuOkw1aX8PqHek7a7GyVm7AnHjDmccjCaZOKPmEA7wihCpQiigSiihAlFFCGThFHAcIoQHIxxQHCKEBwihAccUcAhFHAIo4SghCECZhDvCaQQihICEIQohCGYBCEIBCKEBxQhAMwijkBCKEAhDMIBCOLiAoQizngGPFSi3D3mHxLxGrRVbrCMnpmcmrx65wcrXtHsZLVx6JnGcEgTn6jxbR12NR5oLqOZwrfFLHuNwPG3AGZyC6+YxI9bnOc94y1cdfxjXal9Iu2wgu2MDsJw0YLYXt5J+k55l1z2fhUOcgf4nNUvYwd8jBxN8eGQtdC+/ZXmvlmMpJsY8njPIEt8hWThgcdyZoroyAybCw6rnrNyRNc57GWzFi4OeJqRS9ZZhgjpiXalUuTaVAdRwJzTq207MvcHBHWXGf1urTKu+4+kc/Mivl2hTa21O+JXTdVqVUm0oTz95enkojVqMk8/1jF1F7aqCERG8s9ycTXR5d1fKlXXqPcTKzq1BZxuaWeGNZ5yrYdq4PWTIbWxaglfmOw9ue8x2Itl2FI295obF15IB2qML8mYbKtuoy7bWPRjwIaWVg+srgFfqAkFsU2YGee2JoZQKgwsRmYc7T0hXraNOQH067T1eQW71XT1qANzMd0z33tbaFrONowQZquNN/NXQjI+DMNzIrb+c9Gks1Vwe2sYZfsYWWPwTnJ4lNl1llYwPV1zLKFe6tS2Q6nOI+pav8w1OFzkY4E0M711+Yzcgf2mR2TzVfo2eRLUtV3cM2eeR8R9Yaqp1FjP5gZjnM1I1zLtrOEbqM9JjGrJRkAFakkLx1gm8ZZ7CFI5HST6xdbPNetUrquPpOcCa01zqcuxD/AH6zkItPVWcMx4Mq1L2EgFv6iPrEtbdZ4m1+sYK20L1+ZzvE9Zv9LPlfb2hZp1C7/MwSec95k1lRWsbfpx/eanCM3kx2XvkKpJHTOZqoSwopsYjn0yrQ+WHcWgEgcSyvUL5/qGew+JrOmZbrpKd1K5OdmcTHTaAisV5DHLfEsFqWUMqHkH+8ytagYjOAe0mdt3xbfrA+COCTgH2mRLTVY7KfVjgiUMTk46Axk5fao4ZeD8x+os0Gsw1lV4w1hyue8sQFbicnABmPVuluirtHpvrbDcdZ11VL9EzVj1EBh8iarLh66olhaBFVZYECtnacA59pvUeforaWA8xTlTKLqRUAjNk7Mn4MtsMq8qyaN6WX0Hkf9p94q9Qmo0hRj/GQYPyJCrWG2rCkKwG1gf5gJmrrOXFf1Y4HvIrMUIrfPczGT27ToW5HoJye8z30itA2Oom+NYrOjlXDdxN6WpY64IB7zng88iWbTwy8faWzUldBrCp5/pEXDDIbBzMK2sLAXOQJpArIyD9UxeONyrtyEdfVKL7Nq8PljGy46CUtWSQe0SCsXEDBGZE2Z7QdcMcdIsdAOs6dMZTHJxLDgV57xLWRyesm1bHBI4k1RTbtOWyQOk6Hh/jGo8Pv87R2FGzyOzfec8oSoGOkYqwMY+8zZK1LY+neDftLofFFCs66fU962PDH4ndG7HA6z4yqHOVJ46HuJ0tP4v4tp1xXrbMezcyV24/J/X1Sw0aWo36+xaq17k9Z8/8A2i8a/wBa14FI26SnPljH1Y7zkavWa3XkNrNTZaB0DHgR0gkgHP8A+JnlekttrZUFSxXYcDgjHaa7NCbgRSotqPqBXrNHhGjN2oq3qCGbAB7z0tng2n0eqqt0oZAzEOAc8Gea8rvTVydV4D8PZU+RlQTle2RPTaPTFtMrbScEPW/uZs8V8Bus1a3UjzkP0oeNs69GmqNKiutgwGCMYk5crUmRr0TeZp1Y5+c8zSJVRWKqwolks8c76IQhKgjizDMqiEIQhwigYBCGYZhRCEIZEcUIDhFCAQhCAQhCAQhCA44o4C5jhCARRxQHCEIE4oHrCaBCEIBCEIBCKOAswhDEAhFHICKEcBQhCFEIQhBCEICLADJ4xINYirncD36zF4zqFp0Llu4wBPNaXxHUpSakYMP+6Z7bketGqQrvLAKehnK8X8Ur043I+GHcTgWeLvUPKswxPRZytTZZe5IXb8EyzhadR1/EPEF1+kzkMMczi1WGvIQ8e0VKuhWsMGQnJxJWMKiVCAzrOGJeSYsdRgHPxLVI3F2A4HEKK91e5FJwOPvHYRbWAy7W7iakZtaH2pT6xkkcTnbHxvB2ox5Y9pY2uXZ5TYIHSUJYbbCpb0t0UiXBqqobqXDUg/ymaQa+PKGcfMjp7q9OfK27RjmQ1JVfUvVvaSQSsF1hDKNwPGB2mceHWtdutIGevbMnotZSW2rnePmbLLG2ebqG6ciU/XNt0F1Yy3QtkY7S6up6UL2HO4ele5m2zWVWaXdWQTnofaczV32qvmgAsxwvwIE/xTIdvkgZ6Z95oo1KWKdyFXHXE4/4iy3/AKpGQeOZu8LuudyBSu4dWMhK6S2AKNwZsHsJZqNVS+wXad8Dvj/MLGvGNy189R0lhvyQBgADkEdJltg1goqAsQAqecrKl1lVKjFXmBuTkZxOhZUwDWV1qa/5h8TDelTL/CxnHIEqWr6baLQH052g/wApmTWOXvQK2AD9Mq0uksdtiZKE5Jz0miytarB6c9txjE9Ou8fSw5HQy0XituM59x0mZq8Ig7tzIDUOD5dbDGe8LEtTbUSSGYsemOxkvNuNaswIKjkgYzI6RzbqsrXvUcEe862ofT10bWQ47n2gR1ddTCi2rHC/TK3Jsr2qpz2z3lWmWtrR5TmzI4U8Ymxb3VTVaoQg+lu0isNl2o09P8SsMuegHSZaNWjOzMxVF7HrNOo1FpyNoRgf6NMNWmfUI7IMZPq49pqJVN2qa+wmvJboPtJVaS65CL3O1fYdJNahXUVrAB9zNOgu2bmLEjGGzzKzXOWkVWsoYsO2ZpppXy3ZlPTGJXqbybyoVcE8YEm2ytVNlpRiMhc5hIhWaqnQrnCn1Ke4mfxMiuxnoHpbkSOs1Oxd3X5kKr01GgtSwj0+pDGNahSXNfmkHj6h8SRG1cqeAcgzJTqTXarA53elprpIYWVjoBxJZnZKNUQUWwd/qmjw7WeWgpboPpPt8TCCroa3ONpiDhLgpPBMfi/rqFqqdbub01WcfYzDqcJqHUnOTnPvLNWWahfg8ShyrKpY+oDEkKzqMllJ5HSW0MUTKnFyHIPuJXjeuV4YcSxEYr6eHYY/pNMrLTXerWhNrjmV2AWaYAjoMyxjsCYUbO595GkearDpjkypY5LKVPMnVvJ2joZbeoJcDqp5ioYKjN0nTemcD1oi5Y5Y9AJVu9PWaTcmwbFHznvG2nS1A6DaTJv9VQl9gxzmaq/4hII2/Ex4w3XGJopco4ZmzJSJtUATkd4CkZ6ZMlY62c7uBLqcMOoPtM2tK0pxyRLmpXYvMmuMcjpLNox95i8mvqytWIinOPeaMDMZrG3Mav1VqgVcRheOnWTx8QclU46npJqyI1r6iPmaqa/WCemZHT0lV3WZGeZpp1CV2qGQNUTyTMcuTXGPT/s+NRZqUdKEShBgFuZ6z78/0nM8N1ukvqRNCA4VRu2jp950vmc+MTnezIHeEIpWNpxxQlBCEIDhFCQOEUIQRwizKHFmOKRRmGYQlQ4swhAMwhDMAhmEIQQhCAZjigIBCEIBHFCA4RRwHCEJRIwgYSoIZhCFGYQigEIQMAEIQgEIRSAjizDMKIQhCDMMQhmARHngGEo117abRX3IoZ0QkD5jVji/tLZTZU1bXKLFHCgzyr2bACzbcj+8jUl14Op1NpZ2O7BHeUuwDEagZI6ZmuEi3YXlnUWg5l2oqYKAwwPf4kfxKsEWpVQL1HvN2kIcOjMrZHAJ6TrIzrjuX01m0fSTwfiLziLmVBnf0M6Ximhsr0wKruAPVecSvw7QsoN+qxhfpEaLNOliqBznHJ6R6ii+xARgHoT7w1Wq27cELkyH47DKrsQc8ESaMFmjer1ZLkdcQUiv1APwOCROm2qFdilKdxHXjOZkt1VvnFBtdT1UjE0ii653uQ5zxziSutdxucFBjiV31WLdvBKJj6AOTOjpNKmxbL1ZzjhWgcjSM9WoVwhZD8dZ0dS111RTBwBkTatvrYKUVT2xIb3azZUQPk94Hn67La3w2cAYmtbPxVQr6FeP6TbqdKh+tMkjqswBERgNxwvXvmBd+HrYAKu3aOHzNugYVUYY9TywkCCqKVUEEeoEdZTqblrTejbUPAGOh+0lWY23afS3ZdL7A4GR6u8w/idZu8tgbGB9XHURaQuzggNk9mGMzbp63NhJsI55Cjn+8h6sA1DIppuFeR6kYxW6MYBd8MerKOJMoC2V07e24nmZ7lurJ3X7l/2g9JFPHlN5bW4VfbvG1hYgchfciYqbsWbbPUv8ue01ahj5e1smxj/YSinJFrWscnoo9oXVHAZVAPYSKsKKyzEvg9ZJ7TcgxkZ7ZirFlFx05G1AXPQSvUau62zy9VYU54XHE00pWQnmqRxgtjoZn1dIexS7Z294E6SjDGGX2bPMuurtbBa4YI+kmLShKyGtYYIyssbSLqH3IWU5z95BUqU2NjzDW3Qsx4krdVTSjVVAnI5Yd5S+mHmlQTgdW6iW1vS/pOn3kcArGmOYvmWW7BaGUngAdBNAC6TLopxjues221bV9NIqVe2JnuZFTzmXzCOB95ZUsYLLwzeZj5AxiUJqVsY2GskngZ7TRfXqL13uorA+O0dFAddtYDBe57mVmRztS62VttTbjtmYqGPOegna1FID7GUp9x1nOsqFbNtxz1mpYmdsZXc5AnQpsaulSO3WZFUIuP5mPHxEbLU/h46RZprcSlpFiDH+4SNVRa0M3bmZKGcEqxKjOcTXTYdxJH9ZLMWXtrDo1Yqccscic68sl5XHeba8Orqq5wM59pCmtb6jc45qP95ItQ8rbWlh74zJAkapGXuMEe0lXYHC1Wek7vSfeW6pPK8UWthhSAM/eUM2012tSwHlNgg+xmYgr5gTPXk+0Wt0ti2MpJ45U+8h+IIo2lcM3X5grK+VvcMO0qVSQcfSZeW86vd/+onf3Ezs5yCRgfE6RipFcZ9MmuoK7R2WQcttyD6TIKNx5P3g0MxOSe8K3ZW45+JPYHIA4Ud5KoYZmAztEJlXDZZ6T6GI4+ZQWtot64I6fMQdTy4JJ6nMLnLAAngdIkWt9OrVkJsIBl/mFk3g8AczipkngZxNK3stZR1OJjlwanJ0arFflTNLAeWRkZE42m1DJYMDiTt1N1du88AzF4W1uc8jU+srRMHlvaFer3gHHq7DHSYg3nbmsUDPSWqyqQo4BmrxmJOTu6bVaBtK3nrZ544CryGM9D4L4DTqqBZrK2VWGRnqZ5nw7U10hUendz9XtPZaLxlVZaEWy8kDBA5E8vPqus7jteHaDTeH1eVpE2KecZzNcoqvLj1Vsp+ZcOeZIxRHDEc0ghCEAhCEAhCKA4RRwCEIQCEIQDEIQkCjhmEAhmKHEAhHFiVDhCEAhCEIcUcUAhCEAjihAlCEIEoQhNIIQihRCEWYDgYQgKEISAhCEAhCEAhmEIBCEUAPTPtPJftHfqRcLK7SFIwAO09LrmddHYa2CnBwfafObdXc1rebaXIPHzEn2rU6i0FLKcAlXXtKwiX4bVEYXp8yO17W9CkFuSTLTpw3N1prx9K9czpx4/U3UW0lBXdWMD4Mqt0br60sPHxOhQU27jWAqjkmVWeIZ4VUwO01rOFo77a1w9+4ngqw6wfUG1Sig7PjtIX36ZEWw4II5+JTpbdVUS+mVbKSc8jmBYLlV1V9OrheCxE1XafSPT5lAG7qFzI2ajzBttp2MeSMdZg1Fi6e7KKdjD3jDVun1xW/ybK2r5wGzxNOv09e5LawDd1z7zm7H1X/AEsgjkk9MTY+op0qKu42OR1xmWDZp286rfYh3j3EqfVlOEAOOvxMtfiLaixai5XJ6CTu1FItNKLkqOTiRV93/rNMB6VtHKn3mMVMcLfuV1PVfaHL14+jnj5mrT3hvS7bnUY4lRJvw7UYGoZgB9OMTNX+Grbaa+SOG64l701O256yT7rDdRSCCMr3z2hVNbb9Tt5LAccy/T6ApqHt1CAqnKqe5irpqYhqrBuPIJMus8QVU2k89BIYLFWuvzHAUGZ/OXI8kHb3b3k7GS/ShbD1PvFTVWqHaQcDhPeEAse4EVsVUD1EnvMt1ND+k6ncRwNsdwDgi47AvbPf/wAzHZ+H2kUkhsdTC1q4A2sMMnTjrEbPPbcWxxgznrqLzwa2YDqfeT8wnKg4z1x2ga3z5mCAFHf3kbw7VEoy4B4AlSXZYITnAwcyaqqqQnv094Iuo1doUL1Uc5949TcbQCw2hesNOUr0zg43E5AiG2/0swwDzntC/i5tl5qNeGwOB7TXbeujUgHNjjB+Jk09W3eqnDDoJZqMvpfOqXdbnacyErDfqbPKNSZ9RyDjrOp4NYqVbSm0jksepM5yNfYAlyYbPXHSbKqjWhW2zluvPQQR0LrNOKGUnd89czj6m8JYAijGMgYhdatK7lLbe3yZRoGZteTeB61woPaWRLVb6m3XlKSuELYz7yyvSao3GlG21rwSJu/DJpbWRgOOVPzJsr+Yu0ekjLH3lZcTW3PQ+yzNoB4JlPnU3JkABps8U1IpcoVV3PxOPc4zkrtPWU0r6wrq/TnmVly9u5RgdAZoB8ysBhu4yTG1KP5ddR68n4llZUl1JKagEexE26epVpwx3e3zLn8MLso3Db1zK7EagmthgjpJa1IF3IDuAVSMHnrNJtpXT1AKFVjiY2vrVNrtyegx0i0+osNflpWH3HJkxdPU0lM46g5Uf+ZPXOoZKt24hAS3zNOotqe5RUo3ADeJls8uyxwVwXGM+0RVwva2mqu5eUB9XYzk3OPMc59OektN91aeQxOF/rEgrKogAJH1fM1IzarWvC70B6crI31krvCYE1pq7NL6lRdp6ZHaTt1Hn4BrX1DnA6RrOOUljIeOntJ+Yn+yXnSq7YRpQ9G0nnpN7KiLWFuOgl+mYBiD0IwZm3enGI0sZOgjF1rfR85VhiZ702MADniNbCepjdlxyMmSa39ZYowe2ZYGbgN/mWbGdRkBR2+YMzIQuATLrGEifxATwB1hqrja/HCrwImd7G9QwDxGtIPQ9DzJ4vqCO5IGeJr4I2ECJKqxVkHnPElcoDoQeo5mbY1JkbtI5UKrDIHQ+89V+yNrfjmQAZI5PtPI6NWsZawTkngT6L+z3h1OnRLVDeaF9TEdZ5vl9deNyO/8+0cUJlg4RRyhyMcIBHFCA4o4oBHFCA4RQgEcUIDihCARRxQHCEICkpGOQOEUIDhFCEPMIoQHHIxyhxQhAlCKECcUcUqCEIoBCEIBCGYZgEIZhCl3jhCARRwhBFHFICI8wJCqWY4A6zzniHjWpa5q9IAF6BiP/Ml5RqS1n8a8R1dGsurXDVEYwe081mqzUK3mAk9hL/ENRqULjUMWdxznmcxNNeirbtxznPTidPj4ryvToBLRepFbMgP1Z6zoMj2jcQn3legYXUu7MNqdBIL4glmp/DIMVpy7dJ0rMiOqS1wKSwVT89fvMN9tVCYYpuPQjky3xPxZCwqrAbsoCwo8MRrke1RtAyQeZWdHh+iF7/iNSyiroq+5nTTG3ZpERQDjOOsoqGQxCgIvAX5mW576y2xiig4DSK26lbAhGpQkAdV5nLuau8hHBC9sy5PGfKQJg2WH6iekzXairUKxztJ6cY5iFdOoIulVqVAx6SPeVCmtskEjM5Da6xESus5I+es0Va+zANy4/pCzBq9ONODbUACO8xJrD5oYn+vzOv8Aw70zbkpnOPiTbQaIr6aic9NsuphaelTpjqb2yW+ge0otDac+arqrYztHUy99NZdWBU5VT9XxENEL9VvdsJUvPHWRVNfiDugZDhu6+8toezV2bTUD/ux2nO1Olzq1FQasM39p0ano0llqqx+nBbPWEWWVCoF6VywHHxMK6gamweaNhBwTiSbxWkvut3eWpwFXvE+upvJNdIG74wR/WMGi4bqTTSBuHQzCbL9Iym2zzR0yB0mnwsHzbrNQp9IwoMhqdQbLfKRASewEsKq/Ei1t/lhmHTd0/pIW6ZrhlAS45ImvT1115Gsqav2x2i81Xt20MU3cbiO0DVUyipECAFRxuEL9RSFKLpk809SB1nPIsp1o8x3ZOgzzmdG29NDXnyzY7e46SDM2i81d9YC2Z5X5hda9NeyyoGwdGUSWi1IbIvDDdycDGJfbbRVpz5ALZGRnmFc5dxAJJBb/ABEK2YkqMOPnrINetimwDkc4ElTvu2WV2hc9VxzGGt3h1w3t5qfxAMfeaLbBWccnPJx2MspRagrX7cjnHczSUFqNYFCoOpx1iqxC4n6UZiT1AkXqLtnay8cljL2tsQivToNx6se0jbTaADZeH74UQKbVCaceaw4+lR2nPazFyOD24mjVVeYPLLtg9fiZldNPmuwZUrhcys/rdZY9oQ5DHImhtTkGs4AXgzj6O4rqQucZGZsFJvsKq2GPJgrHTpjZrnNmTnOwGXU+HVNqSuoOdvJX3lurBQKUOHXGPvI6nU7gjlStwHX3i0kT1mn0lP8ACTYpxmcwEV3qibTk8n2jtR7dQ19hJZhwJtp0K36Fmq4uUmEJ7zUAEA3Zzz2mHVs9gNxJLj/iX6Kqy0MrjLL1z8RLtRibCME9DJqubbWbq/NweBzN+g2aWtXxlmGeZvZaBQtukAbH1rjM5YurtuyAVw3T2l3pMR1FFrWGwEo2c4WOqi66rbsJK9xN96sSLxjAXEyXX29K9yk+0sp45ttVht2k4JPOO06eh0ldYbBBIHrJ7SjR6S664E5LZ5yJv1PhlqEhcqh5znrLv4mHqadJYqm9wiDhcd5S1GlRMUqzgd/iYdQrG3bqLD8AdhNSBAoFduAeJOzYyFxp2OAAp6GBrpuGQ5BmvVaI4Xyqy+ec9pyr6npb6uR1Gek1Ilqd1FdYOD/mZdvBM26WlNSpVwQ2Mg+8rsrWnKqu5geZZUrKDjrL6iNwzggmJWwclRz1kXcizK446Yl9WXGr+dlJ4zFfTnbhhiVLYHYta3X2iLBsqGPHSTHX78fqd5esitwRgcGT07FzgiXeJ1WKmne0Y3pkfIldDBa2dBkjpmT8c4GXbYFXjn0/MlqbiLPLUDC95C9yjA49TDP2kKjnGRkkyZ+rrpeC3hNWjsMMp4M+k+GeM6W1QjkpZ8jrPm2jAGo68qOJ6rwpqdRUg1BYWbsKcYnl+b3Xbh49ujh13KcgycyaOo0JsJJ/8TVMys2HCKE0h5hFDMBxQzCQEI4oBCGYQCEcICkooswCEMxwFCEIBCOLMAhCEocUIZgEIZhmAQhmEAzHFCQPMIRCUShCECcIQErIijzFAIRRwohCEAijhCCKEDAI4oQCLpwY55z9rvErtFSlVOc2Qrb4v4np9NpmO8M3TaDmeUPirhgdo2seBiY1ts1OVsAVh6sZ6xNQxU22sQO03OEXbENXcL7wrWAkc4ll1qXb6HGEYA4B6zj6txWcqOQZY1palCh9XVTN5kZ1pvvNNRorc7T1Eyo1lVJZmPP0j3MGre0pk7mJ/vG5LoiAY8s+oe81EtaPDtMFT8Vd/wBQnCk9p021BqWo+WdrHBz/APeVaV6WwXb6Rx7QssW92pJOw/SfkQNZJAJU8OentK7FFjKSOnQe0hpxYUcWHBHKmaalaylskBiMZ+JMVy9QtdxZEr6ZztnNbThbQibiSZ6PTU0JZsqYu4HOBx/eWagIBuFacH6gOkpjk+H+F00htTrCAqnKqT1msaVtVYjrWBXnpjtMtpa7UCm76M5BB7Tp6jWitEpqAUAYznrJSORqCNPe6FsIDwPeW06p1at9rYzkL7y59Otjrc6bgei9zM+oW837qwNo6D2jE1qHnuS9rCtTz5Y4ist1SJ/AC4P8x5xAPqCoFpGOhyMcSD2u6mnT17UXqSPqkxrSrV6qbNRcwsZuEHuZjfTaixs6jCg9fidvSUKlKWalRvOQie2e8ya+qpX8r1M+MlQe8I550Ne8WK2VHaR1Aat1KIGr7IJZWQjYBIx/KTLdOrmz+Kh5OI0sPUakLpK0UB7HGSolug0tlVG64iuwnI4yRKadPXRqWVD0+ljzjM13FqnrSslrHXOeuDNDNrqtVapKEsB1JlGhBVhU49fXB7CW6izW1uq2WqNx5WXJo7nzqC21m6cdpBbqlBp4Kq3Y+8w0HUq+FZbD33DOJXfTqTctO7erH7Ym3alVHk1Nl24Zj2gQfxNFYKqAnv6e8tFy31WM7KAq44HQyh6Kq63tsbheg9zOfampaoCj/pFskDvANLp9QNUoFeUJ5+09AE09BXFK7h3+Zz9C50qtdqG4I9Ke5m2pnKrdeNmTwh7xaSL7tMtjeazetu/tM/4pCWrUkqnsepmy6yu1NgGT2xKtPRWl259ox1AHWRpmNgIVSTWGP9TB1ustVKGCfbtDW6mtrCtNZbjg56TNueipTWf4rnLMeeIiU9cKq7VrN5Zj1ld+kL1BrBuYnIHsJWaXuuwTtPXOJ0aSRYXcekrhZUlckgVvtGAwHBlun1RW/cwwVz/WR1So+obA9an+8zFibdioWz1YdohXUtxqPD3erBsR8kTmjUPaCrqRtmrQG6m51sA8sD1cdRL7qKqdO2oUZVn4EUZ9PWUtwy78DJ+O86vn6Zaj5YwwHHuDOT5q+ZuUFWPHXrIafzrNbXtUsAfW3SDWlltpYawFWrY+oCY9Yn8b6cjqPtLdaWq1Dqa2/DWf0wZl/Emmta7T51XRGHUSWGt2i1ZrG3CqGGBx1lGs8PsLtfSh5j0vquUVjO/vPQ0la02OdxA6GJVseaR7Doylw2sDkL7yFdNupH1FSv0/E2+I0123l0Oxsx0NQy7FBZscsJazgqt8oqqdR1YDrL9Zram0mbHGewz0nH1WreosAMY7R6bZVQt+qXczHKqewiQ1Slf4q82tYK605Ln/AIm6vR6fXbhpywGOWPQmLUX06qkVBQFJ4wMR26n8MqVVDGfSPvLpin/StYjmqq84HXngTJqfDzXySW9yZ2dLeaiQx6j1Z7zL4hf55Zal5UdJdLFPhiguKyPWR6YvLrpoutbly3QyvQv5Tebb9ajCiSZWLk2dDyPmPEYaqSzEsh9Uf4YsT6cATbe4XBK7Se8V+a9Ntz62bP8ASPsSOdZpmWzbjiKmkvetYbAYgE+wmy0GytAQeByZb4gDqL9O1dARRUANg+rGZZySzs/2j1dGo1dNemOaqalQEdzjmcxHZeV4zE6MthDqRzL1pZiAzKpPaXyE9AGTuvPXpJgV1jKPknpLKgrfwLBkjpLa9Kj5rHJHGZm1rF+h243MP/xO14cxe9EoYBs+nd7zg6cOj+UwIwf7zu+FrSLlYIWs7fBnn+Xx24PZ6S7XVBV1aqy/7hOkDkZHeZtIjvUrWqF46TQqhRj+05ROXqfaEUc0yIo4QCEISKIQhAIQigOEIoDhFHCCEIQDJhkwhAIQhAIQhKCEIQCHeEJQQhCAQhCAQEI4DhCECfeEIpWRCEUKcICEIIRRmAQEUcgIoQgKOKEBzxv7c2ltTpNPWMsTxPV6646bR23KMlFyPvPB67xg681auyoC+o+kLyGWJutSK9R4a+kwEfdaU3uewExV6h3Za3y3/aOolt3iv4m9QV8tDxjOYrmXTYsoA3k+rI6Tpx0tjn+IUIN7Bgqr1J5mTetYQs4arbxjvNGpV7c88E5P3nPtXaNqqQO4+Z29jlXTq1daV4VQuYaEGy57Gw2M5E5dSN5TEgjHXM6mhpZdPlWPPI+IE3SxrM0Aliegmitb0xb5W0r0BM26VPwukewEPYek5n4wrqD5znBPSRqN1WpY6ZiwG7dn7SVWsrsZrMkKo2+3Mor1hYFDpwUzzjrj7yy3Ti2lV03AB3YPYQLbtS1dTV0MFYjn5nO0viDDUbC554KnpNWo2smKyMovqI7mZaNHXra2FRNOoXlf+6BK8JcxIsKFT1H/ABNNFDagh7GxXX/Oe5mREZfX6bG9h7zZUll9Y8zIKngdoGzUWoiep8A8cdTKLLxVtKIu5+hIk/K/muxk9BDZSKfJt9XqyO+JBhN9gYmwhs9Qe0nVqbrLhVTgsR1I7Sb0VByzDBPQdcSTJata2VriyvpgfXFWLNI+pssd3+qsYyR9Md7IKhTpkO9jl7W6tLNNrC9Nhao1uR6hjqZz/Lt1mpFfrRTx1xIKX015ckumfbM0m8qoQHkd/mV63S16ZiERmIHLHiYadXUlpFhZjGEbnfyWzuJwc8+82nU+bRu04Hnger7e859tmn1CKMFW/wCZRpRXTc4JYMT0zEWnYtjO1vO5fqY95tq8SfT7GZCwPG72ltddKqbXbdkcL7yNaLvJIVscgDosqYtbz9WxvrUBez4xOfex0/qbuf7zU7al7D5NxAHXPAExWIlljb7vMKjO4DHMgmHvak2KgdR1QyVFmXDJhSeq46TDpNfZprn3jNecGbq380N5iBSeUZZRs8qvObiFcHg9jJFK8lmcluwJmN82qqt6gP8ABjRlqrbd6m7H2kVtoVmXjkD5llK04f8Aik4+o9JzKnsatgx2qPY9Zt0+n83QOeV3H05gc/Wayqt81KWUHk46yiy42hTWSARwD7zYpoVHrVQzKOV9zMtGoDvi2vbg8fBg/wDrreHacLUG1DFs/MPENUlKZVQGzwJirut1dwrrJBHTH8ok9dWdOa01RV3c8SwZ6UZbmtvGUPTHfM16SmoU6jUVoVrP0lu5k38qutRsLrjn4mPU6q26raAUqr6YGBCY2qA1fmD/AG7WEz03AVNTcNyAk8mV6XWV2KAG23DqpOMiVatWUm+oZTIz3hI1abRrbrPxABVB1JPAEvfK6zzqV/hHgw05TUUAmzCqPpE1rfRegRQqYk1rCuNVmnaq71hhlMjkTgJXTaF88FADxjoTOr4izpUVaxVGOMHkznV6e2+pXDAAdFxwZdTGnQNWusDsorAHT3mzxJx+Ft1FAy+eJztQi10kn6v92ZZp7zqfD3prIb3kX/jLo6VtBbc72WdcngCdCm/TaJNjBQG4PuYrNL+D8OZhwQM9JytMwttrd0L2MTj2USoPELtNe5CIQD3xKi1d+lrobcdnQgdp3wleoXyatOCQPVYRic0rXptTZSVzkcfeNw+rlXVPpbACT7gy03JbbW93BBGJ0F0dmorKKN/weCJTqvDBXTvuIDdAAeksqWJKR+MQufQDzKvEdG1DtfWxIbpz0mjR6Vn9OoOGC8Ed5VVrGDvp9SN6dAYHK0hsW4W9cHkHvOlZqXKMGUMnWs45Eq16fhyrVDgdIqfEQyGvUqAOoYCWzU8Z3ax3A3HB/wAS+yphpxY4J2cD7TXU+m8s2su9QOMDpKPPs1zmmlP4Q6kyKpqJYjJyG6zbQzVBVNbON2F/7RHodOHvSs42jrOyukWtsq3B7e0zfVjHZpq71K3IOf5gOROTd4f5FxWw8H6WPeek8sY45mLxegWaRSPTtOQYlqdOFqWNBAVcsRjd8SeiuCZyeSMYPvKb+WCht2Opln4RlXNrhEHeX2LG6vNlilcNjridXw8+X4moLbFYelv+6cbSGusg0WdeOZ6bwI6Z3Ol1artPqBbjB+84/I68HsNFqBdQDkFgMGaZy9NqPD6bhUlyBzxgNnM6Y7Z7zlKlhiEISsjMcUMwCEIZhRCKECRigIQDMIo8wCEIQgjihmA4oQgEIQgOEUIDhFCA4QhAIo4YhRCEUBwzDtF7SolCKEotMUISslCOEgIRRwCEUIBCEIBFCEAjhFCqdUiWUNXYf4bD1T5nfp003iFq6WwtWpOM8ZzPdeN6mwaS7ySFRBgse5nz5dXZZa7+ggnDZ7y/HutXqMes3K2VXb3Erq8SZ7F/Ecjv8zqM1W0q6ixG6joRObd4avNtLgoDwpM9GRz1fqdbSa8V4x2EjpqTqEa1gcNMg0bf9V8AdhmbtJqcIFXAIlnTN7WajTn8GK8+sHC8dppqoYIlagYA9UzUPZbryx/lHAzN2GXcvVi3WRVOH9VddnA9z2lVumBINzr6Rky0aT8RbgsyjPqI7Cab9Aq15DYrUcsf5ow1zdOynUelyFAztz1mykpqmwGeu3OJi2quWoA3Z4OYD8QBvwD9oGy3T3aNi1uPgj2k6bazssqQGwdfmO7VltGhcbnXhwe4mDclYJpBKsc9ekmKnqKNmWqJrLn1YnU0rYoT1HgczCrG6jbYwyORLGvXT08nepHIx0gbUAu1Csw/hquTM9LedqWCjYmcE+wlFdmqsxbUpQD/ADNaWCpCzoNzDGIVbY6ABK1TjgvnJMpu8QrqQrQQzgdSOkypUlbpYScHIj8rTjdYX4POPeMNKjUNY284JJ6HtN1NRLi5bdzA8gDpPPPqQjsahjHImrRanWW1ba2RFbvJlJY7WsB1VLUkZLHkzma/wupNMXQ/SOvuZo0j26UNVqW3mw8NNwrDBQhBI5CnnEpXk6bNQh2bGwemRzHqKrq3rZW9T9p3tTS9TeZc4G48fE5g0jHUNbvNueQcysteLG0aOFO5RzL/AAt0asDbgBvXx3jotWzTnbnIXJ7ciQqesgOp2q/X7yNL9VWjqxVgF7Ccd/xNHQI6k9pp8advLSvT+/OJgrvs052sofPX4gq2yullHIO48mXVpXUpWuwnPIX2MyvfphlSmCT/AGjrJLg0uAR7wdL084E7iAD0lu5dvrI+Zmse9+LUVsd1me5iowoPyDIa1i0CwAkBc8TsJq1/DeZuGyrgfJnnlpfyvMsHp7cyaXrZphUSc7s8dow1KrJ1/nKeGOfvLL8Nc3p2knn5ldr11VpWhzax4+JbuNurRLBwowW9zGGtHgRH4i6s8Fe/xJ+L1m3VJbtzgen7SrTFdPfcNwyRz9p1NK9LVOdRgkKdsqo6Rq20/l4HTLTn2HfYwI20g9OmYqzbRqBk5DdB7SnW6a++z0kjnoJBb5WkbPoG5ehzyJRqNUy6byq0GA3pEtr0floDfaiE9c8mY9VX5d2UuDfGOsqMia27Tajd/MTyMcTsVPZcKvLT0E5f4lml8Oo1mnZ7BttrXK/Ji8Edhv01xwCeTLcSa2W0ab8O9rDc38oMq09Fi0+ggjH0niZPEGFGpeqlncLyWPeR0eossuNbthscTOXFl7TvpdyVvYKo9u8v0Pk6Z9wUJX2XuZivuFFhNhLt2lVfiW0k+UCx7mTKts11fEdaLqzUF+o9I6dIip5oAUlcf2nNpItsFpJLk/T7TuEg05A5A6e80mkrmugKv83Uzz/ixuNi21gqiHg56/M7+gerU6G2tj/EXMdOkru8NdnUHA6YknS15+nV6sIrqoDdzLQmq1lqnUMBWOeJVh67GVztQjC8dJvoAppVlZWPdsyoqvW/SXrj1AcgfEtXRU3ObMYYcsuZk1V7hslueu74mzQaii5GpscbyPSekaYVVWnu1Ni2g+TWMge5nO8ToV3/AIYVQOijtNG8aW90uJAcYDexmO6p1sdjaGHb7yxKWj0xu058gkWoeRnGZtfT2V6VaKhsLLvtacyi5ltBV9lo9j1ndp1I12lAcjeD6wP5sReidxHwNRYWQc2KePczu/g7j/J/med0Fz6C5tVVV5j7sFT1xOoP2k0xBZrLEPcMIkRr/DXA4ZcYOP6ziftPca6E0mP4jHJA7CW6v9qkWsppi9rnoTwBOHRqLL7b7tSS1jc5MsmJqnTWY4ZRntmdH8P5y79XbgdgJjprWxyrAgt0+Iqq7TY1buVCHrM3tqNfkVkFaD9PadfQUnU1IgRndenzOZpdlX/TrLseuTPT/s5rqNM+LVCBuhnH5PHTh66Xhv7PUirzNQNtrdPidnRLbShpuJcL0b3EnXqKLCorsDZEu/8AM4xbR94QhNII4oQCOKEAjijgEIoQCOKEAhCEAjijzAMRRwgKOEMwCKOGIBmEIQHCLMMwCEMwhDihCFEIQhDzCEIE44oTaHFCKRBCEIDhFCA4o4oBHCRJ4hT4kWO0ZiL7TjgmU6tytLsp5A4PtJasjzX7S6utNO+lWwGxjkAHpmeP/AMqBnftx8zd4gtz6uyy4gk+3eYhqNUoKqFHvu7zr8cyJzUvpb7jmt9zAc/AmO3z1baQeJq8y6mzzAcbuDgyZxa+c5A7d51YUaJdzF9Ruwp4X3M1ajTmvFy46c49pFHRGYMMA9PiXrqq9nl2eoYxwJRipssRxepyq9M9pvXWItoZmx5ozn2aY1uUA0so2E8fMzalHrbNTA1npntGI9QGHkL5RHqPqI7zP4gG1WoSlrTXSq5J6cTB4XqHKbS3NfOB3mzXKdRQi05IsOWPsJnWsVvqdFVWK6VLAcfeHmEVAovpPJxKdelenwlahsYGZd4dZUVdCPSR79JKTtl/jZYlS1bCV1aa2xwmSB/wJ3PMoSomlBxwQfeYy77/AKNox1EaYkNJ5K4di6HuBLq9L5zqzqQi/SvvM9uouoUFQGz0HaW1+IXrUXvrIHuBjEurjphK6ecEE9pn1LVsCUUPnrz0mFddt3O5Zqj784mC69XYnTs6k9jxJ2Wxt1Lo+nCF9nqG5s9BJ2aKvalleQmBj5Eo0OlTU6WwOc9yT3ktRqytldTcVVjAH+4y2pFWo0aKx8sAA89eYtNpic17gFPK/E3VsttWWT1dd2JW1SG7CsDgRKYha6sVpD5avqw6Zm8uaaRYgLAjgzAukpews25SPnAMpv1rCtqw3pB4EYSq1o13i2qdbSVQHr2Ea0eTd5WmZ2UdWM2eGao26KxFOGJ/vJaaqw6Z0YfxWbr/ALZRRUl25wp9R5ZfiT0qqr2U7fSwwPiZmW7S37lYsy8E+4li602WoNuCTyAO8lVNFsFj11rvPRSZRdW1Vm6zazkYwJ1aLFFVjoP4i9Jmo0qWk6i9h6Dwp7wYwajw1AvmknewzjpiV6LS26oGkYUDvNDJddcxstDLngCWVHySAoGDxjpGmIHwrUadcrZuHwZB1x9XrY9eJ1G1SLUFUFsjqBMwxWfOdcKRx8wrE7FnFDr9XSGmo/DWXK/Ix1PYyuwu93mrlduTKLNVdfqVCgrkcj3jtNdCvToP47L5lh6AdpbpKHZrhZgErkH2MwNqWqIXow/zLE1jcOTyOoHeTs2K1DpY7gEnH947dawqWhW9bdW9p0K6S+lSxBgtyRM2n0dILXX/AO7gSnbbQRUa2tIcqmMzTqrK0pW5eOeROal6PqHA+lf8TbaobSDuGI/pJViaU02ob7F3sg3Bface+t3fzgoyx4GPpE69harUeXWch0+kd5jSwncjVgbuBniNTGyu3Gm2IAWYcmZ/LGnPmnkt295lu1ArGxex55l2mcWkWMc46cyLHV8R0QPhYsUDzSAxnDap67K7K/UpXr8zrWWvqQKdxBb29pzkT8PVcbCwRDgZ9z7SyljnasM9oFvpx1lq6Kq1V2WdpEILF/8AUNgnofeaqqUo2nOABkSs/q/T+HvSoK2Zx04lmr/GJTtRk5HXPSSquVkyr5xJWCi9M22Y46LM723nTmeHPZRqnCtuGMN8mdyjUmpzpnIBsHT2nDaynRELWA1jN6VPaW7NQt5tuU726H2mrElbfGKEqqN5IVV9IXu3zPOad2bUeUSVRjwJ6S6r/VXoDPhKuHHuZRqfDKPOXD4bPCxL0lnbFr0zp02HLVcH7TFXSSBYA2VPIzOnY9T3/hUG5QMFvcyesSvSeHppwQ2pc5BHYRpjHc4fTKzVsWHU5ziaRot+nAQYLDiQZsaVNQRhyMMo7yuoavUq+qos2leNnxBhVeC+WXv1jlUUZAX+YxuxRK2qTyxYcj4Eu0niJtHk3KTYDyD2lepUXa4KLANowFz0lv8A0zofidr41KkMP5h0MhVi3UgGoWIxwx9pd5NmjsC34epu57TXpqq9L4gloO+hxkfBk1JHC1ejNepYoo2Z6Yli11VlX3FT3BE6HiDg3NYo6mZvw7/h2tI3BeeY3TE1eldrKoDHp8yWv0hLrcDgOMjA6mUaQ+bqlR8bQPTNmttOyunONo9Mni/jn17xaNpPBx956LQlzZWBWjt3VjjM5DVtS6WEcCdfw3y7bwLTsY8jPecvkvTpw9ew8OdXTym0xosQcAjOZ0R06zFpMMlTDJwMAzbmcYt9OKEJpk4RcwgOEUIBCEIDhFCA8wihAI8xQgPMcjCBKEjCA4RRyAzDMIQCOKOARRxSghmEIDzDMIQghFCBKEIQJ94Q7xTTIhCEAhCOAoQhAIZhCASNhARvfHElIMoPxiSrGVFO1bASQR1kNYwNJyQFAyeZK3T6hSTp7Ayk/Sw6TkeONqdNofN1CgqTtO09Zn9bed8Xsqu1WKOoGW+ZxLv4hGWByZ2fINoFla4Df4lTeGktuZ61UcseJ6OE6Y5OammcKWsYMcekY6SFOltF/BPTJYzpvZXU2SQtY+lccsZZU7WfwyASxzke06MOTqtPtVXcnbZwo7mXU6PQ+WAzFLCOPV1mnVqlmry4O1BgfMxavRmphZg9cjnpKHd4cVTctgf59po01Fb0GqxAH/lbPBkdIzGzPuv0/EuZMhkrUBu3PBkHGsF2h1YZVOAefmderWU+Wl1R2qx9dZP05mXXNdQq+dXuQjqR0M57q71m6pSFb6o9PHc8Rr8ykGsjaRx8zJp7FqpFY4bv7mPS6lXqWq4k0twD/tMos0t6X767Utqz9W4A/wBpMXW3Fg0rGo5zzJaTxErYouAZc88dIKrVaVGzhi3P2mDXA03Nah4J5ki16N69O1XmLWGyOdpmVnQqyu5Cjnk5E51N9wQWaZspj1LnpNWn0Oo1Z3bdtR6k8R4vqoWWalzTpa1ZQcbiMBZK7RvUFOouqb4UYm1wmmoFNe3/ALiO859mnZ62ssITJxgnqJdZxtotWtVrCABhnpOdr7gWf+FlD/mdHRVZ0aPeeU43e4k9WuiFaip1YkZxH6fji+H6mx2alCWXsJsY2U272A2e2JnGntpdrvJNag+kg9ZfX4gbXCWoMZ5OJaNNoF9Itrsx/wBo7zF5NbndqCN5/lHea6hWlhRMhAfTzKNSx80sAF+cdIlLFFgOhIes5rPJHtNlGsZ9uoBA9pj8vzq2JYgY4+ZbpiPKFQxgfUPeSkaNTdTeM2IUY9xMlWmCP5m7GDkEnOZVb5iMxryax6iDziWUOlpJsO304K+8YtaKrzVqdyEMpHI+Jdc2msVVLlAxzwZxfPevdWgB3Hj4mqlS1W4nheo9ow1qu1Wk0dPk6dg7E8mQSssEssyQeQJDU+Gq71WVDC9Wmp7qlfZwopHHzJghqNa9a4wqAdMCTV0bRi60+Y7fQOmJgsK61gASdx5HtNdJq8xqrGC1qMAe8H6CjPpirgFicnAxgTC6qLFcY44nR1Grp8v8PpUO3+b3PzMWxXQqg/6Z+r3M1EqjUVfinyn1gASGn01q6hKHH1NyfYTdSlZ9ROCOQfeSU+fqlbOM9eOkauOnYy1C1UxtxgTkXODk55zOlfWbW8lTgY6zE2lpo5d93POJmLSSlVr8xRkkc/MsTUiuvy7PoI6Z6TONUVYpTWQG9IJ7SrUVDTV7biWY9Jc1NxotuY6um9SRs6TZqbBYyOAAbDgnE5zYNKWA9RkibdQw8nTNUAwHWTDWPU6ctqPJI4UcmSsuGmwlajIHE3UbdRqHVuDt6+8y+LULVfWAMlkz/SMVZ4ba6XG+1ssRj7ToWVJrnrOMohzt95xtO4CIScFu03pqLEXy6OpOMyCn8LY2sd7q/T2HYCLUGrb5DN6nP9pp1FOrFYzcScYExLSKbVst/iOOglMV6m4aYhakICjlusrq8RJJFYBbHXE3JWL9SWs+lxyJDS6Kk3mpCPSck/EsiXpzU0Oov1PmHkg5JnoK9Wh0/wDFAbZMra4qz06ejgcBuuZz2dq67Ws9JPQZl9R0PCnK13EH6yWH2j3uWt1N49RGEX2B7zF4feFpARsY7/E6Ibzq2CkZcfVM1YyaYUo+8KSTzuM06PTrcbdbq8Ko4XJ7TG7W1jarIQD9JEua+zVVhAAtSDJX3gRsVbVbjYg+n5k9DbXp1ZRjBHPE5+s1ToOCCw/xK9I192bLDhF/zLi2xptRfNtsVhvbsOMS46PztMHrrJv/AJfec1tQadQ7MMBunzOjpNTdcMI2yv3HWLEXa9mXQ10WsPNH1d5m0tzlWqbnZ0PxKtX5dVpLMS7dFJkaxqWQ+YgrTqT7yXwl7dGjyX038YjcSZXXYKNCaLMHzHPJ7CZxucr5f0AcH5lxrF2nCnO4HH9pGliaRdLSWADbuh9jK9aAUQk7mUdI/MdakRs4PB74jCZCM/PqwftJSTovNWzRgsMqp5E36ALdttp+peqnuJgKIbLKaiAoP95u8H0b3WmssEPYk4zOfPxvg9t4Y4fTggdeg9punL8OS3SqKrGFtX+8DoZ1Jy4nL04RRysjMUcUAhCEB5hCKA4RZhAI8xQgPMBFCA4RQgOEUeYBHFDMBwihmA4oZEMwCORjzAcUMxQHCKOARyMeYE4SOYSotPWEO8U0yIRwgKEIQHFCKFMRQhIHIn3hCVUWYqMzjeLaqkqdLqFVg3IWafFdYdOyoP51OG9jPI5sc77QWtz1B4MSfarvR3UW5NrELV0CqZUK6awdquXPTdN+lJtybVHo4A9pqs0pCixl3E9CeMTvIxa81ray7CvyyWPM36BF8o+YMOi4Bl+tNe7KglzwOO0VdToN4J2qM8jrNRHM16ladwPU9u0zV6p7K9uoAYAf4mnxBjb6lPJ/lxiZ6wKtOW1QCnPCwMNupNVmVO3b0x/xLW1lVyjLFG+O8ts0Ys0fnBfrPA+Zy007I5Ungde2I9R2tNqq76zptQQ3dWPb/wC8pdUqUqrZYfHBnNRzWxas4x/mXrqg43A4I6qY7N1Cu7y9w2gc8p7zQp072bnodT3YkiZGCMoasAMD0zN2mP4nQ2rZw6cj4xFWNO/z681fUvRfcTJrKtyHOcFf8yPhmosW0kjKrwymdZnrtBGwGthysxOms6cPw2w0M9zHCqORjqZtXxO/WEKmV54RZB/DsWMotKofpJ7Tp6PT6LQ15GoRrGHPvNWsyVbp9Lmom05fGSPac3WI9tuLGwo6KOJtv8VTTIRUoZ343GZ9BTbq2e60deFkarVp2RdJ5CNlQOd3aZU0SPfhW27TnrKmots1LV5IRDnM6gTThFsewFgvbvGmM1lz6i9tKqHcO/tKrfBrtOocWb7e4Eu0urrGqZwDtHU+8tu8SCVWalxxnaiypZHN3stqh/SwHWWXMbCFC8tx95T+I/FIWZDuY5G3nEqKanhFBIH+Iw1bvepfIQd+c9pBrKdOVU5OTyZoo87UZUhfSOWxM2p0yISLGyDCNWmtptQrkbWPq9xMz6RlsNtPQtyPiQpIXhPUPbvNejZGO12IYHv3gY/wTNcq4IBOZfVuo1O25coR/edXVBDyBhiuAR0nLR7bbWovIKkfV0xBjbXvrUBWD0vwpmXX1LY6Up9YGW+ZQhu0NZxnarYI6j7y/T3IlqalzuDna3xGLF9K1afS4QDc4InOel2s3gZInQ1KrXuPb+QyqlPNLICV3rkfeQrNZdXptORV6r7Dgn2iua4UivaEBHq+cyWjqFGtxYu5hyufeWXpbdqRWpyF5Y/MqFQgatT2E6a10ppiFA3YyTMN4SquusN6ifVj2kNWbHqrSo7Qw9QEnbUXV6gIqtkkngfMxeIEg7g2Mc4ELmaphUgO8en7COjSC2826mwmsdh3ln/UtSrFZVGdyWYZGJpdfPpZnUADpnuJoqr01ZFjVhFPCL3P3g1DNqFS/C09SBxGmOTctj1eXSQvvnvK6mu0iFbGyO06muoprCbMHcenxOfqsW3ekZVRiXUXG06Zk1CZNbfViaL7fPRbM5ZenyJzlNlSHJO3sMZjpuNYw+cP1HtJqrDUQ3mq+5R0+JpoLA8g5xn7S3R10FCFBbPvK/ENulPl6cl2PLH2maqdup1TDYmNo/xMVlOtH8d2yBwJq0HmXfUvGevvOj4hbp/wZpQgFev3mojmJYlJDD6nHTPQmbtDQ7UWsfSx4B+DOVVp21d1dqAqpPPwJ1bdWBclVZHlngkd5TFlFVVLBW7EHPvOL4rpn1HihRARWOk6+rVyTYowo6TNXctqkpyxOAZJ0WOPRVbpiyEFsHBHtOtRYU0hLDaVfAPxLrtI2E1Q45AcYltaVG/eRurxwvvF7I5etc6bZYwyHPBma3UVqmUyGbrg9po15OpdkUgJnAX2mKmgfia67GHJxLiWnXo2fFj5Oeg9pfaTYU0lJ2qnLYnR1NYRNlZG7oJybc0aoquckHJgLXUFivqyo6Ca9GyU21B2wv8At9zKK0s1LhcYVRnPuYsO9LkLl6zxH5hBrdv4myy0E7myvwJnBsvwPMYV56e86u2nW0KS3lsB0MDpPLAKAFugPsJNxcSoxpq9rL26ntIVWPYXc+n/AG/JlVw/ibd5YAcxXago1VaAbepPvM+q0rYLDtfNbjr8y1OAVtbIPSUqBfyvXvLNu2jnnb295m3Woic1XZKh1bo06Wg2XWqASjZ7znaSltQ6KvB/4nd8Kr/D2nS66ncGyVYTl8lmN8Y9RpRYlaqTuUDntias9pj0JIpwTu2nAPxNcxEvpwzFCVDzHmRjgGYQigPMMxQgOGYQgEMwzFAcIo4CjzCEAhCHMAhCEAzCEIBiEI4BCGIQCEI8QFCPEMQhRd5LERgOEOYSi3vCLMJpk4RRZgShI5hIpxQigOEISBxZ6n2EUi+SuB3jVeS/anWtdqKdMh2VqfU3czm+H3B7XUAjHTnOZ2P2k0oDJeV47zzdht01vmUkFRyJ04wtdoXqpJABA5H3kTrLLcKS2CeB8TmV3m1Tk5bGcCX6YnB1D53AcTrGK0q5e5rCMlR09hMuos1NlgZWO0dVHtHRdY9xYYweGHxLK0xZjcd4PHyJpGL8USSGQMi9DjmcvVXPq23pWxC9Bid59FUWsCn0udx56Sj8MxUhAFGPq7Ae0qM7Bv8AS6sDDDkiYGNdi4LD5myiytS+kubhshSe04Oqrs017JYDtzwfcRILdR5SDKLzMRdmOM4Yma6mWxcY6djKnrKksVznt7SzpCTeLlzzg54nVqcVb2H82cj2mWhFUGwqF2jI+ZR+L+oHqeJmzVnTVpWNltilcYBIIli6vyhgtx3+DI6UeTp2LnBYcSi1lShRwSTyfeTNrUro06prUK4DAdSZBn0lTGxzljKqdygoowAMj5zKtQlZQF+/SSel8SOpTUsAowAZ6zRGqjSsSAdq8fBnk/D9KTYHbCoD37zsavUGnTotY6kk4MtONWsRXUdx/iWtk/Akfw6MmHYKAc4zOa+qsurLAHeTz8Sq+21BsHOBJi61WhncLpyACfUVEpNFmruXSFyQGyeO0s8NNmnPnWn+E3JE7Z09FZXXUEFLV5x2MQ9VU0Joa9tSA46tjpMr6gPY9YOGtGNw7S2/UFanrwTu6EdpiRQXWxV5UZlRO3U1aOsVKQCi8/J+ZzC11rFlKtu6S1qfM1Btzu3HBHtNv4NLAq1kK3aVHNposa5azlGJwTnpLNa1lGabEJUH/qdMy0qyWlb+QDjMRsu8vdqALaAcHMBUau1UAc7kB4yZqa0EhkUOjDGD2lKVVldtY3VNyD3WRes1MFsJGDkEe0CIZ7QdM7FGHUN3EzBh5boRjGcfM6GoRtZtuqAyOMHjcPvMxpQM4cHbtPEGKtLq7BUpty6A4wZJtTYX31cKDwZWGN6qlahK14we8ZanTgICXc9T7SVd6bBeK6zfbzZjgSfhz7U32nA+pszlbS9wZXbk95ddbZYgqXIBPqPxA10aqprr9QVBwdqD2ktOWfUIX7nJPtMlCqtRGOAf7y5XIrYqOZKsWXqW1rlD1PJ9hL0srpX0rn568yg3qrgKm4nrL9O7WvuFQ47dAJm6pKrFhbaCXJ9K+0s1OoVQgssy5HCDmVW6g12MVO6w9DIaY11qSwDWucsfaWFS0wezLajhnHpz2lK50lrA1iwfJmzVELSHKZH/ABOPfrGvR8jAHHE1jGttl9NjZChSO2ZSyktkBf7zmIHZlC5E6dFDowa0nHYRZhK36TzVXJwqDv7ybsCCtVQsY9T0H95nsPmWoucV45xNWnJsYpUMKOJI0YY1VKcBmJ4A4AhpRSzW6nV/9NegPcznavUW6e7YxHpPtDXalba0WogBhyB7yos1HiD32EaakLWOmO8s0VRZ2a0YZVyB7Svwo1+eAccczpeI0iygtpzh0647iQjBq9RdqLDolYhAPW3vKtOt1Db6l3qhwVl+lRtyu4BDdeOhmttM+luBX6bDLRLzgyiwkmsjke3xKHua3KVViqvu3xLNTtCeVVwxOSJitqtZStjlFPXtI0o1rCur+EAR246zFpKbdRqFYIVx0mnUXZAWoYVBgcdYV6ldLRlCWtcd+00x+tRcVXhi2cHqT3mXWUPZcNRUfUD095mIt1RYsSNv0/Bmnw25vM8nUNyDxmPxWrSXIBg4Vjwc8YmirT/xjYMbW9pRq9Ihs54J6fMypbqvD7uhNf8AtPaZXpbfpG3kZK4OfvHqbLAFwCoPQiazrKtVwQFOO0hqL96KgQYQ8fMi45ihzV6QSA3qImpwt+lHAG3vDR76tW5HR/5T0m9qFbT2FF2k9hLUnqrRacik2M3UcfMg5dxtr7Hn5i8M1YRG0WpOA30MYPuW1hjDA4x7zFla1r8MvWrVK1gwqt6viewaum2zS2adg3q7HsZ4nTkm0FlySeRjrPceGaWlUr1FIK8coe04c/XSeOjXUtY2r0kgBmOERiiGIQgEMQhAIcwhAIQhAIo4QCGIQgGIYhCAQjhAUI4QFHCEBxcQhCHCEIBxCEIBCGYQCEIQDMIQ9oEoQhKJRRxYmkEO8OISAhCEKIo4pEOEUMwCI9Y4oVzPHqhZ4c/GcczxNlFgQNSwsDDO2e48bz/p7hAWY9AJ5pdLTqtMDTctdh4as8DMTl9a1mxw67hprV82orjpz0m5tTXajBSUJE5WsrtGrZLSWCHr1zLFAzitgVI79p6eN6crGvTo63E8MOnXrLbLfLtAAOB05mKup0OVOfscyVy6izDpn09sdZUWNc+9q8npzz1m/cBTXTnhhkzjkkMHf0tkDHvN1bCu9Gc5IWVKz6nw9GDapmbKfSfeYG1DX1GuxATnvO14k4elAoOG6DM4WpYVelcc9RASaP8AmVT/AE7RlU+lwTjvIVa8pgAECO7ULZ19J+0VYRKA7ewmRqUVy4bPcCSvDD1KcjEz4sc8g8SxKk15c4zx2i3mwhW4VZbXp0Y7iSBL666gcKu7iLZBKnUFm+kjIx0kNS23AYjgyVtpT0V4UnqcdJSmlsckuCc98ySQt6SS1h6txwOg95a17OylmIYcj5lYpsVNm08dDAIOA2Qyn2i4TWvT3Cw7LODnhgOsv1VYLLtVsEdZfRpFTw7zrht38gHtMq32la9PzljwO8irq1NlX4e8hXHQjvOloa2XR21K2R2mHWUb7K0ThqxkzTSzpoPOQEv1K/HvI1JiNdqXfwXGywdT7iU3udPaqsdu7oYFVtt8yhgSRlZPV1G6hcj1Ac/EqVWoq/E+kYY9V9/n7TJrilZNaXHzF5AzL681+XYxBKcfcTl2Yu1JO7aWb+0qa6mm1NWtq8rUAJYOh9zIWaeypRRaSaWPpPsYPQn4ZbQp3KcMZLT6tjaKNSM1MMhvYyCkVW6NiyAsp6/EKribB5o6HgdRNiaraCzEMhO3+ksurrUJZWAVbtGrIzVV534b+A5yB3UzTZotc1WRR5oXoV6gSlNMPN8yosVY4x7Gel8OU+aqbHrv2jDqeHE58+WNyPHNptRWGZqyqA45EzuER/UDk9p9Sr0tGt0z1aikK4OG46med/aD9nq00FlowjV8g+4mOPy9reLxLh3OKwQJdUxQgOek1nRXU6YX2VkIehPeYNQC7YAx7ztOU5MWWNSsjg1llGemDLASNA74ClWwROdXTkhSxUe812FBWKgzEe0tmJqOpYV31FDww9+s2W6h1U+Y2ysDgD+aZ0oS2pGuJxX9IHeFvl2jyicY6ZiyLpVXeaCw4HbEaaitTtXJY/1zKN6U1+XsP2gNelGBVSNwHU8xia67pWmm8zV284yqe05Sql1mcha/+Zg1GpuvYtYSc9pBbmUATX1rN5R36bKKxivy93yI2JsDMcgdB2mLS2Ls34AYdyMy6zVZYG1wQBxjiZabF201KD6j7mavB7EDM9oABbicTzbbr9o6dhNFX4hLv4isuOftJaRr1FAv1eoS1eG+k+087fTbTea2PIOBPTI5XT6l7DyR6c9pw2P4vU1HB4ABPvNcali/Q021Y1DH0j6sdp29JqFscXUnd5YAZfcSXh+jDVlXGVYbSMTkaNbNN4hdpquQTj+knp47GsK6a0lAPLfkfBP/AOYxcXrr83GQc/YRahqnxWTuRV4Pu051dr2XWHoBJWo6T+UlxuZht7fJlXiNtVNBYpvtccD2mSsm7VKS4CVnPPQx+I62kArSu4jqx7wvTmILLWKnAYnP2ldtO+59hO5RgGTVrKytrnG888SdvmLrGtrAGwdD3E1GKekKgEOvXqJB6lqPryaifS3cS7TK1zk7NuOs1VUqtOpS3JWsZBxJqyMxtd1REuDgf7uo/rNt26/RLW2PM9zMGipptbdS2XQ5A9xNVyvqNS4UlDjhZFjNXTZpjvZc46yFVlvmO5Byegl+nS8XbLDkHjBMlY1aahl5wvQ+8hmlSGe2tyTk8TqcpvrHQrx95UiUWqrqwV16D3lXiOq/D2JZnJHUfEm701Iy8agurpyo6gdDGi3MMuSWHQ+8vS2m1PN25VhziSpCMQaCfjPeZtxZ66Xh2kGo0D3H0vWePmez0SFNLXuGGKgkTlfs9UjaXcyEHdkgjpO5z7zh7WuV6OEUJWDMIQgGIYjzFmAd4QhAUcIQCEIQCEUIDwIYEWYZgOEIQCEOIQCEIQDEeIsx5lBCLrCA4oQgEIQgOKEMwCEOsD1gSzCLMIFkUITSAwjigEIGKQOEISKRhCEIIZhCBTcnmKVx1nlfG9ENMG1NSFRj1qeMz1xPH2nC/am3Hh7J5eQ3O49pLO25XgbmIUuSST7yAuNgAU+peo94PYCpQ9uglFf8N8lS09UnTlb236Vme3AUrxzjp/abfxBXADYxkGZtFqgtmGQDH+Zo1mkKv5lBDI4yD7TbLHrMhN5554MtqJs8mxTlGXkSVOnLq/mj0gdPeUaTzKSCw/hkkL/WSqvtt2m61jlKxhV+JyLt2odSOAe06bhXU1txnrJJp61QlcZA6wY49lAQ/wD8cSauuzbtyR3l94PDYyBK/NrwVUcwilqgeQSJPitOCDIckk9u8bINvpx8wBW81sKoCjqZc9iVqK6wAx6mYGuNY2r/AF+YlL2EsMggR9SVawL2EAZJmm25qFRVI3DrMa3eXwPq7t7S2r+NnJ9XaMRZ+MtDDuD1+Je+oDqoZS2OjY6TK2mtT6wcdciatAl+ptWioHbnlscAfeLizVniuvs1KVaekEBRzgdTNOjRNEg1Wox5hHpXrLNUuk0QKVkWWj6mHOZxNRrb3t3OOB9IMSau471Nj+TddZg3PyF/2iYtNfqa/EPNJJA6r2ImPw++59TucnPuZ2tRS1SUausAr0ZcdZLMX1TdpjXqGelsIfWMHpmSe4tyfqA5+ZDW6hW2JpmBW0dB1HxM7WsgRXIDGBHU3GtQ7DIPX4kdSiWaSq6pcj+bHUS12qcnpkjmS0+1UzXnaTyJdZPQ2glq2bcjjIz2MFrFgeoALcD6f+4SnXU+RqlspPoODLLw9ro9IJ/3YkVnDtpmIur3Bjyp7TVS6mtUD7UJ6e0ktI16+XZg7Oj+0xtptRSxVzmv/mFdCnUX6ez0kbgCVOODmdPwzxrV0EOyK56EEYwJx0L11A5DID/UTWzpQUIbcj9f+0zHKNSvc+G6zT61GtoJ3fzIeqmWeIUDVVpp2GVYgt9hPM+Bata9WGHpUjGfeetR1sUOrA/acLG3I/afQG7wZhQgzUM4A9p8+NGVax/Tj/mfWiAylWAwRyPeea8S/Zjz7Q2nYKjHO3HQ+8vHlhZrxB0wCC4bvviRVNzZb+pn0vTeGVtoDptZRXuAwCB1+Z49PAdQ+o1FAIWyvOFb+YTc+TfU+s1xbbML1xjoPeCUhh5rYHHGTJ30hLP4o2sp+nPSUvh3284HbM6TxmxNtjjC5dviIKlC/wATYM/GcSQwi5YhB7CZL99pxWuAf8yxmxO3UUONqIWbPGBjMqPh2pb1+UQWPAnX8N0NGjr/ABOrIz2zJWeINe5NNZFfuR1m/tniY5vkNSn8RvV2UStKsEvYSz9h7TVctgzZYuz/AGg9TIaL/wCIDv0B5EmmNGk0N9reY2a0zkGd0aejUoEe4F8csDtI/wDvMut0upsYGjJyeFzwPmU1+G6ik77dXRg9VzMNRDxAU6crpNPvZSfUx5yZUdGNNiwDpyZuW3S1nLsHZeQvXMwazUW6h2pqUqX7+w9pYV1LddXRSbq2GGUED/unl7NRcLjZuIexucTo6bSWuhFrHanQe5mmnQU0KLdQNz59K+81uJibuU0qFlIYrwPeUOWo0qo3/Ufoo5MidRbqtWwC7VTj7S4MlZ4O609XPOBM4MTV2KuxjyeoBkGJexayPSOpx1ll9+RvTGxOh9zHWQUG8fV0aUvbL4neGKV1/SkvVxZWjr9XQj3lGvqWqnqCzHj7TTpKhb4cHHDoePma/GY0VstJIrJJYjiPU6s26qyhBgEAMMdYbPMrW5B6yOce8p0yeT4ijXH6+uZiNUaUV06tWQbSDj2moVFdQ+pclVJyvyZh8QqYaxraQdp6SA11oVUZtyZ/tLhGpXs/EuzLg579o9SyDnALEdZWSL2Ugk46mU61wgWteMc5mf1r8a9PqBXtIAI7zP4hcjkZ5UzPp7GZ5peoOwwOD1HtJ5T8Q05KD+CcZ7Tt/s/UurtsrtUjb0x2M5PleUyk8dcD3nsP2T0wYXapl4bAHHUznz5bG+Mx6DRVeTp0QgZA5+ZfntIDAEeZyhUswzFmGZUPMMyOYZgSzDMjmGYEswzI5hmDEswzIboZgxPMM/MhmPMaYlmEhmPdAlmGZDdDdAnmGZDdDdBieY8yvdDdBizMMyvdDdBizMMyvdDMGJ5hmQ3Q3QYszDMr3Q3QYnmGZDdDdBieYZle6PdJpizMWZDdDdLpiyEhuhCY0xRmKbQQgYQCEIpA4sQhCiEISIIjHFAizBFJYzzX7SaqtNIRdnLH0c9J3r2JJAGfaeR/a2jK1jzRyckGT2tTqPOX6WtlBydx6H3lNVbDgEfMle9q11o3KoeCO8BUbGDVN91npkrFxtqRUVS4UrNLXGsfwbDs+cYEq05XA/ElQvbPSaC1JfConPses0yZvqVBvA5HUSvW3VPQmxRx9IEi9SLyudp/lMQrsrVnsqXaOhHOZdGe5FsqDLkOO3vJaYFSD2YciW1MliFumO2JZ5aPX6T6s9RCxnapQLcYIxzx0nEurKWAMCCehzO5aj1EhssrDn7zm31ixWU8jtntGpjMuduMYwP7xNnbhTz3miineuFOMe8osptUkLBjO6Mxzt6GaayuAMQpyresdeuYPUVbKn0y6hulLnOP6yt1ZbQ1QIEkqNuKwVb6nCgbs+8g006mw+jYWBPII6zq2tXVWoewU1kehF7n7zk0XahdSgf05PTE2aurzPUoz6sMp7SVYjY1Z9NRGWPLRlPDtOm65vMPf5M0tpwmnVgEUY445mfSaWt7m1OpYNVV0HYmIJUobNjV07fMbjjHE6d9gtB0wIWsjaW9vmYPxF1+oW1QfLBx6RxKdRqRQHttIyScCN7VfboqNJRis5Ochj3nM1TKCAibgeS2cx6dtV4tYVssIqXqB2EuvOl0VflVAuenvzLiazLnaW2Z+BLkJFY8s/dZnp1SoxYDJPb2iNzNdlR15CyYa0lbL68sfSh5+JvOns09avUwZSBn7TGp26G8nJdzgD2mqguPDMhs7RkH2MLEAELmyljWx647yS6hqcDUqME5UiV3oGqTUqNgfG4jpmSCr6Gf+JWeCMQNFfkWXG+nqRzUekzra1Ooeu2v+E59II6STU+ReNmdjD0tmW+aRivUruU9D7SVRV5iOK0yVJ4IPSel8NOr0d9VbuXrc+o+04Xh+adXvsUPWCML7T1Xn6bVW1rWrAryxxjj7Tz8/XSTp18jt0MOJFSCo2tkdo84mUP2lV2npvINiAsOjdDiWwP2imvP+IfspotT66GNVhOSSc5nJ1P7IX1VbtOfOfvzPbQz8yy2GvlOp0dmn1DUunrX6u+ItPQFt32AsFPAAnv/ABPw3S/htRatf8RzuJHXM5+n0broLLdLSm8rnLd5ufIfXXlNWamxbqCSi/Sg6CJvE9PSgFagNjJyM4+Jv1Xhl76ZLwufM52KOAZjX9lvFNQjXrp1VFGcE9ftOvHnKzeNc6i2zV3W22knjge0rWzZTYyn1E5/pN2lot03n1XVlHYYAaRXwzojscD6pvZWMsdFtU13hlNasVduXbPUTPqtM9tKvXllA6SdemZX3OyrWowFBmrG3RkuSqMcAf7pjWpGHSVV6WouU8289D2WT0On1A1nnasbVfoJu0NdaVWarUEKq/T/ANswPrH1WrTU420Vt6B7zSNmlZRqrqmHTp94X2KniCBz07e0xax7dPrqtSn87c+xmrUJXYLrEO61sbZF1yNTqvKttWodGOT94tEH1lNig4tx6T7/ABOjrtDXp9GGtwbnHCzHoKWpcNYCuzv7zXTOVjostrNiW15A6qe0s0Wpak7eCp/lPM1a31WLfTgufrUd5nvpV1XUUjbzh19jF7I63+nVayjzCu3jjHaZaAKf4KkAZ/vOh4Pcy0lG+kDicfWlDe+c7SxII7GSLXZ0YWlWD468faYfEAb7ltRcFegi0t7HaHcWIR1zOkunqasIT6f5W9plqTXMKu3roPP8yN0lbaCxst5eCTzOhZVa+atoVl6f9wlTLqNMwJ3EYwRGmKPLNKhOmZn1Sh0ZyMlRzOhd/Er9JGRyJmXDWNUwxvEkva3xytJZguxOM/4m/SXbnOR/X7TG1RosZGAwDxNmjrcEkDIPSXnlTj69P/pX41tPapBDdcDoJ6rT0V6ahaaVCqoxx3nB/Z3VqyFGAXB6T0KkEZzPJtdeXSUJHMJWIeTHkyMIXDzDMUUIlmGZGELiWYZkcxZhcSzDMjmGYEswzIZhmQTzDMhDMInuhukMwzBiWYZkMx5jRLdDMjmKNVPMWZGGY0S3Q3SMJNEt0N0jFmXRPdDdIZhmNMT3GG4yEMxpie4xZMhmG6QxPdDcZDdETGmLdxhK8wl0x0jHEYTq5iEIQCIwzCQEIQlBmEUcyCRY8E+0cR6YiqysDuXHUieI/atlu8RWtbBisY+89rqHNYLD+UT5zrMW6m4Of4hb0n3l4Ttb4zODXgPyh7wWjFgYH0N3jqc2F6XU7gOkKW8xGRj8fYzvGEzW6nybCtiMOFPYzF5rK7VMpVgeDNq29EcDcBgGQVVfKufWp4OJtlGjXhW2sTj2M6lWvXy9o4z0mMaStx9IDHpLK6WpG103DsZMA2sr8wZGc9cCK24ZxSSuevzKr6lZTtOJWikqS3UDiS1qLd+oJB4ZR7mSsqWzL/zdh7zOpLAY79RFym4qT04mdXFTMUY/J5EqXUM1u08KO0s1I749Q5+8zPjiwdCMGbkZqwMrucjC54MtpdQ2xjlTxMJfHHPtLKUbzOM4EuI021urgY9IP95dXuGCefmRWwBSHPXoJbp70Bau0elhwfaTVadTSWqrurG4p1HtLfTdR5g4ZcbllJsNaFVJYY//AHRValRYrjjIww9xFTFeqdnr821ztxgD2lVObtFXTyKgxawj2k9fUxs2KMjHpE16Za9NpdrkZPJiXoxhv1GtYqakNWmU4Vekp19b6hatvL49SjnmbbbkvIrU2tnofYToVfhNDpfTVusb6R3MblXGTwekafTOrjDMZBdILtb5IOSeSfYS3UFy6KB6m6KPeWeWdFapZw1zjkf7ZN7LGHxLS6fTsqVJ6jMIxp86gjcRwJptvZvEfWevGZNq6mX8PZ78Y7zUZW+E1tahNnqVxz8S4EVLZUwJUHBHxJeH2LU66dcYRePvK/ELxp9WjhTtccn3kani2itG0zabfuqcZR/YzDRZboy1V67q89fabNOqWBjS+3dzt9z/AOIFxeWrddtq9QRILK7EakgkFOoPtFRZXqFapjnP0n2mHSsKtWaLvpbpNH4Y6e8lThT6hJVaaGupyApcJ1OO09DoKw9deqpvLN0OTyv/AOJyvDsHUoCxUOOfY/0nQt050viNaj0C/htvSef5L27cfHodP5wrw4Xr27S4HIlarhQCegx95MHEzGalCRzDMqJZiMWYZgJgCCCM5HMoqoWkkAeky/rFmTpVH4WpbdyDAPVe2Zf06doZkXcKCe/tIOB+0+kOoKXV1jFJyzdMzh6ml/ILjHqPJHaek8RW6xcuuypcsQT9U4guby3rur2o4JXHYTpw5Ljn6XyqQ+2vey9WJ6SPiNzDbaw3Js9AEn4YAmnv09zAm7kGUUMEFlDeuvtnsZ3jnWe66y/wlUHG5+RmaatMBpkpB9XaUV17uxKKckfM6FVtVuha1CBZWTj+k0y537QahVq09FbZsUer4i8N1o0miNti7rCcAHvmWaqivxFxZSB5m3kyOh06ahhXYDleglmYzW/TadtTbXqdSxZ2J4/2zP4xYRlaeVXqBOvWF02kdmwccKB3lWk0ebWNmCzJuIIkacXwTSM+qW2zIRhzLtWKl1T119DwR8zoVVrVprTX6VVsic3UhNRpzrKWw4JFqwLPP8lHVPqUdplSgW1Zs6np8mRTUpYE6ZHWWWbXq27iozkOOxliVzb6n09m5Ay46j2m3Ra61ayjHeh6fEb3MFxqUB/717x0ppSdyOVJ/tJWpK1X6y10Hl53DnM06LxDzKwt4DcYORK6hU3YZHf3krdCN3mVHBPX4nNrC1GnFeoDVsdrDInP1VxV1ZGGQZ0LA66QG366yduO4M5l9YscHtjmWFWFK9bUbFH8VeonoP2V0Qssdrk3VgAqSODON4SUq1G0gFH9LA9wZ6vw/wAN1Xh1yrRYH0zHcAeonL5OX43xnTot4bpt++tdje4mutdi4zmMHviOci9nmGZHEIDzDJiigPMMxQkDyYZihAcIswgEfaRhAeYZkYcQJZizFCFPMIoswJQzIxyAzDMUIDzDMjCA8wzFCUS3RZzI5ikXE8xZkYZgSJizIxcyaYnmGZDJi3GVcTzDPzIZhILMwkYSo68WZEnmRzO2uKZMWZHMWZNXE8wzIZMMwLMxZzIZhmBOGZDMWYFmYGV7ot3BgQuA3cjg8GeG/aDwxqbDYq+gngjtPcnDLgzBrNONjsyh6wPUD2EzuVqPnSsy2hiDkcDjrLbkSqwMOPM5m296DeSo2oD6RMerZbSuw9J65/rrlUmpDOMnk4wYrKjW44LY6y6kc13EelR0l6KLTjuRmWINMEC5JB+/eWay9qAON1bDg46SvU1EVBlxvX2lDWXKgKkFGHQjOJRAFbGyCD8RONqkY9J6H2lNt5zyo/oMToaOttbX5FeAo9RYznyuNcXOVCMEgyWVACkbjNWryhNa4wvUzEcKDZY309PmTjdb5Yy+IWlbq1BGV6zPdYFUIB8mV2v5tjOc8mPZlwSwCkcmdpHJPTlHbDCWX3tW+1RhfeUmxKeFy3sZdTqVtYVvUGzGERQm0Bj0E0gZTGOkatQp2qcEdpAv2VePeYtXDW914J4HSSFisSRxg8ylgQu0DJMW0qMY5I5iq7CMtihv9gwPmVZAbfaBx9K+0q0VhNbFuFA4kObrvUfSJIv420APYXQDGOTjpKNRqLrNRipfQn1Niaaea/LrG1TwT8TU9dFOnFYxk/8A90amKNM2yptQ31Hhc9pk1/mCtNR/Nn+4mneAd9mBXX0HvMeq1H4izao4/wCJZ2VULqGG8jLETQ1GdOtg6yWn09IXLAMwOcSV9ylACRuJwFHYSsxj0LN/qDIrDnnMu1mqS/XBLRgLwvsZlFdlNxsxzyB8gy612/DgJWLB3yORKqdqfh7VNeVVuvPWabN1xTUIcOnBInP0wLK6ZYqBkZ7TX4fd6hu6E4MyNF+nXU1BwMWryJOu3zdMqv8AUp5kHtFd4Ws8JwfkSN1LCs2Vnknn5ElrUbtMv/6ZbawPpadahn1Gt0wu+qg4+/zODo7CzLnn4+Z3tD6ctYdrMQVb3x2nn+S9u3Hx6PPOD2hIqwZQR0xCZjCUIoAyIcIswzAMwihKpyOATmPMUgy+JUfiNIyjqMED3nmdaWGoateWKgEEc59hPYczkeJaO38ZVrKEBZRtI9/mNxqV5i3Svpm8/U4Q84X2EzeHsup1T7jjn/E6H7QVOz+QW8yzOX2npONSjabdY/oAHA956PjvTnz6roaV6aX1NIIZc8Gc2lymmvrQEs7kL8yvTuBTa5JG89Jv0DVaXRlrMeax4PsJ1ZWeFadtMjNdwVXJ5h4awZr7enqJB9pJFfVadvKBXcME/EyajdpkSivJ8ziNTHQq1KWqTnJVuPmbqdUrpdaO42rPPa7/ANK1VanDMJsrdl2UAcEf2jCVr1+or0/h6IuGY8n5M84Gs095LArXacMOxE6OvDLfUo9TDqJ1bKtLrtAq7RyvB9j7SwrgaLTAXvXwQfUp95v8qtqPMT04OG+JVbS+mXTioEuuf6ibtAtY81LhtFwzj2MlIoxpggQ4w3B+JzdXpfwt+0AlDjENWj1XbFY4U8TVXZ5tapadwHf2kviwadtu5W5XH9p0NJarVLngkkdesyrUFtBHIIwfmRYikbRwuTz7GYbiGusu02oestlW95mp3ZwffM3awDW6AWZHmJwfmUaVBbYE2/UOPvF6ieuro/DTqKmaoAOBlfmeo8MtN2mQsMOg2t8YnK8ARgGrJO+s+pT3E7orVLTYq4LfVjvPNbtdb4uB/t2jkftCGThCEAijigEIQkBCKEAhCEAhFCAQhCQGYZhFCjMMwigEcUMwDMIQgEUcWYBCIxwpRGOKQLMMxxcSqIGHEWZARcwhmAQhmLMCUIZhA6JaLdIE8xZnXXLFm6GRK8wzJos3Q3SvMMwuLN0WZDMMwYluhmQzDMaYnmGZHJiJjTEszj/tJrk0ehZMjzbRgLnp8zrfJnifHqrrrb9Q2TsbAX4lmafjjVkbgbX5zJ6u0HAUDaDjIEoq09jWixvSp6AzVYUqw7V7ivCj5HxPXHG1LSCzaa2UleoaXVsa7gB3ErFhz6jlX7j/AImghfLFy/UhwPmUWWOWrPHqHUfEgNNmskfT1+0S2EsHHHvNtTq6YPDAe3WBxtZonrbcpLKef6TT4eX02duRvE6QVSpVvpPQ+0osCirYowVPHyJnlNa4ufbhmYk8Lkn5nC12oa1ioOEHSdHxi3ylFSHbu5PzOTWAFJs6S8OOHK6htYV7s8dJKrlCD0PSDuQ2APT2Ei+FGVPDTowi7cge0v0pFdVlhHOMCZscDJl3mhVNZHEUOogEsx6zTSQw9LCYbOR6ekSMVGQZLx011d1KHGdzH/EXnIcqV5mfR1izhXGT1Bm5NEmN1j4Hce0xZjUZzqSBtXvFTcUOSM8zUmk8xx5NZ8v/AHGWHRVVsDZnaO3vHWJ2L9YVRQnBPaZl1NjXqTlu3XpLwaTaT5TEDgEc4krNVpkThbAflcSSdLqjxN2VUUn0g8Q0oZ6jYBkiSvqbWadLagT22y5VOh8OapyDc46DtLIlqmux3BAOPmTt8Psas3paCR7dpzqVsyAHIGf7zoU6XVacDUUE2V59QzLSHXYz1NVd9QB2tjHMu0OrTIWxRuHH3jZUvY1ldjsMrx1PtMrV+WylexwfvIu9ujqakr1AepQFtXt2M49bW6a1lfoT/b5nasdFWsHkHpK9VQLFchMkrxBjIzBsW4ORw3yJtorJQHdlG6TnUWNU3k2jcgPWdCqkIM1Puqbp8TNajdotOPxCVE8HvPS6TSnTsaH9dZ5Ge05PhNauAGPrrbhvcT0igcEc+08nL11/ElAUYHQdI8yOYQylFFmEKcOIswgOGYooDzDMUTMqIXc4UcmArbq6KzZa4RfczieI+M2PU66CpyMc2ngATTTWdfcdVqUJqBIprPQD3lfjtor0h09WFZxyB7RL2uPHHzGvJLsWJ5bPWXW6V9VWwUEBf5jxmWV6dVWt2Yerkyy5rbK3dbAqKeJ6uN6cuU7chNK3ngWthB26zX5W8+YynygcKMQW5a1ZxX25YiT0niVYqtewb0XnGOpmkg1HiS00eTSBu7CV6d0Wh9XcNzHhR7Tk2B9TdkDBsbhfadm1a6xptMo4z6/+ZcZtc8pfrNUttgKqx9InQ/E+RrFVsAKMZk9ZcoZTUu3YOJydTedWchSuDyZRddZZqvEN9J+luD7mdfTMKbVrYbSx5HsZk0NFddOAfXjI+8h4i7qKnLerI/uJCNPi5avydTXn+ExB+xhqA/ki+ptyjn7TTXbXqKhTaAd69fmY9O/kMKbD6ASrA+0lWM12qrexX2AnvLqTUxY19COR7SjU+HtWWZeMHK/IkaOWWwHDDr8yVqeunpgtaIztwWwSe0w+KkVvbWT1OR8ibWqL0ttOVbp95z9Ttvq8u0EWJ6QfeZnrV8V6Gxkpep+QRN/h6b7aih5zxOfoh6tjZPODOn4ZQ9WrFxU+StgyfaT5KcHsK6iDXqUAFgG1x7ibgBjI7yCqPqXoR/eTHx0nmjdpwhCVBCEIBCEIBDMIQCLEcICjxDMICxFJYixIFCEIAYQhAUI4QFFHCFKGI4oCMI4u8BQzHCQRyYR4hIpCGIYhClgSOJLEIRHB94sSUIVGKSigOEIQNZMMyJ6xTTCUchzHKHmGYoQHmEUOYDzCEJAQ7ZhF8SgJnnvFrgt7eXyGGGOJ1tdeKqioJ3NwMTzWvsLDJG1F+es1w428i3py77R5wI7HDSvW1s7qyE4HGRyRKGLG5iBjdNCvdS+8DcAOfkT2OGJUrsH8QZQ85Hb5mhsVhRWdyg9JHUXb9OtlCY59Q9pjS1mO4nODgyaOqAjYO3nHP2lFmpTTMEtLqG+ho6NUpcVvjBEss8q5PJuHoJx9jLorXV2L6iQ1eecdpbqGONwP2+RMC0WaW50Jyg/yJqHqr29fb7TFajn+MUu5SzYSncjtOLaT5uSMietdn09QKYOfqQ95x9do0dRqNMuFb6l9pvjUsctzhFJHIMnbXmoOuOOY3APHaOpetbcNj0/M1rLHnv8AMk5yc/EdlZRiCOkipAOGE0gBIyB3kZMkKeOkTLg57GBZp0ZmHlnDTvaJFAAYNa54PsJwaGKtgHBPE9ALTRQiDG9hzOfOt8Y32W16WsErn2E5t12o1NwXaEB6/Al9eBtssbdYff8AlH/3lbp5Tm4biOxbvMRpvrtr0dSrRWGsI44ySfmUXUNad2qZVzyfiZqNRYEe9zyDhcTHrtU1wAzx/N8yxLW19bWieXpyBjjInPe4vbsXgd5VVXgbiOn+Jvp8OK0C+zILDJmsZ3VdFS7jS3CkZDfM3eE3MBfpyTgg8SC7DpgzfUDC3ZpH8z/eBiS1YyV2303BbieGG0zpPRTabDWRtcZHwRMvijBwjqAF2DE0aJCunrZxgHjnvBGVXJPkhs+x9jNWnsfaa2bD1n0/MwF1r8ROFIBPE0X0uWW9DwevxJVi/UDSvh1G0nqDJaat0YJW25WIbHtKq6Xa8rYAdg3YPQztabSVvozqtICBXwVac+dx04xv8JVBYCg+oc/BncHA4/pOV4PWDpEsByWOT8Tpj7zz31anCKEAhCEAhCBgEIoSBzJr1NtaUjpY4B+wmqLAzkjkdICdkqrLHCogGD7Tz+p/9Sz628FNOowg7sZ3raltwr8pnke88/8AtG5GqqQf9MJwo45l4ztY4N9v8QnHXp8QpRWI82wBBztz1gED2nef6e85+pr1F1xVQSM9p6eLnyadbai2fwH4B5+ZkNq7XXAAYcfeIeH6k1szMwwJjFNnmHO446TrI566PhKEu19oG1R195o0jrqr3cnBrb0/Mi1Rr09enBO5+vwJVpqxptVgtuOenvA0i5K9QFuAZnbAHsIanTbWvsrX0L7e0r1Kf/5XzWA9IzN3h7m2i3zDgOTx7iToZU2rRVqKmzuH9pR4iXtprJGAJrzXp6PIT1IpyJHU2VtVVSuOTKudIaRnfSArw1ZBEnqrK7NThSMsoJ+8101JTYKcjLrOZqdMyevBAz/aZqxtrYumy3JyOD7TM9QBwo5HIMtoLbkUnnH95aqg6goR6WHBmL61PGOnWrTcQxyh6j2Mlqba77dyAdO3vOfqKmTVWKRwDLNGjFRt7tNZE2tGl2pfh+89h4KlbUWUugZX6H3nl9PSbr/LHUnAnc8HNtF9QycM21we08/y3t04zp6OhTXWKyeF6S2LvxHMQohCEgcIo4BCEJQQhCAQgIQCEcIChCEAxDEIQCKOECMJLEUBYhCEgIsRwMCMI4QaUUlFClCEJAjCBEICijhClEY4pARRxHrKHiEOfaEYNBhGesJWSjxCEAxDEIQFiPEMwzAIQhzAJXdatNTWMcbRmWTk+NW5RaFP1sM/aXBy9TqdVrFNqYSsHgmc+4F0C5LHr/WatTfuPloQKk4xKFU/h2PTDcz08JkY5XtieoH1KOnWaKq2WsWINyj6h8S6msFsf7gRKqWat3qzyeJ0cyttqwBWAFPJ+ZjesNZtrGFYdJHUHDsOQCM/aT0r7jweokvqyKrga7lHPTrL958sW/ykgGS8RrVqUdD9J5lanGjz1LNxIrSLPN2luoWGkyW2t0A/tKqRtOD1xLKDixix6yb21nSzUZWl7DzgcTLTYq1OxGawOZfa26pyT2wB8TnFyNE7JnIPP2liVRqdOrZZGBrbpx3mRgwZEfIcdDNdLr5gXPDdPgytwWtwwBdTNxiqLME4P9ZSa9xyg4HeXuNzsAOe8iRsQBz/AEllRSwVc5OTK9xC4P8A/KWlAWIBx7Q8ncPZh/maFSHDAmd+tq3qS4nlR0nBVcPhv6zqaIEITnKnpMfJ4vBve9VHm3d+QvvM9t9+swGOysdhElf4hs7wQOvMvFJRwCDsPAPtMRus9jA1+RXnaOpkaaRYC3RF6fM06vSPXV5ij0nuJVpLFsQVOQrLNRijTKtmpSsDKg5Oe5ne1Brbw5xxuQZnnr6L9A4uIJUnhh0E6Gm1S6pGRiAT1+ZKvFVo0S3S2s55U8TDbc11+0epRwOJ0DRsyMnDe3tLq6NM3KjF1QyP+4QtjKo30iq08CZ7tfabkp6VpwJCuxrr2GdpLcCRv0tqagFhwRxz1lxLrVqV82yp0wdvedGij8Yq6ZfSXOczBXmk1l8HjmaNPqCtitUxBU8ETnyrXGTWmyny2CMTvB2Z+J2fCKbER1LHY45GJhxddetvlBmxu4no9DsbTg4Ge/xPNy5a7yYh4YvkCzTH+Vsr8ibsE85kFRQ27HqA6yWZIxUoSOYSiUJGPMBwizFmQOLEIdYBxHFDMBY+ZxP2nAFNT8bs4E7ZM4fj2x3qFmcKDn7yz1ZHnvLFFDahjkucCY/PZQAnpJPYZzJaqzfaFXO0Hj4mzR1adN1gYF8d+09PDpz5dkuktasFyQT8ypUo09uWXzLD0GZsqsGqFpRsIg5b3nI1GvTTWEUVhz3J5xN91npde+2wuxBsIxx2mektpwdRcoD59OZQjPqP4n0sTkDHWWrVZrrhSXO1Blie0uM6u0/8bfqbj6AD/Uy5rStVYGAx5IHYTDqLAqfhamyoOc/aW0o2BvJLMvH9Iw1YT52oNK8OMkfJ9pYQBpmcj1g4PxM2j3064B+p5595s1ro2lexDyX5ELqNjvUteqIJwOPmbfMS+pq7ACLBx8SqhGv0LVWL6cZU+0nSoRED8bOfvJVkVFSPw9qjpwZZgLq1Jxt/8yui0FijHILbhNmmt0+pQgEZHH9pitxxNbZXbq7RX3HMPDua2A+pRFq9MdPrGJ6MSQZZpU2Xb16MOZq3pnO3S0albqbF6hp6dtOKtR5gX0v6h/2med0SHdWw7HpPXKS9QrsHOOJ5efrtOlqklRnrjmOQrJ24PaSmEPMIo5UGRJZkeIQHGIoShwhCARxQgOEIQCKOEqFCOEgUJLEWICiko4wQxCSihCxCOGJGkYR4hiBGEeIYg1HEUliGINRiksQxCokQjhAjFJRSBRGOEKcIQhGg9Yoz1hNIUcIQFCEBAIQjgEMQigBnnfGH3WB8gBTjM717bKmOeQJ5nxNN9YryckZP3id1c6c+tvNtwhGxevzL0b+Ey5HJ4+ZlY+XtrXAz1lHnsbQqnCqeJ7PI4/rYqmoNgklekzL5hO72bmaxYGbLYGBlvtKKrRljgYY5ipjPrK8XFRwCMiV6ZSgznk9R7Tdt8+5nI/lwJDYldbPwWPEza1Izlwdy59IkAPRWvZesKgSenWTTjdnnmS1ZEkYqxz3/AMSR+lj7yO3B5ld1hUKV6A/3mY1cxNbA1Xq7HEyadijWAgFR1HuJpXBD7ejCUafG9kbqVnSOdZqqVTWgA5UnIlWpBXUnHBJyDNmkCLqTW5G0j0t8zNrK3/FHcCMdRNSpWQuxYsfqHX5ictZhsZEbAi0n+8jVYKrCp5Bm5GSsX+JjOOOPmCWlThxnHeaLEVhtbjuDM9qEEHHOIl2GJFA53L17idGix1oAIAUfErupAOnKjG9ecd50F0m2rzLhhSOBMcq3JVGnuZsooUZGc45Maa9wvlWAFDwZG1CVygGe2OwlNenJyxPAPJMya6W82aEV1t6Qec9pxkGdWWB4z1mi2wpS6oTzxkSnQoXswBnaJqeJ+usmpKJ+H1Kiyh+h9piOms0+o21jep5HPaWahT+DbPUHAlDO7adDuYMvTHEg3ae1xdhz6WHBPYy2xSloI4x/xMwy2mNmeMZ595p0dovpLMASAQZK1FWoopuI1Gm9Ljhl95oq0n4irBbDrysw02qlvp+luCJOu567ShYjJ9JktE9dU6hWbGF4PENHWN4Ckcy+u5dQjLb6T0JkqKq0KbPU+7GfiZ5XprjO3R8PJTUAFzS+eC079CWodwZWz129Jno0qlFZ8WIRzkcg/eaqqRSP4R9I6gzy7tda0gnHMMmQDZ7R5hnEoZkcxZEJicJDJhuhU8wzIZhmUT/rCQzHmA8wzI7osyBu6KMucTk+M36UVKzkWHBCKJ0WqVmy3ImBtFQde5ZOMAqewjVeVuDr1r2A8jMyohscirkHrzPQ/tAlQvrDcKF4nFZ7SCKwiqe4E9Px3Y5cvT/E1abT26VWwzjr8zJodB5w8y0Hbnk+8mmgGpYkua8Hnd3mvWaqimkaTTtk7drN7TtGLGIOCbfIXCrlQcdBLloGk8OPmMVNvLHvL9LpwaUUgAsQcewmfxL+Nqq6v5Mjj7RpjPVpHdkNYxu6D4m9qdpyvVOBNFdLo+EHqxgcdBKdQWFoVPpqHqPuYJFOor3WLYn195EqHUVcjcOPkyXh7EWPZYd244H3mj0Pbc4GAnCiTTGjTt5Wi8snlcSdiebpiFOGHH3nPsuIoUqchm5M2JYo2hT16fMxa6SM2iQuNrDkHAmO5btD4lkAhSc/edioirU2EAYY8fBmXxgo6Ix+rPESlQ1AGrosIP8A0yCDKtLnaoaV6Zn2tSp4J5PvLamBuKdh3i+E9dnwpSLUDj6T/cT1Axxjp2nm9KhJqYkbc4J9p6GsnYAe3SeW3t0viziOQzHmEShmIGEFSEeJHOIAwiUcj3jgOORjlDhFHAcICOARRxSocIQhBCPEIChHiHMBQjxFiARR8wxC6UUliLEBRSWIsSCMMSWIpAojHDELqJiksRYgKKPEMQpYke0nI9oBCSxCBeesIHrCVBiGIQgKPEIQFCEIBCEi3CmEYvEtQldDBmAz0nmdTq/Of+Gevea/2hLPeFydoE5CVk7wpxtE6/Hx/TlVFj7nsPUrnEWhqJPmWnOJIAIHXHJEv0+F0oBHM7W9sSJlRepCcIPqb3mS5ti+ntwJsRXc7FOAesx3qPN2r6lBwT7yauNNNpWsBepHJ+ZTc+Bgc5MsqUDgn0jkmV0obrWtJwg6faShKhVQAZOpQlRZ/fMTsHYhTxzz7CUvqNwwMbRxIqdloQc9T/iVs4ZRWMZ6sfYTLZfvvUHnH+YwD5rJn6+pm5xYvL8aKMNvZScKMYmWtlV9tpwQevxNjKandVHoKg7pTRpg9oFncZzNM1XqKVQI1Tb1BPPtLq9VW9W2whnHAMgqGrUorjKY5mPWVrXaNpIBzzEhrRqKE2+Y2Of5vec+2g7dwOf8To1hW0BFxON3pMoRGRnVuQOh95ZcMVUncoDc7T/eWNXm0sBnjpNK6F6qKrjgi88fEsGjJcOtgU9CJm8o1JWrRpRrNJSAdt9LEEf7lnS1hCeUhAKMME46TFpq69P6h9Z4JnUttofRMrqBuGPtONrrJ05OsqathUoXOcHHtMdqHfhjhR0E1WZL+glm7sZnsUBsu24/2nTj458lJpNh2qP6zXplp09exQOfqaZ9PYfMaxj6MR0FrLmJX+F3JmmYttdNQ4RSPKXr8yLUra+F9KdziQVLLnb8Mm2lOre8se0eStf8zHGM9pRDVahAn4XTfSf5pm0Fj0XurEhSOnvK7GNGpXbyB7zoWPTrFUKoS1ew7yoyOAim0nGTwJQLWtsJDdBx8TRraLGo3g5C9RM2mOxwzDjvJFbNOzmxWBwwPPzOxoKzbaa1Xkcic4VKhU8hW5BnX8ODefvVyrHgsJw+S9OvCPQUeYgZWPHUS9WyPaZ6RtQDdu/7pMHA6zy66WLt0N0r3Q3S6YnujzK90W6NMWbo8yvcIbvmNMWbobpXmG6NMWbobpVuhujTFm6G6V7oboMWbveQYAnJHyIsxFuDISOF4kBqtTYz/Qhx/SYraUA8wEIF7ATdqGFb4I5/mPvORqrS1KLV1ZuZ6visxjn6o1uuyoVRtJ447zLpa7LLN7KOOuZdVpGe3+LkKD6mkbma6zydEPSOOvWdp45X10KWNFhsZgQBwZlVLH1C27TtDZJltVBWryeWbqxz0l9t9VO2h2B46e0DU1m0F1xwOMzCT/B2Z9d7dfiS3vqarbcYA4USWnUbNzD1Ku0feBPR1UubFT6ajgH3ldwL6bUW1DgDrFUTRo3VTywOTLV2r4T5I+qztItcnQv5o/DP9wfedCrFa+a3JTgD5mddMdMRbgzW9ZakMDxnP3k5RYCT+ENnO7/ic27VfitOlbHFiNkfM6LsU0123qB0+JwXrZmNicNnP3jhNOVx1NMwy+MZAjorKvuwSCefgzPpmL6jaAMleZ2NEh8xa25R+G+JnncjXCa6WlqdalyMpZjH3E7a9APYTnafTvpiqF99QOVBHSdAMO08jrU8xgyAMMwzizMMyGYxKmJ5jzIR5jRPmPMh/WMfeUxKPMjHCJRyIjlDjiEcAh3hCVDjijEqHCAhAcIo4BFiEIDixCEgUUnFiBGKSxERClzFJYihEYYjhIqMMSWIsSGokRSRERlXUIHpHiBhRCOEI0HrIiSPWLEIUeI4QI4hHEYUoQhAJn1VoqTJPJl56Tk+LFucHosUk7cXxO0WWEsf/wCcyhWp0zEjJfqYqKjfq0VyQpOT8zTqzyQB36fE6y50WdudcNi9OSMy1R/ByOcjiS1CgqrHjI/tKFsO0AcATpKxix7HFPlUn1kcn2EhcUrpGOijB+TLqnqqpLv9ZnN1V26xawPTnJ+Yitr5GjyeWb/iK2xatIFXgkAGQ1behKxxjBMw629fxFdCnp3+ZZNS3F1r+RpGOcE9Jh0129WQ9u/vKtVe1lprY+kTNUzI5AM6Th053k21qbLA4GMHBmlWBsO08r0lWnPr3L/NzI3hq7Q9Yx3+8Dr0lLKcnqo5HvK7WYUi6sbto6DuJXp9SGSvYACfqU95NSaVZAfTyRn5kWdi+o6nTA0MCRKNXSL9KBtKWp1+ZIVhXFtFhrB4254kr31NADOAVboT2jcMZdNqFcnShBswRz3MnVXldg5YcQcjz6vMpWtjyGU9RNJQHVAp06kycqSUVWlxTpyMKjcj5mgaYVa7YeUyDmLyP/VBxjrzN1zCrTm5iPVyM9px3XbOlVzDzGRQMHkfEitqZAtPA+Zjr1fmW/QSP90qtcFnYnp0muPHGbW+xqimKV3H3zMNtLOx3EACUqa2H1sv2Mo1Nm1Cq2ED3951kc7UtReGxTUMIvB+Y7tPdUlSsWJsPC+wkPC611Gprrz0bJ+Z12YfirtS4yK8on2i9JE7P4PhrVIQrBcjHvOAhdW8x9x5/vOpTZZdYvmgGtjkMJrvo0j7BX6Rnn4EmrYzaWrRaism5WPHJ6SjU1ppWW2tyVP08dYaq5RfsrbAc8D2E2aUUXoaNQD5inKykQZ/IrruvTIsGc+0p1FFd6CysdT9Qm2wCxxRaAV24Eo0yfhd6EbqXOPsZFh6cqaFrdsWA4we86fh26qwA/8A85ksqC2nKgq3UToaHoUIyOxx0nn+S9O3B1VYYyDj4j3/ADM+7aMR755XbGjfDf8AMzbzDefeQxp3/MW/5mfdDfBjRvj8yZt0A8GNO/5hvmfdHvgxfvhv+ZRvhvjsxdu+YbpTvhujTF3mgNgnBPSZtZqzUAics3+I7FWweocjoZldeeoyO81xTHO1ru/XqZnrxVsrYDcOZp1ewrjfgk9T7Tn3AVcgnB6sTPXw6jjz9S8Sv2eH/wAI8s3OJV4XUE0Vl9oOc+kyux8hK8El26e06Wrr8uunTJwBjcJ3jlVgBq0iYAD2Hk/+ZzDSrm3UNk11nAPuT3m3XWMtQUctjA+JN6NvhdNSDLFst9pBXSfKCUn+Zd0rqdrtaFB2ohJaXLg+JWVLyQg247CVOyU6a9h9bNgRgsvepLBjkZ2ge5MasDrXPG1E2j7yjUoH0FdtLDevJltdeNuD9YBP3kqxotO7QvnnAmVW8ymogmdHT1CzSWIw6jiYtFgWLprF9O7gzF7akZdXqH02rXAxu6ZlS6uu9CLKgGB5Ze80+LLXYoPO5G4MwaatMhc8seZrjmM306h5OsVlPDTtgW1ul9XqA6gzi6hlF4C9F6Ts0W50yOvJB5HuJj5PG+HuPQ6a9dRQtgGM8EexlynHE5vhbHY/sTkTcG4xPJb27Yt3SQMp3SYaJUsWZjBleZIGVMTzJAysGSEqJyQkAZIGWJUsxyIjEqJCOIRiBLMIo4Q4QjlKIxAQxKhxxRiAQhCAsR4hCAYhHCAoR4ixzAMRYjzCAsRYkooEDEZYQJEiBGEeIsSBYiMlFiRUZEyeIsQFCPEIVeYYh3hNMiKOIyAiMcUjQkY4jADicrxMghuei8zpt0nF17F7vLXgHr8CSrxnbjrW1dqWDpLfL3vg5yx/xNDbGuVKxlV7wqXOrUD3M1b01I5WuRqn24PHaUrg19J0/EULeJBD1PH9Jnt050+pKfyHoZucmcc859I7SIoUX+dZ9KDge5nRelBUTjkGc7WA1q24kBhxN8bqWYos1SqzXPyhOFEwXAvebh064lVlhucADCjgQAc9SeO07yY426gcm0sexjoQs7N95dsGc+4i03prJxyBNb0xT01rVWDPQEj+86dVdbhrLPoE5yV5rrPfOWm9VDh6Wbphse+JKrHqKrKyuoTIQtwJt0ub8qWyrDGfYyerJ1Gm8pVClBkfM5NTOjkoxXH8vzGautgPkF69SrGtv8TXVqB5fkvixCPTn2/+8e5ba/LuAOVyGmGpGrs2sOh4mK1G41VOiBSR7Z7S/R1MHLY3AjBlL52gsMEnj5nRorLUIicMDzOXLl+OnHin5S1ephknr9pltY+I6ry/prReB7ySs/4lw5LFf5RJXWjRDfwHfoPiOEOVULplUuCwUjk/AnI1TZuYLnBnQRvOtNYYs1nLN7TL4nUumYAcnGf6TrO650afw8ugd7Aqn5mW6hPO4BdR3z1kqLrrkZEJCj6vn+s16pEtrRaTjAyuPea8YR8PVKNUtqgjjBm5gbcoACykkr/uE52j1SVXeVqlxzjM6z6RvPS/Tvz/AMzNal6ZzX+HINT509vb/aYhZ/EKjrg8RuLKr7Kivob1BfYyvUqK9ZTZSc7wARGLqm/RsyG5CZq0lisa2tBFoIAb3l4fatgYcHtI0VFtHYFA3I2V+ISLNfWaSLz0VwR9poesWUWqOjkOPiU6dhq0Onc8uO/aWUl66fJsHqQ4/pJWsMsLLkrPB2/5m3TgouD2M51lTB1fccr9J950qmDICeOJ5vld+CzcYbjFkRfM8zslmPdIQzKJkjEMyv5izAt3Q3D3lcMxgs3Q3Sokxgxgt3Q3SrOTGTIizdDdK90NxgW7pj1DZbAXBAyTLXtC9QZj1tjWABAVXHPab4Ttnl4w3WFnZsgDtn2mO2taz519m7PQZl12d24EMo7ZlLaQXothzyfUM9J7uNmPNy9Q0/mvcLQOvT4E3WahrdSNqFvTyZeEpp0eTjIGBM2gUm42NwF7Z6ysyJKll1oLDkjkewk7tUKgpB9OMKPea2ZFFtzHbvGPsJx1ra7WruHHJC+0K2Ut5QL9b7ON3sJXrlVl8tAAqr6j/uMS2AFlH1Kepmi2ndVhfqZuR7QKfDKXfS2F/wDpk7QJsrQalS1XC08A++IUKq6Fhnodv9ZZ4dV5Ghs8w9cmSrxib2MlFmDjK8TBU4amm3o6tg/MsvvDvhB6NuJzg7IRW2cbuJmNWrNYrWV246ryJRoxmypuxE36msMPNQ8OvM52kDE56bDNTxi+tWo0ws1SKmAMEn7zVpSEU1e3SJiN9YUcjqfeQ1CNXYli5295nl41x6rv6EgUenvNQMx6FwatvRus1g8Txcv9nol6TBkwZWJISRKsBkhKwZMTSJiSkRJiVmmJISIEkJqIYkhEBJYhDEYiEkJUojhHAIwIRgSoI4QlDhFHAI8QxHiAsRxwxCFDEccCMJLEWICxFiShCo4hHiKAopKRMAxI4kosQIxSUUgjFJYihTxCOEIn3hDvCWhZhDEJAojzGYiYUojHImQRc8GcW4Gy5zkgY5M615xW3z0mI1AlT2Xk/MzW+KpNMNyVoBxlmMzitkvbaO/9p1aUKhnY+pjn7TLagOpzjGRzM29NRzfEks89NSB8E46Sp1NnF9gVepPvOsyCwHcMgjBmTTaeq2p9y7iDtB95ZVcltTQbfLqZj7MwPJmHxC0WIa76yMHgg45norNBpKKnudd5UZX2zOH4zp2OkVmP8Rl3YH/E7/HylrnznXbEtI09ebdCxrPRpiLIzEouBn6faWanxPU3olIYqqLjEzKRWCWOT3npkrjbE3Yb9oPBHENIAUsQ9V6SkqVCsTyeftLqgGcMDjImmV2lG+nI/lODLXRxi+rlkHrX4malilzgcZ7TXXYos2A9eZmkaSBqKBbQdrqMg+/xOdqaDlbwMbuCPmXaOx0uapPSMnj2zNttBu0zUJ/1E9S/MulUadksrRWO2wfSfePVqV1akYK7faZqlFmmfBxZWckTdd/F01bouGA5+Zi9NRr0gTULWCPSoyR8zottqrZlE5Wis8oq2PQ3/PzOudti47GeT5L29PCdOW6tTTvHNlhzn4mHX6hbmSwnlVwfidi6g228dFXic67RhCXtHAPT3nX4+Uc+fGq1anTaYWKQ1jcn7TH4i5vdbMHBH+JHVEm1gAQOgAk66ba7Ee4eg9BO8xysQ0NypkbQMjH3ltVRW70g4zxMzVeXa2OnaaNJqCjKH6jjM1WYfitCu62KuMjE0eEap/LGmsB3oePtL/FiPwSWY6nAmDw9vQd3Dr0PvH4frsuhVnstwy7gZyPEkanUJYDhN3T2m6zWFqDUwwzHiR1jUbkqvIyy5B+ZFR1FnmnfWMkJ19zL/DSGVnLc4KsJUal0+k3u2efQvvH4WhXzLm9KseZKsJkNGnGoUkOpwPmbgx1GlXU1Eeao9Q95zPEnNbBa23J1x8zT4Y5SlyfpcSXxqVrrddTUHUYsXqJoobK4PE5mksIuK91PHzOuv0gieX5fXfglxF3hiHM4OgMOIYhClxFJ4ix8QiMI9phthUTDmSxFAWY4YhjiEEBDBjGfaAsk8RNtIy4GPmSxIOgcYYnEs9L4x6qmizBQgYPJExHWUKPJVCzA+kCaNQFDGhWwT1mXS0Cu57HICrwWM9nx+PPz9WWVqADY+bT9OP5ZQ7LpVCqpJfocynVX+Y5WgnGeSO8QrttsqpzggYJ7mdJHK1epsuKJywzx8zYqqLi6ruK8CWWrVpRXUuC2P7SvXapNNpxXUo8xhy3tmUZdh1GvCVjIByxHczqWba3YAAso4PtM3hgGn0zaiwDOePmUeIajytK5Zv4l+f6Ayfq/izQt/wCkJc53Wb/7Ser1TLpdh4aw5Ez+Hur6ausjAAwD7xat1V3tYbvKHAj9Jel617aMN9RWZTQLdDvU5evrL9HcdSrM3UjiSoTyyG/lcc/B9pPFV0uX0WGP0iYRzRaEPI6zpatBRp7LEGFPaclXAoO3qwOcdhJxOTp6Bi2lDnnA5MlXYbHsRvpcZWUUMK9LWgYAEZZj7SVdy21s1YxtPB+IsWOj4ZaTYFJ5HX7e07I9xOLpFKWCysdsn5narIdQw7zx/JO3eeJrJASIEsAmJAD7SQHwYwJMCajNpASwLEBJgTcZoEkIsSQEYUASUAJLEIWJKGI8SsgCPEYjEuKWI4YhCHCAEeJQo8RgRgQDEI8QgEfEUcIIo4oBCEIBiGI4QFiGI4oCxFiEICiksRYhUYsSWIYMCBEjLDFgyBYhJcwlB3hGRzDEBSMlEZApEx8xQFmRJjMi0lFNw3bR8yIUFtx6DoJYevPaRPHElbgJmfGWLd5a0rORM1YpuyKzt4zFUgrr2L9zJsNxwekTc9JmtRVqENtD1/7hx955HxTVPZalLek0rhv6T1546npPGeIIP9Ssz0LEmdv/AD5rPyS45eNwNoGMmV2L6C5mq5PLRVxwDkyGorxp9y9D0nuleaxQAWpDknAb1fE0oym0bSMYlFLAKAfpPDCNENdwXPQ8fMtRZqM12rZzzL6dg1Ceccbh6TLH07XVdO4xDU0j8Qir6vLXH2mQr81XixRyDj7zfVY+p0otqB3IePeZ9aVNNZA6dTIU6ptNqFIwFc8+0ipgfxvxCgesYb5l+lb+Ey46HGPiU+JApk1A7GOQw94UvvTI4OOZmtyujo127q25qbofYzoUhlBBPExaV1rUbsc9pvB4B7Tx/LuvTw8PMquqFrKW6Kc495bDA7znLl1uzpyH0wr1j5GcrwI9Qi/h0YjgDmdC6lXO8cNOZrGtVq62GEB5x3no4c9rjy49MWoqF4WytuVHqElpq6yuD9bMMS3U0DTnFeTnrIaBANV5jZwvSenXCxu8ToD6ZKCe/H3mPUVDRlA2N7D/ADNmps83V0AdFO5pDxWk2Mlx+lR0l1LHMW0I/mWtuxziUanzb6/xx6K2NvtNNOnVbUe0ei3j7TUak05/Duv8J+oliMi3nUCsMemMw1tt1dqqjEVjsIhQK2etf5eR8ww9ihgQwPQ+0mLKvbY1JvJ9IGSPaRbUu2zYcVjoBM6m1lemwdDk47xU5rYEZavvx0ksNdyinnza24M6iDKg+/Sc/RIPJ30kY7ibq2cAAjcD1+J5fk416OFW4MYX4klwekntnm12V7YBPiWhZIJGmqdnxFtl+yPy41NZ9kjsmnZApC6y7T7RbZpKSJQ+0aao2wIl234kSvxGiqEntiIlEIjJYiP2je1cbXbV1TttLbhOfqXawKhzgH3nd1dYYFxj0jmcTymsVmB+o4H2ns+K7Hn+SdrdKK1rA43sePibKNMEJv8A5j/N7TnoqeYR1C/UfebNRY504Kkj4nS1zhsos1PnsxNadf6Sjy/xeo8wn6zx9hKdTc40i0p1c8j3nQ0IyuT1VessZqdlZZaq1OVB5P2mLUUrqtW9h5RRgfE1+epV1UcngfMqoVw5oK9OsLVdFRD0gE7VOZZZQ1reWg+o5P2k7XFF4X3mhWVwtSsAxGfmUZ9NQNLp3cnjPpMt1KlNORWctnePtCyw16Uq43e6+0updF0+bMepcDPaZtWGipqtOUYAgrPO1Zr1T018gnaVM7i7tHaWAzW4/sZyrlC6uy4KVPWOJyWtRW58hm6e3aaRWlWkfb1HBmXT0u2oss5wV3AzUAH0r2k9R095LeiRv0zBNm4jBAxOlpBhCvYHgzi6QmygK3JHSdvQg+Rz1Bnl5+vRPGlRLFEiBJqJiRm0wJYoiAMmBNSM2gCSA9oASYEuJpASQEYEkBLEqIEkBHiSAlNRxHiOEuAxHiOGIQsR45ksRYgGI8RciSEAEMR4EIBCEUIlFAQ5lBDEeBDvAUJKEBYhiPHzFzAUIwY4EMQxJY5hiBHEI8QxAWBFiPEeIENoixJ4gRBqOISeIRhqB6xYkiOYSCEUmRImKIyJkscxGFQMgZYZWZmrEDIGTIkDJViBlbGWNK2ma1EGMrYyTSppitxBzjmcnxTR+fm6pfUBz8zqN8yt+RjPWXjcq2SvKW1q6LgerJ3fExkFV8s8jdx8Cem12jr8p7EGG6meevXCkgcjie34+f2jz8+GMyIDYWHIJi1DbLV/5mipfJQu/BbosVlRuqZSPUBkGd44ttrMunrvr+kdRI2gpjUr9LH1GU+GXNsNdynYeATNmnoZqLqG6ZIEz4uG3/p3W0qLKLByD2lN1VLIxrBNRP090PvLtMjnRit+dpIEFAotzYNq2DqYXFWitBqemwb1x0J7yGkQC3K+pAeB7SWp0jadg1ZyHOVOes0VU5q3hSrkc495LBc5avhVz7TXpbztCspB7czHTb5b7XYNgc5k7LqvqLEfHtOPPhrrx546gPGY8/E5mn1KE4DE/wBZqXUqWxiefl8djtOcaOZBq0LbmUE47ya+oZxE+QjGYm61WJ1QkqcHuTONqr3pOafSpM2KLbCyA8seZT4rUKfKQDjbPdOWZxeWz2oaLUNZf/FP1LNmqvcVLXkHicYFqwto6qZezuX3Mc5/xOmMNbWo+iNZHIPB9iItZYz6Si0fWBz/AEmHT73vapR9RnUUVm06ZvoVOD7mERdDZp69RTywGT8yoaYMTfW3l1sP4lftNGiWzT762GUxKLbl8nAHqY4gIOnnhql9IGGB7iPVVNpkGr0/qU8OmMgysM3ko3GUPBHtNtDgqazgBxxC4gt7V1V6jTYNLdQP5TOjpdcX4bG6ZtJp/wAOzLgeVZ9Q7SratN3lk4A5VjOfKa3Lj0NNiP7Z7zRgHpOGl5TDbs8TpaTX12DaSAZ5ufx5XacmsJ8SYSSqZX6EZloUzEhap2R7JeK/ePZH1TWfZFsmny4bI+q6yGuRKTWUkSnxJeJrIUkCk1skhsk+rX2ZSvxIMk1FJWySWNSsxEiRiXssgwABzIuuX4laKawQOp5HvMFodlzUgXI+06fiCoqAldzHoJh8kH1aq4AD+UT1/HenHn6w4akbV9ZJ5xOhWossTcMArkxNfUE2UInsBnkyIsa5vLyEAHqx2nbHLpltrBd3BOP5TLPMKoK0PHv7mUtYt+oXTafLKDyfeX6ZFWyy9/5BhF9jNM6FU03MznO1dwX5m3RoW0vnOT5jnJmVqGIW0klmGW+JsstFGlZ1PRcYkVj1qG4iwH/ptg47yyusLrBaeAqYkvD6t+mUW5IILn5MTsr1XY6kcfEC2+xPIVjhfMbB/pM2uBNYoBxnkRXBRolUnLK2RI6lDdpanVgrgkZkxYlpbbDWabTlQDKdSSXrfPDrtMvrR7UG30WYwQe8g2VqC3L6lziT9W+LtG6LpzUOT0H2ksqaXrUelTjb8TBWprIKn6uQZpS9XJIOe33kvpPF+kYLSFJ9QPE7Oj1SMioowxPSeZqtFlrYGDmdbRXNUytt5PHM5c+DrwvT0iL79Zaq8yGmy9QY85l4E5SJSCyQWSCyQEsZRAkwIwI8SoWI8RgRyoUceI8ShYjxHiPAhEcRgSWIYhSxDEliEIjHHDEuBQxHHGCOI8R4jjAsQxJYijAoYjxCAYhCEuAxEY4YkRGH9JLEeJRAR4kuIYjFRxDEniLEYIYjxJYigLaYBZMxZhC2wkoQKSOYRwkVGRIk8QxArMjiWESMiqzIESwyB6SVYrb4lbS1hK2ElWKmlbS1hzK27zFailjKnMtaUOeJiukVsZWTBjzKmyT1MKxeI6tPKNVbesnkCcOxigIwC06fiWmVB5iHDZ5M5tmmsAFzD0k9Z7PiyTp5/k3WWlLdTfk5I9/abUdEs8tBkKMEyu23yaSijBPcTPQ5CbwDz1neXXF07ylelQIBliP6S6q4jWOoxsKg4+Zy1tLFVfJA6fM2vWV8vXVMWQDa47iKqyu4C5tg3ITyvtNFwTUU7Dg7eftOXrUOnZbqX3V3cgj3m2lx5enZmG4t6vkSC1Kg1RobPOGUSweUmFIKtjhgekHsQWVkMMhuR7CR1FtdZdCMhuVJ9oKy6vab82qPuO8jZYtSZXFikcA9pl2vY5eu70/MWWOVyCQOOIw0xqmsswq7ce01JqiCpYczB5bE7unuIt7pyvrTv8ReMsWcrK9bpW86gNjEnavpI5mPwG3zKnTOVHI+J0mE8HL/AB5PVxuxzUVPxDD3lHi4R6lQ/WT6Z0PKVTkDmYfEQFKWkZx0nXjy3kzZnFwmQohXrjr8SWgoe+zAJxjmbjpvUzn+cZiqsOnViuMz1SvNYSLVTW4GPMzjPtIWMFIKHlOc+8qwzWNsPfkxasAuKlGGI5Mo2HWN+Ddm6txn4lWir8xChwcjKmYm1AH/AKb6gJr0TCrbYDwWwYwjFXa9bPWedrHIM6WjIDKj8oRuH/2lOvrrsuY1DDMOo7zLXbqKnUuuAOvzF7T9d03LX6W5B6Sln07oWsUsw6cyu816jRJemdyHDYPSZ70daEtQ5U9ZMb1fVqgHCken79p1EA27hjA7zjXVEVJdSMjGDOjprFaha2yM9pjlF410dHYGvBDdOvPWehqKnHrXPtmeUVkqwoO4fbGJ3PDR4eoU7mDkfzHM48uOOmuqEEeyWoqlQVIxJhJmRln2/ENgmnZEVlw1mKD2kSntNO2RK/ElhrKa5ApNZHxIFZLF1jKcStkmxllTr8TNjUrIySl1xknpNjLKXXjpMWNSuFq95vLEEIPpzOVrS45VQSf6z0fiFdllR5VQOTmeX1JtdtlOW57T0fDWebEK7PNXcTuPsek3gOKGqqBDOeW95RTVYufN6g5J9o2N2qvWmk7V747Cen1waaaBoqy6MHtYYGO02rRWtdZvPQbj8mZ7QmmT1vlV/wCZaN11K6g5wOg9pKsWscIWc7VMzVN+IW1GPp7Sr+LqtQyuTsXqe0nQfK1BqY+lhtEfg1aS7/0bVp1xgH4kVoKXbnPBXBlTna1ddYwqYBPvJajzVqJJzk4EDMwGqssrrb1IJo0Ci3TnTXEBmB49sTPUhSs6isYsTlh7iTUKzpqaSdp5b4ipCousBaonkHAPeF7PYCHAB7H3xN19CtjU088c47yi6sO23HUbgfYzEvbd8cwmxlBAOUJ/zJUAHhLMKx5H+0xI1lVzBsjceJZZRVbZvUYPVgpwZ0xiVqbTkPhsqfcDrNenqKuorLMfmY9N51fCkuh6bu03VWZO05GemPecvk8dOD0fh91hUV3AHPQzpATHoaw2nrxng5Jm/HvOEjXL1HEkBJBZILLjOogSWJLbHiXERxGBHiSlRHEeJLEMQajHzHj4jEYmo4jkosCXAsGPEcYjDUdsWJOBEGo9I4R9IChHFBoxFJQ4xKFDEI4ChGIYgLvDEcMwFAcRmEGj+kMd4ZjkCzDMeIYlChCKA4f0hDMIf9YRZ+IQqrvCHeOZUojHDECBzImWSJECsj5kCJYRIESLEG6Soy1ukqaZqxW0pbvLWlTdJluKmmez7TQ0rYTnW5WRlOekrOcdJpcSlgRDWsmsp86nAHMrv0ws0wrXGVE1HOYjx1m5zsnSWSuavhyWufNGMLiZn0K0VvWDk8nPtOpeX2/wsBpgei8VMbGyW6z0fHzrjz4xzUQh0OPVn/E1Lb5Op2qfQ3DL2OZmsZqmFhHqxgD4loauthcw3ORwv+2d3FbqtLWa209R5TL49szPQrmplYkNjg+03UvWajcxBYj1GY67wNS5JAz0HaJSqtMt9xd2Jyh5m+9BdSjlugwJmtZkuN2nIVmGGXPBka9aoY1kmtifpI4JlSKg12lc7EB95VZa7/xCuGXsJPWG3zCw9Lj/ADKqA7NuZwCZUA1Qbtg9wZPgMGXuOR7yx0psGxyu7sVl+j06GwG1s46CZ5VrjNrr/s/pmrVrs4Vx0nVczJpcpyOmMfaXNZxPBzu8nr4zIi3EovRbEKsMg/4k2ck8Sst7mSdKwq3l3PW59Kj0n3lOp8vytiIS7nr7CXa1BvD54IxMzWlq9ikLYOJ7OFuOHKdoVIulpd7Tljwo95VqR5lYsAw/QyV6MFqBOSDNOmVdULaQPWg4nRzcqvSZvUk+k9ZPxBTWgSrhVOfuZr19JFC7QQRycSVlPnaBH6bx/ma1lbpED+HG/GbAcY9pZR5Gu0bpjbanX4Mz+GWuiGs9DyR8yzUV2bxq9DyT6bEk1c6ZVqupYtRYGVuHT3mvRvVcraS3KlgcH2Mhq6bNK9Z/mbk/eSdE1NS3UELch9Q6GKRPw5jVa+l1BHX0Z7S+9AgK9WU8H3mRXsKiy+veFPqK9RL2vFmNmHQDhu4mWos09h62Z5+JorLhwyNlM/2mVtQErw2TJU31bdws25HeY5RuV63wmxLQQpPHzOwqnAnjNHrPJYPVYMg8nOcz1XhviFWtQis+pRz2nKTKcmvHENslzHNOasrIFZdiIiTFihllbAzQyytlmauqGWVMs0ESpxM1qVlcYyZU4mh1lFg7TNajl+KgNpwGO1Wb1H4nBe0A2LWCQD6do7e09LqQhrJtGVHacJL1VmArAyeJ0+LpeXjm2tZYmFXYPYy+7b4fSgRcuQCT3JhqQ62B3CpzxmPTKb7/ADGbIHv3nol1xs7Z0qv1YUup2L6jnuZs0tpuV6Kj0IBHvLNVcWB09PpX+YicvQXmvxILV9AyD8zXsNyupqXFCfh6lGOpbuTKa6jjzH+onImgIt+oZz9Ff+SZJTU+oOSSAP7SQorVPKNy8/PtIUMWvrFw/hnPEBiuzy8/wrBz8GMWqCFY+oDCn3hatdUFpelcoBhpk2DTWslfR+QJRXqbKbWZDweHWbFZNamOFdOh9pakWaew11YTjJ5B7SnXE+SXqXpywiVhu2XAgr/mW2FXTg9Bg4nPO2/xySTehalSQOT8GSRy2FcFWHtxLK6m0rlqh9R5UmWu9dxWxAAwPInS1zkSXzEGFsDIeo9po8NKtrqqzkLuGSZktYJtZivXgCbfC6vN1Chjk54+Jy5+Nx7utVCgLjiWhZRpUZawCZpAM5QpASWJICPEuJqAENssxDEuJpYEAJLEMSoWI8CHEMRgMQxHthiFLEMR4hAIYhDEMjEUlCFRhHCAjFgyUICijhiARGOOAoQxCFPrFiAxHCCKPEOIUo+0MRfaEOEIQCKSiMAxCIZ7mOA4QhApI5hiB6wmWi7wjigIyMkZEwImVtJmVsZKsRaUtLGMpYzFWIMZUxk2MqaZrcQMjJGABkXUCuZE1buJeqyYSWQ+zGulHWVvpWPAnUFfEmKeI+qfdxbNEFTecDE5dzFWPtmerbRpZ9ZOJD/SNMTllzNzYn2eE1hUEMFzgzKWS4nJ2mfRbPBtHYu00gTMP2X8OznYees78fkc7I8TpTWUt07tlW5B9pl1V1KFUo5C9zPoP7u6Ct8JTnd1Mso/ZnwmsHdplcnucTU+SfqWPm1WpQuN6kD3mmw6d68bt3PE+iH9nfCSpU6RMHvgSgfst4Wuf4ZOenxF+SfiY8EiLadtS2PYRgHmaF/Z7xA15NR5/wAT6Bp/CdNpgBUnA6cS9qZi/Lfxcj5/R+zeqU5s4nRq8LWnBOWM9W2mz1lbaQHtOfLnyrcyOCqMBjBERRuhnZfSgdpns04AzicrHWcpXLx2iI+MzU9WO0odDmI0yarTjUKq5wAczJqK0rYA8tjAE6RIAyx4E5oR9RqHcrhQeDO3x1z5xmJY3ItnAXkyzw5/LvtuX+biS1CAEbh14JkdIBSOTyx9M7yuNjVaPNLUgZwPUfaZ12uy6atsrUM/1itv8mpwDh7DzMWitFWoZA3U5+83GbW6uoi+xl++IF30mpFhB8t+DKq9QxvO4fVwZq1qfiKa66znAySPeSn4l4lXdqXF69FA/sJz7ibD52mJS0D1D3l+n8Rfd5LD0hdpz3ly01FAUI68n2EaIeGaphcUtTkr6h7iaWp0pRrdHZ0OQB1B+ZDVjT7l8o7bEI5HcTFdS9FrXaRtyk5IEGpWahRbm5CpzyZsZFZUsZh5LTLp8atLA4O8DODNCVDyDXaQ1WMpz/iKsq1NOoGKiNo5OJ3P2fa+vV14U+XZ3x1nmqNXWqkJlSBxnvPffs9WR4dXvZWB5A9py543L062PmPEMCOZYGBERJZh1gVlZWyy4iRIkxWZhKnBmp1lLrM2NRjsBmewfM2WL8TNasxW4w34KkY4M4lqLp7NzDdtGf6zt3DicPxRxnavBPWOF7bvjl2GzW6kscgLNQfyHNNYG8Dk/eLShKd2WzuI/rM+u1C1alypG4jGPmeuRwtZ9ZqWX/0tPBY+tu5l1en/AAqqwX1HpMwRr7ltVfVnmdXUPs2MwzuHE1+YzF+lYeQ1YHLH1fEottWhQidHOHbvM9F1iWsc8N1Evs8p/p+ongTLR3jyTl29JXK/MwWX22Kr1j1A5Et1G620VE9O0r0j0tqmpsO32mozUmuFoDvVtYjkjvLCXqryc7OoOOkepoNW5Tlq+5jqLogLNvrPBEUiVDm0csuPvNemUIebOvQ+0xrpUQ4QYDfSZdUApK2AzF9bh+K1bVF2QpA5YDrObXc5QiggtO2lQ1CHTvYF3dCw7yej/ZHVCwGy5fLPde8n2iWdvPjzHsFbqCw5M9R+zmh3NvZXQjpkdZ6DQ+B6HSquKVdx/Mw6zqqoAAAAA7ATHK/YlxXVWVUDMvA4xiNY5JGdRAxGBH3gMyghDEeIQoRxZhR/SEeIsSgH3jhFiEMQ+ICEA4gYYjxAXMXMlHAjiHEfaRxICEcIC4hDEcKXMOY8QgLEI8iLiAuBGDDiHEAyYYhCAQxHzFmAGHMO8fEBcw5kosQhYzDn3jMJQf1hDEIFPeEO8JlsoYjgRCIGRMmZEiFQaVGWkZkGEzVihpS2SZoZcytkmbFlZyJHbLzXDy5MXWcL8SYT4l61yxa/iXDVC1/EtWv4ly1yYSakZtVLX8SYQ5loSS2yyJqrZHtEtwIsSpqvaJLAksQx8QdFgYkce8njmGJRHEMR4jxII4htHtJ8Q4iiG2Gz4k4RgoaoHtKLNPntN/WG0SYuuLZo89pjv0ZA6T0pqU9pVZpQw4ExeDc5vGX1gHDCVAALtUYnoddoGblVnJs0ltOSyzPcdJZXNuQMQpwBnmZGTfdhQTt6fE6FqAnkZwZA4A9IxO3Hn0xePbj63T3C3ueP7ShNPY144wy8j5natIYEN7TF5PlnKuWAHE68ebny4KLVYOhJKE9JJXs0luVJKv8A4Mkru65tX6D6cw1tqGpQR6m9u03rCR8ttOykZcerI94k1OV21V5Q8HnpMD6oqVNa8gc/MilgU7gTuY8gS/VNa9SGFuFYnHQ/eatHRaHVbThT1IkQ4q03mFQ7Ed5q0TUtpt6v6m6gnoZFk7Z9b52kuG0ZycZx1ErXdTu3HIc5APadE2tfT5ZpLEdO8gvhupvda0TexHOB0mbyi4y6ZfOvX07sn7z6J4Kjpp0UABQJzfBfABp1DakDd8CelRQigIAAJxvda3pZCISUrBYjjigEWI4SiBEqZPiaIioxJY1rDYkyWpOo9YIma2oTFjUrh6leDOPqqltBRxwZ6TU1DB4nC1iFWyJy8rtO44llJS3CnhenxMKaZ7LDcVJ3NgTs2VhiCSACefmVPZXQRWT6mOAPievhy6cOUM0tXXtCgIq5Y+8ws7XKprB9B5+J0GItrILfwwefkyDacLpTUpC7jkzfrLPrMV0eYvLSGmtDngAEDOZK2kvU2OQuJjrSxDsGcsMCBq5p1AtddwbgmFujrs3XUnknJ+JO8N5ddbH+JjEp8zUaa7ax9JGRkRq5q6u+5Kwti71zjPWWWKK6POpHGeVltdiGh8lRuHt0melrNr0jDI0g0V3g1CqysAOPSw7mSVRdSVY4I+lvaYq1spDVW5ZF5V/aXVaqlhguCR2jGpU6NQ9WoC6is21qQMYnvvCbV1GjVq1KgDGDPEaW82aqvy0y4OMHnM+g6RdtK4UKccgDGJyvpb0sjhiMQwYjgI5ULEeIsyUBRxQgPAhCEAgfiEIBCEIBCOLmARxYjgKEcINKBji6wFzAGPiKA4oQ7wCGI4SBYhGYdpQsRf0kooCjjGIGAsQxHDEBYjwIQzAUI8QxAWfiGY8RYAgGYQxCBSesId4SNDj3hDA9o8QI4iIk4SCoiRK57S7ENojFZykia/iadsNkmGsvlxiuadsNsYaoFYHaSCS7AhiJDVez4ktsliBxKiOI4GGYChjMcJQoQjgKEeIsQFiElFAIf0jhmRBjMMRjMfPtKIgCSwIhxHnmFPEO0IQIlQwwQJg1WkV1IA6/E6XMWB7SWSkteXt8GcsSAf7RJ4CzDJM9OQDFwO0z9Y19687X+zVbnNrQv/ZTTuuK7SpnooZ9pcxPs8XqP2Pv52agMPbEz1/sbfYCbnIPae7wYDM1OVhseCq/Yy42esjb9pq/cavBYXHkdMdJ7QAwEfbl/U6eH037L6m+w03kpSvRsdZb+4zo+adYNvyJ7PB7R44xiX7UcHwz9nxpRi+0t8Ts06eqhdtSKP6S3B9oAGZxdAAkhmISQzKykPeOKOEPMIsQlDjiEIAYQzCAu0gyAyyGJFYbtKWzOPr/AA1ipIE9NIvWrjBEzeGtTnlfOrazW5VwcjpML6Ql2t3ZduB8Ce78S8HF4PlYVvtPP3eBa6snCZAHaTjbxrpc5RwFaw0DSAbSp3FpUl1j3uWJIGAP74luoqs097tcCHPAB7iYzcy8IRk/E7yyuWWOlU+NRbWwxuGAPeDr5bKKwGcdPiYHvJu8zJJ2/wCZdVrzXWQcGxuftLhqOpVqLtzsWs6idHUeRdpq7mHUY+089dZddcbMk89Zdp9aRW1DHIIx16S/VPsvLV7iFfKj/MNNY2mv3A7q24IMhpdImPW/B7yV9S18I4cD+bMuDZ+IRH8stmt/iH4bS+aLq3GSOmJhptrapkbLWA+kAZzN+j0HiFzr5embaehmb0uL9PaKdZTbUNzAgGfQdFa9tYZxgkZnG8O/ZupESzWf9Qc8T0K1hQAOMTju1bmH1jAjxA4lYEI4YxAUeYRygEMQhAMQhHAIoRwFDtHFAcICEBRxRwFiOKEAhCEAwIYhHAWIYjihDihCFAjihAREMfMcMQEBHCOARQhADDEcIChCGeYDiiz2jgGIQhKKeMwjIBPMXSZaHMIxDAhBiHMIQCGIdI5Ao/6whKFCOKARYEcJFRhHiGJURxHiAzDmAQhDHMBR8Q5hAIRRwDHzDEIQFiPGI+8eIUocx4hCCI5zHHiFKHEI8QFmEIfeEIxR4hiFRxD+kliGDIiMfEeIsfELoJgI8D2jx3hAIYgBHiVCxDEliEKQkhAQ4gOOKOVBCEIBDMIQCGIQgEIQgEIoQCIgYjyJHIkVl1Hh+k1Jzdp0YjviZbvAvD3TaunRf6TpwzC68jrP2PR1ZqX2vnicez9k/EFPKpweDPo/HUjMeAfqAMst/DY+dL+yHiFigEoFPXAjq/Yli21rCM959D4AwMSOAOgEfbknTxCfsGxPq1Z25nRo/Yzw+oDfY7kdcng/0npuIRtq64+n8A0FFosWldw6cTrV1JWMIoX7SeMR8zOGiOHMJrGTixHEMwJQzAZ94QCLmPEMQARwhAUcUeICjhCUEUcUgcIo4BCEUoIcRxSAhCEA7xwigAhHFAcIoQHCEUAhCBgGYZhCA4swEIBAmEiesBwixHAXTmAb3gYf0gTyPeEj/SECs9YQMJFEcQhCmIo4QhRxdo4QQh2hAXaEDCAQhHDRQzDEIAYswI4igGY4ojIJcQ4ijlChAHMAIDhCAgEBACEB5hEY4ZOGRFCFOEUID5hFHAIo4oD+0UIQCEIxAIQhAPiHxCMSoBHCEgIQjgGI8RRyghFHAIQhAIZhCAQzCEBRZMDCAoRxSA7RGGe0cKIQjlREiGI4QuliMYEI5AfMMwMBKgjiMIDhDtCAxCKOAZjihmA4QzCUEIRQHmEUcAij4hIFHCHWARRxShxRwgLEIRwFCOKARxRwF1HMcIpARxQgEIQgEQjkcwJQizDMBwizHAQEI4QFiLEceYBg+8IQgf/Z"
            isPinned: false
            pinnedBy: ""
            hasExpired: false
        }
        ListElement {
            timestamp: "1660937930"
            senderId: "0x04d1bed19c523299cbd07ddec7b8949ad7dd923819a68e0b733c9c0bc38cde276bd256f098e755f8f028395c2c91f438a22adaff6caded060b7cc0ef3f470f1234"
            amIsender: false
            senderDisplayName: "Pompie"
            senderOptionalName: "@ghd.statusofus.eth"
            message: "Replying to a sticker message"
            isCurrentUser: true
            contentType: StatusMessage.ContentType.Text
            messageContent: ""
            repeatMessageInfo: true
            profileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDKExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg=="
            isContact: false
            trustIndicator: StatusContactVerificationIcons.TrustedType.Untrustworthy
            hasMention: false
            editMode: false
            isReply: true
            replySenderId: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486dsfkjghyu2cf04"
            replySenderName: "You"
            replySenderEnsName: ""
            replyProfileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDKExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg=="
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Sticker
            replyMessageContent: "https://ipfs.infura.io/ipfs/QmW4rVW3BXYHiDHzD6cDwVZtuvEa6aPyb1bbEnitEA6Hhg"
            isPinned: false
            pinnedBy: ""
            hasExpired: false
        }
        ListElement {
            timestamp: "1660937930"
            senderId: "0x04d1bed19c523299cbd07ddec7b8949ad7dd923819a68e0b733c9c0bc38cde276bd256f098e755f8f028395c2c91f438a22adaff6caded060b7cc0ef3f470f1234"
            amIsender: false
            senderDisplayName: "Pompie"
            senderOptionalName: "@ghd.statusofus.eth"
            message: "Replying to a Audio message"
            isCurrentUser: true
            contentType: StatusMessage.ContentType.Text
            messageContent: ""
            repeatMessageInfo: true
            profileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDKExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg=="
            isContact: false
            trustIndicator: StatusContactVerificationIcons.TrustedType.Untrustworthy
            hasMention: false
            editMode: false
            isReply: true
            replySenderId: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486dsfkjghyu2cf04"
            replySenderName: "You"
            replySenderEnsName: ""
            replyProfileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDKExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg=="
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Audio
            replyMessageContent: "/home/khushboo/Music/SymphonyNo6.mp3"
            isPinned: false
            pinnedBy: ""
            hasExpired: false
        }
        ListElement {
            timestamp: "1660937930"
            senderId: "0x04d1bed19c523299cbd07ddec7b8949ad7dd923819a68e0b733c9c0bc38cde276bd256f098e755f8f028395c2c91f438a22adaff6caded060b7cc0ef3f470f1234"
            amIsender: false
            senderDisplayName: "Pumba"
            senderOptionalName: "@quite.statusofus.eth"
            message: "This is me"
            isCurrentUser: true
            contentType: StatusMessage.ContentType.Sticker
            messageContent: "https://ipfs.infura.io/ipfs/QmW4rVW3BXYHiDHzD6cDwVZtuvEa6aPyb1bbEnitEA6Hhg"
            repeatMessageInfo: true
            profileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDKExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg=="
            isContact: false
            trustIndicator: StatusContactVerificationIcons.TrustedType.Verified
            hasMention: false
            editMode: false
            isReply: false
            replySenderId: ""
            replySenderName: ""
            replyProfileImage: ""
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Text
            replyMessageContent: ""
            isPinned: false
            pinnedBy: ""
            hasExpired: false
        }
        ListElement {
            timestamp: "1660937930"
            senderId: "0x04d1bed19c523299cbd07ddec7b8949ad7dd923819a68e0b733c9c0bc38cde276bd256f098e755f8f028395c2c91f438a22adaff6caded060b7cc0ef3f470f1234"
            amIsender: true
            senderDisplayName: "You"
            senderOptionalName: "@ghd.statusofus.eth"
            message: ""
            isCurrentUser: true
            contentType: StatusMessage.ContentType.Image
            messageContent: "https://placekitten.com/600/400"
            repeatMessageInfo: true
            profileImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDKExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg=="
            isContact: true
            trustIndicator: StatusContactVerificationIcons.TrustedType.None
            hasMention: false
            editMode: false
            isReply: false
            replySenderId: ""
            replySenderName: ""
            replyProfileImage: ""
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Text
            replyMessageContent: ""
            isPinned: false
            pinnedBy: ""
            hasExpired: false
        }
        ListElement {
            timestamp: "1657937930"
            amIsender: false
            senderId: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04"
            senderDisplayName: "Teenage Mutant Turtle"
            senderOptionalName: ""
            profileImage: ""
            contentType: StatusMessage.ContentType.Text
            message: 'Simple text message from another user with reactions'
            messageContent: ""
            isContact: false
            trustIndicator: StatusContactVerificationIcons.TrustedType.None
            hasMention: false
            editMode: false
            isReply: false
            replySenderId: ""
            replySenderName: ""
            replyProfileImage: ""
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Text
            replyMessageContent: ""
            isPinned: false
            pinnedBy: ""
            hasExpired: false
            reactions: [
                ListElement {
                    numberOfReactions: 2
                    didIReactWithThisEmoji: false
                    jsonArrayOfUsersReactedWithThisEmoji: '["User 1", "User 3"]'
                    emojiId: 1
                },
                ListElement {
                    numberOfReactions: 3
                    didIReactWithThisEmoji: true
                    jsonArrayOfUsersReactedWithThisEmoji: '["Teenage Mutant Turtle", "User 1", "User 3"]'
                    emojiId: 3
                },
                ListElement {
                    numberOfReactions: 1
                    didIReactWithThisEmoji: false
                    jsonArrayOfUsersReactedWithThisEmoji: '["User 3"]'
                    emojiId: 4
                }
            ]
        }
        ListElement {
            timestamp: "1657937930"
            amIsender: true
            senderId: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04"
            userName: "You"
            ensName: ""
            localName: ""
            profileImage: ""
            contentType: StatusMessage.ContentType.Text
            message: 'Simple text message from current user with reactions'
            messageContent: ""
            isContact: false
            trustIndicator: StatusContactVerificationIcons.TrustedType.None
            hasMention: false
            editMode: false
            isReply: false
            replySenderId: ""
            replySenderName: ""
            replyProfileImage: ""
            replyMessageText: ""
            replyAmISender: false
            replyContentType: StatusMessage.ContentType.Text
            replyMessageContent: ""
            isPinned: false
            pinnedBy: ""
            hasExpired: false
            reactions: [
                ListElement {
                    numberOfReactions: 2
                    didIReactWithThisEmoji: false
                    jsonArrayOfUsersReactedWithThisEmoji: '["User 1", "User 3"]'
                    emojiId: 1
                },
                ListElement {
                    numberOfReactions: 3
                    didIReactWithThisEmoji: true
                    jsonArrayOfUsersReactedWithThisEmoji: '["Teenage Mutant Turtle", "User 1", "User 3"]'
                    emojiId: 3
                },
                ListElement {
                    numberOfReactions: 1
                    didIReactWithThisEmoji: false
                    jsonArrayOfUsersReactedWithThisEmoji: '["User 3"]'
                    emojiId: 4
                }
            ]
        }
    }

    property var membersListModel: ListModel {
        id: membersList
        ListElement {
            localNickname: "This is an example"
            displayName: "Maria"
            pubKey: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04"
            isVerified: true
            isUntrustworthy: false
            isContact: true
            isImage: true
            onlineStatus: 1
            icon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/
                          nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
            isAdmin: false
        }
        ListElement {
            localNickname: ""
            displayName: "carmen.eth"
            pubKey: "0x043a7ed78362567894688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04"
            isVerified: false
            isUntrustworthy: true
            isContact: false
            isImage: false
            onlineStatus: 0
            icon: ""
            isAdmin: false
        }
        ListElement {
            localNickname: "This girl I know from work"
            displayName: "annabelle"
            pubKey: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486dsfkjghyu2cf04"
            isVerified: false
            isUntrustworthy: false
            isContact: false
            isImage: true
            onlineStatus: 1
            isAdmin: false
            icon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAiElEQVR4nOzXUQpAQBRGYWQvLNAyLJDV8C5qpiGnv/M9al5Ot27X0IUwhMYQGkNoDKGJCRlLH67bftx9X+ap/+P9VcxEDK
                     ExhKZ4a9Uq3TZviZmIITSG0DRvlqcbqVbrlouZiCE0htD4h0hjCI0hNN5aNIbQGKKPxEzEEBpDaAyhMYTmDAAA//+gYCErzmCpCQAAAABJRU5ErkJggg=="
        }
        ListElement {
            localNickname: "Mark Cuban"
            displayName: "mark.eth"
            pubKey: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc79872cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04"
            isVerified: false
            isUntrustworthy: true
            isContact: true
            isImage: false
            onlineStatus: 0
            icon: ""
            isAdmin: false
        }
    }

    //    App Section Types:
    //    chat: 0
    //    community: 1
    //    wallet: 2
    //    browser: 3
    //    nodeManagement: 4
    //    profileSettings: 5
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
            sectionId: "examples"
            sectionType: 101
            name: "Examples"
            active: false
            image: ""
            icon: "show"
            color: ""
            hasNotification: false
            notificationsCount: 0
        }
        ListElement {
            sectionId: "demoApp"
            sectionType: 102
            name: "Demo Application"
            active: false
            image: ""
            icon: "status"
            color: ""
            hasNotification: false
            notificationsCount: 0
        }
        ListElement {
            sectionId: "qrScanner"
            sectionType: 103
            name: "QR Scanner"
            active: false
            image: ""
            icon: "qr-scan"
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
            sectionId: "communitiesPortal"
            sectionType: 2
            name: "Communities Portal"
            active: false
            image: ""
            icon: "communities"
            color: ""
            hasNotification: false
            notificationsCount: 0
        }
        ListElement {
            sectionId: "wallet"
            sectionType: 3
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
            sectionType: 4
            name: "Browser"
            active: false
            image: ""
            icon: "bigger/browser"
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

    property ListModel currencyPickerModel: ListModel {
        ListElement {
            key: 0
            name: "United States Dollar"
            shortName: "USD"
            symbol: "$"
            imageSource: "../../assets/twemoji/svg/1f4b4.svg"
            category: ""
            selected: false
        }
        ListElement {
            key: 1
            name: "British Pound"
            shortName: "GBP"
            symbol: "£"
            imageSource: "../../assets/twemoji/svg/1f4b5.svg"
            category: ""
            selected: false
        }
        ListElement {
            key: 2
            name: "Euro"
            shortName: "EUR"
            symbol: "€"
            imageSource: "../../assets/twemoji/svg/1f4b6.svg"
            category: ""
            selected: true
        }
        ListElement {
            key: 3
            name: "Shout Korean Won"
            shortName: "KRW"
            symbol: "₩"
            imageSource: "../../assets/twemoji/svg/1f4b8.svg"
            category: ""
            selected: false
        }
        ListElement {
            key: 4
            name: "Ethereum"
            shortName: "ETH"
            symbol: "Ξ"
            imageSource: "../../assets/twemoji/svg/1f4b7.svg"
            category: "Tokens"
            selected: true
        }
        ListElement {
            key: 5
            name: "Bitcoin"
            shortName: "BTC"
            symbol: "฿"
            imageSource: "../../assets/twemoji/svg/1f4b4.svg"
            category: "Tokens"
            selected: false
        }
        ListElement {
            key: 6
            name: "Status Network Token"
            shortName: "SNT"
            symbol: ""
            imageSource: "../../assets/twemoji/svg/1f4b8.svg"
            category: "Tokens"
            selected: false
        }

        ListElement {
            key: 7
            name: "Emirati Dirham"
            shortName: "AED"
            symbol: "د.إ"
            imageSource: "../../assets/twemoji/svg/1f4b4.svg"
            category: "Other Fiat"
            selected: false
        }
        ListElement {
            key: 8
            name: "Afghani"
            shortName: "AFN"
            symbol: "؋"
            imageSource: "../../assets/twemoji/svg/1f4b7.svg"
            category: "Other Fiat"
            selected: false
        }
        ListElement {
            key: 9
            name: "Argentine Peso"
            shortName: "AFN"
            symbol: "$"
            imageSource: "../../assets/twemoji/svg/1f4b4.svg"
            category: "Other Fiat"
            selected: false
        }
    }

    property ListModel currencyPickerModel2: ListModel {
        ListElement {
            key: 0
            name: "United States Dollar"
            shortName: "USD"
            symbol: "$"
            imageSource: "../../assets/twemoji/svg/1f4b4.svg"
            category: ""
            selected: false
        }
        ListElement {
            key: 1
            name: "British Pound"
            shortName: "GBP"
            symbol: "£"
            imageSource: "../../assets/twemoji/svg/1f4b5.svg"
            category: ""
            selected: false
        }
        ListElement {
            key: 2
            name: "Euro"
            shortName: "EUR"
            symbol: "€"
            imageSource: "../../assets/twemoji/svg/1f4b6.svg"
            category: ""
            selected: true
        }
        ListElement {
            key: 3
            name: "Shout Korean Won"
            shortName: "KRW"
            symbol: "₩"
            imageSource: "../../assets/twemoji/svg/1f4b8.svg"
            category: ""
            selected: false
        }
        ListElement {
            key: 4
            name: "Ethereum"
            shortName: "ETH"
            symbol: "Ξ"
            imageSource: "../../assets/twemoji/svg/1f4b7.svg"
            category: "Tokens"
            selected: true
        }
        ListElement {
            key: 5
            name: "Bitcoin"
            shortName: "BTC"
            symbol: "฿"
            imageSource: "../../assets/twemoji/svg/1f4b4.svg"
            category: "Tokens"
            selected: false
        }
        ListElement {
            key: 6
            name: "Status Network Token"
            shortName: "SNT"
            symbol: ""
            imageSource: "../../assets/twemoji/svg/1f4b8.svg"
            category: "Tokens"
            selected: false
        }

        ListElement {
            key: 7
            name: "Emirati Dirham"
            shortName: "AED"
            symbol: "د.إ"
            imageSource: "../../assets/twemoji/svg/1f4b4.svg"
            category: "Other Fiat"
            selected: false
        }
        ListElement {
            key: 8
            name: "Afghani"
            shortName: "AFN"
            symbol: "؋"
            imageSource: "../../assets/twemoji/svg/1f4b7.svg"
            category: "Other Fiat"
            selected: false
        }
        ListElement {
            key: 9
            name: "Argentine Peso"
            shortName: "AFN"
            symbol: "$"
            imageSource: "../../assets/twemoji/svg/1f4b4.svg"
            category: "Other Fiat"
            selected: false
        }
    }

    property ListModel languagePickerModel: ListModel {
        ListElement {
            key: 0
            name: "English"
            shortName: "English"
            imageSource: "../../assets/twemoji/svg/1f1ec-1f1e7.svg"
            category: ""
            selected: false
        }
        ListElement {
            key: 1
            name: "Korean"
            shortName: "한국어"
            imageSource: "../../assets/twemoji/svg/1f1f0-1f1f7.svg"
            category: ""
            selected: false
        }
        ListElement {
            key: 2
            name: "Portuguese (Brazilian)"
            shortName: "Português"
            imageSource: "../../assets/twemoji/svg/1f1e7-1f1f7.svg"
            category: ""
            selected: true
        }
        ListElement {
            key: 3
            name: "Dutch"
            shortName: "Nederlands"
            imageSource: "../../assets/twemoji/svg/1f1f3-1f1f1.svg"
            category: "Beta Languages"
            selected: false
        }
        ListElement {
            key: 4
            name: "Indonesian"
            shortName: "Bahasa Indonesia"
            imageSource: "../../assets/twemoji/svg/1f1ee-1f1e9.svg"
            category: "Beta Languages"
            selected: false
        }
        ListElement {
            key: 5
            name: "Spanish"
            shortName: "Español"
            imageSource: "../../assets/twemoji/svg/1f1ea-1f1e6.svg"
            category: "Beta Languages"
            selected: false
        }
    }

    property ListModel languageNoImagePickerModel: ListModel {
        ListElement {
            key: 0
            name: "Chinese (Mainland China)"
            shortName: "普通话"
            category: ""
            selected: true
        }
        ListElement {
            key: 1
            name: "Russian"
            shortName: "Русский Язык"
            category: ""
            selected: false
        }
        ListElement {
            key: 2
            name: "Arabic"
            shortName: "اَلْعَرَبِيَّةُ"
            category: "Beta Languages"
            selected: true
        }
        ListElement {
            key: 3
            name: "Chinese (Taiwan)"
            shortName: "臺灣華語"
            category: "Beta Languages"
            selected: false
        }
        ListElement {
            key: 4
            name: "Filipino"
            shortName: "Wikang Filipino"
            category: "Beta Languages"
            selected: false
        }
        ListElement {
            key: 5
            name: "French"
            shortName: "Français"
            category: "Beta Languages"
            selected: false
        }
        ListElement {
            key: 6
            name: "Italian"
            shortName: "Italiano"
            category: "Beta Languages"
            selected: false
        }
        ListElement {
            key: 7
            name: "Turkish"
            shortName: "Türkçe"
            category: "Beta Languages"
            selected: false
        }
        ListElement {
            key: 8
            name: "Urdu"
            shortName: "اُردُو"
            category: "Beta Languages"
            selected: false
        }
    }

    property ListModel featuredCommunitiesModel : ListModel {
        ListElement {
            name: "CryptoKitties";
            description: "A community of cat lovers, meow!";
            logo:"qrc:/images/CryptoKitties.png";
            members: 1045;
            categories: [];
            communityId: "341";
            available: true;
            popularity: 1;
            communityColor: "pink"
        }
        ListElement {
            name: "Friends with Benefits";
            description: "A group chat full of out favorite thinkers and creators.";
            logo:"qrc:/images/FriendsBenefits.png";
            members: 452;
            categories: [];
            communityId: "232";
            available: true;
            popularity: 2;
            communityColor: "grey"
        }
        ListElement {
            name: "Status Hi!!";
            description: "A new community description with long long long and repetitive repetitive repetitive repetitive explanation!!";
            logo:"qrc:/images/SNT.png";
            members: 89;
            categories: [];
            communityId: "223";
            available: true;
            popularity: 3
            communityColor: "blue"
        }
    }

    property ListModel curatedCommunitiesModel : ListModel {
        ListElement {
            name: "Status.im";
            description: "Your portal to Web3. Secure wallet. dApp browser. Private messaging. All-in-one.";
            logo: "qrc:/images/SNT.png";
            banner: "qrc:/images/CommunityBanner1.png";
            members: 299500;
            activeUsers: 71400;
            categories: [];
            communityId: "1";
            available: true;
            popularity: 1
            isPrivate: true
            tokenLogo: "qrc:/images/SNT.png";
        }
        ListElement {
            name: "SuperRare";
            description: "The future of CryptoArt markets—a network governed by artists, collectors and curators.";
            logo:"qrc:/images/SR.png";
            banner: "qrc:/images/SuperRareCommunityBanner.png";
            members: 299500;
            activeUsers: 71400;
            categories: [];
            communityId: "2";
            available: true;
            popularity: 2
            isPrivate: true
            tokenLogo: "qrc:/images/SRToken.png";
        }
        ListElement {
            name: "Coinbase";
            description: "Jump start your crypto portfolio with the easiest place to buy and sell crypto. ";
            logo:"qrc:/images/Coinbase.png";
            banner: "qrc:/images/CoinBaseCommunityBanner.png";
            members: 4900000;
            activeUsers: 245600;
            categories: [];
            communityId: "3";
            available: true;
            popularity: 3
            isPrivate: false
            tokenLogo: "";
        }
        ListElement {
            name: "Rarible";
            description: "Multichain community-centric NFT marketplace. Create, sell and collect NFTs.";
            logo:"qrc:/images/Rarible.png";
            banner: "qrc:/images/RaribleCommunityBanner.png";
            members: 629200;
            activeUsers: 112100;
            categories: [];
            communityId: "4";
            available: true;
            popularity: 4
            isPrivate: true
            tokenLogo: "qrc:/images/RARI.png";
        }
        ListElement {
            name: "Spotify";
            description: "Listening is everything";
            logo:"qrc:/images/Spotify.png";
            banner: "qrc:/images/SpotifyCommunityBanner.png";
            members: 207500;
            activeUsers: 52200;
            categories: [];
            communityId: "5";
            available: true;
            popularity: 5
            isPrivate: false
            tokenLogo: "";
        }
        ListElement {
            name: "Dribbble";
            description: "Open source platform to write and distribute decentralized applications..";
            logo:"qrc:/images/Fluff.png";
            banner: "qrc:/images/DribbbleCommunityBanner.png";
            members: 2300000;
            activeUsers: 112100;
            categories: [];
            communityId: "6";
            available: true;
            popularity: 6
            isPrivate: false
            tokenLogo: "";
        }
        ListElement {
            name: "Status.im";
            description: "Your portal to Web3. Secure wallet. dApp browser. Private messaging. All-in-one.";
            logo:"qrc:/images/SNT.png";
            banner: ""
            members: 299500;
            activeUsers: 71400;
            categories: [];
            communityId: "7";
            available: true;
            popularity: 1
            isPrivate: false
            tokenLogo: "";
        }
        ListElement {
            name: "CryptoPunks";
            description: "Community description goes here. Community description goes here. Community description goes here. Community description goes here. Community description goes here. Community description goes here.";
            logo:"qrc:/images/CryptoPunks.png";
            banner: "";
            members: 4900;
            activeUsers: 245600;
            categories: [];
            communityId: "8";
            available: false;
            popularity: 8
            isPrivate: false
            tokenLogo: "";
        }
        ListElement {
            name: "Socks";
            description: "Community description goes here.";
            logo:"qrc:/images/Socks.png";
            banner: "";
            members: 4900;
            activeUsers: 245600;
            categories: [];
            communityId: "9";
            available: false;
            popularity: 9
            isPrivate: false
            tokenLogo: "";
        }
    }

    property ListModel tagsModel : ListModel {
        ListElement { name: "gaming"; emoji: "🎮"}
        ListElement { name: "art"; emoji: "🖼️️"}
        ListElement { name: "crypto"; emoji: "💸"}
        ListElement { name: "nsfw"; emoji: "🍆"}
        ListElement { name: "markets"; emoji: "💎"}
        ListElement { name: "defi"; emoji: "📈"}
        ListElement { name: "travel"; emoji: "🚁"}
        ListElement { name: "web3"; emoji: "🗺"}
        ListElement { name: "sport"; emoji: "🎾"}
        ListElement { name: "food"; emoji: "🥑"}
        ListElement { name: "enviroment"; emoji: "☠️"}
        ListElement { name: "privacy"; emoji: "👻"}
    }

    property var communityTags :{"Activism":"✊","Art":"🎨","Blockchain":"🔗","Books & blogs":"📚","Career":"💼","Collaboration":"🤝","Commerce":"🛒","Crypto":"Ξ","Culture":"🎎","DAO":"🚀","DIY":"🔨","DeFi":"📈","Design":"🧩","Education":"🎒","Entertainment":"🍿","Environment":"🌿","Event":"🗓","Fantasy":"🧙‍♂️","Fashion":"🧦","Food":"🌶","Gaming":"🎮","Global":"🌍","Health":"🧠","Hobby":"📐","Innovation":"🧪","Language":"📜","Lifestyle":"✨","Local":"📍","Love":"❤️","Markets":"💎","Movies & TV":"🎞","Music":"🎶","NFT":"🖼","NSFW":"🍆","News":"🗞","Non-profit":"🙏","Org":"🏢","Pets":"🐶","Play":"🎲","Podcast":"🎙️","Politics":"🗳️","Privacy":"👻","Product":"🍱","Psyche":"🍁","Security":"🔒","Social":"☕","Software dev":"👩‍💻","Sports":"⚽️","Tech":"📱","Travel":"🗺","Vehicles":"🚕","Web3":"🌐"}
}
