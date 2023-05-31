import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQml.Models 2.14
import QtQuick.Layouts 1.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1

ColumnLayout {
    spacing: 5

    StatusNavigationListItem {
        title: "Menu Item"
    }

    StatusNavigationListItem {
        title: "Menu Item"
        asset.name: "info"
    }

    StatusNavigationListItem {
        title: "Menu Item"
        asset.name: "info"
        badge.value: 1
    }
    StatusNavigationListItem {
        title: "Menu Item (selected) with very long text"
        selected: true
        asset.name: "info"
        badge.value: 1
    }

    StatusChatListItem {
        id: test
        name: "public-channel"
        type: StatusChatListItem.Type.PublicChat
    }

    StatusChatListCategoryItem {
        text: "Chat list category"
        opened: false
        showActionButtons: true
    }

    StatusChatListCategoryItem {
        text: "Chat list category (opened)"
        opened: true
        showActionButtons: true
    }

    StatusChatListCategoryItem {
        text: "Chat list category (no buttons)"
        opened: true
    }

    StatusChatListCategoryItem {
        id: categoryItemInteractive
        text: "Chat category interactive"
        showActionButtons: true
        onAddButtonClicked: testEventsList.eventTriggered("Add button clicked")
        onMenuButtonClicked: testEventsList.eventTriggered("Menu button clicked")
        onToggleButtonClicked: {
            opened = !opened
            testEventsList.eventTriggered("Toggle button clicked")
        }
        onClicked: {
            opened = !opened
            testEventsList.eventTriggered("Item clicked", itemId)
        }
    }

    ListView {
        id: testEventsList

        Layout.fillWidth: true
        Layout.preferredHeight: categoryItemInteractive.opened ? 20 * count : 0

        clip: true

        function eventTriggered(message) {
            let obj = eventDelegateComponent.createObject()
            obj.text = message
            model.insert(0, obj)
        }

        Component {
            id: eventDelegateComponent

            ItemDelegate {
                implicitHeight: 20

                property int index: ObjectModel.index

                Timer {
                    interval: 5000; running: true
                    onTriggered: testObjectModel.remove(index)
                }
            }
        }

        model: ObjectModel {
            id: testObjectModel
        }
    }

    StatusChatListItem {
        name: "group-chat"
        type: StatusChatListItem.Type.GroupChat
    }

    StatusChatListItem {
        name: "community-channel"
        type: StatusChatListItem.Type.CommunityChat
    }

    StatusChatListItem {
        name: "community-channel-emoji"
        type: StatusChatListItem.Type.CommunityChat
        asset.emoji: "😁"
    }

    StatusChatListItem {
        name: "community-channel-with-image"
        asset.isImage: true
        asset.name: "qrc:/demoapp/data/profile-image-1.jpeg"
        type: StatusChatListItem.Type.CommunityChat
    }

    StatusChatListItem {
        name: "Weird Crazy Otter"
        asset.isImage: true
        asset.name: "qrc:/demoapp/data/profile-image-1.jpeg"
        type: StatusChatListItem.Type.OneToOneChat
    }

    StatusChatListItem {
        name: "has-unread-messages"
        type: StatusChatListItem.Type.PublicChat
        hasUnreadMessages: true
    }

    StatusChatListItem {
        name: "has-mentions"
        type: StatusChatListItem.Type.PublicChat
        hasUnreadMessages: true
        notificationsCount: 1
    }

    StatusChatListItem {
        name: "is-muted"
        type: StatusChatListItem.Type.PublicChat
        muted: true
        onUnmute: muted = false
    }

    StatusChatListItem {
        name: "muted-with-mentions"
        type: StatusChatListItem.Type.PublicChat
        muted: true
        hasUnreadMessages: true
        notificationsCount: 1
    }

    StatusChatListItem {
        name: "selected-channel"
        type: StatusChatListItem.Type.PublicChat
        selected: true
    }

    StatusChatListItem {
        name: "selected-muted-channel"
        type: StatusChatListItem.Type.PublicChat
        selected: true
        muted: true
    }

    StatusChatListItem {
        name: "selected-muted-channel-with-unread-messages"
        type: StatusChatListItem.Type.PublicChat
        selected: true
        muted: true
        hasUnreadMessages: true
    }

    StatusChatListItem {
        name: "selected-muted-with-mentions"
        type: StatusChatListItem.Type.PublicChat
        selected: true
        muted: true
        hasUnreadMessages: true
        notificationsCount: 1
    }


    StatusListItem {
        title: "Title"
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        tertiaryTitle: "Tertiary title"

        statusListItemTitle.font.pixelSize: 17
        statusListItemTitle.font.weight: Font.Bold
    }

    StatusListItem {
        title: "Title"
        subTitle: "Super long description that causes a multiline paragraph and makes the size of the component grow. Let's see how it behaves."
        tertiaryTitle: "Tertiary title"
        asset.name: "info"

        statusListItemTitle.font.pixelSize: 17
        statusListItemTitle.font.weight: Font.Bold
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        asset.name: "info"
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        asset.isImage: true
        asset.name: "qrc:/demoapp/data/profile-image-1.jpeg"
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        asset.isImage: true
        asset.name: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/
                      nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
        asset.imgIsIdenticon: true
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        asset.name: "info"
        components: [StatusButton {
            text: "Button"
            size: StatusBaseButton.Size.Small
        }]
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        asset.name: "info"
        components: [StatusSwitch {}]
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        asset.name: "info"
        components: [StatusRadioButton {}]
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        asset.name: "info"
        components: [StatusCheckBox {}]
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        asset.name: "info"
        label: "Text"
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        asset.name: "info"
        label: "Text"
        components: [
            StatusButton {
                text: "Button"
                size: StatusBaseButton.Size.Small
            }
        ]
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        asset.name: "info"
        label: "Text"
        components: [StatusSwitch {}]
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        asset.name: "info"
        label: "Text"
        components: [
          StatusRadioButton {}
        ]
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        asset.name: "info"
        label: "Text"
        components: [StatusCheckBox {}]
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        asset.name: "info"
        label: "Text"
        components: [
            StatusBadge {
                value: 1
            },
            StatusIcon {
                icon: "info"
                color: Theme.palette.baseColor1
                width: 20
                height: 20
            }
        ]
    }

    StatusListItem {
        title: "Title"
        asset.name: "info"
        type: StatusListItem.Type.Secondary
    }

    StatusListItem {
        title: "Title"
        asset.isLetterIdenticon: true
        asset.color: "orange"
    }

    StatusListItem {
        title: "Title"
        titleAsideText: "test"
    }

    StatusListItem {
        title: "Title"
        asset.name: "delete"
        type: StatusListItem.Type.Danger
    }

    StatusListItem {
        title: "List Item with Badge"
        subTitle: "Subtitle"
        asset.isImage: true
        asset.name: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/
                      nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
        asset.imgIsIdenticon: true
        badge.asset.isImage: true
        badge.asset.name: "qrc:/demoapp/data/profile-image-1.jpeg"
        badge.primaryText: "CryptoKitties"
        badge.secondaryText: "#test"
    }

    StatusListItem {
        title: "List Item with Badge 2"
        subTitle: "Subtitle"
        asset.isLetterIdenticon: true
        badge.primaryText: "CryptoKitties"
        badge.secondaryText: "#test"
        badge.asset.color: "orange"
        badge.asset.isLetterIdenticon: true
    }

    StatusListItem {
        title: "List Item with bottom Tags"
        asset.isLetterIdenticon: true
        bottomModel: 3
        bottomDelegate: StatusListItemTag {
            title: "tag"
            asset.isLetterIdenticon: true
        }
    }

    StatusListItem {
        title: "List Item with Tags"
        asset.isLetterIdenticon: true
        tagsModel: ListModel{
            ListElement {
                name: "helloworld.eth"
                emoji: "😁"
            }
            ListElement {
                name: "account1"
                emoji: "😁"
            }
            ListElement {
                name: "account2"
                emoji: "😁"
            }
            ListElement {
                name: "account3"
                emoji: "😁"
            }
            ListElement {
                name: "account4"
                emoji: "😁"
            }
        }
        tagsDelegate: StatusListItemTag {
            bgColor: "blue"
            bgRadius: 6
            height: 24
            closeButtonVisible: false
            asset.emoji: model.emoji
            asset.emojiSize: Emoji.size.verySmall
            asset.isLetterIdenticon: true
            title: model.name
            titleText.font.pixelSize: 12
            titleText.color: Theme.palette.indirectColor1
        }
    }

    StatusListItem {
        implicitWidth: 600
        title: "List Item with inline Tags"
        subTitle: "03:32"
        asset.isLetterIdenticon: true
        inlineTagModel: 6
        inlineTagDelegate: StatusListItemTag {
            height: 24
            title: "tag"
            asset.isLetterIdenticon: true
        }
        components: [
            ColumnLayout {
                Row {
                    Layout.alignment: Qt.AlignRight
                    spacing: 4
                    StatusIcon {
                        color:  Theme.palette.successColor1
                        icon: "arrow-up"
                        rotation: 135
                        height: 18
                    }
                    StatusBaseText {
                        text: "0.0000015 ETH"
                        font.pixelSize: 15
                        color: Theme.palette.directColor1
                    }
                }
                StatusBaseText {
                    Layout.alignment: Qt.AlignRight
                    text: "1201.10 USD"
                    font.pixelSize: 15
                    color: Theme.palette.baseColor1
                }
            }
        ]
    }

    StatusListItem {
        title: "List Item with Emoji"
        subTitle: "Emoji"
        asset.emoji: "😁"
        asset.color: "yellow"
        asset.letterSize: 14
        asset.isLetterIdenticon: true
    }

    StatusDescriptionListItem {
        title: "Title"
        subTitle: "Subtitle"
    }

    StatusDescriptionListItem {
        title: "Title"
        subTitle: "Very long subtitle with icon to see it wrap words when overflown"
        value: "None"
        sensor.enabled: true
        asset.name: "copy"
    }

    StatusDescriptionListItem {
        title: "Title"
        subTitle: "Subtitle"
        tooltip.text: "Tooltip"
        asset.name: "info"
        iconButton.onClicked: tooltip.visible = !tooltip.visible
    }

    StatusContactRequestsIndicatorListItem {
        title: "Contact requests"
        requestsCount: 3
    }

    StatusMemberListItem {
        nickName: "This is an example"
        userName: "annabelle"
        pubKey: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04"
        isVerified: true
        isContact: true
        asset.isImage: true
        asset.name: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/
                      nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
        asset.imgIsIdenticon: true
        status: 1 // FIXME: use enum
        ringSettings.ringSpecModel:
            ListModel {
                ListElement {colorId: 13; segmentLength: 5}
                ListElement {colorId: 31; segmentLength: 5}
                ListElement {colorId: 10; segmentLength: 1}
                ListElement {colorId: 2; segmentLength: 5}
                ListElement {colorId: 26; segmentLength: 2}
                ListElement {colorId: 19; segmentLength: 4}
                ListElement {colorId: 28; segmentLength: 3}
            }
        ringSettings.distinctiveColors: Theme.palette.identiconRingColors
    }

    StatusMemberListItem {
        nickName: "carmen.eth"
        isUntrustworthy: true
        asset.isLetterIdenticon: true
    }

    StatusMemberListItem {
        nickName: "very-long-annoying-nickname.eth"
        isUntrustworthy: true
        asset.isLetterIdenticon: true
    }

    StatusMemberListItem {
        nickName: "untrusted-admin.eth"
        asset.isLetterIdenticon: true
        isUntrustworthy: true
        isAdmin: true
        isContact: true
    }

    StatusMemberListItem {
        nickName: "This girl I know from work"
        userName: "annabelle"
        asset.isLetterIdenticon: true
        status: 1 // FIXME: use enum
    }

    StatusMemberListItem {
        nickName: "Mark Cuban"
        userName: "annabelle"
        pubKey: "0x043a7ed0e8752236a4688563652fd0296453cef00a5dcddbe252dc74f72cc1caa97a2b65e4a1a52d9c30a84c9966beaaaf6b333d659cbdd2e486b443ed1012cf04"
        isContact: true
        asset.isImage: true
        asset.name: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/
                       nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
        asset.imgIsIdenticon: true
    }

    StatusMemberListItem {
        nickName: "admin.guy"
        userName: "adguy"
        isAdmin: true
        asset.isLetterIdenticon: true
        isUntrustworthy: true
    }

    StatusBaseText {
        Layout.fillWidth: true
        Layout.topMargin: 16
        text: "Device delegate with online badge"
        font.pixelSize: 17
    }

    component DeviceListItem: StatusListItem {
        title: "Nokia 3310"
        asset.name: "mobile"
        asset.bgColor: Theme.palette.primaryColor3
        asset.color: Theme.palette.primaryColor1
    }

    DeviceListItem {
        subTitle: "Online now"
        subTitleBadgeComponent: StatusOnlineBadge {
            online: true
        }
    }

    DeviceListItem {
        subTitle: "Online 47 minutes ago"
        subTitleBadgeComponent: StatusOnlineBadge {
            online: false
        }
    }

    DeviceListItem {
        subTitle: "This device"
        subTitleBadgeComponent: null
    }
}
