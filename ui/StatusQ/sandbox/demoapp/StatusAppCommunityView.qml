import QtQuick 2.12
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Layout 0.1
import StatusQ.Core.Theme 0.1

import "data" 1.0

StatusAppThreePanelLayout {
    id: root

    property string communityDetailModalTitle: ""
    property string communityDetailModalImage: ""
    signal chatInfoButtonClicked()

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
            chatInfoButton.onClicked:  { chatInfoButtonClicked(); }

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

        StatusScrollView {
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
                draggableCategories: false
                model: Models.demoCommunityChatListItems

                showCategoryActionButtons: true

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

            width: parent.width
            toolbarComponent: statusChatInfoButton

            onSearchButtonClicked: {
                searchButton.highlighted = !searchButton.highlighted;
                searchPopup.setSearchSelection(communityDetailModalTitle,
                                               "",
                                               communityDetailModalImage);
                searchPopup.open();
            }
            membersButton.onClicked: membersButton.highlighted = !membersButton.highlighted
            onMembersButtonClicked: {
                root.showRightPanel = !root.showRightPanel;
            }

            Component {
                id: statusChatInfoButton

                StatusChatInfoButton {
                   width: Math.min(implicitWidth, parent.width)
                   title: "general"
                   subTitle: "Community Chat"
                   icon.color: Theme.palette.miscColor6
                   type: StatusChatInfoButton.Type.CommunityChat
                }
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
                        searchPopup.searchResults = Models.searchResultsA;
                    } else {
                        searchPopup.searchResults = Models.searchResultsB;
                    }
                    searchPopup.loading = false;
                }
            }
        }
        StatusSearchLocationMenu {
            id: searchPopupMenu
            searchPopup: searchPopup
            locationModel: Models.optionsModel
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
            model: Models.membersListModel
            delegate: StatusMemberListItem {
                implicitWidth: parent.width
                nickName: model.localNickname
                userName: model.displayName
                pubKey: model.pubKey
                isVerified: model.isVerified
                isUntrustworthy: model.isUntrustworthy
                isContact: model.isContact
                image.source: model.icon
                image.isIdenticon: false
                status: model.onlineStatus
            }
        }
    }
}
