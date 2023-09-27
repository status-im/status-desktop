import QtQuick 2.12
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.12

import StatusQ.Core 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Layout 0.1
import StatusQ.Core.Theme 0.1

import "data" 1.0

StatusSectionLayout {
    id: root

    property string communityDetailModalTitle: ""
    property string communityDetailModalImage: ""
    signal chatInfoButtonClicked()

    handle: Rectangle {
        implicitWidth: 5
        color: SplitHandle.pressed ? Theme.palette.baseColor2
                                   : (SplitHandle.hovered ? Qt.darker(Theme.palette.baseColor5, 1.1) : "transparent")
    }

    headerContent: RowLayout {
        id: statusToolBar

        StatusFlatRoundButton {
            id: searchButton
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: padding
            icon.name: "search"
            type: StatusFlatRoundButton.Type.Secondary
            // initializing the tooltip
            tooltip.text: qsTr("Search")
            tooltip.orientation: StatusToolTip.Orientation.Bottom
            tooltip.y: parent.height + 12
            onClicked: {
                searchButton.highlighted = !searchButton.highlighted;
                searchPopup.setSearchSelection(communityDetailModalTitle,
                                               "",
                                               communityDetailModalImage);
                searchPopup.open();
            }
        }

        StatusChatInfoButton {
            Layout.preferredWidth: Math.min(implicitWidth, parent.width)
            Layout.fillHeight: true
            title: "general"
            subTitle: "Community Chat"
            asset.color: Theme.palette.miscColor6
            type: StatusChatInfoButton.Type.CommunityChat
        }

        Item {
            Layout.fillWidth: true
        }

        StatusFlatRoundButton {
            id: membersButton
            icon.name: "group-chat"
            type: StatusFlatRoundButton.Type.Secondary
            // initializing the tooltip
            tooltip.text: qsTr("Members")
            tooltip.orientation: StatusToolTip.Orientation.Bottom
            tooltip.y: parent.height + 12
            onClicked: {
                membersButton.highlighted = !membersButton.highlighted;
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
                statusToolBar.searchButton.highlighted = false
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
            locationModel: Models.optionsModel

            onResetSearchSelection: {
                searchPopup.resetSearchSelection()
            }

            onSetSearchSelection: {
                searchPopup.setSearchSelection(text,
                                               secondaryText,
                                               imageSource,
                                               isIdenticon,
                                               iconName,
                                               iconColor,
                                               isUserIcon,
                                               colorId,
                                               colorHash)
            }
        }
    }

    leftPanel: Item {
        id: leftPanel

        StatusChatInfoToolBar {
            id: statusChatInfoToolBar

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            chatInfoButton.title: "CryptoKitties"
            chatInfoButton.subTitle: "128 Members"
            chatInfoButton.asset.isImage: true
            chatInfoButton.asset.name: "qrc:/demoapp/data/profile-image-1.jpeg"
            chatInfoButton.asset.color: Theme.palette.miscColor6
            chatInfoButton.onClicked:  { chatInfoButtonClicked(); }

            popupMenu: StatusMenu {

                StatusAction {
                    text: "Create channel"
                    icon.name: "channel"
                }

                StatusAction {
                    text: "Create category"
                    icon.name: "channel-category"
                }

                StatusMenuSeparator {}

                StatusAction {
                    text: "Invite people"
                    icon.name: "share-ios"
                    objectName: "invitePeople"
                }

            }
        }

        StatusScrollView {
            id: scrollView

            anchors.top: statusChatInfoToolBar.bottom
            anchors.topMargin: 8
            anchors.bottom: parent.bottom
            width: parent.width

            contentWidth: availableWidth
            clip: true

            StatusChatListAndCategories {
                id: communityCategories

                width: scrollView.availableWidth
                height: implicitHeight > (leftPanel.height - 64) ? implicitHeight + 8 : leftPanel.height - 64

                draggableItems: true
                draggableCategories: false
                model: Models.demoCommunityChatListItems

                showCategoryActionButtons: true

                categoryPopupMenu: StatusMenu {

                    property string categoryId

                    openHandler: function (id) {
                        categoryId = id
                    }

                    StatusAction {
                        text: "Mute Category"
                        icon.name: "notification"
                    }

                    StatusAction {
                        text: "Mark as Read"
                        icon.name: "checkmark-circle"
                    }

                    StatusAction {
                        text: "Edit Category"
                        icon.name: "edit"
                    }

                    StatusMenuSeparator {}

                    StatusAction {
                        text: "Delete Category"
                        icon.name: "delete"
                        type: StatusAction.Type.Danger
                    }
                }

                chatListPopupMenu: StatusMenu {

                    property string chatId

                    StatusAction {
                        text: "Mute chat"
                        icon.name: "notification"
                    }

                    StatusAction {
                        text: "Mark as Read"
                        icon.name: "checkmark-circle"
                    }

                    StatusAction {
                        text: "Clear history"
                        icon.name: "close-circle"
                    }

                    StatusMenuSeparator {}

                    StatusAction {
                        text: "Delete chat"
                        icon.name: "delete"
                        type: StatusAction.Type.Danger
                    }
                }

                popupMenu: StatusMenu {
                    StatusAction {
                        text: "Create channel"
                        icon.name: "channel"
                    }

                    StatusAction {
                        text: "Create category"
                        icon.name: "channel-category"
                    }

                    StatusMenuSeparator {}

                    StatusAction {
                        text: "Invite people"
                        icon.name: "share-ios"
                        objectName: "invitePeople"
                    }
                }
            }
        }
    }

    centerPanel: Item {
        anchors.fill: parent
        StatusBaseText {
            anchors.centerIn: parent
            font.pixelSize: 15
            text: qsTr("Community content here")
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
                asset.name: model.icon
                asset.isImage: (asset.name !== "")
                asset.isLetterIdenticon: (asset.name === "")
                asset.imgIsIdenticon: false
                status: model.onlineStatus
            }
        }
    }
}
