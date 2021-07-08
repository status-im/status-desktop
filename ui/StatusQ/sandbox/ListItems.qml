import QtQuick 2.14
import QtQuick.Layouts 1.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

GridLayout {
    columns: 1
    columnSpacing: 5
    rowSpacing: 5

    StatusNavigationListItem {
        title: "Menu Item"
    }

    StatusNavigationListItem {
        title: "Menu Item"
        icon.name: "info"
    }

    StatusNavigationListItem {
        title: "Menu Item"
        icon.name: "info"
        badge.value: 1
    }
    StatusNavigationListItem {
        title: "Menu Item (selected)"
        selected: true
        icon.name: "info"
        badge.value: 1
    }

    StatusChatListItem {
        id: test
        name: "public-channel"
        type: StatusChatListItem.Type.PublicChat
    }

    StatusChatListCategoryItem {
        title: "Chat list category"
        opened: false
        showActionButtons: true
    }

    StatusChatListCategoryItem {
        title: "Chat list category (opened)"
        opened: true
        showActionButtons: true
    }

    StatusChatListCategoryItem {
        title: "Chat list category (no buttons)"
        opened: true
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
        name: "community-channel-with-image"
        image.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
        type: StatusChatListItem.Type.CommunityChat
    }

    StatusChatListItem {
        name: "Weird Crazy Otter"
        image.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
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
        badge.value: 1
    }

    StatusChatListItem {
        name: "is-muted"
        type: StatusChatListItem.Type.PublicChat
        muted: true
        onUnmute: muted = false
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
        icon.name: "info"
    }


    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        image.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        icon.name: "info"
        components: [StatusButton {
            text: "Button"
            size: StatusBaseButton.Size.Small
        }]
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        icon.name: "info"
        components: [StatusSwitch {}]
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        icon.name: "info"
        components: [StatusRadioButton {}]
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        icon.name: "info"
        components: [StatusCheckBox {}]
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        icon.name: "info"
        label: "Text"
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        icon.name: "info"
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
        icon.name: "info"
        label: "Text"
        components: [StatusSwitch {}]
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        icon.name: "info"
        label: "Text"
        components: [
          StatusRadioButton {}
        ]
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        icon.name: "info"
        label: "Text"
        components: [StatusCheckBox {}]
    }

    StatusListItem {
        title: "Title"
        subTitle: "Subtitle"
        icon.name: "info"
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
        icon.name: "info"
        type: StatusListItem.Type.Secondary
    }

    StatusListItem {
        title: "Title"
        icon.isLetterIdenticon: true
        icon.background.color: "orange"
    }

    StatusDescriptionListItem {
        title: "Title"
        subTitle: "Subtitle"
    }

    StatusDescriptionListItem {
        title: "Title"
        subTitle: "Subtitle"
        tooltip.text: "Tooltip"
        icon.name: "info"
        iconButton.onClicked: tooltip.visible = !tooltip.visible
    }

    StatusContactRequestsIndicatorListItem {
        title: "Contact requests"
        requestsCount: 3
    }
}
