import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import Sandbox 0.1

GridLayout {
    columns: 1
    columnSpacing: 5
    rowSpacing: 5

    StatusSelectableText {
        color: Theme.palette.baseColor1
        text: "This is a multiline paragraph that can be selected and copied. A paragraph is a group of words put together to form a group that is usually longer than a sentence. Paragraphs are often made up of several sentences. There are usually between three and eight sentences. Paragraphs can begin with an indentation (about five spaces), or by missing a line out, and then starting again."
        font.pixelSize: 15
        width: 300
        multiline: true
    }

    StatusSelectableText {
        color: Theme.palette.baseColor1
        text: "<p>This is a selectable link in rich text format to test <a href='www.google.com'>www.google.com</a></p>"
        font.pixelSize: 15
        width: 200
    }

    StatusIconTabButton {
        icon.name: "chat"
    }

    StatusIconTabButton {
        icon.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
    }

    StatusIconTabButton {
        icon.color: Theme.palette.miscColor9
        // This icon source is flawed and demonstrates the fallback case
        // when the image source can't be loaded
        icon.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jp"
        name: "Pascal"
    }

    StatusIconTabButton {
        name: "#status"
    }

    Button {
        text: "Hover me!"
        StatusToolTip {
            visible: parent.hovered
            text: "Top"
        }
        StatusToolTip {
            visible: parent.hovered
            text: "Right"
            orientation: StatusToolTip.Orientation.Right
            x: parent.width + 16
            y: parent.height / 2 - height / 2 + 4
        }
        StatusToolTip {
            visible: parent.hovered
            text: "Bottom"
            orientation: StatusToolTip.Orientation.Bottom
            y: parent.height + 12
        }
        StatusToolTip {
            visible: parent.hovered
            text: "Left"
            orientation: StatusToolTip.Orientation.Left
            x: -parent.width /2 -8
            y: parent.height / 2 - height / 2 + 4
        }
    }

    StatusNavBarTabButton {
        icon.name: "chat"
        tooltip.text: "Chat"
    }

    StatusNavBarTabButton {
        name: "#status"
        tooltip.text: "Some Channel"
    }

    StatusNavBarTabButton {
        icon.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
        tooltip.text: "Some Community"
    }

    StatusNavBarTabButton {
        icon.name: "profile"
        tooltip.text: "Profile"
        badge.value: 0
        badge.visible: true
        badge.anchors.leftMargin:-16
    }

    StatusNavBarTabButton {
        icon.name: "chat"
        tooltip.text: "Chat"
        badge.value: 35
    }

    StatusNavBarTabButton {
        icon.name: "chat"
        tooltip.text: "Chat"
        badge.value: 100
    }

    StatusSwitch {

    }

    StatusRadioButton {
        text: "i'm radio!"
    }

    StatusCheckBox {}

    StatusChatInfoButton {
        title: "Iuri Matias"
        subTitle: "Contact"
        icon.color: Theme.palette.miscColor7
        image.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
        type: StatusChatInfoButton.Type.OneToOneChat
        muted: true
        pinnedMessagesCount: 1
    }

    Item {
        implicitWidth: 100
        implicitHeight: 48
        StatusChatInfoButton {
            title: "Iuri Matias elided"
            subTitle: "Contact"
            icon.color: Theme.palette.miscColor7
            image.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
            type: StatusChatInfoButton.Type.OneToOneChat
            muted: true
            pinnedMessagesCount: 1
            width: 100
        }
    }

    Item {
        implicitWidth: 100
        implicitHeight: 48
        StatusChatInfoButton {
            title: "Iuri Matias big not elided"
            subTitle: "Contact"
            icon.color: Theme.palette.miscColor7
            image.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
            type: StatusChatInfoButton.Type.OneToOneChat
            muted: true
            pinnedMessagesCount: 1
            width: 400
        }
    }

    StatusChatInfoButton {
        title: "group"
        subTitle: "Group Chat"
        pinnedMessagesCount: 1
        icon.color: Theme.palette.miscColor7
        type: StatusChatInfoButton.Type.GroupChat
    }

    StatusChatInfoButton {
        title: "public-chat"
        subTitle: "Public Chat"
        icon.color: Theme.palette.miscColor7
        type: StatusChatInfoButton.Type.PublicChat
    }

    StatusChatInfoButton {
        title: "community-channel"
        subTitle: "Community Chat"
        icon.color: Theme.palette.miscColor7
        type: StatusChatInfoButton.Type.CommunityChat
    }

    StatusSlider {
        width: 360
        from: 0
        to: 100
        value: 40
    }

    StatusBanner {
        id: banner
        width: 360
        topPadding: 20
        type: StatusBanner.Type.Danger
        statusText: "Banner"
    }

    StatusProgressBar {
        id: progressBar        
        text: "Weak"
        value: 0.5
        fillColor : Theme.palette.pinColor1
    }
}
