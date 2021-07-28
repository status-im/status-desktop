import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Layout 0.1
import StatusQ.Popups 0.1

Rectangle {
    id: demoApp
    height: 602
    width: 1002
    border.width: 1
    border.color: Theme.palette.baseColor2

    Row {
        anchors.top: demoApp.top
        anchors.left: demoApp.left
        anchors.topMargin: 14
        anchors.leftMargin: 14

        spacing: 6
        z: statusAppLayout.z + 1

        Rectangle {
            color: "#E24640"
            height: 12
            width: 12
            radius: 6
        }
        Rectangle {
            color: "#FFC12F"
            height: 12
            width: 12
            radius: 6
        }
        Rectangle {
            color: "#2ACB42"
            height: 12
            width: 12
            radius: 6
        }
    }

    StatusAppLayout {
        id: statusAppLayout
        anchors.top: demoApp.top
        anchors.left: demoApp.left
        anchors.topMargin: demoApp.border.width
        anchors.leftMargin: demoApp.border.width

        height: demoApp.height - demoApp.border.width * 2
        width: demoApp.width - demoApp.border.width * 2

        appNavBar: StatusAppNavBar {

            id: navBar

            navBarChatButton: StatusNavBarTabButton {
                icon.name: "chat"
                tooltip.text: "Chat"
                checked: appView.sourceComponent == statusAppChatView
                onClicked: {
                    appView.sourceComponent = statusAppChatView
                }
            }

            navBarCommunityTabButtons.model: ListModel {
                ListElement {
                    name: "Status Community"
                    tooltipText: "Status Community"
                }
            }

            navBarCommunityTabButtons.delegate: StatusNavBarTabButton {
                id: communityBtn
                anchors.horizontalCenter: parent.horizontalCenter
                name: model.name
                tooltip.text: model.tooltipText
                icon.color: Theme.palette.miscColor6
                icon.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
                checked: appView.sourceComponent == statusAppCommunityView
                onClicked: {
                    appView.sourceComponent = statusAppCommunityView
                }

                popupMenu: StatusPopupMenu {

                    StatusMenuItem {
                        text: qsTr("Invite People")
                        icon.name: "share-ios"
                    }

                    StatusMenuItem {
                        text: qsTr("View Community")
                        icon.name: "group"
                    }

                    StatusMenuItem {
                        text: qsTr("Edit Community")
                        icon.name: "edit"
                        enabled: false
                    }

                    StatusMenuSeparator {}

                    StatusMenuItem {
                        text: qsTr("Leave Community")
                        icon.name: "arrow-right"
                        icon.width: 14
                        iconRotation: 180
                        type: StatusMenuItem.Type.Danger
                    }
                }

            }

            navBarTabButtons: [
                StatusNavBarTabButton {
                    icon.name: "wallet"
                    tooltip.text: "Wallet"
                },
                StatusNavBarTabButton {
                    icon.name: "browser"
                    tooltip.text: "Browser"
                },
                StatusNavBarTabButton {
                    icon.name: "status-update"
                    tooltip.text: "Timeline"
                },
                StatusNavBarTabButton {
                    id: profileNavButton
                    icon.name: "profile"
                    badge.visible: true
                    badge.anchors.rightMargin: 4
                    badge.anchors.topMargin: 5
                    badge.border.color: hovered ? Theme.palette.statusBadge.hoverBorderColor : Theme.palette.statusAppNavBar.backgroundColor
                    badge.border.width: 2

                    tooltip.text: "Profile"

                    checked: appView.sourceComponent == statusAppProfileSettingsView
                    onClicked: {
                        appView.sourceComponent = statusAppProfileSettingsView
                    }
                }
            ]
        }

        appView: Loader {
            id: appView
            anchors.fill: parent
            sourceComponent: statusAppChatView
        }
    }

    Component {
        id: statusAppChatView

        StatusAppTwoPanelLayout {

            leftPanel: Item {
                anchors.fill: parent

                StatusNavigationPanelHeadline {
                    id: headline
                    anchors.top: parent.top
                    anchors.topMargin: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Chat"
                }

                Item {
                    id: searchInputWrapper
                    anchors.top: headline.bottom
                    anchors.topMargin: 16
                    width: parent.width
                    height: searchInput.height

                    StatusBaseInput {
                        id: searchInput

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: actionButton.left
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16

                        height: 36
                        topPadding: 8
                        bottomPadding: 0
                        placeholderText: "Search"
                        icon.name: "search"
                    }

                    StatusRoundButton {
                        id: actionButton
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        width: 32
                        height: 32

                        type: StatusRoundButton.Type.Secondary
                        icon.name: "add"
                        state: "default"

                        onClicked: chatContextMenu.popup(actionButton.width-chatContextMenu.width, actionButton.height + 4)
                        states: [
                            State {
                                name: "default"
                                PropertyChanges {
                                    target: actionButton
                                    icon.rotation: 0
                                    highlighted: false
                                }
                            },
                            State {
                                name: "pressed"
                                PropertyChanges {
                                    target: actionButton
                                    icon.rotation: 45
                                    highlighted: true
                                }
                            }
                        ]

                        transitions: [
                            Transition {
                                from: "default"
                                to: "pressed"

                                RotationAnimation {
                                    duration: 150
                                    direction: RotationAnimation.Clockwise
                                    easing.type: Easing.InCubic
                                }
                            },
                            Transition {
                                from: "pressed"
                                to: "default"
                                RotationAnimation {
                                    duration: 150
                                    direction: RotationAnimation.Counterclockwise
                                    easing.type: Easing.OutCubic
                                }
                            }
                        ]

                        StatusPopupMenu {
                            id: chatContextMenu

                            onOpened: {
                                actionButton.state = "pressed"
                            }

                            onClosed: {
                                actionButton.state = "default"
                            }

                            StatusMenuItem {
                                text: "Start new chat"
                                icon.name: "private-chat"
                            }

                            StatusMenuItem {
                                text: "Start group chat"
                                icon.name: "group-chat"
                            }

                            StatusMenuItem {
                                text: "Join public chat"
                                icon.name: "public-chat"
                            }

                            StatusMenuItem {
                                text: "Communities"
                                icon.name: "communities"
                            }
                        }
                    }
                }

                Column {
                    anchors.top: searchInputWrapper.bottom
                    anchors.topMargin: 16
                    width: parent.width
                    spacing: 8

                    StatusContactRequestsIndicatorListItem {
                        anchors.horizontalCenter: parent.horizontalCenter
                        title: "Contact requests"
                        requestsCount: 3
                        sensor.onClicked: demoContactRequestsModal.open()
                    }

                    StatusChatList {
                        anchors.horizontalCenter: parent.horizontalCenter

                        chatListItems.model: models.demoChatListItems
                        selectedChatId: "0"
                        onChatItemSelected: selectedChatId = id
                        onChatItemUnmuted: {
                            for (var i = 0; i < models.demoChatListItems.count; i++) {
                                let item = models.demoChatListItems.get(i);
                                if (item.chatId === id) {
                                    models.demoChatListItems.setProperty(i, "muted", false)
                                }
                            }
                        }

                        popupMenu: StatusPopupMenu {

                            property string chatId

                            openHandler: function (id) {
                                chatId = id
                            }

                            StatusMenuItem {
                                text: "View Profile"
                                icon.name: "group-chat"
                            }

                            StatusMenuSeparator {}

                            StatusMenuItem {
                                text: "Mute chat"
                                icon.name: "notification"
                            }

                            StatusMenuItem {
                                text: "Mark as Read"
                                icon.name: "checkmark-circle"
                            }

                            StatusMenuItem {
                                text: "Clear history"
                                icon.name: "close-circle"
                            }

                            StatusMenuSeparator {}

                            StatusMenuItem {
                                text: "Delete chat"
                                icon.name: "delete"
                                type: StatusMenuItem.Type.Danger
                            }
                        }
                    }
                }
            }

            rightPanel: Item {
                anchors.fill: parent

                StatusChatToolBar {
                    anchors.top: parent.top
                    width: parent.width

                    chatInfoButton.title: "Amazing Funny Squirrel"
                    chatInfoButton.subTitle: "Contact"
                    chatInfoButton.icon.color: Theme.palette.miscColor7
                    chatInfoButton.type: StatusChatInfoButton.Type.OneToOneChat
                    chatInfoButton.pinnedMessagesCount: 1

                    searchButton.visible: false
                    membersButton.visible: false
                    notificationCount: 1

                    onNotificationButtonClicked: notificationCount = 0

                    popupMenu: StatusPopupMenu {
                        id: contextMenu

                        StatusMenuItem {
                            text: "Mute Chat"
                            icon.name: "notification"
                        }
                        StatusMenuItem {
                            text: "Mark as Read"
                            icon.name: "checkmark-circle"
                        }
                        StatusMenuItem {
                            text: "Clear History"
                            icon.name: "close-circle"
                        }

                        StatusMenuSeparator {}

                        StatusMenuItem {
                            text: "Leave Chat"
                            icon.name: "arrow-right"
                            icon.width: 14
                            iconRotation: 180
                            type: StatusMenuItem.Type.Danger
                        }
                    }
                }
            }
        }
    }

    Component {
        id: statusAppCommunityView

        StatusAppThreePanelLayout {
            id: root

            handle: Rectangle {
                implicitWidth: 5
                color: SplitHandle.pressed ? Theme.palette.baseColor2
                                           : (SplitHandle.hovered ? Qt.darker(Theme.palette.baseColor5, 1.1) : "transparent")
            }
            leftPanel: Item {
                id: leftPanel

                StatusChatInfoToolBar {
                    id: statusChatInfoToolBar

                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter

                    chatInfoButton.title: "CryptoKitties"
                    chatInfoButton.subTitle: "128 Members"
                    chatInfoButton.image.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
                    chatInfoButton.icon.color: Theme.palette.miscColor6
                    chatInfoButton.onClicked: demoCommunityDetailModal.open()

                    popupMenu: StatusPopupMenu {

                        StatusMenuItem {
                            text: "Create channel"
                            icon.name: "channel"
                        }

                        StatusMenuItem {
                            text: "Create category"
                            icon.name: "channel-category"
                        }

                        StatusMenuSeparator {}

                        StatusMenuItem {
                            text: "Invite people"
                            icon.name: "share-ios"
                        }

                    }
                }

                ScrollView {
                    id: scrollView

                    anchors.top: statusChatInfoToolBar.bottom
                    anchors.topMargin: 8
                    anchors.bottom: parent.bottom
                    width: leftPanel.width

                    contentHeight: communityCategories.height
                    clip: true

                    StatusChatListAndCategories {
                        id: communityCategories
                        width: leftPanel.width
                        height: implicitHeight > (leftPanel.height - 64) ? implicitHeight + 8 : leftPanel.height - 64

                        draggableItems: true
                        chatList.model: models.demoCommunityChatListItems
                        categoryList.model: models.demoCommunityCategoryItems

                        showCategoryActionButtons: true
                        onChatItemSelected: selectedChatId = id

                        categoryPopupMenu: StatusPopupMenu {

                            property string categoryId

                            openHandler: function (id) {
                                categoryId = id
                            }

                            StatusMenuItem {
                                text: "Mute Category"
                                icon.name: "notification"
                            }

                            StatusMenuItem {
                                text: "Mark as Read"
                                icon.name: "checkmark-circle"
                            }

                            StatusMenuItem {
                                text: "Edit Category"
                                icon.name: "edit"
                            }

                            StatusMenuSeparator {}

                            StatusMenuItem {
                                text: "Delete Category"
                                icon.name: "delete"
                                type: StatusMenuItem.Type.Danger
                            }
                        }

                        chatListPopupMenu: StatusPopupMenu {

                            property string chatId

                            StatusMenuItem {
                                text: "Mute chat"
                                icon.name: "notification"
                            }

                            StatusMenuItem {
                                text: "Mark as Read"
                                icon.name: "checkmark-circle"
                            }

                            StatusMenuItem {
                                text: "Clear history"
                                icon.name: "close-circle"
                            }

                            StatusMenuSeparator {}

                            StatusMenuItem {
                                text: "Delete chat"
                                icon.name: "delete"
                                type: StatusMenuItem.Type.Danger
                            }
                        }

                        popupMenu: StatusPopupMenu {
                            StatusMenuItem {
                                text: "Create channel"
                                icon.name: "channel"
                            }

                            StatusMenuItem {
                                text: "Create category"
                                icon.name: "channel-category"
                            }

                            StatusMenuSeparator {}

                            StatusMenuItem {
                                text: "Invite people"
                                icon.name: "share-ios"
                            }
                        }
                    }
                }
            }

            centerPanel: Item {
                StatusChatToolBar {
                    id: statusChatToolBar
                    anchors.top: parent.top
                    width: parent.width

                    chatInfoButton.title: "general"
                    chatInfoButton.subTitle: "Community Chat"
                    chatInfoButton.icon.color: Theme.palette.miscColor6
                    chatInfoButton.type: StatusChatInfoButton.Type.CommunityChat
                    onSearchButtonClicked: {
                        searchButton.highlighted = !searchButton.highlighted;
                        searchPopup.setSearchSelection(demoCommunityDetailModal.header.title,
                                                       "",
                                                       demoCommunityDetailModal.header.image.source);
                        searchPopup.open();
                    }
                    membersButton.onClicked: membersButton.highlighted = !membersButton.highlighted
                    onMembersButtonClicked: {
                        root.showRightPanel = !root.showRightPanel;
                    }
                }

                StatusSearchPopup {
                    id: searchPopup
                    searchOptionsPopupMenu: searchPopupMenu
                    onAboutToHide: {
                        if (searchPopupMenu.visible) {
                            searchPopupMenu.close();
                        }
                        //clear menu
                        for (var i = 2; i < searchPopupMenu.count; i++) {
                            searchPopupMenu.removeItem(searchPopupMenu.takeItem(i));
                        }
                    }
                    onClosed: {
                        statusChatToolBar.searchButton.highlighted = false
                        searchPopupMenu.dismiss();
                    }
                    onSearchTextChanged: {
                        if (searchPopup.searchText !== "") {
                            searchPopup.loading = true;
                            searchModelSimTimer.start();
                        } else {
                            searchPopup.searchResults = [];
                            searchModelSimTimer.stop();
                        }
                    }
                    Timer {
                        id: searchModelSimTimer
                        interval: 500
                        onTriggered: {
                            if (searchPopup.searchText.startsWith("c")) {
                                searchPopup.searchResults = models.searchResultsA;
                            } else {
                                searchPopup.searchResults = models.searchResultsB;
                            }
                            searchPopup.loading = false;
                        }
                    }
                }
                StatusSearchLocationMenu {
                    id: searchPopupMenu
                    searchPopup: searchPopup
                    locationModel: models.optionsModel
                }
            }

            rightPanel: Item {
                id: rightPanel
                StatusBaseText {
                    id: titleText
                    anchors.top: parent.top
                    anchors.topMargin:16
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    opacity: (rightPanel.width > 50) ? 1.0 : 0.0
                    visible: (opacity > 0.1)
                    font.pixelSize: 15
                    text: qsTr("Members")
                }

                ListView {
                    anchors.top: titleText.bottom
                    anchors.topMargin: 16
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 16
                    boundsBehavior: Flickable.StopAtBounds
                    model: ["John", "Nick", "Maria", "Mike"]
                    delegate: Row {
                        width: parent.width
                        height: 30
                        spacing: 8
                        Rectangle {
                            width: 24
                            height: 24
                            radius: width/2
                            color: Qt.rgba(Math.random(), Math.random(), Math.random(), 255)
                        }
                        StatusBaseText {
                            height: parent.height
                            horizontalAlignment: Text.AlignHCenter
                            opacity: (rightPanel.width > 50) ? 1.0 : 0.0
                            visible: (opacity > 0.1)
                            font.pixelSize: 15
                            color: Theme.palette.directColor1
                            text: modelData
                        }
                    }
                }
            }
        }
    }

    Component {
        id: statusAppProfileSettingsView

        StatusAppTwoPanelLayout {

            leftPanel: Item {
                anchors.fill: parent

                StatusNavigationPanelHeadline {
                    id: profileHeadline
                    anchors.top: parent.top
                    anchors.topMargin: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Profile"
                }

                ScrollView {
                    anchors.top: profileHeadline.bottom
                    anchors.topMargin: 16
                    anchors.bottom: parent.bottom
                    width: parent.width

                    contentHeight: profileMenuItems.height + 8
                    contentWidth: parent.width
                    clip: true

                    Column {
                        id: profileMenuItems
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 4

                        Repeater {
                            model: models.demoProfileGeneralMenuItems
                            delegate: StatusNavigationListItem {
                                title: model.title
                                icon.name: model.icon
                            }
                        }

                        StatusListSectionHeadline { text: "Settings" }

                        Repeater {
                            model: models.demoProfileSettingsMenuItems
                            delegate: StatusNavigationListItem {
                                title: model.title
                                icon.name: model.icon
                            }
                        }

                        Item {
                            id: invisibleSeparator
                            height: 16
                            width: parent.width
                        }

                        Repeater {
                            model: models.demoProfileOtherMenuItems
                            delegate: StatusNavigationListItem {
                                title: model.title
                                icon.name: model.icon
                            }
                        }
                    }
                }
            }

            rightPanel: Item {
                anchors.fill: parent
            }
        }
    }

    StatusModal {
        id: demoContactRequestsModal
        anchors.centerIn: parent

        header.title: "Contact Requests"
        headerActionButton: StatusFlatRoundButton {
            type: StatusFlatRoundButton.Type.Secondary
            width: 32
            height: 32

            icon.width: 20
            icon.height: 20
            icon.name: "notification"
        }

        content: StatusBaseText {
            anchors.centerIn: parent
            text: "Contact request will be shown here"
            font.pixelSize: 15
            color: Theme.palette.directColor1
        }

        rightButtons: [
            StatusButton {
                text: "Decline all"
                type: StatusBaseButton.Type.Danger
                onClicked: demoContactRequestsModal.close()
            },
            StatusButton {
                text: "Accept all"
                onClicked: demoContactRequestsModal.close()
            }
        ]
    }

    StatusModal {
        id: demoCommunityDetailModal

        anchors.centerIn: parent

        header.title: "Cryptokitties"
        header.subTitle: "Public Community"
        header.image.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"

        content: Column {
            width: demoCommunityDetailModal.width

            StatusModalDivider {
                bottomPadding: 8
            }

            StatusBaseText {
                text: "A community of cat lovers, meow!"
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 15
                height: 46
                color: Theme.palette.directColor1
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                anchors.rightMargin: 16
            }

            StatusModalDivider {
                topPadding: 8
                bottomPadding: 8
            }

            StatusDescriptionListItem {
                title: "Share community"
                subTitle: "https://join.status.im/u/0x04...45f19"
                tooltip.text: "Copy to clipboard"
                icon.name: "copy"
                iconButton.onClicked: tooltip.visible = !tooltip.visible
                width: parent.width
            }

            StatusModalDivider {
                topPadding: 8
                bottomPadding: 8
            }

            StatusListItem {
                anchors.horizontalCenter: parent.horizontalCenter
                statusListItemTitle.font.pixelSize: 17
                title: "Members"
                icon.name: "group-chat"
                label: "184"
                components: [
                    StatusIcon {
                        icon: "chevron-down"
                        rotation: 270
                        color: Theme.palette.baseColor1
                    }
                ]
            }

            StatusListItem {
                anchors.horizontalCenter: parent.horizontalCenter
                statusListItemTitle.font.pixelSize: 17
                title: "Notifications"
                icon.name: "notification"
                components: [
                    StatusSwitch {}
                ]
            }

            StatusModalDivider {
                topPadding: 8
                bottomPadding: 8
            }

            StatusListItem {
                anchors.horizontalCenter: parent.horizontalCenter
                statusListItemTitle.font.pixelSize: 17
                title: "Edit community"
                icon.name: "edit"
                type: StatusListItem.Type.Secondary
            }

            StatusListItem {
                anchors.horizontalCenter: parent.horizontalCenter
                statusListItemTitle.font.pixelSize: 17
                title: "Transfer ownership"
                icon.name: "exchange"
                type: StatusListItem.Type.Secondary
            }

            StatusListItem {
                anchors.horizontalCenter: parent.horizontalCenter
                statusListItemTitle.font.pixelSize: 17
                title: "Leave community"
                icon.name: "arrow-right"
                icon.rotation: 180
                type: StatusListItem.Type.Secondary
            }
        }
    }

    Models {
        id: models
    }
}
